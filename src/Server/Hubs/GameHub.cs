using Microsoft.AspNetCore.SignalR;
using EraOnline.Server.Services;
using EraOnline.Shared.Constants;
using EraOnline.Shared.Models;
using EraOnline.Shared.Protocol;

namespace EraOnline.Server.Hubs;

/// <summary>
/// SignalR hub for game communication.
/// VB6: Replaces the text-based TCP protocol routed through HandleData (TCP.bas:768).
/// </summary>
public class GameHub : Hub
{
    private readonly GameDataService _gameData;
    private readonly WorldState _world;
    private readonly ChatLogger _chatLog;
    private readonly GameLoopService _gameLoopService;
    private readonly ILogger<GameHub> _logger;

    public GameHub(GameDataService gameData, WorldState world, ChatLogger chatLog, GameLoopService gameLoopService, ILogger<GameHub> logger)
    {
        _gameData = gameData;
        _world = world;
        _chatLog = chatLog;
        _gameLoopService = gameLoopService;
        _logger = logger;
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var player = _world.RemovePlayer(Context.ConnectionId);
        if (player != null)
        {
            // Save character position
            player.Character.LastMap = player.Map;
            player.Character.LastX = player.X;
            player.Character.LastY = player.Y;
            await _world.SaveCharacter(player.Character);

            // VB6: EraseUserChar + SendData(ToMapButIndex, "ERC" & charIndex)
            await Clients.Group(MapGroup(player.Map))
                .SendAsync("EraseChar", new EraseCharMessage(player.CharIndex));

            _chatLog.LogConnect(player.Character.Name, "logged off");
            _logger.LogInformation("Player {Name} disconnected, saved at map {Map} ({X},{Y})",
                player.Character.Name, player.Map, player.X, player.Y);
        }

        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Login with existing character.
    /// VB6: HandleData "LOGIN" -> ConnectUser (TCP.bas:446)
    /// </summary>
    public async Task<LoginResponse> Login(LoginRequest request)
    {
        var name = request.Name?.Trim() ?? "";
        if (string.IsNullOrEmpty(name))
            return new LoginResponse(false, "Name is required.");

        // Check if already logged in
        if (_world.IsNameOnline(name))
            return new LoginResponse(false, "A character with that name is already logged in.");

        // Load character file
        var character = await _world.LoadCharacter(name);
        if (character == null)
            return new LoginResponse(false, "Character does not exist.");

        // Check password
        var hash = WorldState.HashPassword(request.Password ?? "");
        if (hash != character.PasswordHash)
            return new LoginResponse(false, "Wrong password.");

        // Place in world
        await PlacePlayerInWorld(character);

        return new LoginResponse(true);
    }

    /// <summary>
    /// Create a new character and log in.
    /// VB6: HandleData "NLOGIN" -> ConnectNewUser (TCP.bas:136)
    /// </summary>
    public async Task<LoginResponse> CreateCharacter(CreateCharacterRequest request)
    {
        var name = request.Name?.Trim() ?? "";
        if (string.IsNullOrEmpty(name) || name.Length < 2 || name.Length > 20)
            return new LoginResponse(false, "Name must be 2-20 characters.");

        if (string.IsNullOrEmpty(request.Password) || request.Password.Length < 3)
            return new LoginResponse(false, "Password must be at least 3 characters.");

        // Check if name exists
        if (_world.CharacterExists(name))
            return new LoginResponse(false, "Character name already exists. Try another name.");

        // Validate race
        var validRaces = new[] { "Human", "Haaki", "Wood Elf", "Dark Elf" };
        var race = validRaces.FirstOrDefault(r => r.Equals(request.Race, StringComparison.OrdinalIgnoreCase)) ?? "Human";

        var gender = request.Gender?.Equals("Female", StringComparison.OrdinalIgnoreCase) == true ? "Female" : "Male";

        // Validate class for race (VB6: Form5.frx per-race class lists)
        var className = request.Class ?? "Warrior";
        if (!ClassTemplates.ClassesByRace.TryGetValue(race, out var validClasses) ||
            !validClasses.Contains(className, StringComparer.OrdinalIgnoreCase))
        {
            className = "Warrior"; // fallback
        }
        // Normalize casing to match template key
        className = ClassTemplates.Get(className) != null ? className
            : validClasses?.FirstOrDefault(c => c.Equals(className, StringComparison.OrdinalIgnoreCase)) ?? "Warrior";

        var template = ClassTemplates.Get(className);
        if (template == null)
            return new LoginResponse(false, "Invalid class selection.");

        // Validate specialized skills (3 skill names from the 28 available)
        var specSkill1 = ValidateSpecSkill(request.SpecSkill1);
        var specSkill2 = ValidateSpecSkill(request.SpecSkill2);
        var specSkill3 = ValidateSpecSkill(request.SpecSkill3);

        // Create character data (VB6: ConnectNewUser + GiveSkills)
        var head = WorldState.RandomHead(race, gender);

        var character = new CharacterData
        {
            Name = name,
            PasswordHash = WorldState.HashPassword(request.Password),
            Race = race,
            Gender = gender,
            Body = 1,
            Head = head,
            Class = className,
            MagicSchool = template.MagicSchool,
            SpecSkill1 = specSkill1,
            SpecSkill2 = specSkill2,
            SpecSkill3 = specSkill3,
            MaxHp = template.MaxHp,
            CurrentHp = template.MaxHp,
            MaxMan = template.MaxMan,
            CurrentMan = template.MaxMan,
            MinHit = template.MinHit,
            MaxHit = template.MaxHit,
            Skills = (int[])template.Skills.Clone(),
        };
        character.InitStartingInventory();

        // Add class-specific extra items (VB6: GiveSkills adds tools for crafters)
        if (template.ExtraItems != null)
        {
            int slot = 5; // first free slot after default items (slots 0-4 used by InitStartingInventory)
            foreach (var (objIndex, amount) in template.ExtraItems)
            {
                if (slot < 20)
                {
                    character.Inventory[slot] = new InventorySlot { ObjIndex = objIndex, Amount = amount };
                    slot++;
                }
            }
        }

        // Add starting spells for magic classes (VB6: GiveSkills sets SpellObj slots)
        if (template.StartingSpells != null)
        {
            for (int i = 0; i < template.StartingSpells.Length && i < character.SpellBook.Length; i++)
            {
                character.SpellBook[i] = template.StartingSpells[i];
            }
        }

        // Save to disk
        await _world.SaveCharacter(character);

        _logger.LogInformation("New character created: {Name} ({Race} {Gender} {Class})", name, race, gender, className);

        // Place in world
        await PlacePlayerInWorld(character);

        return new LoginResponse(true);
    }

    /// <summary>
    /// Place a character in the world and send initial state.
    /// VB6: ConnectUser (TCP.bas:567-637)
    /// </summary>
    private async Task PlacePlayerInWorld(CharacterData character)
    {
        // Determine position: saved position or starting city
        int map, x, y;
        if (character.LastMap > 0 && _gameData.Maps.ContainsKey(character.LastMap))
        {
            map = character.LastMap;
            x = character.LastX;
            y = character.LastY;
        }
        else
        {
            (map, x, y) = _world.GetStartingPosition(character.Race);
        }

        // Find a legal position near the target (in case the tile is occupied)
        (x, y) = FindNearbyLegalPos(map, x, y);

        var charIndex = _world.AllocateCharIndex();
        var player = _world.AddPlayer(Context.ConnectionId, character, charIndex, map, x, y);

        // Store original appearance for resurrection (VB6: Flags.StartHead)
        player.OriginalHead = character.Head;
        player.OriginalBody = character.Body;

        // Join the map's SignalR group for broadcasts
        await Groups.AddToGroupAsync(Context.ConnectionId, MapGroup(map));

        // VB6: Send initial state to the connecting player
        // SUC - your char index
        await Clients.Caller.SendAsync("SetCharIndex", new SetCharIndexMessage(charIndex));

        // SCM - load map
        await Clients.Caller.SendAsync("MapLoad", new MapLoadMessage(map));

        // Send existing characters on this map to the new player
        foreach (var other in _world.GetPlayersOnMap(map))
        {
            var (ow, os) = GetEquipAnims(other.Character);
            await Clients.Caller.SendAsync("MakeChar", new MakeCharMessage(
                other.CharIndex, other.Character.Name, other.Character.Body, other.Character.Head,
                other.Heading, other.X, other.Y, ow, os, other.Character.Criminal > 0));
        }

        // Send live NPC positions (not static spawns — NPCs may have moved)
        foreach (var npc in _world.GetNpcsOnMap(map))
        {
            await Clients.Caller.SendAsync("MakeChar", new MakeCharMessage(
                npc.CharIndex, npc.Name,
                npc.Body, npc.Head, npc.Heading,
                npc.X, npc.Y, npc.WeaponAnim, npc.ShieldAnim));
        }

        // Send ground items on this map
        await SendGroundItems(map);

        // Broadcast the new player to everyone else on the map
        var (pw, ps) = GetEquipAnims(character);
        await Clients.OthersInGroup(MapGroup(map))
            .SendAsync("MakeChar", new MakeCharMessage(
                charIndex, character.Name, character.Body, character.Head,
                (int)Direction.South, x, y, pw, ps, character.Criminal > 0));

        // Welcome messages
        await Clients.Caller.SendAsync("Chat", new ChatMessage(
            $"Welcome to Era Online, {character.Name}!", FontType.Info));

        // VB6: SendUserStatsBox — send full stats on login
        await SendStats(character);

        // VB6: UpdateUserInv(True) — send full inventory on login
        await SendFullInventory(character);

        // VB6: UpdateUserSpell(True) — send full spell book on login
        await SendFullSpellBook(character);

        // VB6: SendData(ToIndex, "PLM" & MapInfo(map).Music) — play zone music
        await SendMapMusic(map);

        // Send current weather state (VB6: RAI/SAI sent on login if raining)
        if (_gameLoopService.Raining)
        {
            await Clients.Caller.SendAsync("Weather", true);
        }

        // VB6: Open App.Path & "\Connect.log" For Append
        _chatLog.LogConnect(character.Name, $"logged in. Map:{map} ({x},{y})");
    }

    /// <summary>
    /// Handle movement request from client. Server-authoritative.
    /// VB6: HandleData "M" -> MoveUserChar (GameLogic.bas:2607)
    /// Client sends direction, server validates and broadcasts.
    /// </summary>
    public async Task Move(int direction)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;

        if (direction < 1 || direction > 4) return;
        var heading = (Direction)direction;

        // Cancel meditation on movement (VB6: movement code clears Meditate flag)
        if (player.Meditating)
        {
            player.Meditating = false;
            _world.PickupGroundItem(player.Map, player.X, player.Y);
            await Clients.Group(MapGroup(player.Map)).SendAsync("EraseObj",
                new EraseObjMessage(player.X, player.Y));
            await Clients.Caller.SendAsync("Meditate", new MeditateMessage(false));
        }

        if (_world.MovePlayer(player, heading))
        {
            // VB6: SendData(ToMapButIndex, "MOC" & charIndex & "," & x & "," & y)
            await Clients.Group(MapGroup(player.Map))
                .SendAsync("MoveChar", new MoveCharMessage(
                    player.CharIndex, player.X, player.Y, (int)heading));

            // VB6: DoTileEvents — check for zone transitions
            await DoTileEvents(player);
        }
        else
        {
            // Invalid move - correct client position
            // VB6: SendData(ToIndex, "SUP" & x & "," & y)
            await Clients.Caller.SendAsync("SetPosition",
                new SetPositionMessage(player.X, player.Y));
        }
    }

    /// <summary>
    /// Handle left-click on a tile. VB6: HandleData "LC" -> LookatTile (GameLogic.bas:2841)
    /// Inspects tile for players, NPCs, objects. Sets targeting.
    /// </summary>
    public async Task LeftClick(int x, int y)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;

        if (x < 1 || x > GameConstants.MapWidth || y < 1 || y > GameConstants.MapHeight) return;

        var foundSomething = false;

        // VB6: Check for object on the tile
        var groundObj = _world.GetGroundItem(player.Map, x, y);
        if (groundObj != null && groundObj.ObjIndex > 0)
        {
            var objName = _gameData.Objects.FirstOrDefault(o => o.Id == groundObj.ObjIndex)?.Name ?? "something";
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You see a {objName}.", FontType.Talk));
            foundSomething = true;
        }

        // Check for characters — VB6 checks tile and tile+1 Y (characters render offset by 1)
        var foundPlayer = FindPlayerAt(player.Map, x, y) ?? FindPlayerAt(player.Map, x, y + 1);
        var foundNpc = FindNpcAt(player.Map, x, y) ?? FindNpcAt(player.Map, x, y + 1);

        // React to NPC (VB6: FoundChar = 2)
        if (foundNpc != null)
        {
            await Clients.Caller.SendAsync("Target", new TargetMessage(foundNpc.Value.name));
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You target {foundNpc.Value.name}.", FontType.Talk));
            player.TargetNpcIndex = foundNpc.Value.npcIndex;
            player.TargetPlayerCharIndex = 0;
            foundSomething = true;
        }
        // React to player (VB6: FoundChar = 1)
        else if (foundPlayer != null && foundPlayer.CharIndex != player.CharIndex)
        {
            var other = foundPlayer;
            await Clients.Caller.SendAsync("Target", new TargetMessage(other.Character.Name));

            var desc = !string.IsNullOrEmpty(other.Character.Description)
                ? $" - {other.Character.Description}"
                : "";
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You see {other.Character.Name}{desc}", FontType.Talk));

            player.TargetPlayerCharIndex = other.CharIndex;
            player.TargetNpcIndex = 0;
            foundSomething = true;
        }

        if (!foundSomething)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You see nothing of interest.", FontType.Talk));
        }
    }

    /// <summary>Find a player at a specific tile position on a map.</summary>
    private PlayerState? FindPlayerAt(int map, int x, int y)
    {
        return _world.GetPlayersOnMap(map).FirstOrDefault(p => p.X == x && p.Y == y);
    }

    /// <summary>Find a live NPC instance at a specific tile position on a map.</summary>
    private (string name, int npcIndex)? FindNpcAt(int map, int x, int y)
    {
        // Check live NPC instances at this tile
        var npc = _world.GetNpcOnTile(map, x, y);
        if (npc != null)
            return (npc.Name, npc.NpcIndex);
        return null;
    }

    // ===================== Inventory =====================

    /// <summary>
    /// Use/equip an inventory item. VB6: HandleData "USE" -> UseInvItem (GameLogic.bas:380)
    /// </summary>
    public async Task UseItem(int slot)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;
        var ch = player.Character;
        if (slot < 0 || slot >= 20) return;
        var inv = ch.Inventory[slot];
        if (inv.ObjIndex <= 0) return;

        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
        if (objDef == null) return;

        // VB6: Level check — "You don't have enough health to equip this"
        if (objDef.Level > 0 && ch.MaxHp < objDef.Level)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You don`t have enough health to equip this. You need {objDef.Level} health to equip this.", FontType.Info));
            return;
        }

        // VB6: ClassForbid check — class restrictions on items
        if (objDef.ClassForbid.Length > 0 && objDef.ClassForbid.Any(c => c == ch.Class))
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Your class forbid you in using this !", FontType.Info));
            return;
        }

        var objType = objDef.ObjType;

        switch (objType)
        {
            case 1: // OBJTYPE_USEONCE — consumable
                ch.CurrentHp = Math.Min(ch.CurrentHp + objDef.MaxHp, ch.MaxHp);
                inv.Amount--;
                if (inv.Amount <= 0) { inv.ObjIndex = 0; inv.Amount = 0; }
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                break;

            case 2: // OBJTYPE_WEAPON
                if (inv.Equipped) { await UnequipSlot(player, slot); break; }
                if (ch.WeaponEqpSlot >= 0) await UnequipSlot(player, ch.WeaponEqpSlot);
                inv.Equipped = true;
                ch.WeaponEqpSlot = slot;
                ch.MaxHit += objDef.MaxHit;
                ch.MinHit += objDef.MinHit;
                player.WeaponEqpSlot = slot;
                player.EquippedToolObjType = 0; // Regular weapon, not a tool
                await UpdateCharAppearance(player);
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                break;

            case 16: // OBJTYPE_FISHINGROD — equips as weapon, sets tool type
            case 17: // OBJTYPE_LUMBERJACKAXE
            case 48: // OBJTYPE_PICKAXE
                if (inv.Equipped) { await UnequipSlot(player, slot); break; }
                if (ch.WeaponEqpSlot >= 0) await UnequipSlot(player, ch.WeaponEqpSlot);
                inv.Equipped = true;
                ch.WeaponEqpSlot = slot;
                player.WeaponEqpSlot = slot;
                player.EquippedToolObjType = objType; // VB6: OBJtarget = 16/17/48
                await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.SwordSwing));
                await UpdateCharAppearance(player);
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                break;

            case 3: // OBJTYPE_ARMOUR
            case 15: // OBJTYPE_CLOTHING
                if (inv.Equipped) { await UnequipSlot(player, slot); break; }
                if (ch.ArmourEqpSlot >= 0) await UnequipSlot(player, ch.ArmourEqpSlot);
                inv.Equipped = true;
                ch.ArmourEqpSlot = slot;
                ch.Def += objDef.Def;
                ch.Body = objDef.ClothingType > 0 ? objDef.ClothingType : ch.Body;
                player.ArmourEqpSlot = slot;
                await UpdateCharAppearance(player);
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                break;

            case 23: // OBJTYPE_SPELL — inscribe spell scroll to spell book
                await InscribeSpell(player, slot);
                break;

            case 24: // OBJTYPE_SHIELD
                if (inv.Equipped) { await UnequipSlot(player, slot); break; }
                if (ch.ShieldEqpSlot >= 0) await UnequipSlot(player, ch.ShieldEqpSlot);
                inv.Equipped = true;
                ch.ShieldEqpSlot = slot;
                ch.Def += objDef.Def;
                player.ShieldEqpSlot = slot;
                await UpdateCharAppearance(player);
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                break;

            case 14: // OBJTYPE_HELMET
                if (inv.Equipped) { await UnequipSlot(player, slot); break; }
                if (ch.HeadEqpSlot >= 0) await UnequipSlot(player, ch.HeadEqpSlot);
                inv.Equipped = true;
                ch.HeadEqpSlot = slot;
                player.HeadEqpSlot = slot;
                await SendInvSlot(ch, slot);
                break;

            case 6: // OBJTYPE_FOOD
                ch.Food = Math.Min(ch.Food + 1, 100);
                inv.Amount--;
                if (inv.Amount <= 0) { inv.ObjIndex = 0; inv.Amount = 0; }
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                await Clients.Caller.SendAsync("Chat", new ChatMessage("You eat some food.", FontType.Info));
                break;

            case 7: // OBJTYPE_DRINK
                ch.Drink = Math.Min(ch.Drink + 1, 100);
                inv.Amount--;
                if (inv.Amount <= 0) { inv.ObjIndex = 0; inv.Amount = 0; }
                await SendInvSlot(ch, slot);
                await SendStats(ch);
                await Clients.Caller.SendAsync("Chat", new ChatMessage("You take a drink.", FontType.Info));
                break;

            // --- Crafting: Drawings (set recipe, don't consume) ---

            case 25: // OBJTYPE_CARPENTRYDRAWING
                player.CraftMakeItem = objDef.MakeItem;
                player.CraftNeedPlanks = objDef.NeedPlanks;
                player.CraftSkillRequired = objDef.Skill;
                await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.Paper));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You look at the drawing and you are ready to make it ! Just find the planks now !", FontType.Info));
                break;

            case 26: // OBJTYPE_BLACKSMITHINGDRAWING
                player.CraftMakeItem = objDef.MakeItem;
                player.CraftNeedSteel = objDef.NeedSteel;
                player.CraftSkillRequired = objDef.Skill;
                await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.Paper));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You look at the drawing and you are ready to make it ! Just find the steel now !", FontType.Info));
                break;

            case 27: // OBJTYPE_TAILORDRAWING
                player.CraftMakeItem = objDef.MakeItem;
                player.CraftNeedFoldedCloth = objDef.NeedFoldedCloth;
                player.CraftSkillRequired = objDef.Skill;
                await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.Paper));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You look at the drawing and you are ready to make it ! Just find the folded cloth now !", FontType.Info));
                break;

            // --- Crafting: Material processing ---

            case 35: // OBJTYPE_PLANKS — use planks to make item from carpentry drawing
                if (player.CraftMakeItem <= 0 || player.CraftNeedPlanks <= 0)
                { await Clients.Caller.SendAsync("Chat", new ChatMessage("You need to read a carpentry drawing first.", FontType.Info)); break; }
                await StartCraft(player, slot, 9, (int)SkillType.Carpentry, player.CraftNeedPlanks,
                    "You begin making the object.");
                break;

            case 31: // OBJTYPE_STEEL — use steel to make item from blacksmithing drawing
                if (player.CraftMakeItem <= 0 || player.CraftNeedSteel <= 0)
                { await Clients.Caller.SendAsync("Chat", new ChatMessage("You need to read a blacksmithing drawing first.", FontType.Info)); break; }
                await StartCraft(player, slot, 8, (int)SkillType.Blacksmithing, player.CraftNeedSteel,
                    "You begin making the object.");
                break;

            case 30: // OBJTYPE_FOLDEDCLOTH — use folded cloth to make item from tailoring drawing
                if (player.CraftMakeItem <= 0 || player.CraftNeedFoldedCloth <= 0)
                { await Clients.Caller.SendAsync("Chat", new ChatMessage("You need to read a tailoring drawing first.", FontType.Info)); break; }
                await StartCraft(player, slot, 10, (int)SkillType.Tailoring, player.CraftNeedFoldedCloth,
                    "You begin making the object.");
                break;

            case 22: // OBJTYPE_SAW — use saw to turn logs into planks (need 2+ logs)
                await StartCraft(player, slot, 4, (int)SkillType.Carpentry, 2,
                    "You begin sawing to make planks.");
                break;

            case 28: // OBJTYPE_SEWINGKIT — use sewing kit to turn cloth into folded cloth (need 2+)
                await StartCraft(player, slot, 3, (int)SkillType.Tailoring, 2,
                    "You begin creating folded cloth.");
                break;

            case 33: // OBJTYPE_HAMMER — use hammer to turn ore into steel (need 2+)
                await StartCraft(player, slot, 5, (int)SkillType.Blacksmithing, 2,
                    "You begin smelting to make steel.");
                break;

            case 20: // OBJTYPE_LOG — drop log to set up campfire
                await StartCraft(player, slot, 13, (int)SkillType.Surviving, 1,
                    "You begin setting the camp...");
                break;

            default:
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You can't use that.", FontType.Info));
                break;
        }
    }

    /// <summary>VB6: HandleData "DRP" -> DropObj (GameLogic.bas:1903)</summary>
    /// <summary>VB6: HandleData "DRP" -> DropObj (GameLogic.bas:1903)</summary>
    public async Task DropItem(int slot, int amount)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;
        var ch = player.Character;
        if (slot < 0 || slot >= 20) return;
        var inv = ch.Inventory[slot];
        if (inv.ObjIndex <= 0) return;
        if (amount < 1) amount = inv.Amount;
        if (amount > inv.Amount) amount = inv.Amount;

        // VB6: Check if tile already has an item
        if (_world.GetGroundItem(player.Map, player.X, player.Y) != null)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("No room on ground.", FontType.Info));
            return;
        }

        if (inv.Equipped) await UnequipSlot(player, slot);

        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);

        // VB6: MakeObj — place on ground and broadcast to map
        _world.PlaceGroundItem(player.Map, player.X, player.Y, inv.ObjIndex, amount);
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("MakeObj", new MakeObjMessage(objDef?.GrhIndex ?? 0, player.X, player.Y));

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"You drop {objDef?.Name ?? "an item"}.", FontType.Info));

        // Remove from inventory
        inv.Amount -= amount;
        if (inv.Amount <= 0) { inv.ObjIndex = 0; inv.Amount = 0; inv.Equipped = false; }
        await SendInvSlot(ch, slot);
    }

    /// <summary>VB6: HandleData "GET" -> GetObj (GameLogic.bas:1531)</summary>
    public async Task GetItem()
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;
        var ch = player.Character;

        // VB6: Check for object on player's tile
        var groundItem = _world.GetGroundItem(player.Map, player.X, player.Y);
        if (groundItem == null || groundItem.ObjIndex <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Nothing here.", FontType.Info));
            return;
        }

        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == groundItem.ObjIndex);

        // VB6: Check if pickable
        if (objDef != null && objDef.Pickable == 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You cannot pick this item up.", FontType.Info));
            return;
        }

        // Find a matching slot (stack) or empty slot
        int targetSlot = -1;
        for (int i = 0; i < 20; i++)
        {
            if (ch.Inventory[i].ObjIndex == groundItem.ObjIndex)
            { targetSlot = i; break; }
        }
        if (targetSlot < 0)
        {
            for (int i = 0; i < 20; i++)
            {
                if (ch.Inventory[i].ObjIndex <= 0)
                { targetSlot = i; break; }
            }
        }
        if (targetSlot < 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You cannot hold any more items now!", FontType.Info));
            return;
        }

        // Pick up: add to inventory, remove from ground
        ch.Inventory[targetSlot].ObjIndex = groundItem.ObjIndex;
        ch.Inventory[targetSlot].Amount += groundItem.Amount;

        _world.PickupGroundItem(player.Map, player.X, player.Y);

        // VB6: EraseObj — broadcast removal to map
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("EraseObj", new EraseObjMessage(player.X, player.Y));

        await SendInvSlot(ch, targetSlot);
    }

    private async Task UnequipSlot(PlayerState player, int slot)
    {
        var ch = player.Character;
        if (slot < 0 || slot >= 20) return;
        var inv = ch.Inventory[slot];
        if (!inv.Equipped) return;

        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
        inv.Equipped = false;

        if (slot == ch.WeaponEqpSlot)
        {
            ch.WeaponEqpSlot = -1; player.WeaponEqpSlot = -1;
            player.EquippedToolObjType = 0; // VB6: OBJtarget = 0
            if (objDef != null) { ch.MaxHit -= objDef.MaxHit; ch.MinHit -= objDef.MinHit; }
        }
        else if (slot == ch.ArmourEqpSlot)
        {
            ch.ArmourEqpSlot = -1; player.ArmourEqpSlot = -1;
            ch.Body = 1;
            if (objDef != null) ch.Def -= objDef.Def;
        }
        else if (slot == ch.ShieldEqpSlot)
        {
            ch.ShieldEqpSlot = -1; player.ShieldEqpSlot = -1;
            if (objDef != null) ch.Def -= objDef.Def;
        }
        else if (slot == ch.HeadEqpSlot)
        {
            ch.HeadEqpSlot = -1; player.HeadEqpSlot = -1;
        }

        await UpdateCharAppearance(player);
        await SendInvSlot(ch, slot);
        await SendStats(ch);
    }

    private async Task UpdateCharAppearance(PlayerState player)
    {
        var ch = player.Character;
        int weaponAnim = 2, shieldAnim = 2;
        if (ch.WeaponEqpSlot >= 0)
        {
            var wObj = _gameData.Objects.FirstOrDefault(o => o.Id == ch.Inventory[ch.WeaponEqpSlot].ObjIndex);
            if (wObj != null && wObj.WeaponAnim > 0) weaponAnim = wObj.WeaponAnim;
        }
        if (ch.ShieldEqpSlot >= 0)
        {
            var sObj = _gameData.Objects.FirstOrDefault(o => o.Id == ch.Inventory[ch.ShieldEqpSlot].ObjIndex);
            if (sObj != null && sObj.ShieldAnim > 0) shieldAnim = sObj.ShieldAnim;
        }

        await Clients.Group(MapGroup(player.Map))
            .SendAsync("ChangeChar", new MakeCharMessage(
                player.CharIndex, ch.Name, ch.Body, ch.Head,
                player.Heading, player.X, player.Y, weaponAnim, shieldAnim, ch.Criminal > 0));
    }

    /// <summary>
    /// Check for zone transitions after a move.
    /// VB6: DoTileEvents (GameLogic.bas:134-200)
    /// </summary>
    private async Task DoTileEvents(PlayerState player)
    {
        if (!_gameData.Maps.TryGetValue(player.Map, out var mapDef)) return;

        int destMap = 0, destX = 0, destY = 0;

        // Edge exits (VB6: Y<7 north, Y>94 south, X<9 west, X>92 east)
        if (player.Y < 7 && mapDef.Exits.TryGetValue("north", out var north) && north > 1)
        {
            destMap = north; destX = player.X; destY = 94;
        }
        else if (player.Y > 94 && mapDef.Exits.TryGetValue("south", out var south) && south > 1)
        {
            destMap = south; destX = player.X; destY = 7;
        }
        else if (player.X < 9 && mapDef.Exits.TryGetValue("west", out var west) && west > 1)
        {
            destMap = west; destX = 91; destY = player.Y;
        }
        else if (player.X > 92 && mapDef.Exits.TryGetValue("east", out var east) && east > 1)
        {
            destMap = east; destX = 10; destY = player.Y;
        }

        // Tile exits (VB6: MapData(map, x, y).TileExit.map > 0)
        if (destMap == 0)
        {
            foreach (var exit in mapDef.TileExits)
            {
                // exit = [x, y, destMap, destX, destY]
                if (exit.Length >= 5 && exit[0] == player.X && exit[1] == player.Y)
                {
                    destMap = exit[2]; destX = exit[3]; destY = exit[4];
                    break;
                }
            }
        }

        if (destMap > 0 && _gameData.Maps.ContainsKey(destMap))
        {
            // Check destination is valid
            if (_world.IsTileBlocked(destMap, destX, destY))
            {
                // Find a nearby legal position
                (destX, destY) = FindNearbyLegalPos(destMap, destX, destY);
            }

            await WarpPlayer(player, destMap, destX, destY);
            return;
        }

        // VB6: Check for adjacent campfire (object 155) — sends "TEN" to enable campfire healing timer
        int[] cdx = { -1, 1, 0, 0 };
        int[] cdy = { 0, 0, -1, 1 };
        for (int i = 0; i < 4; i++)
        {
            var item = _world.GetGroundItem(player.Map, player.X + cdx[i], player.Y + cdy[i]);
            if (item != null && item.ObjIndex == 155)
            {
                await Clients.Caller.SendAsync("CampfireNearby", true);
                return;
            }
        }
    }

    /// <summary>
    /// Warp a player to a new map. VB6: WarpUserChar (GameLogic.bas:2982-3100)
    /// </summary>
    private async Task WarpPlayer(PlayerState player, int newMap, int newX, int newY)
    {
        var oldMap = player.Map;
        var oldMusic = _gameData.Maps.TryGetValue(oldMap, out var oldMapDef) ? oldMapDef.Music : "";

        // Erase from old map (broadcast to old map's players)
        await Clients.Group(MapGroup(oldMap))
            .SendAsync("EraseChar", new EraseCharMessage(player.CharIndex));

        // Update occupancy and position
        _world.WarpPlayer(player, newMap, newX, newY);

        // Switch SignalR groups
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, MapGroup(oldMap));
        await Groups.AddToGroupAsync(Context.ConnectionId, MapGroup(newMap));

        // Send new map to the warping player
        await Clients.Caller.SendAsync("MapLoad", new MapLoadMessage(newMap));

        // Send all characters on the new map to this player
        foreach (var other in _world.GetPlayersOnMap(newMap))
        {
            var (ow, os) = GetEquipAnims(other.Character);
            await Clients.Caller.SendAsync("MakeChar", new MakeCharMessage(
                other.CharIndex, other.Character.Name, other.Character.Body, other.Character.Head,
                other.Heading, other.X, other.Y, ow, os, other.Character.Criminal > 0));
        }

        // Send live NPC positions on the new map
        foreach (var npc in _world.GetNpcsOnMap(newMap))
        {
            await Clients.Caller.SendAsync("MakeChar", new MakeCharMessage(
                npc.CharIndex, npc.Name,
                npc.Body, npc.Head, npc.Heading,
                npc.X, npc.Y, npc.WeaponAnim, npc.ShieldAnim));
        }

        // Send ground items on the new map
        await SendGroundItems(newMap);

        // Announce this player to others on the new map
        var (ww, ws) = GetEquipAnims(player.Character);
        await Clients.OthersInGroup(MapGroup(newMap))
            .SendAsync("MakeChar", new MakeCharMessage(
                player.CharIndex, player.Character.Name, player.Character.Body, player.Character.Head,
                player.Heading, newX, newY, ww, ws, player.Character.Criminal > 0));

        // Send position correction to the player
        await Clients.Caller.SendAsync("SetCharIndex", new SetCharIndexMessage(player.CharIndex));
        await Clients.Caller.SendAsync("SetPosition", new SetPositionMessage(newX, newY));

        // Play new zone music if different from old zone
        _gameData.Maps.TryGetValue(newMap, out var newMapDef);
        var newMusic = newMapDef?.Music ?? "";
        if (newMusic != oldMusic)
        {
            await SendMapMusic(newMap);
        }
    }

    /// <summary>
    /// Handle all chat input from the client.
    /// VB6: HandleData ";" (say), "-" (shout), ":" (emote), "\" (whisper), "/" (commands)
    /// (TCP.bas:991-1100)
    /// </summary>
    public async Task Say(string message)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || string.IsNullOrEmpty(message)) return;

        // Slash commands
        if (message.StartsWith('/'))
        {
            await HandleSlashCommand(player, message);
            return;
        }

        // Chat type determined by first character prefix
        // VB6 client: SendTxt_KeyUp prepends prefix before sending
        if (message.StartsWith('-'))
        {
            // Shout — broadcast to entire map
            // VB6: SendData(ToMap, ..., "Name shouts: text")
            var text = message[1..].TrimStart();
            if (string.IsNullOrEmpty(text)) return;

            var formatted = player.IsDead
                ? $"{player.Character.Name} shouts: oooOOOOo OOOOOooo Ooooo"
                : $"{player.Character.Name} shouts: {text}";

            await Clients.Group(MapGroup(player.Map))
                .SendAsync("Chat", new ChatMessage(formatted, FontType.Talk));
            if (!player.IsDead) _chatLog.LogChat(player.Map, player.Character.Name, text);
        }
        else if (message.StartsWith(':'))
        {
            // Emote — broadcast to map (VB6 uses ToPCArea, we use map for now)
            // VB6: SendData(ToPCArea, ..., "Name emotetext")
            var text = message[1..].TrimStart();
            if (string.IsNullOrEmpty(text)) return;

            var formatted = player.IsDead
                ? $"{player.Character.Name} seems to try to express something. But noone can understand the ghostly movements."
                : $"{player.Character.Name} {text}";

            await Clients.Group(MapGroup(player.Map))
                .SendAsync("Chat", new ChatMessage(formatted, FontType.Talk));
            if (!player.IsDead) _chatLog.LogChat(player.Map, player.Character.Name, $" {text}");
        }
        else if (message.StartsWith('\\'))
        {
            // Whisper/Tell — send to specific player
            // VB6: HandleData "\" -> parse "name,message"
            var text = message[1..].TrimStart();
            var spaceIdx = text.IndexOf(' ');
            if (spaceIdx <= 0)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("Usage: \\name message", FontType.Info));
                return;
            }

            var targetName = text[..spaceIdx];
            var whisperText = text[(spaceIdx + 1)..];
            var target = _world.GetPlayerByName(targetName);

            if (target == null)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"{targetName} is not online.", FontType.Info));
                return;
            }

            // Send to target
            await Clients.Client(target.ConnectionId).SendAsync("Chat",
                new ChatMessage($"{player.Character.Name} whispers: {whisperText}", FontType.Talk));
            // Echo to sender
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You whisper to {target.Character.Name}: {whisperText}", FontType.Talk));
            // VB6 logs whispers to the sender's zone file
            _chatLog.LogChat(player.Map, player.Character.Name, whisperText);
        }
        else
        {
            // Say — broadcast to map (VB6 uses ToPCArea)
            // VB6: SendData(ToPCArea, ..., "Name: text")
            var text = message.StartsWith(';') ? message[1..].TrimStart() : message;
            if (string.IsNullOrEmpty(text)) return;

            var formatted = player.IsDead
                ? $"{player.Character.Name}: oooOO OOoo oOO OOooo"
                : $"{player.Character.Name}: {text}";

            await Clients.Group(MapGroup(player.Map))
                .SendAsync("Chat", new ChatMessage(formatted, FontType.Talk));
            if (!player.IsDead) _chatLog.LogChat(player.Map, player.Character.Name, text);
        }
    }

    /// <summary>Handle slash commands. VB6: HandleData "/" prefix (TCP.bas:1100+)</summary>
    private async Task HandleSlashCommand(PlayerState player, string command)
    {
        var parts = command.Split(' ', 2, StringSplitOptions.TrimEntries);
        var cmd = parts[0].ToUpperInvariant();
        var arg = parts.Length > 1 ? parts[1] : "";

        switch (cmd)
        {
            case "/WHO":
                // VB6: HandleData "/WHO" -> list all online player names
                var names = _world.GetAllOnlinePlayers().Select(p => p.Character.Name);
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"Players online: {string.Join(", ", names)}", FontType.Info));
                break;

            case "/PLAYERS":
                var count = _world.GetOnlineCount();
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"There are {count} player(s) online.", FontType.Info));
                break;

            case "/STATS":
                // VB6: HandleData "/STATS" -> SendUserStatsTxt
                var c = player.Character;
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"{c.Name} — {c.Race} {c.Gender} — Map {player.Map} ({player.X},{player.Y})", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"HP:{c.CurrentHp}/{c.MaxHp} STA:{c.CurrentSta}/{c.MaxSta} MAN:{c.CurrentMan}/{c.MaxMan} Gold:{c.Gold}", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"HIT:{c.MinHit}-{c.MaxHit} DEF:{c.Def} EXP:{c.Exp}/{c.Elu} Food:{c.Food} Drink:{c.Drink}", FontType.Info));
                break;

            case "/DESC":
                // VB6: HandleData "/DESC" -> set character description
                if (!string.IsNullOrWhiteSpace(arg))
                {
                    player.Character.Description = arg;
                    await Clients.Caller.SendAsync("Chat",
                        new ChatMessage($"Description set to: {arg}", FontType.Info));
                }
                else
                {
                    await Clients.Caller.SendAsync("Chat",
                        new ChatMessage($"Your description: {player.Character.Description ?? "(none)"}", FontType.Info));
                }
                break;

            case "/SAVE":
                // VB6: HandleData "/SAVE" -> SaveUser
                player.Character.LastMap = player.Map;
                player.Character.LastX = player.X;
                player.Character.LastY = player.Y;
                await _world.SaveCharacter(player.Character);
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("Character saved.", FontType.Info));
                break;

            case "/QUIT":
                // VB6: HandleData "/QUIT" -> SaveUser + CloseSocket
                player.Character.LastMap = player.Map;
                player.Character.LastX = player.X;
                player.Character.LastY = player.Y;
                await _world.SaveCharacter(player.Character);
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("Saving and disconnecting...", FontType.Info));
                Context.Abort();
                break;

            case "/TRADE":
                await HandleTrade(player);
                break;

            case "/TRAIN":
                await HandleTrain(player);
                break;

            case "/HEAL":
                await HandleHeal(player);
                break;

            case "/DEPOSIT":
                await HandleBankDeposit(player, arg);
                break;

            case "/WITHDRAW":
                await HandleBankWithdraw(player, arg);
                break;

            case "/BALANCE":
                await HandleBankBalance(player);
                break;

            case "/RESSURECT":
            case "/RESURRECT":
                await HandleResurrect(player);
                break;

            case "/DUEL":
                await HandleDuel(player);
                break;

            case "/MEDITATE":
                await HandleMeditate(player);
                break;

            case "/DROPGOLD":
                await HandleDropGold(player, arg);
                break;

            case "/HAIL":
                await HandleHail(player);
                break;

            case "/GOSSIP":
            case "/NEWS":
                await HandleGossip(player);
                break;

            case "/HELP":
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("Commands: /WHO /STATS /DESC /TRADE /TRAIN /HEAL /HAIL /GOSSIP /DUEL /MEDITATE /RESSURECT /SAVE /QUIT /HELP", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("Chat: just type to say, - to shout, : to emote, \\name to whisper", FontType.Info));
                break;

            default:
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"Unknown command: {cmd}", FontType.Info));
                break;
        }
    }

    /// <summary>Simple ping to verify the connection works.</summary>
    public string Ping() => "Pong";

    // ===================== Rotation (Turn in Place) =====================

    /// <summary>
    /// Rotate player heading without moving. VB6: HandleData ">" and "&lt;".
    /// Shift+Right = rotate clockwise, Shift+Left = rotate counter-clockwise.
    /// </summary>
    public async Task Rotate(bool clockwise)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;

        if (clockwise)
        {
            // VB6: Heading + 1, wrap WEST -> NORTH
            player.Heading++;
            if (player.Heading > (int)Direction.West) player.Heading = (int)Direction.North;
        }
        else
        {
            // VB6: Heading - 1, wrap NORTH -> WEST
            player.Heading--;
            if (player.Heading < (int)Direction.North) player.Heading = (int)Direction.West;
        }

        // Broadcast facing change to all players on map (VB6: ChangeUserChar ToMap)
        var (pw, ps) = GetEquipAnims(player.Character);
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("MakeChar", new MakeCharMessage(
                player.CharIndex, player.Character.Name, player.Character.Body, player.Character.Head,
                player.Heading, player.X, player.Y, pw, ps, player.Character.Criminal > 0));
    }

    // ===================== Combat =====================

    /// <summary>
    /// Toggle battle mode. VB6: HandleData "BTL" -> OpenBattlemode/EndBattlemode.
    /// Plays battle music (Mus5) on enter, restores zone music on exit.
    /// </summary>
    public async Task ToggleBattleMode()
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || player.IsDead) return;

        player.BattleMode = !player.BattleMode;

        if (player.BattleMode)
        {
            // VB6: OpenBattlemode
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You prepear for attack !", FontType.Info));
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("If you seem to be unable to hit your opponent, hold in ALT and press any cursor then opposite cursor afterwards to turn back to the opponent.", FontType.Info));
            // Play battle music (Mus5)
            await Clients.Caller.SendAsync("PlayMusic", new PlayMusicMessage(5, true));
        }
        else
        {
            // VB6: EndBattlemode — restore zone music
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You have left battlemode.", FontType.Info));
            await SendMapMusic(player.Map);
        }
    }

    /// <summary>
    /// Consider target. VB6: HandleData "COO" -> Consider (GameLogic.bas:6784).
    /// Shows target's HP and hit power via chat messages.
    /// </summary>
    public async Task Consider()
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || player.IsDead) return;

        // Consider NPC
        if (player.TargetNpcIndex > 0)
        {
            var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
            if (npc != null)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You look at {npc.Name}...", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You assume the health of your target is {npc.CurrentHp}/{npc.MaxHp}", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You assume its hit power would be about {npc.MaxHit} points...", FontType.Info));
                return;
            }
        }

        // Consider player
        if (player.TargetPlayerCharIndex > 0)
        {
            var other = _world.GetPlayerByCharIndex(player.TargetPlayerCharIndex);
            if (other != null)
            {
                var ch = other.Character;
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You look at {ch.Name}...", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You assume the health of your target is {ch.CurrentHp}/{ch.MaxHp}", FontType.Info));
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You assume its hit power would be about {ch.MaxHit} points.", FontType.Info));
                return;
            }
        }
    }

    // ===================== Trading =====================

    /// <summary>
    /// Open trade with targeted NPC. VB6: HandleData "/TRADE" -> NpcTrade (GameLogic.bas:3138).
    /// Sends NPC inventory to client to display trade window.
    /// </summary>
    private async Task HandleTrade(PlayerState player)
    {
        if (player.IsDead)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You are dead and cannot do that.", FontType.Info));
            return;
        }

        if (player.TargetNpcIndex <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Trade with who ?", FontType.Info));
            return;
        }

        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Trade with who ?", FontType.Info));
            return;
        }

        // VB6: Tradeable = 1 means CANNOT trade (confusing naming)
        if (npc.Tradeable == 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You cannot trade with this NPC.", FontType.Info));
            return;
        }

        // Build NPC inventory slots for the client
        var slots = new List<NpcInvSlotMessage>();
        for (int s = 0; s < npc.Inventory.Length; s++)
        {
            var inv = npc.Inventory[s];
            if (inv.ObjIndex > 0)
            {
                var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
                if (objDef != null)
                {
                    long value = 0;
                    long.TryParse(objDef.Value, out value);
                    slots.Add(new NpcInvSlotMessage(
                        s, inv.ObjIndex, objDef.Name, inv.Amount,
                        objDef.GrhIndex, (int)value, objDef.Level));
                }
            }
        }

        await Clients.Caller.SendAsync("TradeOpen",
            new TradeOpenMessage(npc.Name, slots.ToArray()));
    }

    /// <summary>
    /// Merchant skill price multiplier. VB6: NPCSellItem/NPCBuyItem Luck2 table.
    /// Higher merchant skill (Skill8) = lower multiplier = cheaper prices.
    /// </summary>
    private static double GetMerchantMultiplier(int merchantSkill) => merchantSkill switch
    {
        >= 99 => 1.0,
        >= 79 => 1.5,
        >= 69 => 2.0,
        >= 59 => 2.5,
        >= 49 => 3.0,
        >= 39 => 3.5,
        >= 29 => 4.0,
        >= 19 => 4.5,
        _ => 5.0
    };

    /// <summary>
    /// Player buys an item from the NPC. VB6: HandleData "BUY" -> NPCSellItem (GameLogic.bas:4991).
    /// </summary>
    public async Task BuyFromNpc(int slot)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || player.IsDead) return;

        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null) return;

        if (slot < 0 || slot >= npc.Inventory.Length) return;
        var npcInv = npc.Inventory[slot];
        if (npcInv.ObjIndex <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, Err...what do you want to buy again ?", FontType.Talk));
            return;
        }

        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == npcInv.ObjIndex);
        if (objDef == null) return;

        long.TryParse(objDef.Value, out long baseValue);
        double mult = GetMerchantMultiplier(player.Character.Skills[8]);
        long price = baseValue > 20 ? (long)(baseValue * mult) : baseValue;

        var ch = player.Character;
        if (ch.Gold < price)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, You do not have enough gold !", FontType.Talk));
            return;
        }

        // Find inventory slot — first matching item to stack, else first empty
        int targetSlot = -1;
        for (int i = 0; i < 20; i++)
        {
            if (ch.Inventory[i].ObjIndex == npcInv.ObjIndex) { targetSlot = i; break; }
        }
        if (targetSlot < 0)
        {
            for (int i = 0; i < 20; i++)
            {
                if (ch.Inventory[i].ObjIndex == 0) { targetSlot = i; break; }
            }
        }
        if (targetSlot < 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You cannot hold any more items now !", FontType.Info));
            return;
        }

        // Complete the purchase
        ch.Gold -= (int)price;
        ch.Inventory[targetSlot].ObjIndex = npcInv.ObjIndex;
        ch.Inventory[targetSlot].Amount += 1;
        npc.Gold += price;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"{npc.Name} says, you want this fine item ! Deal !", FontType.Talk));
        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"You pay {price} gold.", FontType.Info));
        await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.Coins));

        // Merchant skill improvement: 1/30 chance (VB6: RandomNumber(1,30) = 5)
        await TryImproveSkill(player, 8, 30);

        await SendInvSlot(ch, targetSlot);
        await SendStats(ch);
    }

    /// <summary>
    /// Player sells an item to the NPC. VB6: HandleData "SLL" -> NPCBuyItem (GameLogic.bas:5104).
    /// </summary>
    public async Task SellToNpc(int slot)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || player.IsDead) return;
        if (slot < 0 || slot >= 20) return;

        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null) return;

        var ch = player.Character;
        var invSlot = ch.Inventory[slot];
        if (invSlot.ObjIndex <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, Buy what ?!", FontType.Talk));
            return;
        }

        // Can't sell equipped items (VB6 client check)
        if (invSlot.Equipped)
        {
            return;
        }

        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == invSlot.ObjIndex);
        if (objDef == null) return;

        // VB6: Sellable = 1 means NOT sellable (confusing naming)
        if (objDef.Sellable == 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, i have no interest in this item.", FontType.Talk));
            return;
        }

        long.TryParse(objDef.Value, out long baseValue);
        if (baseValue == 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, I have no need for this item.", FontType.Talk));
            return;
        }

        // Check NPC categories — does this NPC buy this type of item?
        bool willBuy = false;
        if (npc.Categories.Length > 0 && npc.Categories[0] == "All")
            willBuy = true;
        else if (npc.Categories.Length > 0 && npc.Categories[0] == "Nothing")
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, Im not interested in any trading.", FontType.Talk));
            return;
        }
        else
        {
            foreach (var cat in npc.Categories)
            {
                if (!string.IsNullOrEmpty(cat) && cat == objDef.Category)
                { willBuy = true; break; }
            }
        }

        if (!willBuy)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npc.Name} says, I have no interest in an item of such type.", FontType.Talk));
            return;
        }

        // Price — divide by merchant multiplier (higher skill = more gold)
        double mult = GetMerchantMultiplier(ch.Skills[8]);
        long sellPrice = baseValue > 20 ? (long)(baseValue / mult) : baseValue;
        if (sellPrice < 1) sellPrice = 1;

        // Check if NPC has enough gold
        if (npc.Gold < sellPrice)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("I cannot afford this im afraid !", FontType.Info));
            return;
        }

        // Complete the sale
        if (invSlot.Amount > 1)
        {
            invSlot.Amount -= 1;
        }
        else
        {
            invSlot.ObjIndex = 0;
            invSlot.Amount = 0;
        }
        invSlot.Equipped = false;
        ch.Gold += (int)sellPrice;
        npc.Gold -= sellPrice;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"{npc.Name} gives you {sellPrice} gold for the {objDef.Name}", FontType.Talk));
        await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.Coins));

        // Merchant skill improvement: 1/150 chance (VB6: RandomNumber(1,150) = 5)
        await TryImproveSkill(player, 8, 150);

        await SendInvSlot(ch, slot);
        await SendStats(ch);
    }

    /// <summary>
    /// Check if player's class should change based on highest skill.
    /// VB6: CheckClass in Checks.bas. Called after skill changes.
    /// </summary>
    private void CheckClass(CharacterData ch)
    {
        int highestSkill = 0;
        int highestValue = 0;
        for (int i = 1; i <= 28; i++)
        {
            if (ch.Skills[i] > highestValue)
            {
                highestValue = ch.Skills[i];
                highestSkill = i;
            }
        }

        if (highestSkill > 0 && SkillInfo.SkillToClass.TryGetValue(highestSkill, out var newClass))
        {
            if (ch.Class != newClass)
                ch.Class = newClass;
        }
    }

    /// <summary>
    /// Try to improve a skill. VB6 pattern: RandomNumber(1, chance) == target, skill >= 10, below level cap.
    /// </summary>
    private async Task TryImproveSkill(PlayerState player, int skillIndex, int chance)
    {
        var ch = player.Character;
        if (ch.Skills[skillIndex] < 10) return;

        // VB6: LevelSkill(ELV).LevelValue > current skill
        int level = ch.Level;
        int levelCap = level >= 1 && level < SkillInfo.LevelCap.Length
            ? SkillInfo.LevelCap[level] : 100;
        if (ch.Skills[skillIndex] >= levelCap) return;

        if (Random.Shared.Next(1, chance + 1) == 5)
        {
            ch.Skills[skillIndex]++;
            CheckClass(ch);
            string skillName = ((SkillType)skillIndex).ToString();
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"Your {skillName} skill has improved ({ch.Skills[skillIndex]}) !", FontType.SkillInfo));
        }
    }

    // ===================== Spells & Meditation =====================

    /// <summary>
    /// Inscribe a spell scroll into the spell book. VB6: InscribeSpell (GameLogic.bas:1609).
    /// Called from UseItem when item type is OBJTYPE_SPELL (23).
    /// </summary>
    private async Task InscribeSpell(PlayerState player, int slot)
    {
        var ch = player.Character;
        var inv = ch.Inventory[slot];
        var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
        if (objDef == null || objDef.SpellType <= 0) return;

        // Find an empty spell book slot
        int emptySlot = -1;
        for (int i = 0; i < ch.SpellBook.Length; i++)
        {
            if (ch.SpellBook[i] == 0) { emptySlot = i; break; }
        }
        if (emptySlot < 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Your spell book is full !", FontType.Info));
            return;
        }

        ch.SpellBook[emptySlot] = objDef.SpellType;
        await Clients.Caller.SendAsync("Chat",
            new ChatMessage("You have inscribed the spell into your spell book.", FontType.Info));

        // Remove the scroll from inventory (consumed)
        inv.ObjIndex = 0; inv.Amount = 0; inv.Equipped = false;
        await SendInvSlot(ch, slot);

        // Send the new spell slot to client
        await SendSpellSlot(ch, emptySlot);
    }

    /// <summary>
    /// Cast a spell from the spell book. VB6: HandleData "CST" -> CastSpellAtPC / CastSpellAtNPC.
    /// Unified function that dispatches to NPC or player target based on current targeting state.
    /// </summary>
    public async Task CastSpell(int spellSlot)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;
        var ch = player.Character;

        if (spellSlot < 0 || spellSlot >= ch.SpellBook.Length) return;
        int spellId = ch.SpellBook[spellSlot];
        if (spellId <= 0) return;

        var spell = _gameData.Spells.FirstOrDefault(s => s.Id == spellId);
        if (spell == null) return;

        // VB6: Check magic school — player's MagicSchool must be in the spell's Schools array
        if (!string.IsNullOrEmpty(ch.MagicSchool) && spell.Schools.Length > 0)
        {
            bool canCast = spell.Schools.Any(s =>
                string.Equals(s, ch.MagicSchool, StringComparison.OrdinalIgnoreCase));
            if (!canCast)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You cannot cast this spell because it's not in your school of magic !", FontType.Info));
                return;
            }
        }

        // VB6: Check mana
        if (spell.NeedsMana > ch.CurrentMan)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You dont have enough mana to cast the spell.", FontType.Info));
            return;
        }

        // Determine target: NPC or player
        if (player.TargetNpcIndex > 0)
            await CastSpellAtNpc(player, spell);
        else if (player.TargetPlayerCharIndex > 0)
            await CastSpellAtPlayer(player, spell);
        else
        {
            // Self-cast if no target (for utility spells)
            await CastSpellAtPlayer(player, spell, selfCast: true);
        }
    }

    /// <summary>
    /// Cast a spell at an NPC target. VB6: CastSpellAtNPC (GameLogic.bas:4848).
    /// </summary>
    private async Task CastSpellAtNpc(PlayerState player, SpellDef spell)
    {
        var ch = player.Character;
        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null || !npc.Active)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You have no target !", FontType.Info));
            return;
        }

        var template = _gameData.Npcs.FirstOrDefault(n => n.Id == npc.TemplateId);

        // VB6: Can't cast destruction on non-attackable NPCs
        if (spell.Destruction == 1 && (template == null || template.Attackable != 1))
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"A mysterious force prevents you from casting a spell at {npc.Name} !", FontType.Info));
            return;
        }

        // VB6: Can't cast destruction when dead
        if (spell.Destruction == 1 && player.IsDead)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You cannot cast destruction spells when dead.", FontType.Info));
            return;
        }

        // Deduct mana
        ch.CurrentMan -= spell.NeedsMana;

        // Make NPC hostile (VB6: NPCList.Hostile = 1)
        if (spell.Destruction == 1)
        {
            npc.Hostile = true;
            if (template?.Guard == 1)
            {
                ch.Criminal = 2;
                ch.CriminalCount += 60;
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You are now a criminal !", FontType.Info));
            }
        }

        // Play spell sound
        if (spell.Sound > 0)
            await Clients.Group(MapGroup(player.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(spell.Sound));

        // Apply NPC effects (only damage and healing apply to NPCs)
        if (spell.GiveHp > 0) npc.MaxHp += spell.GiveHp;
        if (spell.HealHp > 0) npc.CurrentHp = npc.MaxHp;
        if (spell.DamageHp > 0) npc.CurrentHp -= spell.DamageHp;

        // Caster message
        if (!string.IsNullOrEmpty(spell.CasterMessage))
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage(spell.CasterMessage, FontType.Info));

        // NPC death check
        if (npc.CurrentHp <= 0)
        {
            bool wasGuard = template?.Guard == 1;
            bool wasNotHostile = !npc.Hostile;
            bool wasNotChasing = npc.Movement != (int)NpcMovement.HostileChase;
            await NpcDie(player, npc, wasNotHostile, wasNotChasing);
        }

        // +2 EXP per cast
        ch.Exp += 2;
        await CheckUserLevel(player);
        await SendStats(ch);
        await SendFullSpellBook(ch);
    }

    /// <summary>
    /// Cast a spell at a player target (or self). VB6: CastSpellAtPC (GameLogic.bas:4622).
    /// </summary>
    private async Task CastSpellAtPlayer(PlayerState caster, SpellDef spell, bool selfCast = false)
    {
        var casterCh = caster.Character;
        PlayerState target;

        if (selfCast)
        {
            target = caster;
        }
        else
        {
            target = _world.GetPlayerByCharIndex(caster.TargetPlayerCharIndex);
            if (target == null)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You have no target !", FontType.Info));
                return;
            }
        }

        var targetCh = target.Character;

        // VB6: Destruction spell PK checks
        if (spell.Destruction == 1 && !selfCast)
        {
            if (target.IsDead)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You cannot attack the dead !", FontType.Info));
                return;
            }

            var map = _gameData.Maps.GetValueOrDefault(caster.Map);
            if (map?.PkFreeZone == true && (!caster.Duel || !target.Duel))
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("This is a Player Killing free area. Both players must be in duel mode (/DUEL) to fight here !", FontType.Info));
                return;
            }
        }

        // Deduct mana
        casterCh.CurrentMan -= spell.NeedsMana;

        // Play spell sound
        if (spell.Sound > 0)
            await Clients.Group(MapGroup(caster.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(spell.Sound));

        // Apply all spell effects to target
        if (spell.GiveHp > 0) targetCh.MaxHp += spell.GiveHp;
        if (spell.GiveMana > 0) targetCh.MaxMan += spell.GiveMana;
        if (spell.GiveStamina > 0) targetCh.MaxSta += spell.GiveStamina;
        if (spell.GiveMoney > 0) targetCh.Gold += spell.GiveMoney;
        if (spell.GiveFood > 0) targetCh.Food += spell.GiveFood;
        if (spell.GiveDrink > 0) targetCh.Drink += spell.GiveDrink;
        if (spell.GiveExp > 0) targetCh.Exp += spell.GiveExp;
        if (spell.HealHp > 0) targetCh.CurrentHp = targetCh.MaxHp;
        if (spell.HealMana > 0) targetCh.CurrentMan = targetCh.MaxMan;
        if (spell.HealStamina > 0) targetCh.CurrentSta = targetCh.MaxSta;
        if (spell.DamageHp > 0) targetCh.CurrentHp -= spell.DamageHp;
        if (spell.DamageMana > 0) targetCh.CurrentMan -= spell.DamageMana;
        if (spell.DamageStamina > 0) targetCh.CurrentSta -= spell.DamageStamina;

        // VB6: Teleport/Anchor
        if (spell.Teleport == 1)
        {
            if (!targetCh.TeleportAnchorSet)
            {
                targetCh.TeleportAnchorMap = target.Map;
                targetCh.TeleportAnchorX = target.X;
                targetCh.TeleportAnchorY = target.Y;
                targetCh.TeleportAnchorSet = true;
                await Clients.Client(target.ConnectionId).SendAsync("Chat",
                    new ChatMessage("You are anchored here. To teleport back to here, recast the teleport spell.", FontType.Info));
            }
            else
            {
                await Clients.Client(target.ConnectionId).SendAsync("Chat",
                    new ChatMessage("You teleport back to the anchored position.", FontType.Info));
                await WarpPlayer(target, targetCh.TeleportAnchorMap, targetCh.TeleportAnchorX, targetCh.TeleportAnchorY);
                targetCh.TeleportAnchorSet = false;
            }
        }

        // VB6: Resurrection via spell
        if (spell.Resurrection == 1 && target.IsDead)
        {
            target.IsDead = false;
            targetCh.Body = target.OriginalBody;
            targetCh.Head = target.OriginalHead;
            var (pw, ps) = GetEquipAnims(targetCh);
            await Clients.Group(MapGroup(target.Map)).SendAsync("ChangeChar",
                new MakeCharMessage(target.CharIndex, targetCh.Name, targetCh.Body, targetCh.Head,
                    target.Heading, target.X, target.Y, pw, ps, targetCh.Criminal > 0));
            await Clients.Group(MapGroup(target.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(SoundId.Chorus));
            await Clients.Client(target.ConnectionId).SendAsync("Death", false);
        }

        // Messages
        if (!string.IsNullOrEmpty(spell.CasterMessage))
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage(spell.CasterMessage, FontType.Info));
        if (!string.IsNullOrEmpty(spell.TargetMessage) && !selfCast)
            await Clients.Client(target.ConnectionId).SendAsync("Chat",
                new ChatMessage(spell.TargetMessage, FontType.Info));

        // VB6: Player death from destruction spell
        if (!selfCast && spell.Destruction == 1 && targetCh.CurrentHp <= 0)
        {
            // Criminal/rep effects (same as melee PvP kill)
            if (targetCh.Criminal == 0 && !target.Duel)
            {
                casterCh.CriminalCount += 75;
                casterCh.Criminal = 2;
                casterCh.CommonRep -= 5;
                casterCh.NobleRep -= 5;
                casterCh.OverallRep -= 20;
                casterCh.UnderRep += 3;
                casterCh.BendarrRep += 3;
            }
            else
            {
                casterCh.OverallRep += 2;
                casterCh.CommonRep += 2;
            }

            int expGain = targetCh.Level * 20;
            casterCh.Exp += expGain;
            await Clients.Group(MapGroup(caster.Map)).SendAsync("Chat",
                new ChatMessage($"{targetCh.Name} has been slain by {casterCh.Name} !", FontType.Talk));
            await _gameLoopService.UserDieFromHub(target);
        }

        // +2 EXP per cast
        casterCh.Exp += 2;
        await CheckUserLevel(caster);
        await SendStats(casterCh);
        if (!selfCast && target.ConnectionId != caster.ConnectionId)
        {
            await Clients.Client(target.ConnectionId).SendAsync("Stats", new StatsMessage(
                targetCh.CurrentHp, targetCh.MaxHp, targetCh.CurrentMan, targetCh.MaxMan,
                targetCh.CurrentSta, targetCh.MaxSta, targetCh.Gold, targetCh.Exp, targetCh.Elu,
                targetCh.Food, targetCh.Drink, targetCh.MinHit, targetCh.MaxHit, targetCh.Def,
                targetCh.TrainingPoints, targetCh.Class, targetCh.RepRank, targetCh.Skills,
                targetCh.Criminal, targetCh.CriminalCount));
        }
    }

    /// <summary>
    /// Toggle meditation. VB6: HandleData "/MEDITATE" -> Meditate (GameLogic.bas:5370).
    /// Places/removes a meditation aura (obj 231). Mana regen ticks in game loop.
    /// </summary>
    private async Task HandleMeditate(PlayerState player)
    {
        if (player.Meditating)
        {
            // Stop meditating: remove aura, clear flag
            player.Meditating = false;
            _world.PickupGroundItem(player.Map, player.X, player.Y);
            await Clients.Group(MapGroup(player.Map)).SendAsync("EraseObj",
                new EraseObjMessage(player.X, player.Y));
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You snap out of the meditation trance.", FontType.Info));
            await Clients.Caller.SendAsync("Meditate", new MeditateMessage(false));
        }
        else
        {
            // Start meditating: place aura, set flag
            player.Meditating = true;
            // VB6: Object 231 = meditation aura
            var auraDef = _gameData.Objects.FirstOrDefault(o => o.Id == 231);
            if (auraDef != null)
            {
                _world.PlaceGroundItem(player.Map, player.X, player.Y, 231, 1);
                await Clients.Group(MapGroup(player.Map)).SendAsync("MakeObj",
                    new MakeObjMessage(auraDef.GrhIndex, player.X, player.Y));
            }
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You are surrounded by a meditation aura and you start to meditate...", FontType.Info));
            await Clients.Caller.SendAsync("Meditate", new MeditateMessage(true));
        }
    }

    /// <summary>Send full spell book to client (VB6: UpdateUserSpell with updateall=True).</summary>
    private async Task SendFullSpellBook(CharacterData ch)
    {
        for (int i = 0; i < ch.SpellBook.Length; i++)
            await SendSpellSlot(ch, i);
    }

    /// <summary>Send a single spell book slot to client (VB6: ChangeUserSpells -> "SPL" message).</summary>
    private async Task SendSpellSlot(CharacterData ch, int slot)
    {
        int spellId = ch.SpellBook[slot];
        if (spellId > 0)
        {
            var spell = _gameData.Spells.FirstOrDefault(s => s.Id == spellId);
            await Clients.Caller.SendAsync("SpellSlot",
                new SpellSlotMessage(slot, spellId, spell?.Name ?? "Unknown", spell?.Desc ?? "", spell?.NeedsMana ?? 0));
        }
        else
        {
            await Clients.Caller.SendAsync("SpellSlot",
                new SpellSlotMessage(slot, 0, "(Empty)", "", 0));
        }
    }

    // ===================== Crafting =====================

    /// <summary>
    /// Start a crafting job. Validates material amount and skill, sets working state,
    /// sends progress bar to client.
    /// VB6: DOS message with skill level for progress bar speed.
    /// </summary>
    private async Task StartCraft(PlayerState player, int slot, int jobType, int skillIndex,
        int requiredAmount, string startMessage)
    {
        var ch = player.Character;

        // Check material amount
        if (ch.Inventory[slot].Amount < requiredAmount)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You do not have enough materials to make this.", FontType.Info));
            return;
        }

        // For drawing-based crafts, check skill requirement
        if (jobType >= 8 && jobType <= 10 && player.CraftSkillRequired > ch.Skills[skillIndex])
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You do not have enough skill to make this item. You need atleast {player.CraftSkillRequired} skill points.", FontType.Info));
            return;
        }

        // Start crafting
        player.Working = true;
        player.WhatJob = jobType;
        player.CraftSlot = slot;
        player.CraftStartTime = DateTime.UtcNow;

        // Progress duration based on skill: higher skill = faster (100 - skill) * 50ms, min 2s
        int skillLevel = ch.Skills[skillIndex];
        int durationMs = Math.Max(2000, (100 - skillLevel) * 50);

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage(startMessage + " The blue bar represents how much time left.", FontType.Info));
        await Clients.Caller.SendAsync("CraftStart", new CraftStartMessage(jobType, durationMs));
    }

    /// <summary>
    /// Client reports crafting progress bar is complete. Server validates and produces output.
    /// VB6: HandleData "XBX" -> calls the appropriate craft function with SkillFinished=1.
    /// </summary>
    public async Task CompleteCraft(int jobType)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || !player.Working || player.WhatJob != jobType) return;

        var ch = player.Character;
        var slot = player.CraftSlot;
        // Gathering jobs use slot=-1 (no inventory material); crafting jobs need a valid slot
        bool isGathering = (jobType == 2 || jobType == 7 || jobType == 15);
        if (!isGathering && (slot < 0 || slot >= 20)) return;

        // Minimum time check (prevent speed hacking)
        var elapsed = (DateTime.UtcNow - player.CraftStartTime).TotalMilliseconds;
        if (elapsed < 1500) return; // must wait at least 1.5s

        // Reset working state
        player.Working = false;
        player.WhatJob = 0;

        int soundId = SoundId.Coins;
        int resultObjIndex = 0;
        int resultAmount = 1;
        int consumeAmount = 0;
        int skillIndex = 0;
        int skillChance = 15;
        string successMessage = "Success!";

        switch (jobType)
        {
            case 3: // CreateFoldedCloth (sewing kit + 2 cloth → 4 folded cloth)
                consumeAmount = 2; resultObjIndex = 151; resultAmount = 4;
                soundId = SoundId.FoldClothing; skillIndex = (int)SkillType.Tailoring;
                successMessage = "And you manage to create some folded cloth !";
                break;

            case 4: // CreatePlanks (saw + 2 logs → 4 planks)
                consumeAmount = 2; resultObjIndex = 148; resultAmount = 4;
                soundId = SoundId.Saw; skillIndex = (int)SkillType.Carpentry;
                successMessage = "And you manage to create planks !";
                break;

            case 5: // CreateSteel (hammer + 2 ore → 4 steel)
                consumeAmount = 2; resultObjIndex = 149; resultAmount = 4;
                soundId = SoundId.Smithing; skillIndex = (int)SkillType.Blacksmithing;
                successMessage = "And you manage to create steel !";
                break;

            case 8: // MakeBlacksmithingObj (steel → weapon from drawing)
                consumeAmount = player.CraftNeedSteel; resultObjIndex = player.CraftMakeItem;
                soundId = SoundId.Smithing; skillIndex = (int)SkillType.Blacksmithing;
                skillChance = 4; successMessage = "And you manage to create it!";
                break;

            case 9: // MakeCarpentryObj (planks → item from drawing)
                consumeAmount = player.CraftNeedPlanks; resultObjIndex = player.CraftMakeItem;
                soundId = SoundId.Saw; skillIndex = (int)SkillType.Carpentry;
                skillChance = 4; successMessage = "And you manage to create it!";
                break;

            case 10: // MakeTailoringObj (folded cloth → clothing from drawing)
                consumeAmount = player.CraftNeedFoldedCloth; resultObjIndex = player.CraftMakeItem;
                soundId = SoundId.FoldClothing; skillIndex = (int)SkillType.Tailoring;
                skillChance = 4; successMessage = "And you manage to create it!";
                break;

            case 13: // SetCamp (log → campfire)
                consumeAmount = 1; resultObjIndex = 155; // campfire
                soundId = SoundId.Burn; skillIndex = (int)SkillType.Surviving;
                skillChance = 30; successMessage = "And it ignite !";
                break;

            // --- Gathering skills (no material consumed, produce resource at feet) ---

            case 2: // Chop — lumberjacking produces 1 log
                consumeAmount = 0; resultObjIndex = 114; resultAmount = 1;
                soundId = SoundId.Chopping; skillIndex = (int)SkillType.Lumberjacking;
                successMessage = "And you manage to chop of a log !";
                break;

            case 7: // Fish — fishing produces 1 fish
                consumeAmount = 0; resultObjIndex = 135; resultAmount = 1; // VB6: random 308-317 (don't exist), use 135 (1kg fish)
                soundId = SoundId.FishingPole; skillIndex = (int)SkillType.Fishing;
                successMessage = "You pull up a nice fish !";
                break;

            case 15: // Mine — mining produces 4 ore
                consumeAmount = 0; resultObjIndex = 154; resultAmount = 4;
                soundId = SoundId.FishingPole; skillIndex = (int)SkillType.Mining;
                successMessage = "You manage to mine some fine ore !";
                break;

            default: return;
        }

        if (resultObjIndex <= 0) return;

        // Consume materials (gathering jobs have consumeAmount=0, skip)
        if (consumeAmount > 0)
        {
            if (slot < 0 || slot >= 20) return;
            if (ch.Inventory[slot].Amount < consumeAmount)
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("You no longer have enough materials.", FontType.Info));
                return;
            }
            ch.Inventory[slot].Amount -= consumeAmount;
            if (ch.Inventory[slot].Amount <= 0)
            { ch.Inventory[slot].ObjIndex = 0; ch.Inventory[slot].Amount = 0; }
        }

        // Play sound
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("PlaySound", new PlaySoundMessage(soundId));

        // Create result item on ground at player position
        await Clients.Caller.SendAsync("Chat",
            new ChatMessage(successMessage, FontType.Info));
        _world.PlaceGroundItem(player.Map, player.X, player.Y, resultObjIndex, resultAmount);
        var resultObj = _gameData.Objects.FirstOrDefault(o => o.Id == resultObjIndex);
        if (resultObj != null)
        {
            await Clients.Group(MapGroup(player.Map))
                .SendAsync("MakeObj", new MakeObjMessage(resultObj.GrhIndex, player.X, player.Y));
        }

        // Skill improvement
        await TryImproveSkill(player, skillIndex, skillChance);

        // EXP reward
        ch.Exp += 3;
        await CheckUserLevel(player);
        if (consumeAmount > 0 && slot >= 0 && slot < 20)
            await SendInvSlot(ch, slot);
        await SendStats(ch);

        // Clear craft recipe data after drawing-based crafts
        if (jobType >= 8 && jobType <= 10)
        {
            player.CraftMakeItem = 0;
            player.CraftNeedPlanks = 0;
            player.CraftNeedSteel = 0;
            player.CraftNeedFoldedCloth = 0;
            player.CraftSkillRequired = 0;
        }
    }

    // ===================== Gathering Skills =====================

    /// <summary>
    /// Gather a resource by clicking on a tile in battle mode.
    /// VB6: HandleData "CHP" -> Chop, "FSH" -> Fish, "MIN" -> Mine (GameLogic.bas).
    /// Client detects the tile type (tree/water/rock) and sends the gather type.
    /// The server validates the equipped tool and starts a progress bar.
    /// </summary>
    public async Task GatherResource(string gatherType)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;

        // VB6: Must be alive
        if (player.IsDead)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You are dead and cannot do that.", FontType.Talk));
            return;
        }

        // VB6: Must not already be working
        if (player.Working)
        {
            return;
        }

        int jobType;
        int skillIndex;
        string startMessage;

        switch (gatherType)
        {
            case "chop":
                // VB6: OBJtarget must be 17 (LumberjackAxe)
                if (player.EquippedToolObjType != 17)
                {
                    await Clients.Caller.SendAsync("Chat",
                        new ChatMessage("You need to equip a lumberjack axe first.", FontType.Info));
                    return;
                }
                jobType = 2;
                skillIndex = (int)SkillType.Lumberjacking;
                startMessage = "You begin chopping on the tree.";
                break;

            case "fish":
                // VB6: OBJtarget must be 16 (FishingRod)
                if (player.EquippedToolObjType != 16)
                {
                    await Clients.Caller.SendAsync("Chat",
                        new ChatMessage("You need to equip a fishing rod first.", FontType.Info));
                    return;
                }
                jobType = 7;
                skillIndex = (int)SkillType.Fishing;
                startMessage = "You throw the line into the water and wait...";
                break;

            case "mine":
                // VB6: OBJtarget must be 48 (Pickaxe)
                if (player.EquippedToolObjType != 48)
                {
                    await Clients.Caller.SendAsync("Chat",
                        new ChatMessage("You need to equip a pickaxe first.", FontType.Info));
                    return;
                }
                jobType = 15;
                skillIndex = (int)SkillType.Mining;
                startMessage = "You begin mining after ore...";
                break;

            default: return;
        }

        // Start the gathering progress bar (reuses crafting infrastructure)
        // VB6: DOS message with skill level and job type
        var ch = player.Character;
        player.Working = true;
        player.WhatJob = jobType;
        player.CraftSlot = -1; // No inventory slot for gathering
        player.CraftStartTime = DateTime.UtcNow;

        int skillLevel = ch.Skills[skillIndex];
        int durationMs = Math.Max(2000, (100 - skillLevel) * 50);

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage(startMessage + " The blue bar represents how much time left.", FontType.Info));
        await Clients.Caller.SendAsync("CraftStart", new CraftStartMessage(jobType, durationMs));
    }

    // ===================== Campfire Healing =====================

    /// <summary>
    /// Heal from adjacent campfire. VB6: HandleData "CMP" -> CampHeal (GameLogic.bas:4058).
    /// Client calls this every 10 seconds while near a campfire.
    /// Restores HP by maxHP/5 and STA by maxSTA/5.
    /// </summary>
    public async Task CampHeal()
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || player.IsDead) return;

        var ch = player.Character;

        // Check for adjacent campfire (object 155) on any of the 4 adjacent tiles
        bool nearCampfire = false;
        int[] dx = { -1, 1, 0, 0 };
        int[] dy = { 0, 0, -1, 1 };
        for (int i = 0; i < 4; i++)
        {
            var item = _world.GetGroundItem(player.Map, player.X + dx[i], player.Y + dy[i]);
            if (item != null && item.ObjIndex == 155)
            { nearCampfire = true; break; }
        }
        // Also check the tile we're standing on
        var standingItem = _world.GetGroundItem(player.Map, player.X, player.Y);
        if (standingItem != null && standingItem.ObjIndex == 155) nearCampfire = true;

        if (!nearCampfire) return;

        bool healed = false;
        if (ch.CurrentHp < ch.MaxHp)
        {
            ch.CurrentHp = Math.Min(ch.CurrentHp + ch.MaxHp / 5, ch.MaxHp);
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You regain some health by sitting with the camp fire !", FontType.Info));
            healed = true;
        }

        if (ch.CurrentSta < ch.MaxSta)
        {
            ch.CurrentSta = Math.Min(ch.CurrentSta + ch.MaxSta / 5, ch.MaxSta);
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You regain some stamina by sitting with the camp fire !", FontType.Info));
            healed = true;
        }

        if (!healed)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You sit by the campfire, but cannot seem to heal.", FontType.Info));
        }

        await SendStats(ch);
    }

    // ===================== NPC Healing =====================

    /// <summary>
    /// NPC healer heals the player for gold. VB6: HandleData "/HEAL" -> NpcHeal (GameLogic.bas:3225).
    /// Charge = level * 10 gold, capped at 200 for level 20+. npcType 5 = Healer.
    /// </summary>
    private async Task HandleHeal(PlayerState player)
    {
        if (player.IsDead)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You are dead and must be ressurected. No healer can heal your fatal wounds.", FontType.Talk));
            return;
        }

        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Heal from who ?", FontType.Info));
            return;
        }

        var template = _gameData.Npcs.FirstOrDefault(n => n.Id == npc.TemplateId);
        if (template == null || template.NpcType != 5)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("This NPC is not a healer.", FontType.Info));
            return;
        }

        var ch = player.Character;

        // VB6: charge = level * 10, capped at 200
        int charge = Math.Min(ch.Level * 10, 200);
        if (charge < 10) charge = 10;

        if (ch.Gold < charge)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"Sorry, you do not have enough gold ! Healing for you costs {charge} gold !", FontType.Info));
            return;
        }

        ch.CurrentHp = ch.MaxHp;
        ch.Gold -= charge;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"That`ll be {charge} gold, now you are fully healed !", FontType.Info));

        await SendStats(ch);
    }

    // ===================== Banking =====================

    /// <summary>Check if player has targeted a Banker NPC (npcType 48).</summary>
    private async Task<bool> CheckBanker(PlayerState player)
    {
        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You need to target a banker first.", FontType.Info));
            return false;
        }
        var template = _gameData.Npcs.FirstOrDefault(n => n.Id == npc.TemplateId);
        if (template == null || template.NpcType != 48)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("This NPC is not a banker.", FontType.Info));
            return false;
        }
        return true;
    }

    /// <summary>VB6: HandleData "/DEPOSIT" -> BankDeposit, "DPT" amount</summary>
    private async Task HandleBankDeposit(PlayerState player, string amountStr)
    {
        if (!await CheckBanker(player)) return;

        if (!int.TryParse(amountStr, out int amount) || amount <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Usage: /DEPOSIT amount", FontType.Info));
            return;
        }

        var ch = player.Character;
        if (ch.Gold < amount)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You do not have that much gold.", FontType.Info));
            return;
        }

        ch.Gold -= amount;
        ch.BankGold += amount;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"The banker responds, Ok. Here ye go. Deposited {amount} gold.", FontType.Talk));
        await SendStats(ch);
    }

    /// <summary>VB6: HandleData "/WITHDRAW" -> BankWithdraw, "WTH" amount</summary>
    private async Task HandleBankWithdraw(PlayerState player, string amountStr)
    {
        if (!await CheckBanker(player)) return;

        if (!int.TryParse(amountStr, out int amount) || amount <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Usage: /WITHDRAW amount", FontType.Info));
            return;
        }

        var ch = player.Character;
        if (ch.BankGold < amount)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You do not have that much gold in the bank.", FontType.Info));
            return;
        }

        ch.Gold += amount;
        ch.BankGold -= amount;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"The banker responds, Ok. Here ye go. Withdrew {amount} gold.", FontType.Talk));
        await SendStats(ch);
    }

    /// <summary>VB6: HandleData "/BALANCE" -> BankBalance</summary>
    private async Task HandleBankBalance(PlayerState player)
    {
        if (!await CheckBanker(player)) return;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"The banker responds, Thee have {player.Character.BankGold} gold in the bank !", FontType.Talk));
    }

    // ===================== Training =====================

    /// <summary>
    /// Open training with targeted NPC. VB6: HandleData "/TRAIN" -> NpcTrain (GameLogic.bas:3389).
    /// Trainer NPCs are npcType 62.
    /// </summary>
    private async Task HandleTrain(PlayerState player)
    {
        if (player.IsDead)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You are dead and cannot do that.", FontType.Info));
            return;
        }

        var npc = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npc == null)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Train with who ?", FontType.Info));
            return;
        }

        var template = _gameData.Npcs.FirstOrDefault(n => n.Id == npc.TemplateId);
        if (template == null || template.NpcType != 62)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("This NPC is not a trainer.", FontType.Info));
            return;
        }

        if (player.Character.TrainingPoints <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Come back when you have some training points.", FontType.Talk));
            return;
        }

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage("Sure. I guess i can teach ya a few tricks of the trade.", FontType.Talk));
        await SendStats(player.Character);
        await Clients.Caller.SendAsync("TrainOpen", player.Character.Skills);
    }

    /// <summary>
    /// Spend a training point to raise a skill. VB6: HandleData "T01"-"T28".
    /// </summary>
    public async Task TrainSkill(int skillIndex)
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null) return;

        var ch = player.Character;
        if (skillIndex < 1 || skillIndex > 28) return;
        if (ch.TrainingPoints <= 0) return;

        ch.Skills[skillIndex]++;
        ch.TrainingPoints--;
        CheckClass(ch);

        await SendStats(ch);
    }

    /// <summary>
    /// Player attack. VB6: HandleData "ATT" -> UserAttack.
    /// Server-authoritative: checks battle mode, cooldown, finds target from facing direction.
    /// </summary>
    public async Task Attack()
    {
        var player = _world.GetPlayer(Context.ConnectionId);
        if (player == null || player.IsDead) return;

        if (!player.BattleMode)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Go into battle mode first !", FontType.Talk));
            return;
        }

        // Server-authoritative cooldown (4000ms)
        var now = DateTime.UtcNow;
        if ((now - player.LastAttackTime).TotalMilliseconds < GameConstants.PlayerAttackInterval)
            return;
        player.LastAttackTime = now;

        // VB6: UserAttack — get the tile we're facing
        var (dx, dy) = ((Direction)player.Heading) switch
        {
            Direction.North => (0, -1),
            Direction.East => (1, 0),
            Direction.South => (0, 1),
            Direction.West => (-1, 0),
            _ => (0, 0)
        };
        int attackX = player.X + dx;
        int attackY = player.Y + dy;

        // Play swing sound to area (VB6: PLW SOUND_SWING)
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("PlaySound", new PlaySoundMessage(SoundId.Swing));

        // Bounds check
        if (attackX < 1 || attackX > GameConstants.MapWidth || attackY < 1 || attackY > GameConstants.MapHeight)
            return;

        // VB6: Look for player first, then NPC (UserAttack checks userindex before Npcindex)
        var targetPlayer = FindPlayerAt(player.Map, attackX, attackY);
        if (targetPlayer != null && targetPlayer.CharIndex != player.CharIndex)
        {
            await UserAttackUser(player, targetPlayer);
            return;
        }

        var npc = _world.GetNpcOnTile(player.Map, attackX, attackY);
        if (npc != null)
        {
            if (npc.Active)
            {
                var template = _gameData.Npcs.FirstOrDefault(n => n.Id == npc.TemplateId);
                if (template != null && template.Attackable == 1)
                {
                    await UserAttackNpc(player, npc);
                }
                else
                {
                    await Clients.Caller.SendAsync("Chat",
                        new ChatMessage("A mysterious force prevents you from attacking...", FontType.Fight));
                }
            }
            return;
        }
    }

    /// <summary>
    /// Player attacks NPC. VB6: UserAttackNPC (GameLogic.bas:1992).
    /// Faithful port of hit chance, damage, backstab, skill improvement, and NPC death.
    /// </summary>
    private async Task UserAttackNpc(PlayerState player, NpcState npc)
    {
        var ch = player.Character;

        // VB6: Swordmanship (Skill16) hit chance
        int swordSkill = ch.Skills[16];
        int hitChance; // 1 = hit, anything else = miss
        if (swordSkill > 50)
        {
            hitChance = 1; // always hit
        }
        else if (swordSkill <= 30)
        {
            hitChance = Random.Shared.Next(1, 4); // 1/3 chance (VB6: Luck2=3)
        }
        else
        {
            hitChance = Random.Shared.Next(1, 3); // 1/2 chance (VB6: Luck2=2)
        }

        // Track attacker and make NPC hostile
        npc.AttackedBy = player.CharIndex;

        bool wasNotHostile = !npc.Hostile;
        if (!npc.Hostile)
            npc.Hostile = true;

        bool wasNotChasing = npc.Movement == (int)NpcMovement.Stand || npc.Movement == (int)NpcMovement.RandomWalk;
        if (wasNotChasing)
            npc.Movement = (int)NpcMovement.HostileChase;

        // VB6: Make player criminal if attacking guards
        if (npc.Guard > 0 && ch.Criminal == 0)
        {
            ch.Criminal = 2;
            ch.CriminalCount += 60;
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Attacking guards art we !? Doust art now a criminal !", FontType.Info));
        }

        // Calculate damage
        int hit = Random.Shared.Next(ch.MinHit, ch.MaxHit + 1);
        hit -= npc.Def / 2;
        if (hit < 1) hit = 1;

        // Hit or miss
        if (hitChance != 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You miss !", FontType.Fight));
            return; // VB6 exits sub on miss, no skill improvement
        }

        // Backstab on first strike (VB6: Flags.Strike == 0)
        if (!player.HasStruck)
        {
            int backstabSkill = ch.Skills[22]; // Backstabbing
            int backstabChance = backstabSkill switch
            {
                <= 10 => 30,
                <= 20 => 25,
                <= 30 => 22,
                <= 40 => 20,
                <= 50 => 17,
                <= 60 => 15,
                <= 70 => 12,
                <= 80 => 10,
                <= 90 => 6,
                _ => 3
            };
            if (Random.Shared.Next(1, backstabChance + 1) == backstabChance)
            {
                npc.CurrentHp -= 8;
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You backstab {npc.Name} for 8 points of damage !", FontType.Info));
            }
            else
            {
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"You fail in backstabbing {npc.Name}", FontType.Info));
            }
            // Backstab skill improvement: 1/7 chance
            if (Random.Shared.Next(1, 8) == 5 && ch.Skills[22] > 9 &&
                ch.Level <= GameConstants.MaxLevel && SkillInfo.LevelCap[Math.Min(ch.Level, 50)] > ch.Skills[22])
            {
                ch.Skills[22]++;
                CheckClass(ch);
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"Your backstabbing skill has improved ({ch.Skills[22]}) !", FontType.SkillInfo));
            }
            player.HasStruck = true;
        }

        // Apply damage
        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"You strike the {npc.Name} for {hit} !", FontType.Fight));
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("PlaySound", new PlaySoundMessage(SoundId.SwordHit2));
        npc.CurrentHp -= hit;

        // Check NPC death
        if (npc.CurrentHp <= 0)
        {
            await NpcDie(player, npc, wasNotHostile, wasNotChasing);
        }

        // Skill improvement: 1/40 chance each (VB6: Raise = RandomNumber(1,40), if Raise == 6)
        await TryImproveSkill(ch, 6, "tactics");          // Skill6 = Tactics
        await TryImproveSkill(ch, 16, "swordmanship");    // Skill16 = Swordmanship
        if (ch.ShieldEqpSlot >= 0) // only if shield equipped
            await TryImproveSkill(ch, 17, "parrying");    // Skill17 = Parrying

        // Check level up and send updated stats
        await CheckUserLevel(player);
        await SendStats(ch);
    }

    /// <summary>
    /// Player attacks player. VB6: UserAttackUser (GameLogic.bas:2252).
    /// Faithful port of PvP combat: criminal flagging, duel mode, PK-free zones, hit/damage, death.
    /// </summary>
    private async Task UserAttackUser(PlayerState attacker, PlayerState victim)
    {
        var aCh = attacker.Character;
        var vCh = victim.Character;
        var attackerClient = Clients.Client(attacker.ConnectionId);
        var victimClient = Clients.Client(victim.ConnectionId);

        // VB6: Can't attack the dead
        if (victim.IsDead)
        {
            await attackerClient.SendAsync("Chat",
                new ChatMessage("You cannot attack the dead !", FontType.Info));
            return;
        }

        // VB6: PK-free zone check
        var map = _gameData.Maps.GetValueOrDefault(attacker.Map);
        if (map?.PkFreeZone == true)
        {
            if (!attacker.Duel || !victim.Duel)
            {
                await attackerClient.SendAsync("Chat",
                    new ChatMessage("This is a Player Killing free area. Both players must be in duel mode (/DUEL) to fight here !", FontType.Info));
                return;
            }
        }

        // VB6: Swordmanship (Skill16) hit chance — same brackets as NPC combat
        int swordSkill = aCh.Skills[(int)SkillType.Swordmanship];
        int hitChance;
        if (swordSkill <= 30)
            hitChance = Random.Shared.Next(1, 4); // 1/3 chance
        else if (swordSkill <= 50)
            hitChance = Random.Shared.Next(1, 3); // 1/2 chance
        else
            hitChance = 1; // always hit

        if (hitChance != 1)
        {
            await attackerClient.SendAsync("Chat",
                new ChatMessage("You miss !", FontType.Info));
            return;
        }

        // VB6: Attacking an innocent makes you a criminal
        if (vCh.Criminal == 0 && !victim.Duel && aCh.Criminal == 0)
        {
            await attackerClient.SendAsync("Chat",
                new ChatMessage("You are attacking a innocent ! You criminal !", FontType.Info));
            await victimClient.SendAsync("Chat",
                new ChatMessage("Someone attacked you ! Your attacker is now a criminal !", FontType.Info));
            aCh.Criminal = 2;
            aCh.CriminalCount += 45;
            // Broadcast updated appearance (red name)
            var (cw, cs) = GetEquipAnims(aCh);
            await Clients.Group(MapGroup(attacker.Map))
                .SendAsync("ChangeChar", new MakeCharMessage(
                    attacker.CharIndex, aCh.Name, aCh.Body, aCh.Head,
                    attacker.Heading, attacker.X, attacker.Y, cw, cs, true));
        }

        // VB6: Hit = random(MinHIT, MaxHIT) - DEF/2, min 1
        int hit = Random.Shared.Next(aCh.MinHit, aCh.MaxHit + 1) - (vCh.Def / 2);
        if (hit < 1) hit = 1;

        attacker.Character.CurrentSta -= 1;

        // VB6: Random body part (flavor text only)
        string spotString = Random.Shared.Next(1, 5) switch
        {
            1 => " in the head !",
            2 => " on the legs !",
            3 => " on the hands !",
            _ => " on the chest !"
        };

        await attackerClient.SendAsync("Chat",
            new ChatMessage($"You strike {vCh.Name} for {hit}{spotString}", FontType.Fight));
        await victimClient.SendAsync("Chat",
            new ChatMessage($"{aCh.Name} hits you for {hit}{spotString}", FontType.Fight));

        vCh.CurrentHp -= hit;

        // VB6: Sound effects
        await Clients.Group(MapGroup(attacker.Map))
            .SendAsync("PlaySound", new PlaySoundMessage(SoundId.SwordHit2));
        int hurtSound = vCh.Gender == "Female" ? SoundId.FemaleScream : SoundId.MaleHurt;
        await Clients.Group(MapGroup(victim.Map))
            .SendAsync("PlaySound", new PlaySoundMessage(hurtSound));

        // VB6: Backstab on first strike
        if (!attacker.HasStruck)
        {
            await BackstabPC(attacker, victim);
            attacker.HasStruck = true;
        }

        // VB6: Player death
        if (vCh.CurrentHp <= 0)
        {
            attacker.TargetNpcIndex = 0;
            attacker.TargetPlayerCharIndex = 0;

            await Clients.Group(MapGroup(attacker.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(SoundId.MaleHurt2));

            // VB6: EXP = victim level * 20
            int expGain = vCh.Level * 20;
            aCh.Exp += expGain;
            await attackerClient.SendAsync("Chat",
                new ChatMessage($"You have gained {expGain} experience !", FontType.Info));
            await Clients.Group(MapGroup(attacker.Map)).SendAsync("Chat",
                new ChatMessage($"{vCh.Name} has been slain by {aCh.Name} !", FontType.Talk));

            attacker.HasStruck = false;

            // VB6: Reputation effects of PvP kill
            if (vCh.Criminal == 0 && !victim.Duel)
            {
                // Murdered an innocent
                aCh.CriminalCount += 30;
                aCh.CommonRep -= 5;
                aCh.NobleRep -= 5;
                aCh.OverallRep -= 20;
                aCh.UnderRep += 3;
                aCh.BendarrRep += 3;
                aCh.Criminal = 2;
                await attackerClient.SendAsync("Chat",
                    new ChatMessage("You gain reputation with Bendarr and the underworld ! You also lose some reputation with the Nobles and the common people.", FontType.Info));
            }
            else
            {
                // Killed a criminal or duel opponent
                aCh.OverallRep += 2;
                aCh.CommonRep += 2;
                await attackerClient.SendAsync("Chat",
                    new ChatMessage("You gain some reputation with common people !", FontType.Info));
            }

            // Kill the victim (VB6: UserDie)
            await _gameLoopService.UserDieFromHub(victim);
        }

        // VB6: Skill improvement 1/40 chance
        await TryImproveSkill(aCh, (int)SkillType.Tactics, "tactics");
        await TryImproveSkill(aCh, (int)SkillType.Swordmanship, "swordmanship");
        if (aCh.Skills[(int)SkillType.Parrying] > 0)
            await TryImproveSkill(aCh, (int)SkillType.Parrying, "parrying");

        await CheckUserLevel(attacker);
        await SendStats(aCh);
        await CheckUserLevel(victim);
        await Clients.Client(victim.ConnectionId).SendAsync("Stats", new StatsMessage(
            vCh.CurrentHp, vCh.MaxHp, vCh.CurrentMan, vCh.MaxMan,
            vCh.CurrentSta, vCh.MaxSta, vCh.Gold, vCh.Exp, vCh.Elu,
            vCh.Food, vCh.Drink, vCh.MinHit, vCh.MaxHit, vCh.Def,
            vCh.TrainingPoints, vCh.Class, vCh.RepRank, vCh.Skills,
            vCh.Criminal, vCh.CriminalCount));
        CheckRep(aCh);
    }

    /// <summary>
    /// Backstab on first PvP strike. VB6: BackstabPC (GameLogic.bas:5260).
    /// Skill22 (backstabbing) determines chance. Flat 5 bonus damage on success.
    /// </summary>
    private async Task BackstabPC(PlayerState attacker, PlayerState victim)
    {
        int skill = attacker.Character.Skills[(int)SkillType.Backstabbing];
        int luck2 = skill switch
        {
            <= 10 => 50, <= 20 => 45, <= 30 => 40, <= 40 => 35, <= 50 => 30,
            <= 60 => 25, <= 70 => 20, <= 80 => 15, <= 90 => 10, _ => 3
        };

        if (Random.Shared.Next(1, luck2 + 1) == luck2)
        {
            await Clients.Client(attacker.ConnectionId).SendAsync("Chat",
                new ChatMessage("You successfully backstabbed your victim !", FontType.Fight));
            await Clients.Client(victim.ConnectionId).SendAsync("Chat",
                new ChatMessage("You were backstabbed !", FontType.Fight));
            victim.Character.CurrentHp -= 5;
        }

        // VB6: 1/15 chance to raise backstabbing skill
        var ch = attacker.Character;
        int bsCap = ch.Level >= 1 && ch.Level <= 50 ? SkillInfo.LevelCap[ch.Level] : 100;
        if (Random.Shared.Next(1, 16) == 5 && ch.Skills[(int)SkillType.Backstabbing] > 9 &&
            bsCap > ch.Skills[(int)SkillType.Backstabbing])
        {
            ch.Skills[(int)SkillType.Backstabbing]++;
            await Clients.Client(attacker.ConnectionId).SendAsync("Chat",
                new ChatMessage($"Your backstabbing skill has improved ({ch.Skills[(int)SkillType.Backstabbing]}) !", FontType.SkillInfo));
            CheckClass(ch);
        }
    }

    /// <summary>
    /// Calculate reputation rank title from overall rep. VB6: CheckRep (GameLogic.bas:5456).
    /// </summary>
    private static void CheckRep(CharacterData ch)
    {
        ch.RepRank = ch.OverallRep switch
        {
            > 1500 => ch.Gender == "Female" ? "The High Madam" : "The High Sir",
            > 1000 => ch.Gender == "Female" ? "The Great Lady" : "The Great Lord",
            > 900  => ch.Gender == "Female" ? "The Lady" : "The Lord",
            > 800  => "The Fameous",
            > 700  => "The Honorable",
            > 600  => "The Respectable",
            > 499  => "",
            < 0    => ch.Gender == "Female" ? "The Dreaded Lady" : "The Dreaded Lord",
            < 100  => ch.Gender == "Female" ? "The Dark Lady" : "The Dark Lord",
            < 200  => "The Hated",
            < 300  => "The Scum",
            < 400  => "The Disrespected",
            _      => ch.RepRank
        };
    }

    /// <summary>
    /// Toggle duel mode. VB6: Duel (GameLogic.bas:3617). /DUEL command.
    /// </summary>
    private async Task HandleDuel(PlayerState player)
    {
        player.Duel = !player.Duel;
        if (player.Duel)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You go into duelling mode. Any player over level 5 can kill you now and vice versa.", FontType.Info));
            await Clients.Group(MapGroup(player.Map)).SendAsync("Chat",
                new ChatMessage($"{player.Character.Name} goes into duel !", FontType.Info));
        }
        else
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You have left duel mode.", FontType.Info));
            await Clients.Group(MapGroup(player.Map)).SendAsync("Chat",
                new ChatMessage($"{player.Character.Name} has ended duel.", FontType.Info));
        }
    }

    /// <summary>
    /// Drop gold on the ground. VB6: DropGold (GameLogic.bas:5244). Object 193 = gold pile.
    /// </summary>
    private async Task HandleDropGold(PlayerState player, string amountStr)
    {
        if (!long.TryParse(amountStr, out var amount) || amount <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Usage: /DROPGOLD amount", FontType.Info));
            return;
        }
        var ch = player.Character;
        if (amount > ch.Gold) amount = ch.Gold;
        if (amount <= 0) return;

        ch.Gold -= (int)amount;
        // VB6: object 193 = gold pile
        var goldObj = _gameData.Objects.FirstOrDefault(o => o.Id == 193);
        if (goldObj != null)
        {
            _world.PlaceGroundItem(player.Map, player.X, player.Y, 193, (int)amount);
            await Clients.Group(MapGroup(player.Map)).SendAsync("MakeObj",
                new MakeObjMessage(goldObj.GrhIndex, player.X, player.Y));
        }
        await SendStats(ch);
    }

    /// <summary>
    /// VB6: 1/40 chance to raise a combat skill per swing. Checks skill >= 10 and level cap.
    /// </summary>
    private async Task TryImproveSkill(CharacterData ch, int skillIndex, string skillName)
    {
        if (Random.Shared.Next(1, 41) != 6) return;
        if (ch.Skills[skillIndex] <= 9) return;
        if (ch.Level > GameConstants.MaxLevel) return;
        int cap = SkillInfo.LevelCap[Math.Min(ch.Level, 50)];
        if (ch.Skills[skillIndex] >= cap) return;

        ch.Skills[skillIndex]++;
        CheckClass(ch);
        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"Your {skillName} skill has improved ({ch.Skills[skillIndex]}) !", FontType.SkillInfo));
    }

    /// <summary>
    /// NPC death. VB6: NPCDie (GameLogic.bas:217).
    /// Places corpse + loot, gives rewards, respawns NPC at random position.
    /// </summary>
    private async Task NpcDie(PlayerState killer, NpcState npc, bool wasNotHostile, bool wasNotChasing)
    {
        var ch = killer.Character;
        int map = npc.Map;

        // Announce kill
        await Clients.Group(MapGroup(map)).SendAsync("Chat",
            new ChatMessage($"{ch.Name} has slain {npc.Name} !", FontType.Info));

        // Play death sound
        if (npc.Sound > 0)
            await Clients.Group(MapGroup(map)).SendAsync("PlaySound", new PlaySoundMessage(npc.Sound));

        // Reset player combat state
        killer.HasStruck = false;
        killer.TargetNpcIndex = 0;

        // Give EXP
        ch.Exp += npc.GiveExp;

        // Give gold
        ch.Gold += (int)npc.GiveGold;
        if (npc.GiveGold > 0)
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"You found {npc.GiveGold} gold on the corpse !", FontType.Info));

        // Reputation (VB6: guard kill vs monster kill)
        if (npc.Guard > 0)
        {
            ch.Criminal = 2;
            ch.CriminalCount += 30;
            ch.NobleRep -= 5;
            // ch.BendarrRep += 2; // TODO: per-deity rep not yet on CharacterData
            ch.OverallRep -= 5;
            ch.UnderRep += 3;
            ch.CommonRep -= 3;
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("Killing a guard ?! You are now a criminal !", FontType.Info));
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You lose some reputation with the Nobles and the common people. You gain reputation with Bendarr and the underworld !", FontType.Info));
        }
        else
        {
            ch.CommonRep++;
            ch.NobleRep++;
            ch.OverallRep++;
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You gain reputation with the Nobles and the common people !", FontType.Info));
        }

        // Place corpse at NPC's death position
        if (npc.DeathObj > 0)
        {
            var corpseObj = _gameData.Objects.FirstOrDefault(o => o.Id == npc.DeathObj);
            if (corpseObj != null && _world.PlaceGroundItem(map, npc.X, npc.Y, npc.DeathObj, 1))
            {
                await Clients.Group(MapGroup(map)).SendAsync("MakeObj",
                    new MakeObjMessage(corpseObj.GrhIndex, npc.X, npc.Y));
            }
        }

        // Loot roll (VB6: LOOT = RandomNumber(1, LootChance), if LOOT > 1 → no loot)
        int lootRoll = Random.Shared.Next(1, npc.LootChance + 1);
        if (lootRoll == 1 && npc.Inventory.Length > 0)
        {
            // Place up to 4 inventory items in adjacent tiles
            var offsets = new (int dx, int dy)[] { (-1, 0), (1, 0), (0, 1), (0, -1) };
            for (int i = 0; i < Math.Min(npc.Inventory.Length, 4); i++)
            {
                var inv = npc.Inventory[i];
                if (inv.ObjIndex <= 0) continue;
                int lx = npc.X + offsets[i].dx;
                int ly = npc.Y + offsets[i].dy;
                if (!_world.IsNpcLegalPos(map, lx, ly))
                    continue;
                var lootObj = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
                if (lootObj != null && _world.PlaceGroundItem(map, lx, ly, inv.ObjIndex, 1))
                {
                    await Clients.Group(MapGroup(map)).SendAsync("MakeObj",
                        new MakeObjMessage(lootObj.GrhIndex, lx, ly));
                }
            }
        }
        else if (lootRoll > 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You recover no loot from the corpse.", FontType.Info));
        }

        // Erase NPC from old position
        await Clients.Group(MapGroup(map)).SendAsync("EraseChar", new EraseCharMessage(npc.CharIndex));

        // Reset NPC stats for respawn
        npc.CurrentHp = npc.MaxHp;
        npc.Target = 0;
        npc.AttackedBy = 0;
        if (wasNotHostile) npc.Hostile = npc.OriginalHostile;
        if (wasNotChasing) npc.Movement = npc.OriginalMovement;

        // Respawn at random legal position on same map (VB6: Looper goto)
        int newX, newY;
        int attempts = 0;
        do
        {
            newX = Random.Shared.Next(1, GameConstants.MapWidth + 1);
            newY = Random.Shared.Next(1, GameConstants.MapHeight + 1);
            attempts++;
        } while (!_world.IsNpcLegalPos(map, newX, newY) && attempts < 500);

        _world.WarpNpc(npc, map, newX, newY);

        // Broadcast new NPC position to all players on map
        await Clients.Group(MapGroup(map)).SendAsync("MakeChar", new MakeCharMessage(
            npc.CharIndex, npc.Name, npc.Body, npc.Head, npc.Heading,
            newX, newY, npc.WeaponAnim, npc.ShieldAnim));
    }

    /// <summary>
    /// Check if player leveled up. VB6: CheckUserLevel (GameLogic.bas:86).
    /// </summary>
    private async Task CheckUserLevel(PlayerState player)
    {
        var ch = player.Character;

        if (ch.Level >= GameConstants.MaxLevel)
        {
            ch.Exp = 0;
            ch.Elu = 0;
            return;
        }

        if (ch.Exp < ch.Elu) return;

        // Level up!
        ch.Level++;
        ch.Exp = 0;

        // VB6: ELU scaling by level bracket
        double multiplier = ch.Level switch
        {
            < 5 => 2.0,
            < 10 => 1.9,
            < 15 => 1.8,
            < 20 => 1.7,
            < 25 => 1.6,
            < 30 => 1.5,
            _ => 1.4
        };
        ch.Elu = (int)(ch.Elu * multiplier);

        // Stat boosts
        ch.MaxHp++;
        ch.MaxSta += 2;
        ch.MaxMan += 15;
        ch.MaxHit++;
        ch.MinHit++;

        // Training points
        ch.TrainingPoints += 5;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage("You gained 5 training points, and your attributes has gone up !", FontType.Info));
        await Clients.Caller.SendAsync("PlaySound", new PlaySoundMessage(SoundId.SpellEffect1));
        await Clients.Caller.SendAsync("PlayVoice", new PlayVoiceMessage(11));

        await SendStats(ch);
    }

    /// <summary>
    /// Handle /RESSURECT command. VB6: NpcRessurect (GameLogic.bas:3279).
    /// Player must be dead and have targeted a Priest of Life (npcType 61) or Healer (npcType 5).
    /// </summary>
    private async Task HandleResurrect(PlayerState player)
    {
        if (!player.IsDead)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("ARE DOUST PLAYING TRICKS ON ME ? YOU ARE NOT DEAD !", FontType.Talk));
            return;
        }

        // Check if player has targeted a Priest of Life or Healer
        // VB6: Checks NPCtarget (npcType) against Case 61 (Priest of Life) or Case 5 (Healer)
        var targetNpc = _world.GetNpcByIndex(player.TargetNpcIndex);
        var targetTemplate = targetNpc != null
            ? _gameData.Npcs.FirstOrDefault(n => n.Id == targetNpc.TemplateId)
            : null;
        if (targetTemplate == null || (targetTemplate.NpcType != 61 && targetTemplate.NpcType != 5))
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You need to target a Priest of Life first (left-click on one, then type /RESSURECT).", FontType.Info));
            return;
        }

        // Check that the targeted NPC is actually nearby (within 2 tiles)
        if (targetNpc!.Map != player.Map ||
            Math.Abs(targetNpc.X - player.X) > 2 || Math.Abs(targetNpc.Y - player.Y) > 2)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You need to be near a Priest of Life.", FontType.Info));
            return;
        }

        // Resurrect!
        var ch = player.Character;
        player.IsDead = false;

        // Restore original appearance
        ch.Body = player.OriginalBody;
        ch.Head = player.OriginalHead;

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage("The priest of life says, You are ressurected. Welcome to the side of the living.", FontType.Talk));

        // Play chorus sound
        await Clients.Group(MapGroup(player.Map))
            .SendAsync("PlaySound", new PlaySoundMessage(SoundId.Chorus));

        // Tell client death is over
        await Clients.Caller.SendAsync("Death", false);

        // Broadcast restored appearance
        var (pw, ps) = GetEquipAnims(ch);
        await Clients.Group(MapGroup(player.Map)).SendAsync("MakeChar",
            new MakeCharMessage(player.CharIndex, ch.Name, ch.Body, ch.Head,
                player.Heading, player.X, player.Y, pw, ps, ch.Criminal > 0));

        await SendStats(ch);
        await SendFullInventory(ch);
    }

    // ===================== NPC Hailing & Gossip =====================

    /// <summary>
    /// Hail a targeted NPC to hear their dialogue.
    /// VB6: HandleData "/HAIL" (TCP.bas:1883). Reads NPCList(NPC).Hail.
    /// </summary>
    private async Task HandleHail(PlayerState player)
    {
        // VB6: Must have an NPC targeted
        if (player.TargetNpcIndex <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You need to target an NPC first.", FontType.Info));
            return;
        }

        var npcInstance = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npcInstance == null) return;

        var npcDef = _gameData.Npcs.FirstOrDefault(n => n.Id == npcInstance.TemplateId);
        if (npcDef == null) return;

        // VB6: Tameable NPCs can't talk
        if (npcDef.Tameable == 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("I dont think your target would be very talkative.", FontType.Info));
            return;
        }

        // VB6: Send hail text (may be empty for most NPCs)
        var hail = npcDef.Hail;
        if (string.IsNullOrEmpty(hail))
            hail = " I have nothing to say to you.";

        await Clients.Caller.SendAsync("Chat",
            new ChatMessage($"{npcDef.Name} says,{hail}", FontType.Talk));
    }

    /// <summary>
    /// Ask a targeted NPC for gossip. Streetwise skill (Skill26) determines success chance.
    /// VB6: HandleData "/GOSSIP" and "/NEWS" -> Gossip (GameLogic.bas:5691).
    /// </summary>
    private async Task HandleGossip(PlayerState player)
    {
        var ch = player.Character;

        // VB6: Must have an NPC targeted
        if (player.TargetNpcIndex <= 0)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("You must target a NPC before asking for gossip !", FontType.Talk));
            return;
        }

        var npcInstance = _world.GetNpcByIndex(player.TargetNpcIndex);
        if (npcInstance == null) return;

        var npcDef = _gameData.Npcs.FirstOrDefault(n => n.Id == npcInstance.TemplateId);
        if (npcDef == null) return;

        // VB6: Tameable NPCs don't gossip
        if (npcDef.Tameable == 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("I do not think your creature is very much into the gossip of Menath.", FontType.Talk));
            return;
        }

        // VB6: Tradeable=1 means NPC can't trade (inverted naming), and also can't gossip
        if (npcDef.Tradeable == 1)
        {
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage("I doubt the there is gossip to get here.", FontType.Talk));
            return;
        }

        // VB6: Streetwise skill determines gossip chance
        // Higher skill = better odds (luck2 decreases = random(1, luck2) more likely to match)
        int streetwise = ch.Skills[(int)SkillType.Streetwise];
        int luck2;
        if (streetwise >= 90) luck2 = 1;
        else if (streetwise >= 80) luck2 = 2;
        else if (streetwise >= 70) luck2 = 5;
        else if (streetwise >= 60) luck2 = 6;
        else if (streetwise >= 50) luck2 = 7;
        else if (streetwise >= 40) luck2 = 10;
        else if (streetwise >= 30) luck2 = 15;
        else if (streetwise >= 20) luck2 = 25;
        else if (streetwise >= 10) luck2 = 30;
        else luck2 = 999999; // effectively impossible at very low skill

        var rng = Random.Shared;
        int roll = rng.Next(1, luck2 + 1);

        if (roll == luck2 && _gameData.Gossip.Count > 0)
        {
            // Tell gossip
            var gossip = _gameData.Gossip[rng.Next(_gameData.Gossip.Count)];
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npcDef.Name} tells you, {gossip.Text}", FontType.Info));
        }
        else
        {
            // Refuse
            await Clients.Caller.SendAsync("Chat",
                new ChatMessage($"{npcDef.Name} says, I try not to spread any rumors.", FontType.Info));
        }

        // VB6: 1/10 chance to raise Streetwise skill
        await TryImproveSkill(player, (int)SkillType.Streetwise, 10);
        await CheckUserLevel(player);
        await SendStats(ch);
    }

    // --- Helpers ---

    private static string MapGroup(int mapId) => $"map:{mapId}";

    /// <summary>Resolve weapon/shield anim indices from a character's equipped items.</summary>
    private (int weaponAnim, int shieldAnim) GetEquipAnims(CharacterData ch)
    {
        int weaponAnim = 2, shieldAnim = 2; // 2 = no visible weapon/shield
        if (ch.WeaponEqpSlot >= 0 && ch.WeaponEqpSlot < 20)
        {
            var obj = _gameData.Objects.FirstOrDefault(o => o.Id == ch.Inventory[ch.WeaponEqpSlot].ObjIndex);
            if (obj != null && obj.WeaponAnim > 0) weaponAnim = obj.WeaponAnim;
        }
        if (ch.ShieldEqpSlot >= 0 && ch.ShieldEqpSlot < 20)
        {
            var obj = _gameData.Objects.FirstOrDefault(o => o.Id == ch.Inventory[ch.ShieldEqpSlot].ObjIndex);
            if (obj != null && obj.ShieldAnim > 0) shieldAnim = obj.ShieldAnim;
        }
        return (weaponAnim, shieldAnim);
    }

    /// <summary>VB6: UpdateUserInv(True) — send all 20 inventory slots</summary>
    private async Task SendFullInventory(CharacterData ch)
    {
        for (int i = 0; i < 20; i++)
            await SendInvSlot(ch, i);
    }

    /// <summary>VB6: ChangeUserInv — send one inventory slot update (SIS message)</summary>
    private async Task SendInvSlot(CharacterData ch, int slot)
    {
        var inv = ch.Inventory[slot];
        if (inv.ObjIndex > 0)
        {
            var obj = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
            await Clients.Caller.SendAsync("InventorySlot", new InventorySlotMessage(
                slot, inv.ObjIndex, obj?.Name ?? "(Unknown)", inv.Amount,
                inv.Equipped, obj?.GrhIndex ?? 0, int.TryParse(obj?.Value, out var v) ? v : 0));
        }
        else
        {
            await Clients.Caller.SendAsync("InventorySlot", new InventorySlotMessage(
                slot, 0, "(None)", 0, false, 0, 0));
        }
    }

    /// <summary>Send all ground items on a map to the caller.</summary>
    private async Task SendGroundItems(int map)
    {
        foreach (var (x, y, item) in _world.GetAllGroundItems(map))
        {
            var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == item.ObjIndex);
            if (objDef != null)
                await Clients.Caller.SendAsync("MakeObj", new MakeObjMessage(objDef.GrhIndex, x, y));
        }
    }

    /// <summary>VB6: SendUserStatsBox (GameLogic.bas) — send SST with all stats</summary>
    private async Task SendStats(CharacterData c)
    {
        await Clients.Caller.SendAsync("Stats", new StatsMessage(
            c.CurrentHp, c.MaxHp,
            c.CurrentMan, c.MaxMan,
            c.CurrentSta, c.MaxSta,
            c.Gold,
            c.Exp, c.Elu,
            c.Food, c.Drink,
            c.MinHit, c.MaxHit,
            c.Def,
            c.TrainingPoints,
            c.Class,
            c.RepRank,
            c.Skills,
            c.Criminal,
            c.CriminalCount));
    }

    /// <summary>
    /// Send zone music for a map. VB6: SendData(ToIndex, "PLM" & MapInfo(map).Music)
    /// Music field is like "24-1" (music number 24, loop flag 1).
    /// </summary>
    private async Task SendMapMusic(int mapId)
    {
        if (!_gameData.Maps.TryGetValue(mapId, out var mapDef)) return;
        var musicStr = mapDef.Music;
        if (string.IsNullOrEmpty(musicStr)) return;

        // Parse "24-1" format: number-loopflag (VB6: ReadField with delimiter "-")
        var parts = musicStr.Split('-');
        if (parts.Length >= 1 && int.TryParse(parts[0], out var musicNum) && musicNum > 0)
        {
            var loop = parts.Length < 2 || parts[1] != "0"; // default to loop
            await Clients.Caller.SendAsync("PlayMusic", new PlayMusicMessage(musicNum, loop));
        }
    }

    private (int x, int y) FindNearbyLegalPos(int map, int x, int y)
    {
        // Try the exact position first
        if (!_world.IsTileBlocked(map, x, y))
            return (x, y);

        // Spiral outward to find a free tile (VB6: ClosestLegalPos)
        for (int radius = 1; radius <= 5; radius++)
        {
            for (int dy = -radius; dy <= radius; dy++)
            {
                for (int dx = -radius; dx <= radius; dx++)
                {
                    if (Math.Abs(dx) != radius && Math.Abs(dy) != radius) continue;
                    if (!_world.IsTileBlocked(map, x + dx, y + dy))
                        return (x + dx, y + dy);
                }
            }
        }

        return (x, y); // give up, use the original position
    }

    /// <summary>Validate a specialized skill name against the canonical list.</summary>
    private static string ValidateSpecSkill(string? skillName)
    {
        if (string.IsNullOrWhiteSpace(skillName)) return "";
        for (int i = 1; i <= SkillInfo.SkillCount; i++)
        {
            if (string.Equals(SkillInfo.Names[i], skillName, StringComparison.OrdinalIgnoreCase))
                return SkillInfo.Names[i]; // return canonical spelling
        }
        return "";
    }
}

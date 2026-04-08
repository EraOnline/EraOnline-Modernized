using Microsoft.AspNetCore.SignalR;
using EraOnline.Server.Services;
using EraOnline.Shared.Constants;
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
    private readonly ILogger<GameHub> _logger;

    public GameHub(GameDataService gameData, WorldState world, ChatLogger chatLog, ILogger<GameHub> logger)
    {
        _gameData = gameData;
        _world = world;
        _chatLog = chatLog;
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
                other.Heading, other.X, other.Y, ow, os));
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
                (int)Direction.South, x, y, pw, ps));

        // Welcome messages
        await Clients.Caller.SendAsync("Chat", new ChatMessage(
            $"Welcome to Era Online, {character.Name}!", FontType.Info));

        // VB6: SendUserStatsBox — send full stats on login
        await SendStats(character);

        // VB6: UpdateUserInv(True) — send full inventory on login
        await SendFullInventory(character);

        // VB6: SendData(ToIndex, "PLM" & MapInfo(map).Music) — play zone music
        await SendMapMusic(map);

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
            player.TargetNpcIndex = foundNpc.Value.npcTemplateId;
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

    /// <summary>Find an NPC at a specific tile position on a map (from spawn data).</summary>
    private (string name, int npcTemplateId)? FindNpcAt(int map, int x, int y)
    {
        // Check live NPC instances at this tile
        var npc = _world.GetNpcOnTile(map, x, y);
        if (npc != null)
            return (npc.Name, npc.TemplateId);
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
                player.Heading, player.X, player.Y, weaponAnim, shieldAnim));
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
                other.Heading, other.X, other.Y, ow, os));
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
                player.Heading, newX, newY, ww, ws));

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

            case "/HELP":
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage("Commands: /WHO /PLAYERS /STATS /DESC /SAVE /QUIT /HELP", FontType.Info));
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

        // VB6: Look for player first, then NPC
        // Player vs Player: defer to later
        // For now, look for NPC
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
            c.Skills));
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

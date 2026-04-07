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
    private readonly ILogger<GameHub> _logger;

    public GameHub(GameDataService gameData, WorldState world, ILogger<GameHub> logger)
    {
        _gameData = gameData;
        _world = world;
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

        // Create character data (VB6: ConnectNewUser initial values)
        var head = WorldState.RandomHead(race, gender);
        var body = 1; // default body

        var character = new CharacterData
        {
            Name = name,
            PasswordHash = WorldState.HashPassword(request.Password),
            Race = race,
            Gender = gender,
            Body = body,
            Head = head
        };

        // Save to disk
        await _world.SaveCharacter(character);

        _logger.LogInformation("New character created: {Name} ({Race} {Gender})", name, race, gender);

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
            await Clients.Caller.SendAsync("MakeChar", new MakeCharMessage(
                other.CharIndex, other.Character.Name, other.Character.Body, other.Character.Head,
                other.Heading, other.X, other.Y, 2, 2));
        }

        // Send NPC spawn positions
        if (_gameData.Maps.TryGetValue(map, out var mapDef))
        {
            foreach (var spawn in mapDef.NpcSpawns)
            {
                var npcTemplate = _gameData.Npcs.FirstOrDefault(n => n.Id == spawn[2]);
                if (npcTemplate != null)
                {
                    // Use negative char indices for NPCs to distinguish from players
                    await Clients.Caller.SendAsync("MakeChar", new MakeCharMessage(
                        -(spawn[2] * 1000 + spawn[0]), // unique NPC char index
                        npcTemplate.Name,
                        npcTemplate.Body > 0 ? npcTemplate.Body : 1,
                        npcTemplate.Head > 0 ? npcTemplate.Head : 1,
                        npcTemplate.Heading > 0 ? npcTemplate.Heading : (int)Direction.South,
                        spawn[0], spawn[1], 2, 2));
                }
            }
        }

        // Broadcast the new player to everyone else on the map
        await Clients.OthersInGroup(MapGroup(map))
            .SendAsync("MakeChar", new MakeCharMessage(
                charIndex, character.Name, character.Body, character.Head,
                (int)Direction.South, x, y, 2, 2));

        // Welcome messages
        await Clients.Caller.SendAsync("Chat", new ChatMessage(
            $"Welcome to Era Online, {character.Name}!", FontType.Info));
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
                await Clients.Caller.SendAsync("Chat",
                    new ChatMessage($"{player.Character.Name} — {player.Character.Race} {player.Character.Gender} — Map {player.Map} ({player.X},{player.Y})", FontType.Info));
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

    // --- Helpers ---

    private static string MapGroup(int mapId) => $"map:{mapId}";

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
}

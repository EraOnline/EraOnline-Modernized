using System.Text.Json;
using Microsoft.AspNetCore.SignalR.Client;
using EraOnline.Shared.Constants;
using EraOnline.Shared.Protocol;

namespace EraOnline.Client.CLI.Session;

/// <summary>
/// Manages the SignalR connection to the server and dispatches events to GameState.
/// Runs as a daemon process, accepting commands via IPC.
/// </summary>
public class GameSession : IAsyncDisposable
{
    private readonly string _serverUrl;
    private readonly string _characterName;
    private readonly string _password;
    private HubConnection? _connection;
    private readonly GameState _state = new();
    private readonly JsonSerializerOptions _jsonOptions = new() { PropertyNameCaseInsensitive = true };

    // Map name lookup (loaded from map data files)
    private readonly Dictionary<int, string> _mapNames = new();

    public GameState State => _state;
    public bool IsConnected => _connection?.State == HubConnectionState.Connected;

    public GameSession(string serverUrl, string characterName, string password, string? dataPath = null)
    {
        _serverUrl = serverUrl.TrimEnd('/');
        _characterName = characterName;
        _password = password;
        _state.CharacterName = characterName;

        // Load map names from data files if available
        LoadMapNames(dataPath);
    }

    private void LoadMapNames(string? dataPath)
    {
        if (dataPath == null) return;
        var mapsDir = Path.Combine(dataPath, "maps");
        if (!Directory.Exists(mapsDir)) return;

        foreach (var file in Directory.GetFiles(mapsDir, "map-*.json"))
        {
            try
            {
                var json = File.ReadAllText(file);
                using var doc = JsonDocument.Parse(json);
                if (doc.RootElement.TryGetProperty("name", out var nameProp) &&
                    doc.RootElement.TryGetProperty("mapId", out var idProp))
                {
                    var name = nameProp.GetString() ?? "";
                    var id = idProp.GetInt32();
                    if (!string.IsNullOrEmpty(name))
                        _mapNames[id] = name;
                }
            }
            catch { /* skip malformed files */ }
        }
    }

    public async Task<bool> ConnectAndLogin()
    {
        var hubUrl = $"{_serverUrl}/gamehub";

        _connection = new HubConnectionBuilder()
            .WithUrl(hubUrl)
            .WithAutomaticReconnect()
            .Build();

        // Register all event handlers
        RegisterHandlers();

        // Connect
        try
        {
            await _connection.StartAsync();
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"Failed to connect to {hubUrl}: {ex.Message}");
            return false;
        }

        // Login
        try
        {
            var response = await _connection.InvokeAsync<LoginResponse>("Login",
                new LoginRequest(_characterName, _password));

            if (!response.Success)
            {
                Console.Error.WriteLine($"Login failed: {response.ErrorMessage}");
                await _connection.StopAsync();
                return false;
            }
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"Login error: {ex.Message}");
            await _connection.StopAsync();
            return false;
        }

        return true;
    }

    private void RegisterHandlers()
    {
        if (_connection == null) return;

        _connection.On<SetCharIndexMessage>("SetCharIndex", msg =>
        {
            _state.SetCharIndex(msg.CharIndex);
        });

        _connection.On<MapLoadMessage>("MapLoad", msg =>
        {
            var mapName = _mapNames.GetValueOrDefault(msg.MapId, $"Map {msg.MapId}");
            _state.OnMapLoad(msg.MapId, mapName);
        });

        _connection.On<MakeCharMessage>("MakeChar", msg =>
        {
            _state.OnMakeChar(msg);
        });

        _connection.On<EraseCharMessage>("EraseChar", msg =>
        {
            _state.OnEraseChar(msg.CharIndex);
        });

        _connection.On<MoveCharMessage>("MoveChar", msg =>
        {
            _state.OnMoveChar(msg);
        });

        _connection.On<MakeCharMessage>("ChangeChar", msg =>
        {
            _state.OnChangeChar(msg);
        });

        _connection.On<SetPositionMessage>("SetPosition", msg =>
        {
            _state.SetPosition(msg.X, msg.Y);
        });

        _connection.On<ChatMessage>("Chat", msg =>
        {
            _state.OnChat(msg);
        });

        _connection.On<StatsMessage>("Stats", msg =>
        {
            _state.OnStats(msg);
        });

        _connection.On<TargetMessage>("Target", msg =>
        {
            _state.OnTarget(msg.Text);
        });

        _connection.On<InventorySlotMessage>("InventorySlot", msg =>
        {
            _state.OnInventorySlot(msg);
        });

        _connection.On<SpellSlotMessage>("SpellSlot", msg =>
        {
            _state.OnSpellSlot(msg);
        });

        _connection.On<MakeObjMessage>("MakeObj", msg =>
        {
            _state.OnMakeObj(msg);
        });

        _connection.On<EraseObjMessage>("EraseObj", msg =>
        {
            _state.OnEraseObj(msg);
        });

        _connection.On<bool>("Death", isDead =>
        {
            _state.OnDeath(isDead);
        });

        _connection.On<bool>("Weather", raining =>
        {
            _state.OnWeather(raining);
        });

        _connection.On<MeditateMessage>("Meditate", msg =>
        {
            _state.OnMeditate(msg.Meditating);
        });

        // Audio events — log but don't play
        _connection.On<PlayMusicMessage>("PlayMusic", msg => { });
        _connection.On<PlaySoundMessage>("PlaySound", msg => { });
        _connection.On<PlayVoiceMessage>("PlayVoice", msg => { });

        // Trade/Train — log opening
        _connection.On<TradeOpenMessage>("TradeOpen", msg =>
        {
            _state.AddEvent($"Trade window opened with {msg.NpcName}.");
        });

        _connection.On<int[]>("TrainOpen", skills =>
        {
            _state.AddEvent("Training window opened.");
        });

        _connection.On<CraftStartMessage>("CraftStart", msg =>
        {
            _state.AddEvent($"Crafting started ({msg.DurationMs}ms).");
        });

        _connection.On<bool>("CampfireNearby", nearby =>
        {
            if (nearby) _state.AddEvent("You feel the warmth of a campfire.");
        });

        // Reconnection handling
        _connection.Reconnecting += error =>
        {
            _state.AddEvent("Connection lost, reconnecting...");
            return Task.CompletedTask;
        };

        _connection.Reconnected += connectionId =>
        {
            _state.AddEvent("Reconnected to server.");
            return Task.CompletedTask;
        };

        _connection.Closed += error =>
        {
            _state.AddEvent("Disconnected from server.");
            return Task.CompletedTask;
        };
    }

    // --- Command execution (called by IPC handler) ---

    public async Task<string> ExecuteCommand(string command)
    {
        if (_connection == null || _connection.State != HubConnectionState.Connected)
            return "Not connected to server.";

        var parts = command.Split(' ', 2, StringSplitOptions.TrimEntries);
        var cmd = parts[0].ToLowerInvariant();
        var arg = parts.Length > 1 ? parts[1] : "";

        try
        {
            switch (cmd)
            {
                case "n": case "north": await _connection.InvokeAsync("Move", (int)Direction.North); break;
                case "s": case "south": await _connection.InvokeAsync("Move", (int)Direction.South); break;
                case "e": case "east": await _connection.InvokeAsync("Move", (int)Direction.East); break;
                case "w": case "west": await _connection.InvokeAsync("Move", (int)Direction.West); break;

                case "turn":
                    var clockwise = arg.StartsWith("r", StringComparison.OrdinalIgnoreCase);
                    await _connection.InvokeAsync("Rotate", clockwise);
                    break;

                case "say":
                    if (!string.IsNullOrEmpty(arg))
                        await _connection.InvokeAsync("Say", arg);
                    break;

                case "shout":
                    if (!string.IsNullOrEmpty(arg))
                        await _connection.InvokeAsync("Say", $"-{arg}");
                    break;

                case "emote":
                    if (!string.IsNullOrEmpty(arg))
                        await _connection.InvokeAsync("Say", $":{arg}");
                    break;

                case "whisper":
                    if (!string.IsNullOrEmpty(arg))
                        await _connection.InvokeAsync("Say", $"\\{arg}");
                    break;

                case "look":
                    if (!string.IsNullOrEmpty(arg) && arg.StartsWith("at ", StringComparison.OrdinalIgnoreCase))
                    {
                        // Target a nearby entity by name
                        var targetName = arg[3..].Trim();
                        var nearby = _state.GetNearbyCharacters(10);
                        var match = nearby.FirstOrDefault(n =>
                            n.ch.Name.Contains(targetName, StringComparison.OrdinalIgnoreCase));
                        if (match.ch != null)
                        {
                            await _connection.InvokeAsync("LeftClick", match.ch.X, match.ch.Y);
                        }
                        else
                        {
                            _state.AddEvent($"No one named '{targetName}' nearby.");
                        }
                    }
                    // For plain 'look', just return state (handled below)
                    break;

                case "battle":
                    await _connection.InvokeAsync("ToggleBattleMode");
                    _state.BattleMode = !_state.BattleMode;
                    break;

                case "attack":
                    await _connection.InvokeAsync("Attack");
                    break;

                case "consider":
                    await _connection.InvokeAsync("Consider");
                    break;

                case "target":
                    if (!string.IsNullOrEmpty(arg))
                    {
                        var nearby2 = _state.GetNearbyCharacters(10);
                        var match2 = nearby2.FirstOrDefault(n =>
                            n.ch.Name.Contains(arg, StringComparison.OrdinalIgnoreCase));
                        if (match2.ch != null)
                        {
                            await _connection.InvokeAsync("LeftClick", match2.ch.X, match2.ch.Y);
                        }
                        else
                        {
                            _state.AddEvent($"No one named '{arg}' nearby.");
                        }
                    }
                    break;

                case "inventory":
                case "inv":
                    // Just format and return — no server call needed
                    break;

                case "use":
                    if (int.TryParse(arg, out var useSlot))
                        await _connection.InvokeAsync("UseItem", useSlot);
                    break;

                case "drop":
                    var dropParts = arg.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                    if (dropParts.Length >= 1 && int.TryParse(dropParts[0], out var dropSlot))
                    {
                        var amount = dropParts.Length > 1 && int.TryParse(dropParts[1], out var a) ? a : 1;
                        await _connection.InvokeAsync("DropItem", dropSlot, amount);
                    }
                    break;

                case "get":
                    await _connection.InvokeAsync("GetItem");
                    break;

                case "buy":
                    if (int.TryParse(arg, out var buySlot))
                        await _connection.InvokeAsync("BuyFromNpc", buySlot);
                    break;

                case "sell":
                    if (int.TryParse(arg, out var sellSlot))
                        await _connection.InvokeAsync("SellToNpc", sellSlot);
                    break;

                case "train":
                    if (int.TryParse(arg, out var trainSlot))
                        await _connection.InvokeAsync("TrainSkill", trainSlot);
                    break;

                case "spells":
                    // Just format and return
                    break;

                case "cast":
                    if (int.TryParse(arg, out var castSlot))
                        await _connection.InvokeAsync("CastSpell", castSlot);
                    break;

                case "fish":
                    await _connection.InvokeAsync("GatherResource", "fish");
                    break;

                case "mine":
                    await _connection.InvokeAsync("GatherResource", "mine");
                    break;

                case "chop":
                    await _connection.InvokeAsync("GatherResource", "chop");
                    break;

                case "stats":
                case "status":
                    // Return formatted stats — no server call
                    break;

                case "events":
                    // Just return events — no server call
                    break;

                default:
                    // Pass through slash commands
                    if (command.StartsWith('/'))
                    {
                        await _connection.InvokeAsync("Say", command);
                    }
                    else
                    {
                        return FormatResponse($"Unknown command: {cmd}. Type 'help' for a list.");
                    }
                    break;
            }
        }
        catch (Exception ex)
        {
            return FormatResponse($"Error: {ex.Message}");
        }

        // Wait briefly for server events to arrive
        await Task.Delay(250);

        // Format response based on command type
        return cmd switch
        {
            "look" when string.IsNullOrEmpty(arg) => FormatLook(),
            "inventory" or "inv" => FormatInventory(),
            "spells" => FormatSpells(),
            "stats" or "status" => FormatStats(),
            "help" => FormatHelp(),
            _ => FormatResponse(null),
        };
    }

    // --- Response formatting ---

    private string FormatResponse(string? extraMessage)
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();

        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        if (extraMessage != null)
        {
            if (events.Count > 0) sb.AppendLine();
            sb.AppendLine(extraMessage);
        }

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");

        return sb.ToString();
    }

    private string FormatLook()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();

        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] ═══ {_state.MapName} ({_state.X},{_state.Y}) facing {_state.DirectionName(_state.Heading)} ═══");
        sb.AppendLine($"HP {_state.Hp}/{_state.MaxHp} | STA {_state.Sta}/{_state.MaxSta} | MAN {_state.Man}/{_state.MaxMan} | Gold {_state.Gold} | Weather: {(_state.IsRaining ? "Rain" : "Clear")}");

        var nearby = _state.GetNearbyCharacters(10);
        if (nearby.Count > 0)
        {
            sb.AppendLine();
            sb.AppendLine("Nearby:");
            foreach (var (ch, dist, dir) in nearby)
            {
                var desc = ch.IsCriminal ? " [criminal]" : "";
                sb.AppendLine($"  {ch.Name}{desc} — {dist} tile{(dist != 1 ? "s" : "")} {dir}");
            }
        }

        if (_state.GroundObjects.Count > 0)
        {
            sb.AppendLine();
            sb.AppendLine("Ground items visible on map.");
        }

        if (_state.TargetName != null)
            sb.AppendLine($"\nTarget: {_state.TargetName}");

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");

        return sb.ToString();
    }

    private string FormatInventory()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        sb.AppendLine("Inventory:");
        for (int i = 0; i < 20; i++)
        {
            var slot = _state.Inventory[i];
            if (slot.ObjIndex > 0)
            {
                var eq = slot.Equipped ? " [equipped]" : "";
                var qty = slot.Amount > 1 ? $" x{slot.Amount}" : "";
                sb.AppendLine($"  [{i}] {slot.Name}{qty}{eq}");
            }
        }

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");
        return sb.ToString();
    }

    private string FormatSpells()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        sb.AppendLine("Spell Book:");
        for (int i = 0; i < 50; i++)
        {
            var spell = _state.SpellBook[i];
            if (spell.SpellIndex > 0)
                sb.AppendLine($"  [{i}] {spell.Name} (Mana: {spell.NeedsMana}) — {spell.Desc}");
        }

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");
        return sb.ToString();
    }

    private string FormatStats()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        sb.AppendLine($"Character: {_state.CharacterName}");
        sb.AppendLine($"Class: {_state.Class} | Rank: {_state.RepRank}");
        sb.AppendLine($"Map: {_state.MapName} (Map {_state.Map}) at ({_state.X},{_state.Y})");
        sb.AppendLine($"HP: {_state.Hp}/{_state.MaxHp} | STA: {_state.Sta}/{_state.MaxSta} | MAN: {_state.Man}/{_state.MaxMan}");
        sb.AppendLine($"HIT: {_state.MinHit}-{_state.MaxHit} | DEF: {_state.Def}");
        sb.AppendLine($"Gold: {_state.Gold} | EXP: {_state.Exp}/{_state.Elu}");
        sb.AppendLine($"Food: {_state.Food} | Drink: {_state.Drink}");
        sb.AppendLine($"Training Points: {_state.TrainingPoints}");
        if (_state.Criminal > 0) sb.AppendLine($"Criminal: YES (count: {_state.Criminal})");

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");
        return sb.ToString();
    }

    private string FormatHelp()
    {
        return """
        Era Online CLI Commands:
          Movement:  n, s, e, w, turn left, turn right
          Look:      look, look at <name>
          Combat:    battle, attack, consider, target <name>
          Chat:      say <msg>, shout <msg>, emote <action>, whisper <name> <msg>
          Items:     inventory, use <slot>, drop <slot> [amount], get
          Trading:   buy <slot>, sell <slot>
          Training:  train <slot>
          Magic:     spells, cast <slot>, /meditate
          Gather:    fish, mine, chop
          Info:      stats, events, help
          Slash:     /who, /trade, /train, /heal, /hail, /gossip, /save, /stats, etc.
          Session:   stop
        """;
    }

    public async ValueTask DisposeAsync()
    {
        if (_connection != null)
        {
            try { await _connection.StopAsync(); }
            catch { /* ignore */ }
            await _connection.DisposeAsync();
        }
    }
}

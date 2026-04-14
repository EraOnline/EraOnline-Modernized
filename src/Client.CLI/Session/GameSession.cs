using System.Text.Json;
using Microsoft.AspNetCore.SignalR.Client;
using EraOnline.Shared.Constants;
using EraOnline.Shared.Protocol;
using EraOnline.Client.CLI.Navigation;
using EraOnline.Client.CLI.Rendering;

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

    // Headless renderer for screenshots
    private SpriteLoader? _spriteLoader;
    private HeadlessRenderer? _renderer;
    private string? _screenshotDir;

    // World knowledge (per-character, persisted)
    private WorldKnowledge? _knowledge;
    private Journal? _journal;
    private string? _dataPath;
    private bool _mapKnowledgeUpdated;

    public GameState State => _state;
    public bool IsConnected => _connection?.State == HubConnectionState.Connected;

    private readonly bool _skipSslVerify;

    public GameSession(string serverUrl, string characterName, string password, string? dataPath = null, bool skipSslVerify = false)
    {
        _serverUrl = serverUrl.TrimEnd('/');
        _characterName = characterName;
        _password = password;
        _skipSslVerify = skipSslVerify;
        _state.CharacterName = characterName;

        // Load map names from data files if available
        LoadMapNames(dataPath);

        // Init renderer and world knowledge if data path available
        if (dataPath != null)
        {
            _dataPath = dataPath;
            _spriteLoader = new SpriteLoader(dataPath);
            _spriteLoader.LoadAll();
            _renderer = new HeadlessRenderer(_spriteLoader, dataPath);

            var dataHome = Environment.GetEnvironmentVariable("XDG_DATA_HOME")
                ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".local", "share");
            var charDir = Path.Combine(dataHome, "eraonline", "characters", characterName);
            _screenshotDir = Path.Combine(charDir, "screenshots");
            _knowledge = new WorldKnowledge(charDir);
            _journal = new Journal(charDir);
        }
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
            .WithUrl(hubUrl, options =>
            {
                if (_skipSslVerify)
                {
                    options.HttpMessageHandlerFactory = handler =>
                    {
                        if (handler is HttpClientHandler clientHandler)
                            clientHandler.ServerCertificateCustomValidationCallback = (_, _, _, _) => true;
                        return handler;
                    };
                }
            })
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
            // Use world knowledge name if available, fall back to known names, then generic
            var mapName = _knowledge?.GetMap(msg.MapId).DisplayName
                ?? _mapNames.GetValueOrDefault(msg.MapId, $"Map {msg.MapId}");
            _state.OnMapLoad(msg.MapId, mapName);
            _mapKnowledgeUpdated = false; // Mark for update on next command
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

    private void EnsureMapKnowledge()
    {
        if (_mapKnowledgeUpdated || _knowledge == null || _state.Map <= 0) return;
        _knowledge.OnMapEnter(_state.Map, _state, _dataPath);
        // Update map name from knowledge
        var mk = _knowledge.GetMap(_state.Map);
        if (!string.IsNullOrEmpty(mk.Name))
            _state.MapName = mk.DisplayName;
        _mapKnowledgeUpdated = true;
    }

    public async Task<string> ExecuteCommand(string command)
    {
        if (_connection == null || _connection.State != HubConnectionState.Connected)
            return "Not connected to server.";

        // Ensure map knowledge is updated (deferred from MapLoad since NPCs arrive after)
        EnsureMapKnowledge();

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

                case "move":
                    if (!string.IsNullOrEmpty(arg))
                    {
                        await ExecutePathfind(arg);
                    }
                    break;

                case "face":
                    if (!string.IsNullOrEmpty(arg))
                    {
                        await ExecuteFace(arg);
                    }
                    break;

                case "spaces":
                    // Handled in formatting below
                    if (arg.StartsWith("define ", StringComparison.OrdinalIgnoreCase) && _knowledge != null)
                    {
                        var defParts = arg[7..].Trim().Split(' ');
                        if (defParts.Length >= 3 && int.TryParse(defParts[^2], out var sx) && int.TryParse(defParts[^1], out var sy))
                        {
                            var spaceName = string.Join(' ', defParts[..^2]);
                            var mk = _knowledge.GetMap(_state.Map);
                            mk.AddSpaceIfNew(spaceName, sx, sy, "manual", false);
                            _knowledge.Save();
                            _state.AddEvent($"Defined space '{spaceName}' at ({sx},{sy}).");
                        }
                    }
                    break;

                case "map":
                    if (arg == "render" && _renderer != null && _screenshotDir != null)
                    {
                        var path = _renderer.RenderFullMap(_state.Map, _state, _screenshotDir);
                        _state.AddEvent($"Full map rendered: {path}");
                    }
                    else if (arg.StartsWith("probe ", StringComparison.OrdinalIgnoreCase) && _renderer != null && _screenshotDir != null)
                    {
                        var coords = arg[6..].Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
                        if (coords.Length >= 2 && int.TryParse(coords[0], out var px) && int.TryParse(coords[1], out var py))
                        {
                            var path = _renderer.RenderProbe(_state.Map, px, py, _state, _screenshotDir);
                            _state.AddEvent($"Probe at ({px},{py}): {path}");
                        }
                    }
                    // else: handled in formatting below (shows map overview)
                    break;

                case "overworld":
                    // Handled in formatting below
                    break;

                case "npcs":
                    // Handled in formatting below — lists all visible NPCs with positions
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

                case "screenshot":
                    if (_renderer != null && _screenshotDir != null)
                    {
                        var path = _renderer.RenderScreenshot(_state, _screenshotDir);
                        _state.AddEvent($"Screenshot saved: {path}");
                    }
                    else
                    {
                        _state.AddEvent("Screenshot not available: game data not loaded.");
                    }
                    break;

                case "events":
                    // Just return events — no server call
                    break;

                case "await":
                case "wait":
                    await ExecuteAwait(arg);
                    break;

                case "journal":
                    if (_journal == null)
                    {
                        _state.AddEvent("Journal not available.");
                    }
                    else if (arg.StartsWith("write ", StringComparison.OrdinalIgnoreCase))
                    {
                        var entry = arg[6..].Trim().Trim('"');
                        _journal.Write(entry);
                        _state.AddEvent("Journal entry saved.");
                    }
                    else if (arg == "read" || string.IsNullOrEmpty(arg))
                    {
                        return _journal.Read() + "\n──\n" + $"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}\n";
                    }
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
            "screenshot" => FormatResponse(null),
            "spaces" when !arg.StartsWith("define") => FormatSpaces(),
            "map" when string.IsNullOrEmpty(arg) => FormatMap(),
            "map" when arg == "render" || arg.StartsWith("probe") => FormatResponse(null),
            "npcs" => FormatNpcs(),
            "overworld" => FormatOverworld(),
            "help" => FormatHelp(),
            _ => FormatResponse(null),
        };
    }

    // --- Pathfinding ---

    private async Task ExecutePathfind(string target)
    {
        if (_knowledge == null)
        {
            _state.AddEvent("Pathfinding not available: no world knowledge.");
            return;
        }

        var mk = _knowledge.GetMap(_state.Map);

        // Try to parse "to X Y" for coordinate targets
        int goalX, goalY;
        if (target.StartsWith("to ", StringComparison.OrdinalIgnoreCase))
        {
            var coords = target[3..].Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (coords.Length >= 2 && int.TryParse(coords[0], out goalX) && int.TryParse(coords[1], out goalY))
            {
                // Coordinate target
            }
            else
            {
                _state.AddEvent($"Invalid coordinates: {target[3..]}");
                return;
            }
        }
        else
        {
            // Look up space by name
            var space = mk.Spaces.FirstOrDefault(s =>
                s.Name.Contains(target, StringComparison.OrdinalIgnoreCase));
            if (space == null)
            {
                _state.AddEvent($"Unknown space '{target}'. Use 'spaces list' to see known locations.");
                return;
            }
            goalX = space.X;
            goalY = space.Y;
            _state.AddEvent($"Pathfinding to {space.Name} ({goalX},{goalY})...");
        }

        if (mk.BlockedTiles == null)
        {
            _state.AddEvent("No tile data for pathfinding on this map.");
            return;
        }

        var path = Pathfinder.FindPath(mk, _state.X, _state.Y, goalX, goalY);
        if (path == null || path.Count == 0)
        {
            _state.AddEvent(path == null ? "No path found!" : "Already there.");
            return;
        }

        var directions = Pathfinder.PathToDirections(path, _state.X, _state.Y);
        _state.AddEvent($"Walking {directions.Count} tiles...");

        // Execute the path step by step
        int steps = 0;
        foreach (var dir in directions)
        {
            await _connection!.InvokeAsync("Move", dir);
            await Task.Delay(350); // Match visual movement speed
            steps++;

            // Check for interruptions: damage taken or chat received
            var newEvents = _state.GetNewEvents();
            bool interrupted = false;
            foreach (var evt in newEvents)
            {
                // Re-add events so they show in the final output
                _state.AddEvent(evt.Text);
                // Interrupt on any combat or any chat from another character
                if (evt.Text.Contains("strikes you") || evt.Text.Contains("has slain you") ||
                    evt.Text.Contains("tells,") || evt.Text.Contains("whispers:") ||
                    evt.Text.Contains("shouts:") ||
                    (evt.Text.Contains(": ") && !evt.Text.StartsWith(_state.CharacterName)))
                {
                    interrupted = true;
                }
            }

            if (interrupted)
            {
                _state.AddEvent($"Movement interrupted after {steps} steps at ({_state.X},{_state.Y}).");
                return;
            }
        }

        _state.AddEvent($"Arrived at ({_state.X},{_state.Y}).");
    }

    // --- Face toward target ---

    private async Task ExecuteFace(string targetName)
    {
        // Find the character by name
        var nearby = _state.GetNearbyCharacters(15);
        var match = nearby.FirstOrDefault(n =>
            n.Item1.Name.Contains(targetName, StringComparison.OrdinalIgnoreCase));

        if (match.Item1 == null)
        {
            _state.AddEvent($"No one named '{targetName}' nearby to face.");
            return;
        }

        var target = match.Item1;
        int dx = target.X - _state.X;
        int dy = target.Y - _state.Y;

        // Determine the best cardinal direction to face
        // Prioritize the axis with the larger delta
        int desiredHeading;
        if (Math.Abs(dx) >= Math.Abs(dy))
            desiredHeading = dx > 0 ? (int)Direction.East : (int)Direction.West;
        else
            desiredHeading = dy > 0 ? (int)Direction.South : (int)Direction.North;

        // Rotate to face that direction (headings: 1=N, 2=E, 3=S, 4=W)
        // Each Rotate(clockwise) increments heading by 1 (wrapping), counter-clockwise decrements
        int current = _state.Heading;
        if (current == desiredHeading)
        {
            _state.AddEvent($"Already facing {_state.DirectionName(desiredHeading)} toward {target.Name} ({target.X},{target.Y}).");
            return;
        }

        // Calculate shortest rotation: clockwise vs counter-clockwise
        int cwSteps = (desiredHeading - current + 4) % 4;
        int ccwSteps = (current - desiredHeading + 4) % 4;
        bool clockwise = cwSteps <= ccwSteps;
        int steps = Math.Min(cwSteps, ccwSteps);

        for (int i = 0; i < steps; i++)
        {
            await _connection!.InvokeAsync("Rotate", clockwise);
            await Task.Delay(100);
        }

        _state.AddEvent($"Facing {_state.DirectionName(desiredHeading)} toward {target.Name} ({target.X},{target.Y}).");
    }

    // --- Await mode ---

    private async Task ExecuteAwait(string arg)
    {
        // Parse: <seconds> [--until <trigger>]
        var parts = arg.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        double seconds = 5;
        string? trigger = null;

        if (parts.Length >= 1 && double.TryParse(parts[0], out var s))
            seconds = s;
        for (int i = 1; i < parts.Length - 1; i++)
        {
            if (parts[i] == "--until")
                trigger = parts[i + 1].ToLowerInvariant();
        }

        var startTime = DateTime.Now;
        var deadline = startTime.AddSeconds(seconds);
        // Snapshot the event count BEFORE we start waiting
        int lastSeenCount;
        lock (_state.RecentEvents) { lastSeenCount = _state.RecentEvents.Count; }

        while (DateTime.Now < deadline)
        {
            await Task.Delay(100);

            if (trigger == null) continue;

            // Check for new events since we last looked
            List<TimestampedEvent> newEvents;
            lock (_state.RecentEvents)
            {
                if (_state.RecentEvents.Count <= lastSeenCount) continue;
                newEvents = _state.RecentEvents.Skip(lastSeenCount).ToList();
                lastSeenCount = _state.RecentEvents.Count;
            }

            foreach (var evt in newEvents)
            {
                var text = evt.Text;
                bool triggered = trigger switch
                {
                    "chat" => text.Contains(": ") || text.Contains("tells,") ||
                              text.Contains("whispers:") || text.Contains("shouts:"),
                    "combat" => text.Contains("strikes you") || text.Contains("has slain") ||
                                text.Contains("You are dead") || text.Contains("damage"),
                    "player" => text.Contains("left the area") || text.Contains("Welcome to Era"),
                    "any" => true,
                    "craft" => text.Contains("Crafting") || text.Contains("crafting"),
                    _ => false,
                };

                if (triggered)
                {
                    var elapsed = (DateTime.Now - startTime).TotalSeconds;
                    _state.AddEvent($"── await triggered ({trigger}) after {elapsed:F1}s ──");
                    return;
                }
            }
        }

        _state.AddEvent($"── await timeout ({seconds:F1}s) ──");
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

        // Build numbered legend: all characters sorted by distance
        var nearby = _state.GetNearbyCharacters(15);
        var ordered = nearby.OrderBy(n => n.Item2).ToList();

        // Assign numbers 1-9 to entities
        var entityMap = new Dictionary<(int x, int y), char>();
        var legend = new List<string>();
        int num = 1;
        foreach (var (ch, dist, dir) in ordered)
        {
            if (num > 9) break;
            var c = (char)('0' + num);
            entityMap[(ch.X, ch.Y)] = c;
            var criminal = ch.IsCriminal ? " [criminal]" : "";
            legend.Add($"  {c} {ch.Name}{criminal} ({ch.X},{ch.Y})");
            num++;
        }

        // ASCII map: 20 wide, 11 tall centered on player, with coordinate headers
        sb.AppendLine();
        var mk = _knowledge?.GetMap(_state.Map);
        int halfW = 20, halfH = 11;

        // X-axis header (two rows: tens digit, ones digit)
        var xTens = new System.Text.StringBuilder("     ");
        var xOnes = new System.Text.StringBuilder("     ");
        for (int dx = -halfW; dx < halfW; dx++)
        {
            int tx = _state.X + dx;
            if (tx < 1 || tx > 100)
            {
                xTens.Append("  ");
                xOnes.Append("  ");
            }
            else
            {
                xTens.Append(tx / 10 % 10);
                xTens.Append(' ');
                xOnes.Append(tx % 10);
                xOnes.Append(' ');
            }
        }
        sb.AppendLine(xTens.ToString());
        sb.AppendLine(xOnes.ToString());

        for (int dy = -halfH; dy <= halfH; dy++)
        {
            int ty = _state.Y + dy;
            var row = new System.Text.StringBuilder($" {ty,3} ");
            for (int dx = -halfW; dx < halfW; dx++)
            {
                int tx = _state.X + dx;

                if (tx < 1 || tx > 100 || ty < 1 || ty > 100)
                {
                    row.Append("# ");
                    continue;
                }

                if (dx == 0 && dy == 0)
                {
                    row.Append("@ ");
                }
                else if (entityMap.TryGetValue((tx, ty), out var ec))
                {
                    row.Append(ec);
                    row.Append(' ');
                }
                else if (_state.GroundObjects.ContainsKey($"{tx},{ty}"))
                {
                    row.Append("* ");
                }
                else if (mk?.BlockedTiles != null)
                {
                    int idx = (ty - 1) * 100 + (tx - 1);
                    row.Append(mk.BlockedTiles[idx] != 0 ? "# " : ". ");
                }
                else
                {
                    row.Append(". ");
                }
            }
            sb.AppendLine(row.ToString());
        }

        // Legend
        sb.AppendLine();
        sb.AppendLine($"  @ You ({_state.X},{_state.Y})");
        foreach (var entry in legend)
            sb.AppendLine(entry);
        if (_state.GroundObjects.Count > 0)
            sb.AppendLine("  * ground item");

        if (_state.TargetName != null)
            sb.AppendLine($"\nTarget: {_state.TargetName}");

        // Show nearest spaces with absolute positions
        if (_knowledge != null)
        {
            var nearSpaces = mk!.Spaces
                .Select(s => (s, dist: Math.Abs(s.X - _state.X) + Math.Abs(s.Y - _state.Y)))
                .OrderBy(x => x.dist)
                .Take(5)
                .ToList();
            if (nearSpaces.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Spaces:");
                foreach (var (space, dist) in nearSpaces)
                    sb.AppendLine($"  {space.Name} ({space.X},{space.Y}) — {dist} tiles");
            }
        }

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

    private string FormatSpaces()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        if (_knowledge == null)
        {
            sb.AppendLine("No world knowledge available.");
        }
        else
        {
            var mk = _knowledge.GetMap(_state.Map);
            sb.AppendLine($"Known spaces on {mk.DisplayName} (Map {mk.MapId}):");
            if (mk.Spaces.Count == 0)
            {
                sb.AppendLine("  (none discovered yet)");
            }
            else
            {
                foreach (var space in mk.Spaces.OrderBy(s => Math.Abs(s.X - _state.X) + Math.Abs(s.Y - _state.Y)))
                {
                    var dist = Math.Abs(space.X - _state.X) + Math.Abs(space.Y - _state.Y);
                    var dir = GameState.GetRelativeDir(space.X - _state.X, space.Y - _state.Y);
                    var auto = space.Auto ? " [auto]" : "";
                    sb.AppendLine($"  {space.Name} ({space.X},{space.Y}) — {dist} tiles {dir}{auto}");
                }
            }
        }

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");
        return sb.ToString();
    }

    private string FormatMap()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        if (_knowledge == null)
        {
            sb.AppendLine("No world knowledge available.");
        }
        else
        {
            var mk = _knowledge.GetMap(_state.Map);
            sb.AppendLine($"═══ {mk.DisplayName} (Map {mk.MapId}) ═══");
            sb.AppendLine($"You are at ({_state.X},{_state.Y}). Visited {mk.VisitCount} times.");

            if (mk.Spaces.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Known spaces:");
                foreach (var space in mk.Spaces.OrderBy(s => Math.Abs(s.X - _state.X) + Math.Abs(s.Y - _state.Y)))
                {
                    var dist = Math.Abs(space.X - _state.X) + Math.Abs(space.Y - _state.Y);
                    var dir = GameState.GetRelativeDir(space.X - _state.X, space.Y - _state.Y);
                    sb.AppendLine($"  {space.Name,-30} {dist,3} tiles {dir}");
                }
            }

            if (mk.Exits.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Exits:");
                foreach (var (direction, destId) in mk.Exits)
                {
                    var destName = _knowledge.GetMap(destId).DisplayName;
                    sb.AppendLine($"  {direction,-6} → {destName} (Map {destId})");
                }
            }
        }

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");
        return sb.ToString();
    }

    private string FormatNpcs()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        var allChars = _state.Characters.Values
            .Where(c => !c.IsMyChar)
            .OrderBy(c => c.Name)
            .ToList();

        sb.AppendLine($"Characters on {_state.MapName} (Map {_state.Map}): {allChars.Count}");
        foreach (var ch in allChars)
        {
            var dist = Math.Abs(ch.X - _state.X) + Math.Abs(ch.Y - _state.Y);
            sb.AppendLine($"  {ch.Name,-35} ({ch.X,3},{ch.Y,3})  {dist,3} tiles");
        }

        sb.AppendLine("──");
        sb.AppendLine($"[{DateTime.Now:HH:mm:ss}] {_state.StatusLine()}");
        return sb.ToString();
    }

    private string FormatOverworld()
    {
        var sb = new System.Text.StringBuilder();
        var events = _state.GetNewEvents();
        foreach (var evt in events)
            sb.AppendLine($"[{evt.Timestamp:HH:mm:ss.fff}] {evt.Text}");

        if (_knowledge == null)
        {
            sb.AppendLine("No world knowledge available.");
        }
        else
        {
            sb.AppendLine("═══ Known World ═══");
            foreach (var (mapId, mk) in _knowledge.Maps.OrderBy(kv => kv.Key))
            {
                var current = mapId == _state.Map ? " ← you are here" : "";
                var exitList = mk.Exits.Count > 0
                    ? " → " + string.Join(", ", mk.Exits.Select(e => $"{e.Key}:{_knowledge.GetMap(e.Value).DisplayName}"))
                    : "";
                sb.AppendLine($"  {mk.DisplayName,-20} (Map {mapId,3}) visits:{mk.VisitCount}{exitList}{current}");
            }
        }

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
        _renderer?.Dispose();
        _spriteLoader?.Dispose();
        if (_connection != null)
        {
            try { await _connection.StopAsync(); }
            catch { /* ignore */ }
            await _connection.DisposeAsync();
        }
    }
}

using System.Text.Json;
using EraOnline.Client.CLI.IPC;
using EraOnline.Client.CLI.Session;

// Default configuration
const int DefaultPort = 19999;
const string DefaultServer = "http://localhost:5000";

// --- Determine mode: "start" = daemon, anything else = send command to daemon ---

if (args.Length == 0 || args[0] == "help" || args[0] == "--help")
{
    PrintUsage();
    return 0;
}

if (args[0] == "start")
{
    return await RunDaemon(args);
}
else if (args[0] == "tail")
{
    return TailLog(args);
}
else if (args[0] == "stream")
{
    return await StreamLog(args);
}
else
{
    // Join all args as a command and send to daemon
    var command = string.Join(' ', args);
    return await SendCommand(command);
}

// --- Daemon mode ---

async Task<int> RunDaemon(string[] args)
{
    string? name = null;
    string? password = null;
    string server = DefaultServer;
    int port = DefaultPort;
    bool skipSsl = false;

    // Parse args
    for (int i = 1; i < args.Length; i++)
    {
        switch (args[i])
        {
            case "--name" when i + 1 < args.Length:
                name = args[++i];
                break;
            case "--password" when i + 1 < args.Length:
                password = args[++i];
                break;
            case "--server" when i + 1 < args.Length:
                server = args[++i];
                break;
            case "--port" when i + 1 < args.Length:
                port = int.Parse(args[++i]);
                break;
            case "--no-ssl-verify":
                skipSsl = true;
                break;
        }
    }

    // Try loading config.json for defaults
    var configPath = GetConfigPath();
    if (File.Exists(configPath))
    {
        try
        {
            var configJson = File.ReadAllText(configPath);
            var config = JsonSerializer.Deserialize<Dictionary<string, string>>(configJson);
            if (config != null)
            {
                if (server == DefaultServer && config.TryGetValue("server", out var s)) server = s;
                if (config.TryGetValue("port", out var p) && int.TryParse(p, out var pp)) port = pp;
            }
        }
        catch { /* ignore bad config */ }
    }

    if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(password))
    {
        Console.Error.WriteLine("Usage: eraonline start --name <character> --password <password> [--server <url>] [--port <ipc-port>]");
        return 1;
    }

    // Find game data path
    var dataPath = FindDataPath();

    Console.WriteLine($"Era Online CLI — Connecting to {server} as {name}...");

    await using var session = new GameSession(server, name, password, dataPath, skipSsl);

    if (!await session.ConnectAndLogin())
    {
        return 1;
    }

    Console.WriteLine($"Logged in as {name}. IPC listening on port {port}.");
    Console.WriteLine("Send commands with: eraonline <command>");
    Console.WriteLine("Stop with: eraonline stop");

    // Start IPC server
    await using var ipcServer = new IpcServer(port, session);
    var tcs = new TaskCompletionSource();
    ipcServer.StopRequested += () => tcs.TrySetResult();
    Console.CancelKeyPress += (_, e) =>
    {
        e.Cancel = true;
        tcs.TrySetResult();
    };
    ipcServer.Start();

    // Wait until stop signal (IPC stop command or Ctrl+C) or disconnection
    while (session.IsConnected && !tcs.Task.IsCompleted)
    {
        await Task.WhenAny(tcs.Task, Task.Delay(1000));
    }

    Console.WriteLine("Session ended.");
    return 0;
}

// --- Command mode ---

async Task<int> SendCommand(string command)
{
    var port = DefaultPort;

    // Try loading port from config
    var configPath = GetConfigPath();
    if (File.Exists(configPath))
    {
        try
        {
            var configJson = File.ReadAllText(configPath);
            var config = JsonSerializer.Deserialize<Dictionary<string, string>>(configJson);
            if (config != null && config.TryGetValue("port", out var p) && int.TryParse(p, out var pp))
                port = pp;
        }
        catch { }
    }

    // "stop" sends a special stop command
    if (command == "stop")
        command = "__stop__";

    var response = await IpcClient.SendCommand(port, command);
    Console.Write(response);
    if (!response.EndsWith('\n')) Console.WriteLine();
    return 0;
}

// --- Helpers ---

void PrintUsage()
{
    Console.WriteLine("""
    Era Online CLI

    Session:
      eraonline start --name <name> --password <pw> [--server <url>] [--port <port>]
      eraonline stop

    Event log (works without daemon — reads events.log):
      eraonline tail [N=50] [--filter cat,cat] [--name <character>]
      eraonline tail --since <id> [--filter cat,cat]
      eraonline stream [--filter cat,cat] [--name <character>]

      Categories: chat, whisper, shout, emote, combat, skill, weather,
                  map, character, navigation, render, craft, stats, system, info

    Commands (while session is running):
      Movement:  n, s, e, w, turn left, turn right
      Look:      look, look at <name>
      Combat:    battle, attack, consider, target <name>
      Chat:      say <msg>, shout <msg>, emote <action>, whisper <name> <msg>
      Items:     inventory, use <slot>, drop <slot> [amount], get
      Trading:   buy <slot>, sell <slot>
      Training:  train <slot>
      Magic:     spells, cast <slot>
      Gather:    fish, mine, chop
      Info:      stats, events, help
      Slash:     /who, /trade, /train, /heal, /hail, /gossip, /save, etc.
    """);
}

string GetConfigPath()
{
    var configHome = Environment.GetEnvironmentVariable("XDG_CONFIG_HOME")
        ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".config");
    return Path.Combine(configHome, "eraonline", "config.json");
}

// --- Tail / Stream (read events.log directly; no daemon required) ---

int TailLog(string[] args)
{
    var (logPath, err) = ResolveEventLog(args);
    if (logPath == null) { Console.Error.WriteLine(err); return 1; }

    int n = 50;
    HashSet<string>? filter = null;
    long sinceId = -1;
    for (int i = 1; i < args.Length; i++)
    {
        if (args[i] == "--filter" && i + 1 < args.Length)
            filter = new HashSet<string>(args[++i].Split(',', StringSplitOptions.RemoveEmptyEntries),
                StringComparer.OrdinalIgnoreCase);
        else if (args[i] == "--since" && i + 1 < args.Length)
            long.TryParse(args[++i], out sinceId);
        else if (args[i] == "--name" && i + 1 < args.Length)
            i++; // already consumed by ResolveEventLog
        else if (int.TryParse(args[i], out var count))
            n = count;
    }

    if (!File.Exists(logPath))
    {
        Console.Error.WriteLine($"No event log at {logPath}. Has the daemon ever been started for this character?");
        return 1;
    }

    // Read all lines (events.log is line-oriented, append-only). For huge logs this could be
    // optimized to read backward, but at LLM-session scales we're fine.
    string[] lines;
    using (var fs = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    using (var sr = new StreamReader(fs))
    {
        var all = new List<string>();
        string? line;
        while ((line = sr.ReadLine()) != null) all.Add(line);
        lines = all.ToArray();
    }

    long emittedId = 0;
    var matched = lines
        .Select((text, idx) => (text, id: (long)(idx + 1)))
        .Where(t => sinceId < 0 || t.id > sinceId)
        .Where(t => filter == null || MatchesFilter(t.text, filter))
        .ToList();

    var slice = sinceId >= 0 ? matched : matched.TakeLast(n).ToList();
    foreach (var (text, id) in slice)
    {
        Console.WriteLine($"{id}\t{text}");
        emittedId = id;
    }
    return 0;
}

async Task<int> StreamLog(string[] args)
{
    var (logPath, err) = ResolveEventLog(args);
    if (logPath == null) { Console.Error.WriteLine(err); return 1; }

    HashSet<string>? filter = null;
    for (int i = 1; i < args.Length; i++)
    {
        if (args[i] == "--filter" && i + 1 < args.Length)
            filter = new HashSet<string>(args[++i].Split(',', StringSplitOptions.RemoveEmptyEntries),
                StringComparer.OrdinalIgnoreCase);
    }

    // Wait for the file to exist if the daemon is just starting.
    var spinDeadline = DateTime.UtcNow.AddSeconds(10);
    while (!File.Exists(logPath) && DateTime.UtcNow < spinDeadline)
        await Task.Delay(200);
    if (!File.Exists(logPath))
    {
        Console.Error.WriteLine($"No event log at {logPath}. Is the daemon running?");
        return 1;
    }

    // Open shared-read and seek to end so we only print new lines.
    using var fs = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
    using var sr = new StreamReader(fs);
    fs.Seek(0, SeekOrigin.End);

    var cancel = new CancellationTokenSource();
    Console.CancelKeyPress += (_, e) => { e.Cancel = true; cancel.Cancel(); };

    while (!cancel.IsCancellationRequested)
    {
        string? line;
        bool any = false;
        while ((line = sr.ReadLine()) != null)
        {
            any = true;
            if (filter == null || MatchesFilter(line, filter))
            {
                Console.WriteLine(line);
                Console.Out.Flush(); // line-buffered for Monitor
            }
        }
        if (!any) await Task.Delay(150, cancel.Token).ContinueWith(_ => { });
    }
    return 0;
}

static bool MatchesFilter(string line, HashSet<string> filter)
{
    // Format is timestamp|category|text. Pull the category between the first two pipes.
    var first = line.IndexOf('|');
    if (first < 0) return false;
    var second = line.IndexOf('|', first + 1);
    if (second < 0) return false;
    var category = line.Substring(first + 1, second - first - 1);
    return filter.Contains(category);
}

(string? logPath, string? err) ResolveEventLog(string[] args)
{
    string? name = null;
    for (int i = 1; i < args.Length - 1; i++)
        if (args[i] == "--name") { name = args[i + 1]; break; }

    var dataHome = Environment.GetEnvironmentVariable("XDG_DATA_HOME")
        ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".local", "share");

    if (string.IsNullOrEmpty(name))
    {
        var activeFile = Path.Combine(dataHome, "eraonline", "active.txt");
        if (File.Exists(activeFile))
        {
            try { name = File.ReadAllText(activeFile).Trim(); } catch { }
        }
    }

    if (string.IsNullOrEmpty(name))
        return (null, "No active character. Pass --name <character>, or start a daemon first.");

    var logPath = Path.Combine(dataHome, "eraonline", "characters", name, "events.log");
    return (logPath, null);
}

string? FindDataPath()
{
    // Check XDG data path first
    var dataHome = Environment.GetEnvironmentVariable("XDG_DATA_HOME")
        ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".local", "share");
    var xdgPath = Path.Combine(dataHome, "eraonline", "data");
    if (Directory.Exists(xdgPath)) return xdgPath;

    // Check relative to the binary (development mode)
    var binDir = AppContext.BaseDirectory;
    var devPath = Path.GetFullPath(Path.Combine(binDir, "..", "..", "..", "..", "..", "src", "Client.Web", "wwwroot", "data"));
    if (Directory.Exists(devPath)) return devPath;

    // Check current working directory up toward repo root
    var cwd = Directory.GetCurrentDirectory();
    var webDataPath = Path.Combine(cwd, "src", "Client.Web", "wwwroot", "data");
    if (Directory.Exists(webDataPath)) return webDataPath;

    return null;
}

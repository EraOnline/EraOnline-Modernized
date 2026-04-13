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

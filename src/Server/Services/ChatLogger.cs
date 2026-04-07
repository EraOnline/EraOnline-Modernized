namespace EraOnline.Server.Services;

/// <summary>
/// Logs chat and connection events to text files, matching the original VB6 logging.
/// VB6: Open "Logs\Zone{map}.log" / "Connect.log" For Append Shared As #5
/// </summary>
public class ChatLogger
{
    private readonly string _logPath;
    private readonly object _lock = new();

    public ChatLogger(IConfiguration config)
    {
        _logPath = config.GetValue<string>("LogPath") ?? Path.Combine(Directory.GetCurrentDirectory(), "logs");
        Directory.CreateDirectory(_logPath);
    }

    /// <summary>Log a chat message to the zone log. VB6: Logs\Zone{map}.log</summary>
    public void LogChat(int map, string playerName, string message)
    {
        var file = Path.Combine(_logPath, $"Zone{map}.log");
        var line = $"{playerName}:{message} ({DateTime.Now:HH:mm:ss yyyy-MM-dd})";
        AppendLine(file, line);
    }

    /// <summary>Log a connection event. VB6: Connect.log</summary>
    public void LogConnect(string playerName, string action)
    {
        var file = Path.Combine(_logPath, "Connect.log");
        var line = $"{playerName} {action}. {DateTime.Now:HH:mm:ss yyyy-MM-dd}";
        AppendLine(file, line);
    }

    private void AppendLine(string file, string line)
    {
        lock (_lock)
        {
            File.AppendAllText(file, line + Environment.NewLine);
        }
    }
}

namespace EraOnline.Client.CLI.Session;

/// <summary>
/// Append-only per-character event log. Source of truth for everything that happens.
///
/// Format: ISO8601 timestamp | category | text (newlines in text replaced with \n literals)
///   2026-04-19T08:15:32.498Z|chat|Yo-Ho: hello
///   2026-04-19T08:15:43.928Z|combat|You strike the giant snake for 9 !
///
/// Thread-safe via internal lock. AutoFlush so external readers (tail -f, eraonline tail/stream)
/// see writes immediately.
/// </summary>
public sealed class EventLog : IDisposable
{
    private readonly StreamWriter _writer;
    private readonly object _gate = new();
    public string FilePath { get; }

    public EventLog(string characterDataDir)
    {
        Directory.CreateDirectory(characterDataDir);
        FilePath = Path.Combine(characterDataDir, "events.log");
        var stream = new FileStream(FilePath, FileMode.Append, FileAccess.Write, FileShare.Read);
        _writer = new StreamWriter(stream) { AutoFlush = true };
    }

    public void Write(string category, string text)
    {
        var safeText = (text ?? "").Replace("\\", "\\\\").Replace("\r", "").Replace("\n", "\\n");
        var safeCategory = (category ?? "info").Replace("|", "_").Replace("\n", "");
        var line = $"{DateTime.UtcNow:O}|{safeCategory}|{safeText}";
        lock (_gate)
        {
            _writer.WriteLine(line);
        }
    }

    public void Dispose()
    {
        lock (_gate)
        {
            try { _writer.Dispose(); } catch { }
        }
    }
}

namespace EraOnline.Client.CLI.Session;

/// <summary>
/// Per-character journal for maintaining session continuity across context windows.
/// Appends timestamped entries to a markdown file.
/// </summary>
public class Journal
{
    private readonly string _filePath;

    public Journal(string characterDataDir)
    {
        Directory.CreateDirectory(characterDataDir);
        _filePath = Path.Combine(characterDataDir, "journal.md");
    }

    public void Write(string entry)
    {
        var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm");
        var text = $"\n## {timestamp}\n\n{entry}\n";
        File.AppendAllText(_filePath, text);
    }

    public string Read(int maxLines = 100)
    {
        if (!File.Exists(_filePath))
            return "(No journal entries yet.)";

        var lines = File.ReadAllLines(_filePath);
        if (lines.Length <= maxLines)
            return string.Join('\n', lines);

        // Return the last N lines
        return "...(earlier entries omitted)...\n" +
               string.Join('\n', lines.Skip(lines.Length - maxLines));
    }
}

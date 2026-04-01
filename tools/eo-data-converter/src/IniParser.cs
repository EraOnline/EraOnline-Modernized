namespace EoDataConverter;

/// <summary>
/// Parses VB6-style INI files (Windows GetPrivateProfileString format).
/// Sections are [SectionName], keys are Key=Value.
/// </summary>
public class IniParser
{
    private readonly Dictionary<string, Dictionary<string, string>> _sections = new(StringComparer.OrdinalIgnoreCase);

    public static IniParser Load(string path)
    {
        var parser = new IniParser();
        if (!File.Exists(path)) return parser;

        string currentSection = "";
        foreach (var rawLine in File.ReadLines(path))
        {
            var line = rawLine.Trim();
            if (line.Length == 0 || line.StartsWith('\'') || line.StartsWith(';'))
                continue;

            if (line.StartsWith('[') && line.Contains(']'))
            {
                currentSection = line[1..line.IndexOf(']')];
                if (!parser._sections.ContainsKey(currentSection))
                    parser._sections[currentSection] = new(StringComparer.OrdinalIgnoreCase);
            }
            else if (line.Contains('=') && currentSection.Length > 0)
            {
                var eqIndex = line.IndexOf('=');
                var key = line[..eqIndex].Trim();
                var value = line[(eqIndex + 1)..].Trim();
                parser._sections[currentSection][key] = value;
            }
        }
        return parser;
    }

    public string GetVar(string section, string key, string defaultValue = "")
    {
        if (_sections.TryGetValue(section, out var sec) && sec.TryGetValue(key, out var val))
            return val;
        return defaultValue;
    }

    public int GetInt(string section, string key, int defaultValue = 0)
    {
        var s = GetVar(section, key);
        return int.TryParse(s, out var v) ? v : defaultValue;
    }

    public long GetLong(string section, string key, long defaultValue = 0)
    {
        var s = GetVar(section, key);
        return long.TryParse(s, out var v) ? v : defaultValue;
    }

    public IEnumerable<string> Sections => _sections.Keys;
}

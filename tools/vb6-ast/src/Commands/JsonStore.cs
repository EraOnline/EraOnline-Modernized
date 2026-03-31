using System.Text.Json;
using System.Text.Json.Serialization;
using Vb6Ast.Models;

namespace Vb6Ast.Commands;

/// <summary>
/// Handles reading/writing JSON data files, with support for merging
/// (preserving annotations when re-parsing).
/// </summary>
public static class JsonStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    };

    public static string GetDataDir()
    {
        // Walk up from current directory to find the tools/vb6-ast/data directory
        var dir = Directory.GetCurrentDirectory();
        while (dir != null)
        {
            var candidate = Path.Combine(dir, "tools", "vb6-ast", "data");
            if (Directory.Exists(candidate))
                return candidate;
            // Also check if we're inside the tool directory
            if (Path.GetFileName(dir) == "vb6-ast")
                return Path.Combine(dir, "data");
            dir = Path.GetDirectoryName(dir);
        }
        // Default: relative to current directory
        return Path.Combine(Directory.GetCurrentDirectory(), "tools", "vb6-ast", "data");
    }

    public static string GetSourceDir()
    {
        var dir = Directory.GetCurrentDirectory();
        while (dir != null)
        {
            var candidate = Path.Combine(dir, "src_vb6");
            if (Directory.Exists(candidate))
                return candidate;
            dir = Path.GetDirectoryName(dir);
        }
        return Path.Combine(Directory.GetCurrentDirectory(), "src_vb6");
    }

    public static string GetJsonPath(string dataDir, string relativePath)
    {
        // Convert e.g. "Server/GameLogic.bas" to "Server/GameLogic.json"
        var jsonRelative = Path.ChangeExtension(relativePath, ".json");
        return Path.Combine(dataDir, jsonRelative);
    }

    public static void SaveModule(string path, Vb6Module module)
    {
        var dir = Path.GetDirectoryName(path);
        if (dir != null && !Directory.Exists(dir))
            Directory.CreateDirectory(dir);

        var json = JsonSerializer.Serialize(module, JsonOptions);
        File.WriteAllText(path, json);
    }

    public static Vb6Module? LoadModule(string path)
    {
        if (!File.Exists(path))
            return null;

        var json = File.ReadAllText(path);
        return JsonSerializer.Deserialize<Vb6Module>(json, JsonOptions);
    }

    /// <summary>
    /// Merge a newly parsed module with existing data, preserving manual annotations.
    /// Strategy: keep manual annotations (purpose, notes, status, csharpLocation) from existing,
    /// but prefer auto-detected sends/calls from the fresh parse when they're richer.
    /// </summary>
    public static Vb6Module MergeModules(Vb6Module parsed, Vb6Module existing)
    {
        foreach (var member in parsed.Members)
        {
            var existingMember = existing.Members.FirstOrDefault(m => m.Name == member.Name && m.Kind == member.Kind);
            if (existingMember != null)
            {
                MergeAnnotations(member.Annotations, existingMember.Annotations);
            }
        }

        foreach (var type in parsed.Types)
        {
            var existingType = existing.Types.FirstOrDefault(t => t.Name == type.Name);
            if (existingType != null)
            {
                MergeAnnotations(type.Annotations, existingType.Annotations);
            }
        }

        foreach (var constant in parsed.Constants)
        {
            var existingConst = existing.Constants.FirstOrDefault(c => c.Name == constant.Name);
            if (existingConst != null)
            {
                MergeAnnotations(constant.Annotations, existingConst.Annotations);
            }
        }

        foreach (var variable in parsed.Variables)
        {
            var existingVar = existing.Variables.FirstOrDefault(v => v.Name == variable.Name);
            if (existingVar != null)
            {
                MergeAnnotations(variable.Annotations, existingVar.Annotations);
            }
        }

        return parsed;
    }

    /// <summary>
    /// Merge annotations: manual fields (purpose, notes, status, csharpLocation) always
    /// come from existing. For sends/calls, prefer the richer source - auto-detected
    /// from a fresh parse is usually more complete than manual, but if someone manually
    /// set them we keep the manual version.
    /// </summary>
    private static void MergeAnnotations(Annotations parsed, Annotations existing)
    {
        // Manual fields: always preserve from existing
        parsed.Purpose = existing.Purpose ?? parsed.Purpose;
        parsed.Status = existing.Status != "not-started" ? existing.Status : parsed.Status;
        parsed.CsharpLocation = existing.CsharpLocation ?? parsed.CsharpLocation;

        // Notes: merge both, deduplicated
        var allNotes = existing.Notes.Concat(parsed.Notes).Where(n => !string.IsNullOrEmpty(n)).Distinct().ToList();
        parsed.Notes = allNotes;

        // Sends/Calls: if existing has manually-set values, keep them.
        // Otherwise use the auto-detected ones from the fresh parse.
        // Heuristic: if existing has values, they were either manually set or auto-detected
        // from a previous parse. Either way they're valid. But fresh auto-detection
        // may find more. Take the longer list.
        if (existing.Sends.Count > parsed.Sends.Count)
            parsed.Sends = existing.Sends;
        if (existing.Calls.Count > parsed.Calls.Count)
            parsed.Calls = existing.Calls;
    }

    public static IEnumerable<Vb6Module> LoadAllModules(string dataDir)
    {
        if (!Directory.Exists(dataDir))
            yield break;

        foreach (var file in Directory.GetFiles(dataDir, "*.json", SearchOption.AllDirectories))
        {
            var module = LoadModule(file);
            if (module != null)
                yield return module;
        }
    }
}

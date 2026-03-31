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
    /// Merge a newly parsed module with existing data, preserving annotations.
    /// </summary>
    public static Vb6Module MergeModules(Vb6Module parsed, Vb6Module existing)
    {
        // Use the newly parsed structure but preserve annotations from existing
        foreach (var member in parsed.Members)
        {
            var existingMember = existing.Members.FirstOrDefault(m => m.Name == member.Name && m.Kind == member.Kind);
            if (existingMember != null)
            {
                member.Annotations = existingMember.Annotations;
            }
        }

        foreach (var type in parsed.Types)
        {
            var existingType = existing.Types.FirstOrDefault(t => t.Name == type.Name);
            if (existingType != null)
            {
                type.Annotations = existingType.Annotations;
            }
        }

        foreach (var constant in parsed.Constants)
        {
            var existingConst = existing.Constants.FirstOrDefault(c => c.Name == constant.Name);
            if (existingConst != null)
            {
                constant.Annotations = existingConst.Annotations;
            }
        }

        foreach (var variable in parsed.Variables)
        {
            var existingVar = existing.Variables.FirstOrDefault(v => v.Name == variable.Name);
            if (existingVar != null)
            {
                variable.Annotations = existingVar.Annotations;
            }
        }

        return parsed;
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

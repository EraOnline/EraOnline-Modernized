using Vb6Ast.Commands;
using Vb6Ast.Models;
using Vb6Ast.Parsing;

// Module matching: supports "GameLogic" (name only) or "Server/GameLogic" (project-qualified)
static bool ModuleMatches(Vb6Module module, string filter)
{
    // Exact name match
    if (module.Name.Equals(filter, StringComparison.OrdinalIgnoreCase))
        return true;

    // Path-qualified match: "Server/GameLogic" matches sourcePath "Server/GameLogic.bas"
    var sourceWithoutExt = Path.ChangeExtension(module.SourcePath, null);
    if (sourceWithoutExt.Equals(filter, StringComparison.OrdinalIgnoreCase))
        return true;

    // Partial path match: "Server/General" matches "Server/General"
    if (sourceWithoutExt.Contains(filter, StringComparison.OrdinalIgnoreCase))
        return true;

    return false;
}

if (args.Length == 0)
{
    PrintUsage();
    return 0;
}

var command = args[0].ToLowerInvariant();
var rest = args[1..];

return command switch
{
    "parse" => RunParse(rest),
    "list" => RunList(rest),
    "show" => RunShow(rest),
    "annotate" => RunAnnotate(rest),
    "query" => RunQuery(rest),
    "stats" => RunStats(rest),
    _ => PrintUsage()
};

// ─── Parse ───────────────────────────────────────────────────────────

int RunParse(string[] args)
{
    var sourceDir = JsonStore.GetSourceDir();
    var dataDir = JsonStore.GetDataDir();

    string? fileFilter = null;
    for (int i = 0; i < args.Length; i++)
    {
        if (args[i] == "--file" && i + 1 < args.Length)
            fileFilter = args[++i];
    }

    if (!Directory.Exists(sourceDir))
    {
        Console.Error.WriteLine($"Source directory not found: {sourceDir}");
        return 1;
    }

    var parser = new Vb6FileParser();
    var files = Directory.GetFiles(sourceDir, "*.bas", SearchOption.AllDirectories)
        .Concat(Directory.GetFiles(sourceDir, "*.frm", SearchOption.AllDirectories))
        .Where(f => !f.EndsWith(".frx", StringComparison.OrdinalIgnoreCase))
        .OrderBy(f => f);

    int parsed = 0, errors = 0;

    foreach (var file in files)
    {
        var relativePath = Path.GetRelativePath(sourceDir, file);

        if (fileFilter != null && !relativePath.Contains(fileFilter, StringComparison.OrdinalIgnoreCase))
            continue;

        try
        {
            var module = parser.Parse(file, relativePath);
            var jsonPath = JsonStore.GetJsonPath(dataDir, relativePath);

            // Merge with existing data to preserve annotations
            var existing = JsonStore.LoadModule(jsonPath);
            if (existing != null)
            {
                module = JsonStore.MergeModules(module, existing);
            }

            JsonStore.SaveModule(jsonPath, module);

            var memberCount = module.Members.Count;
            var typeCount = module.Types.Count;
            var constCount = module.Constants.Count;
            var varCount = module.Variables.Count;
            var total = memberCount + typeCount + constCount + varCount;

            Console.WriteLine($"  {relativePath,-45} {memberCount,3} members  {typeCount,2} types  {constCount,3} consts  {varCount,2} vars");
            parsed++;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"  ERROR {relativePath}: {ex.Message}");
            errors++;
        }
    }

    Console.WriteLine($"\nParsed {parsed} files ({errors} errors). Data saved to {dataDir}");
    return errors > 0 ? 1 : 0;
}

// ─── List ────────────────────────────────────────────────────────────

int RunList(string[] args)
{
    var dataDir = JsonStore.GetDataDir();
    if (args.Length == 0)
    {
        Console.Error.WriteLine("Usage: vb6-ast list <modules|members|types|constants|globals> [--module NAME]");
        return 1;
    }

    var what = args[0].ToLowerInvariant();
    string? moduleFilter = null;
    for (int i = 0; i < args.Length; i++)
    {
        if (args[i] == "--module" && i + 1 < args.Length)
            moduleFilter = args[++i];
    }

    var modules = JsonStore.LoadAllModules(dataDir)
        .Where(m => moduleFilter == null || ModuleMatches(m, moduleFilter))
        .OrderBy(m => m.SourcePath)
        .ToList();

    switch (what)
    {
        case "modules":
            Console.WriteLine($"{"Module",-30} {"Source Path",-45} {"Members",8} {"Types",6} {"Consts",7} {"Vars",5}");
            Console.WriteLine(new string('-', 105));
            foreach (var m in modules)
            {
                var qualifiedName = Path.ChangeExtension(m.SourcePath, null);
                Console.WriteLine($"{qualifiedName,-30} {m.SourcePath,-45} {m.Members.Count,8} {m.Types.Count,6} {m.Constants.Count,7} {m.Variables.Count,5}");
            }
            Console.WriteLine($"\nTotal: {modules.Count} modules");
            Console.WriteLine("Tip: Use --module Server/General to disambiguate modules with the same name across projects.");
            break;

        case "members":
            foreach (var m in modules)
            {
                if (m.Members.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Name} ({m.SourcePath}) ===");
                foreach (var member in m.Members)
                {
                    var status = member.Annotations.Status == "not-started" ? " " :
                                 member.Annotations.Status == "ported" ? "x" :
                                 member.Annotations.Status == "skipped" ? "-" : "~";
                    Console.WriteLine($"  [{status}] {member.Kind,-8} {member.Name,-35} L{member.LineStart}-{member.LineEnd}");
                }
            }
            break;

        case "types":
            foreach (var m in modules)
            {
                if (m.Types.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Name} ===");
                foreach (var t in m.Types)
                {
                    Console.WriteLine($"  Type {t.Name} ({t.Fields.Count} fields) L{t.LineStart}-{t.LineEnd}");
                    foreach (var f in t.Fields)
                    {
                        var arrayInfo = f.IsArray ? $"({f.ArrayBounds})" : "";
                        Console.WriteLine($"    {f.Name,-25} As {f.FieldType}{arrayInfo}");
                    }
                }
            }
            break;

        case "constants":
            foreach (var m in modules)
            {
                if (m.Constants.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Name} ===");
                foreach (var c in m.Constants)
                {
                    Console.WriteLine($"  {c.Visibility,-7} Const {c.Name,-35} = {c.Value}");
                }
            }
            break;

        case "globals":
            foreach (var m in modules)
            {
                if (m.Variables.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Name} ===");
                foreach (var v in m.Variables)
                {
                    var arrayInfo = v.IsArray ? $"({v.ArrayBounds})" : "";
                    Console.WriteLine($"  {v.Visibility,-7} {v.Name,-35} As {v.VariableType}{arrayInfo}");
                }
            }
            break;

        default:
            Console.Error.WriteLine($"Unknown list type: {what}. Use: modules, members, types, constants, globals");
            return 1;
    }

    return 0;
}

// ─── Show ────────────────────────────────────────────────────────────

int RunShow(string[] args)
{
    var dataDir = JsonStore.GetDataDir();
    if (args.Length == 0)
    {
        Console.Error.WriteLine("Usage: vb6-ast show <name> [--type]");
        return 1;
    }

    bool showType = args.Contains("--type");
    var name = args.First(a => !a.StartsWith("--"));

    var modules = JsonStore.LoadAllModules(dataDir).ToList();

    if (showType)
    {
        var found = modules.SelectMany(m => m.Types.Select(t => (Module: m, Type: t)))
            .Where(x => x.Type.Name.Equals(name, StringComparison.OrdinalIgnoreCase))
            .ToList();

        if (found.Count == 0)
        {
            Console.Error.WriteLine($"Type '{name}' not found.");
            return 1;
        }

        foreach (var (module, type) in found)
        {
            Console.WriteLine($"Type: {type.Name}");
            Console.WriteLine($"Module: {module.Name} ({module.SourcePath})");
            Console.WriteLine($"Lines: {type.LineStart}-{type.LineEnd}");
            Console.WriteLine($"Status: {type.Annotations.Status}");
            if (type.Annotations.Purpose != null)
                Console.WriteLine($"Purpose: {type.Annotations.Purpose}");
            if (type.Annotations.CsharpLocation != null)
                Console.WriteLine($"C# Location: {type.Annotations.CsharpLocation}");
            Console.WriteLine($"Fields ({type.Fields.Count}):");
            foreach (var f in type.Fields)
            {
                var arrayInfo = f.IsArray ? $"({f.ArrayBounds})" : "";
                Console.WriteLine($"  {f.Name,-25} As {f.FieldType}{arrayInfo}");
            }
            foreach (var note in type.Annotations.Notes)
                Console.WriteLine($"Note: {note}");
        }
    }
    else
    {
        var found = modules.SelectMany(m => m.Members.Select(member => (Module: m, Member: member)))
            .Where(x => x.Member.Name.Equals(name, StringComparison.OrdinalIgnoreCase))
            .ToList();

        if (found.Count == 0)
        {
            Console.Error.WriteLine($"Member '{name}' not found.");
            return 1;
        }

        foreach (var (module, member) in found)
        {
            Console.WriteLine($"{member.Kind}: {member.Name}");
            Console.WriteLine($"Module: {module.Name} ({module.SourcePath})");
            Console.WriteLine($"Params: {member.Params}");
            if (member.ReturnType != null)
                Console.WriteLine($"Returns: {member.ReturnType}");
            Console.WriteLine($"Lines: {member.LineStart}-{member.LineEnd}");
            Console.WriteLine($"Visibility: {member.Visibility}");
            Console.WriteLine($"Status: {member.Annotations.Status}");
            if (member.Annotations.Purpose != null)
                Console.WriteLine($"Purpose: {member.Annotations.Purpose}");
            if (member.Annotations.CsharpLocation != null)
                Console.WriteLine($"C# Location: {member.Annotations.CsharpLocation}");
            if (member.Annotations.Sends.Count > 0)
                Console.WriteLine($"Sends: {string.Join(", ", member.Annotations.Sends)}");
            if (member.Annotations.Calls.Count > 0)
                Console.WriteLine($"Calls: {string.Join(", ", member.Annotations.Calls)}");
            foreach (var note in member.Annotations.Notes)
                Console.WriteLine($"Note: {note}");

            if (found.Count > 1)
                Console.WriteLine("---");
        }
    }

    return 0;
}

// ─── Annotate ────────────────────────────────────────────────────────

int RunAnnotate(string[] args)
{
    var dataDir = JsonStore.GetDataDir();
    if (args.Length < 2)
    {
        Console.Error.WriteLine("Usage: vb6-ast annotate <name> --purpose TEXT | --note TEXT | --status STATUS | --csharp LOC | --sends MSG,MSG | --calls FN,FN");
        return 1;
    }

    var name = args[0];
    bool isType = args.Contains("--type");

    // Parse flags
    string? purpose = null, note = null, status = null, csharp = null, sends = null, calls = null;
    for (int i = 1; i < args.Length; i++)
    {
        switch (args[i])
        {
            case "--purpose" when i + 1 < args.Length: purpose = args[++i]; break;
            case "--note" when i + 1 < args.Length: note = args[++i]; break;
            case "--status" when i + 1 < args.Length: status = args[++i]; break;
            case "--csharp" when i + 1 < args.Length: csharp = args[++i]; break;
            case "--sends" when i + 1 < args.Length: sends = args[++i]; break;
            case "--calls" when i + 1 < args.Length: calls = args[++i]; break;
        }
    }

    var modules = JsonStore.LoadAllModules(dataDir).ToList();
    var jsonFiles = Directory.GetFiles(dataDir, "*.json", SearchOption.AllDirectories);
    int updated = 0;

    foreach (var jsonFile in jsonFiles)
    {
        var module = JsonStore.LoadModule(jsonFile);
        if (module == null) continue;

        bool changed = false;

        if (isType)
        {
            foreach (var type in module.Types.Where(t => t.Name.Equals(name, StringComparison.OrdinalIgnoreCase)))
            {
                ApplyAnnotation(type.Annotations, purpose, note, status, csharp, sends, calls);
                changed = true;
                updated++;
            }
        }
        else
        {
            foreach (var member in module.Members.Where(m => m.Name.Equals(name, StringComparison.OrdinalIgnoreCase)))
            {
                ApplyAnnotation(member.Annotations, purpose, note, status, csharp, sends, calls);
                changed = true;
                updated++;
            }
        }

        if (changed)
        {
            JsonStore.SaveModule(jsonFile, module);
        }
    }

    Console.WriteLine($"Updated {updated} item(s).");
    return updated > 0 ? 0 : 1;
}

void ApplyAnnotation(Annotations ann, string? purpose, string? note, string? status, string? csharp, string? sends, string? calls)
{
    if (purpose != null) ann.Purpose = purpose;
    if (note != null && !ann.Notes.Contains(note)) ann.Notes.Add(note);
    if (status != null) ann.Status = status;
    if (csharp != null) ann.CsharpLocation = csharp;
    if (sends != null) ann.Sends = sends.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();
    if (calls != null) ann.Calls = calls.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();
}

// ─── Query ───────────────────────────────────────────────────────────

int RunQuery(string[] args)
{
    var dataDir = JsonStore.GetDataDir();

    string? statusFilter = null, moduleFilter = null, sendsFilter = null, callsFilter = null;
    bool unannotated = false, protocol = false;

    for (int i = 0; i < args.Length; i++)
    {
        switch (args[i])
        {
            case "--status" when i + 1 < args.Length: statusFilter = args[++i]; break;
            case "--module" when i + 1 < args.Length: moduleFilter = args[++i]; break;
            case "--sends" when i + 1 < args.Length: sendsFilter = args[++i]; break;
            case "--calls" when i + 1 < args.Length: callsFilter = args[++i]; break;
            case "--unannotated": unannotated = true; break;
            case "--protocol": protocol = true; break;
        }
    }

    var modules = JsonStore.LoadAllModules(dataDir)
        .Where(m => moduleFilter == null || ModuleMatches(m, moduleFilter))
        .OrderBy(m => m.SourcePath)
        .ToList();

    if (protocol)
    {
        // List all unique protocol messages across all members
        var allSends = modules
            .SelectMany(m => m.Members)
            .SelectMany(member => member.Annotations.Sends)
            .Distinct()
            .OrderBy(s => s);

        Console.WriteLine("Known protocol messages (from annotations):");
        foreach (var msg in allSends)
        {
            var senders = modules
                .SelectMany(m => m.Members.Where(member => member.Annotations.Sends.Contains(msg)).Select(member => $"{m.Name}.{member.Name}"))
                .ToList();
            Console.WriteLine($"  {msg,-10} sent by: {string.Join(", ", senders)}");
        }
        return 0;
    }

    var results = modules.SelectMany(m => m.Members.Select(member => (Module: m, Member: member)));

    if (statusFilter != null)
        results = results.Where(x => x.Member.Annotations.Status.Equals(statusFilter, StringComparison.OrdinalIgnoreCase));

    if (unannotated)
        results = results.Where(x => string.IsNullOrEmpty(x.Member.Annotations.Purpose));

    if (sendsFilter != null)
        results = results.Where(x => x.Member.Annotations.Sends.Any(s => s.Equals(sendsFilter, StringComparison.OrdinalIgnoreCase)));

    if (callsFilter != null)
        results = results.Where(x => x.Member.Annotations.Calls.Any(c => c.Equals(callsFilter, StringComparison.OrdinalIgnoreCase)));

    var list = results.ToList();

    foreach (var (module, member) in list)
    {
        var statusTag = member.Annotations.Status switch
        {
            "ported" => "[x]",
            "skipped" => "[-]",
            "in-progress" => "[~]",
            _ => "[ ]"
        };
        var qualifiedName = Path.ChangeExtension(module.SourcePath, null);
        Console.WriteLine($"  {statusTag} {qualifiedName,-25} {member.Kind,-8} {member.Name,-35} L{member.LineStart}-{member.LineEnd}");
    }

    Console.WriteLine($"\n{list.Count} results.");
    return 0;
}

// ─── Stats ───────────────────────────────────────────────────────────

int RunStats(string[] args)
{
    var dataDir = JsonStore.GetDataDir();

    string? moduleFilter = null;
    for (int i = 0; i < args.Length; i++)
    {
        if (args[i] == "--module" && i + 1 < args.Length)
            moduleFilter = args[++i];
    }

    var modules = JsonStore.LoadAllModules(dataDir)
        .Where(m => moduleFilter == null || ModuleMatches(m, moduleFilter))
        .OrderBy(m => m.SourcePath)
        .ToList();

    int totalMembers = 0, ported = 0, skipped = 0, inProgress = 0, notStarted = 0;
    int totalAnnotated = 0;
    int totalTypes = 0, totalConsts = 0, totalVars = 0;

    Console.WriteLine($"{"Module",-30} {"Total",6} {"Ported",7} {"Skip",5} {"WIP",4} {"TODO",5} {"Ann%",5}");
    Console.WriteLine(new string('-', 65));

    foreach (var m in modules)
    {
        int mTotal = m.Members.Count;
        int mPorted = m.Members.Count(x => x.Annotations.Status == "ported");
        int mSkipped = m.Members.Count(x => x.Annotations.Status == "skipped");
        int mInProgress = m.Members.Count(x => x.Annotations.Status == "in-progress");
        int mNotStarted = m.Members.Count(x => x.Annotations.Status == "not-started");
        int mAnnotated = m.Members.Count(x => !string.IsNullOrEmpty(x.Annotations.Purpose));
        var annPct = mTotal > 0 ? (mAnnotated * 100 / mTotal).ToString() + "%" : "-";

        if (mTotal > 0)
        {
            var qualifiedName = Path.ChangeExtension(m.SourcePath, null);
            Console.WriteLine($"{qualifiedName,-30} {mTotal,6} {mPorted,7} {mSkipped,5} {mInProgress,4} {mNotStarted,5} {annPct,5}");
        }

        totalMembers += mTotal;
        ported += mPorted;
        skipped += mSkipped;
        inProgress += mInProgress;
        notStarted += mNotStarted;
        totalAnnotated += mAnnotated;
        totalTypes += m.Types.Count;
        totalConsts += m.Constants.Count;
        totalVars += m.Variables.Count;
    }

    Console.WriteLine(new string('-', 65));
    var totalAnnPct = totalMembers > 0 ? (totalAnnotated * 100 / totalMembers).ToString() + "%" : "-";
    Console.WriteLine($"{"TOTAL",-30} {totalMembers,6} {ported,7} {skipped,5} {inProgress,4} {notStarted,5} {totalAnnPct,5}");

    Console.WriteLine($"\nTypes: {totalTypes}  Constants: {totalConsts}  Global Variables: {totalVars}");
    Console.WriteLine($"Modules: {modules.Count}");

    return 0;
}

// ─── Usage ───────────────────────────────────────────────────────────

int PrintUsage()
{
    Console.WriteLine("""
    vb6-ast - VB6 source code analyzer for Era Online

    Usage:
      vb6-ast parse [--file PATTERN]              Parse VB6 files and generate/update JSON data
      vb6-ast list <what> [--module NAME]          List modules|members|types|constants|globals
      vb6-ast show <name> [--type]                 Show details of a member or type
      vb6-ast annotate <name> [OPTIONS]            Add annotations to a member or type
        --purpose TEXT    Set purpose description
        --note TEXT       Add a note (appends)
        --status STATUS   Set status: not-started|in-progress|ported|skipped
        --csharp LOC      Set C# implementation location
        --sends MSG,MSG   Set protocol messages sent
        --calls FN,FN     Set functions called
        --type            Target a type definition instead of a member
      vb6-ast query [OPTIONS]                      Search across all modules
        --status STATUS   Filter by porting status
        --module NAME     Filter by module name
        --sends MSG       Find members that send a protocol message
        --calls FN        Find members that call a function
        --unannotated     Find members with no purpose set
        --protocol        List all known protocol messages
      vb6-ast stats [--module NAME]                Show porting progress
    """);
    return 0;
}

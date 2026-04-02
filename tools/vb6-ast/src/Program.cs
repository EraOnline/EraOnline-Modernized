using Vb6Ast.Commands;
using Vb6Ast.Models;
using Vb6Ast.Parsing;

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

// ─── Helpers ─────────────────────────────────────────────────────────

/// <summary>
/// Resolve an address like "Server/GameLogic:UserDie" or "Server/GameLogic" to a module.
/// Addresses are unambiguous paths: "Project/Module" for modules, "Project/Module:MemberName" for members.
/// </summary>
static (Vb6Module? Module, string? MemberName, string JsonPath) ResolveAddress(string address, string dataDir)
{
    string modulePart;
    string? memberName = null;

    if (address.Contains(':'))
    {
        var parts = address.Split(':', 2);
        modulePart = parts[0];
        memberName = parts[1];
    }
    else
    {
        modulePart = address;
    }

    // modulePart should be like "Server/GameLogic"
    var jsonPath = Path.Combine(dataDir, modulePart + ".json");
    if (!File.Exists(jsonPath))
    {
        // Try case-insensitive search
        var dir = Path.GetDirectoryName(jsonPath);
        var file = Path.GetFileName(jsonPath);
        if (dir != null && Directory.Exists(dir))
        {
            var match = Directory.GetFiles(dir, "*.json")
                .FirstOrDefault(f => Path.GetFileName(f).Equals(file, StringComparison.OrdinalIgnoreCase));
            if (match != null)
                jsonPath = match;
        }
    }

    var module = JsonStore.LoadModule(jsonPath);
    return (module, memberName, jsonPath);
}

static bool ModuleMatches(Vb6Module module, string filter)
{
    if (module.Address.Equals(filter, StringComparison.OrdinalIgnoreCase))
        return true;
    if (module.Name.Equals(filter, StringComparison.OrdinalIgnoreCase))
        return true;
    if (module.SourcePath.Contains(filter, StringComparison.OrdinalIgnoreCase))
        return true;
    return false;
}

static string GetFlag(string[] args, string flag)
{
    for (int i = 0; i < args.Length; i++)
        if (args[i] == flag && i + 1 < args.Length)
            return args[i + 1];
    return "";
}

static bool HasFlag(string[] args, string flag) => args.Contains(flag);

// ─── Parse ───────────────────────────────────────────────────────────

int RunParse(string[] args)
{
    var sourceDir = JsonStore.GetSourceDir();
    var dataDir = JsonStore.GetDataDir();
    var fileFilter = GetFlag(args, "--file");

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
        if (fileFilter != "" && !relativePath.Contains(fileFilter, StringComparison.OrdinalIgnoreCase))
            continue;

        try
        {
            var module = parser.Parse(file, relativePath);
            var jsonPath = JsonStore.GetJsonPath(dataDir, relativePath);

            // Merge with existing data to preserve annotations
            var existing = JsonStore.LoadModule(jsonPath);
            if (existing != null)
                module = JsonStore.MergeModules(module, existing);

            JsonStore.SaveModule(jsonPath, module);

            var memberCount = module.Members.Count;
            var typeCount = module.Types.Count;
            var constCount = module.Constants.Count;
            var varCount = module.Variables.Count;
            var controlCount = module.Controls.Count;

            Console.WriteLine($"  {module.Address,-40} {memberCount,3} members  {typeCount,2} types  {constCount,3} consts  {varCount,2} vars  {controlCount,2} controls");
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
        Console.Error.WriteLine("Usage: vb6-ast list <modules|members|types|constants|globals|controls> [--module ADDRESS]");
        return 1;
    }

    var what = args[0].ToLowerInvariant();
    var moduleFilter = GetFlag(args, "--module");

    var modules = JsonStore.LoadAllModules(dataDir)
        .Where(m => moduleFilter == "" || ModuleMatches(m, moduleFilter))
        .OrderBy(m => m.SourcePath)
        .ToList();

    switch (what)
    {
        case "modules":
            Console.WriteLine($"{"Address",-35} {"Source",-45} {"Mbr",4} {"Typ",4} {"Con",4} {"Var",4} {"Ctl",4}");
            Console.WriteLine(new string('-', 105));
            foreach (var m in modules)
            {
                Console.WriteLine($"{m.Address,-35} {m.SourcePath,-45} {m.Members.Count,4} {m.Types.Count,4} {m.Constants.Count,4} {m.Variables.Count,4} {m.Controls.Count,4}");
            }
            Console.WriteLine($"\nTotal: {modules.Count} modules");
            break;

        case "members":
            foreach (var m in modules)
            {
                if (m.Members.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Address} ({m.SourcePath}) ===");
                foreach (var member in m.Members)
                {
                    var status = member.Annotations.Status switch
                    {
                        "ported" => "x", "skipped" => "-", "in-progress" => "~", _ => " "
                    };
                    Console.WriteLine($"  [{status}] {member.Kind,-8} {member.Name,-35} L{member.LineStart}-{member.LineEnd}  {m.Address}:{member.Name}");
                }
            }
            break;

        case "types":
            foreach (var m in modules)
            {
                if (m.Types.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Address} ===");
                foreach (var t in m.Types)
                {
                    var statusTag = t.Annotations.Status switch { "ported" => "[x]", "skipped" => "[-]", "in-progress" => "[~]", _ => "[ ]" };
                    var csharpInfo = t.Annotations.CsharpLocation != null ? $"  -> {t.Annotations.CsharpLocation}" : "";
                    Console.WriteLine($"  {statusTag} Type {t.Name} ({t.Fields.Count} fields) L{t.LineStart}-{t.LineEnd}{csharpInfo}");
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
                Console.WriteLine($"\n=== {m.Address} ===");
                foreach (var c in m.Constants)
                {
                    var statusTag = c.Annotations.Status switch { "ported" => "[x]", "skipped" => "[-]", "in-progress" => "[~]", _ => "[ ]" };
                    var csharpInfo = c.Annotations.CsharpLocation != null ? $"  -> {c.Annotations.CsharpLocation}" : "";
                    Console.WriteLine($"  {statusTag} {c.Visibility,-7} Const {c.Name,-35} = {c.Value}{csharpInfo}");
                }
            }
            break;

        case "globals":
            foreach (var m in modules)
            {
                if (m.Variables.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Address} ===");
                foreach (var v in m.Variables)
                {
                    var statusTag = v.Annotations.Status switch { "ported" => "[x]", "skipped" => "[-]", "in-progress" => "[~]", _ => "[ ]" };
                    var csharpInfo = v.Annotations.CsharpLocation != null ? $"  -> {v.Annotations.CsharpLocation}" : "";
                    var arrayInfo = v.IsArray ? $"({v.ArrayBounds})" : "";
                    Console.WriteLine($"  {statusTag} {v.Visibility,-7} {v.Name,-35} As {v.VariableType}{arrayInfo}{csharpInfo}");
                }
            }
            break;

        case "controls":
            foreach (var m in modules)
            {
                if (m.Controls.Count == 0) continue;
                Console.WriteLine($"\n=== {m.Address} ({m.SourcePath}) ===");
                foreach (var c in m.Controls)
                {
                    var interval = c.Properties.GetValueOrDefault("Interval", "");
                    var intervalStr = interval != "" && interval != "0" ? $" Interval={interval}ms" : "";
                    Console.WriteLine($"  {c.ControlType,-35} {c.Name,-25}{intervalStr}");
                    foreach (var (key, value) in c.Properties.Where(p => p.Key != "Left" && p.Key != "Top" && p.Key != "Height" && p.Key != "Width" && p.Key != "TabIndex"))
                    {
                        Console.WriteLine($"    {key} = {value}");
                    }
                }
            }
            break;

        default:
            Console.Error.WriteLine($"Unknown: {what}. Use: modules, members, types, constants, globals, controls");
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
        Console.Error.WriteLine("Usage: vb6-ast show <Address:Name> or <name> [--type]");
        return 1;
    }

    bool showType = HasFlag(args, "--type");
    var target = args.First(a => !a.StartsWith("--"));
    var modules = JsonStore.LoadAllModules(dataDir).ToList();

    // If the target contains ":", it's an address - resolve to specific module
    if (target.Contains(':'))
    {
        var (module, memberName, _) = ResolveAddress(target, dataDir);
        if (module == null) { Console.Error.WriteLine($"Module not found for: {target}"); return 1; }
        if (memberName == null) { Console.Error.WriteLine($"No member specified in: {target}"); return 1; }

        if (showType)
        {
            var type = module.Types.FirstOrDefault(t => t.Name.Equals(memberName, StringComparison.OrdinalIgnoreCase));
            if (type == null) { Console.Error.WriteLine($"Type '{memberName}' not found in {module.Address}"); return 1; }
            PrintType(module, type);
        }
        else
        {
            var member = module.Members.FirstOrDefault(m => m.Name.Equals(memberName, StringComparison.OrdinalIgnoreCase));
            if (member == null) { Console.Error.WriteLine($"Member '{memberName}' not found in {module.Address}"); return 1; }
            PrintMember(module, member);
        }
    }
    else
    {
        // Search across all modules (less precise, shows all matches)
        if (showType)
        {
            var found = modules.SelectMany(m => m.Types.Select(t => (Module: m, Type: t)))
                .Where(x => x.Type.Name.Equals(target, StringComparison.OrdinalIgnoreCase)).ToList();
            if (found.Count == 0) { Console.Error.WriteLine($"Type '{target}' not found."); return 1; }
            foreach (var (m, t) in found) { PrintType(m, t); Console.WriteLine("---"); }
        }
        else
        {
            var found = modules.SelectMany(m => m.Members.Select(member => (Module: m, Member: member)))
                .Where(x => x.Member.Name.Equals(target, StringComparison.OrdinalIgnoreCase)).ToList();
            if (found.Count == 0) { Console.Error.WriteLine($"Member '{target}' not found."); return 1; }
            foreach (var (m, member) in found) { PrintMember(m, member); Console.WriteLine("---"); }
        }
    }

    return 0;
}

void PrintMember(Vb6Module module, Vb6Member member)
{
    Console.WriteLine($"{member.Kind}: {member.Name}");
    Console.WriteLine($"Address: {module.Address}:{member.Name}");
    Console.WriteLine($"Module: {module.Name} ({module.SourcePath})");
    Console.WriteLine($"Params: {member.Params}");
    if (member.ReturnType != null) Console.WriteLine($"Returns: {member.ReturnType}");
    Console.WriteLine($"Lines: {member.LineStart}-{member.LineEnd}");
    Console.WriteLine($"Visibility: {member.Visibility}");
    Console.WriteLine($"Status: {member.Annotations.Status}");
    if (member.Annotations.Purpose != null) Console.WriteLine($"Purpose: {member.Annotations.Purpose}");
    if (member.Annotations.CsharpLocation != null) Console.WriteLine($"C# Location: {member.Annotations.CsharpLocation}");
    if (member.Annotations.Sends.Count > 0) Console.WriteLine($"Sends: {string.Join(", ", member.Annotations.Sends)}");
    if (member.Annotations.Calls.Count > 0) Console.WriteLine($"Calls: {string.Join(", ", member.Annotations.Calls)}");
    foreach (var note in member.Annotations.Notes) Console.WriteLine($"Note: {note}");
}

void PrintType(Vb6Module module, Vb6TypeDef type)
{
    Console.WriteLine($"Type: {type.Name}");
    Console.WriteLine($"Address: {module.Address}:{type.Name}");
    Console.WriteLine($"Module: {module.Name} ({module.SourcePath})");
    Console.WriteLine($"Lines: {type.LineStart}-{type.LineEnd}");
    Console.WriteLine($"Status: {type.Annotations.Status}");
    if (type.Annotations.Purpose != null) Console.WriteLine($"Purpose: {type.Annotations.Purpose}");
    if (type.Annotations.CsharpLocation != null) Console.WriteLine($"C# Location: {type.Annotations.CsharpLocation}");
    Console.WriteLine($"Fields ({type.Fields.Count}):");
    foreach (var f in type.Fields)
    {
        var arrayInfo = f.IsArray ? $"({f.ArrayBounds})" : "";
        Console.WriteLine($"  {f.Name,-25} As {f.FieldType}{arrayInfo}");
    }
    foreach (var note in type.Annotations.Notes) Console.WriteLine($"Note: {note}");
}

// ─── Annotate ────────────────────────────────────────────────────────

int RunAnnotate(string[] args)
{
    var dataDir = JsonStore.GetDataDir();
    if (args.Length < 2)
    {
        Console.Error.WriteLine("""
        Usage: vb6-ast annotate <address> [OPTIONS]

        Address format (required, must be unambiguous):
          Server/GameLogic:UserDie      A specific member in a specific module
          Server/Declarations:User      A specific type (with --type)
          Server/Declarations:NORTH     A constant (with --constant)
          Server/Declarations:UserList  A global variable (with --global)

        Options:
          --purpose TEXT    Set purpose description
          --note TEXT       Add a note (appends)
          --status STATUS   Set status: not-started|in-progress|ported|skipped
          --csharp LOC      Set C# implementation location
          --sends MSG,MSG   Set protocol messages sent
          --calls FN,FN     Set functions called
          --type            Target a type definition instead of a member
          --constant        Target a constant instead of a member
          --global          Target a global variable instead of a member
        """);
        return 1;
    }

    var address = args[0];
    if (!address.Contains(':'))
    {
        Console.Error.WriteLine($"Error: Address must be fully qualified as Module:Name (e.g., Server/GameLogic:UserDie)");
        Console.Error.WriteLine($"Got: {address}");
        return 1;
    }

    var (module, memberName, jsonPath) = ResolveAddress(address, dataDir);
    if (module == null)
    {
        Console.Error.WriteLine($"Module not found for address: {address}");
        return 1;
    }
    if (memberName == null)
    {
        Console.Error.WriteLine($"No member/type name in address: {address}");
        return 1;
    }

    bool isType = HasFlag(args, "--type");
    bool isConstant = HasFlag(args, "--constant");
    bool isGlobal = HasFlag(args, "--global");
    var purpose = GetFlag(args, "--purpose");
    var note = GetFlag(args, "--note");
    var status = GetFlag(args, "--status");
    var csharp = GetFlag(args, "--csharp");
    var sends = GetFlag(args, "--sends");
    var calls = GetFlag(args, "--calls");

    bool changed = false;

    if (isType)
    {
        var type = module.Types.FirstOrDefault(t => t.Name.Equals(memberName, StringComparison.OrdinalIgnoreCase));
        if (type == null) { Console.Error.WriteLine($"Type '{memberName}' not found in {module.Address}"); return 1; }
        ApplyAnnotation(type.Annotations, purpose, note, status, csharp, sends, calls);
        Console.WriteLine($"Updated type {memberName} in {module.Address}");
        changed = true;
    }
    else if (isConstant)
    {
        var constant = module.Constants.FirstOrDefault(c => c.Name.Equals(memberName, StringComparison.OrdinalIgnoreCase));
        if (constant == null) { Console.Error.WriteLine($"Constant '{memberName}' not found in {module.Address}"); return 1; }
        ApplyAnnotation(constant.Annotations, purpose, note, status, csharp, sends, calls);
        Console.WriteLine($"Updated constant {memberName} in {module.Address}");
        changed = true;
    }
    else if (isGlobal)
    {
        var variable = module.Variables.FirstOrDefault(v => v.Name.Equals(memberName, StringComparison.OrdinalIgnoreCase));
        if (variable == null) { Console.Error.WriteLine($"Global '{memberName}' not found in {module.Address}"); return 1; }
        ApplyAnnotation(variable.Annotations, purpose, note, status, csharp, sends, calls);
        Console.WriteLine($"Updated global {memberName} in {module.Address}");
        changed = true;
    }
    else
    {
        var member = module.Members.FirstOrDefault(m => m.Name.Equals(memberName, StringComparison.OrdinalIgnoreCase));
        if (member == null) { Console.Error.WriteLine($"Member '{memberName}' not found in {module.Address}"); return 1; }
        ApplyAnnotation(member.Annotations, purpose, note, status, csharp, sends, calls);
        Console.WriteLine($"Updated {member.Kind} {memberName} in {module.Address}");
        changed = true;
    }

    if (changed)
        JsonStore.SaveModule(jsonPath, module);

    return changed ? 0 : 1;
}

void ApplyAnnotation(Annotations ann, string purpose, string note, string status, string csharp, string sends, string calls)
{
    if (purpose != "") ann.Purpose = purpose;
    if (note != "" && !ann.Notes.Contains(note)) ann.Notes.Add(note);
    if (status != "") ann.Status = status;
    if (csharp != "") ann.CsharpLocation = csharp;
    if (sends != "") ann.Sends = sends.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();
    if (calls != "") ann.Calls = calls.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();
}

// ─── Query ───────────────────────────────────────────────────────────

int RunQuery(string[] args)
{
    var dataDir = JsonStore.GetDataDir();

    var statusFilter = GetFlag(args, "--status");
    var moduleFilter = GetFlag(args, "--module");
    var sendsFilter = GetFlag(args, "--sends");
    var callsFilter = GetFlag(args, "--calls");
    bool unannotated = HasFlag(args, "--unannotated");
    bool protocol = HasFlag(args, "--protocol");

    var modules = JsonStore.LoadAllModules(dataDir)
        .Where(m => moduleFilter == "" || ModuleMatches(m, moduleFilter))
        .OrderBy(m => m.SourcePath)
        .ToList();

    if (protocol)
    {
        var allSends = modules.SelectMany(m => m.Members)
            .SelectMany(member => member.Annotations.Sends)
            .Distinct().OrderBy(s => s);

        Console.WriteLine("Known protocol messages:");
        foreach (var msg in allSends)
        {
            var senders = modules
                .SelectMany(m => m.Members.Where(member => member.Annotations.Sends.Contains(msg))
                    .Select(member => $"{m.Address}:{member.Name}"))
                .ToList();
            Console.WriteLine($"  {msg,-10} sent by: {string.Join(", ", senders)}");
        }
        return 0;
    }

    // Build unified list of all annotatable items: members, types, constants, globals
    var items = new List<(Vb6Module Module, string Kind, string Name, Annotations Ann)>();

    foreach (var m in modules)
    {
        foreach (var member in m.Members)
            items.Add((m, member.Kind, member.Name, member.Annotations));
        foreach (var t in m.Types)
            items.Add((m, "type", t.Name, t.Annotations));
        foreach (var c in m.Constants)
            items.Add((m, "const", c.Name, c.Annotations));
        foreach (var v in m.Variables)
            items.Add((m, "global", v.Name, v.Annotations));
    }

    if (statusFilter != "") items = items.Where(x => x.Ann.Status.Equals(statusFilter, StringComparison.OrdinalIgnoreCase)).ToList();
    if (unannotated) items = items.Where(x => string.IsNullOrEmpty(x.Ann.Purpose)).ToList();
    if (sendsFilter != "") items = items.Where(x => x.Ann.Sends.Any(s => s.Equals(sendsFilter, StringComparison.OrdinalIgnoreCase))).ToList();
    if (callsFilter != "") items = items.Where(x => x.Ann.Calls.Any(c => c.Contains(callsFilter, StringComparison.OrdinalIgnoreCase))).ToList();

    foreach (var (module, kind, name, ann) in items)
    {
        var statusTag = ann.Status switch { "ported" => "[x]", "skipped" => "[-]", "in-progress" => "[~]", _ => "[ ]" };
        var csharpInfo = ann.CsharpLocation != null ? $"  -> {ann.CsharpLocation}" : "";
        Console.WriteLine($"  {statusTag} {module.Address}:{name,-35} {kind,-8}{csharpInfo}");
    }

    Console.WriteLine($"\n{items.Count} results.");
    return 0;
}

// ─── Stats ───────────────────────────────────────────────────────────

int RunStats(string[] args)
{
    var dataDir = JsonStore.GetDataDir();
    var moduleFilter = GetFlag(args, "--module");
    bool showAll = HasFlag(args, "--all");

    var modules = JsonStore.LoadAllModules(dataDir)
        .Where(m => moduleFilter == "" || ModuleMatches(m, moduleFilter))
        .OrderBy(m => m.SourcePath)
        .ToList();

    // Collect all annotatable items across all modules
    int totalMembers = 0, membersPorted = 0, membersSkipped = 0;
    int totalTypes = 0, typesPorted = 0, typesSkipped = 0;
    int totalConsts = 0, constsPorted = 0, constsSkipped = 0;
    int totalGlobals = 0, globalsPorted = 0, globalsSkipped = 0;
    int totalControls = 0;

    Console.WriteLine($"{"Address",-35} {"Func",5} {"Type",5} {"Const",6} {"Glob",5} {"Ported",7} {"Skip",5}");
    Console.WriteLine(new string('-', 75));

    foreach (var m in modules)
    {
        int mMembers = m.Members.Count;
        int mTypes = m.Types.Count;
        int mConsts = m.Constants.Count;
        int mGlobals = m.Variables.Count;
        int mTotal = mMembers + mTypes + mConsts + mGlobals;
        if (mTotal == 0 && !showAll) continue;

        int mPorted = m.Members.Count(x => x.Annotations.Status == "ported")
            + m.Types.Count(x => x.Annotations.Status == "ported")
            + m.Constants.Count(x => x.Annotations.Status == "ported")
            + m.Variables.Count(x => x.Annotations.Status == "ported");
        int mSkipped = m.Members.Count(x => x.Annotations.Status == "skipped")
            + m.Types.Count(x => x.Annotations.Status == "skipped")
            + m.Constants.Count(x => x.Annotations.Status == "skipped")
            + m.Variables.Count(x => x.Annotations.Status == "skipped");

        Console.WriteLine($"{m.Address,-35} {mMembers,5} {mTypes,5} {mConsts,6} {mGlobals,5} {mPorted,7} {mSkipped,5}");

        totalMembers += mMembers; membersPorted += m.Members.Count(x => x.Annotations.Status == "ported"); membersSkipped += m.Members.Count(x => x.Annotations.Status == "skipped");
        totalTypes += mTypes; typesPorted += m.Types.Count(x => x.Annotations.Status == "ported"); typesSkipped += m.Types.Count(x => x.Annotations.Status == "skipped");
        totalConsts += mConsts; constsPorted += m.Constants.Count(x => x.Annotations.Status == "ported"); constsSkipped += m.Constants.Count(x => x.Annotations.Status == "ported");
        totalGlobals += mGlobals; globalsPorted += m.Variables.Count(x => x.Annotations.Status == "ported"); globalsSkipped += m.Variables.Count(x => x.Annotations.Status == "skipped");
        totalControls += m.Controls.Count;
    }

    int grandTotal = totalMembers + totalTypes + totalConsts + totalGlobals;
    int grandPorted = membersPorted + typesPorted + constsPorted + globalsPorted;
    int grandSkipped = membersSkipped + typesSkipped + constsSkipped + globalsSkipped;

    Console.WriteLine(new string('-', 75));
    Console.WriteLine($"{"TOTAL",-35} {totalMembers,5} {totalTypes,5} {totalConsts,6} {totalGlobals,5} {grandPorted,7} {grandSkipped,5}");

    Console.WriteLine();
    Console.WriteLine($"Porting progress:");
    Console.WriteLine($"  Functions/Subs: {membersPorted}/{totalMembers} ported, {membersSkipped} skipped");
    Console.WriteLine($"  Types:          {typesPorted}/{totalTypes} ported, {typesSkipped} skipped");
    Console.WriteLine($"  Constants:      {constsPorted}/{totalConsts} ported, {constsSkipped} skipped");
    Console.WriteLine($"  Globals:        {globalsPorted}/{totalGlobals} ported, {globalsSkipped} skipped");
    Console.WriteLine($"  ---");
    Console.WriteLine($"  Overall:        {grandPorted}/{grandTotal} ported ({(grandTotal > 0 ? grandPorted * 100 / grandTotal : 0)}%), {grandSkipped} skipped");
    Console.WriteLine($"\n  Controls: {totalControls}  Modules: {modules.Count}");

    return 0;
}

// ─── Usage ───────────────────────────────────────────────────────────

int PrintUsage()
{
    Console.WriteLine("""
    vb6-ast - VB6 source code analyzer for Era Online

    Addresses use the format: Project/Module:MemberName
    Examples: Server/GameLogic:UserDie, Client/frmMain, Server/Declarations:User

    Usage:
      vb6-ast parse [--file PATTERN]              Parse VB6 files, extract declarations + call graph
      vb6-ast list <what> [--module ADDR]          List modules|members|types|constants|globals|controls
      vb6-ast show <address|name> [--type]         Show details of a member or type
      vb6-ast annotate <addr:name> [OPTIONS]       Annotate a member, type, constant, or global
        --purpose TEXT    Set purpose description
        --note TEXT       Add a note (appends)
        --status STATUS   Set status: not-started|in-progress|ported|skipped
        --csharp LOC      Set C# implementation location
        --sends MSG,MSG   Set protocol messages sent
        --calls FN,FN     Set functions called
        --type            Target a type definition
        --constant        Target a constant
        --global          Target a global variable
      vb6-ast query [OPTIONS]                      Search across all modules
        --status STATUS   Filter by porting status
        --module ADDR     Filter by module address
        --sends MSG       Find members that send a protocol message
        --calls NAME      Find members that call a function
        --unannotated     Find members with no purpose set
        --protocol        List all known protocol messages
      vb6-ast stats [--module ADDR] [--all]        Show porting progress (--all includes empty modules)
    """);
    return 0;
}

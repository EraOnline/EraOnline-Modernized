using System.Text.Json.Serialization;

namespace Vb6Ast.Models;

public class Vb6Module
{
    [JsonPropertyName("module")]
    public string Name { get; set; } = "";

    [JsonPropertyName("sourcePath")]
    public string SourcePath { get; set; } = "";

    /// <summary>
    /// Qualified address: e.g. "Server/GameLogic" - used as the unique identifier for this module.
    /// </summary>
    [JsonPropertyName("address")]
    public string Address { get; set; } = "";

    [JsonPropertyName("controls")]
    public List<Vb6Control> Controls { get; set; } = [];

    [JsonPropertyName("types")]
    public List<Vb6TypeDef> Types { get; set; } = [];

    [JsonPropertyName("constants")]
    public List<Vb6Constant> Constants { get; set; } = [];

    [JsonPropertyName("globals")]
    public List<Vb6Variable> Variables { get; set; } = [];

    [JsonPropertyName("declares")]
    public List<Vb6Declare> Declares { get; set; } = [];

    [JsonPropertyName("members")]
    public List<Vb6Member> Members { get; set; } = [];
}

/// <summary>
/// A VB6 form control (Timer, Socket, CommandButton, etc.) parsed from the form designer section.
/// </summary>
public class Vb6Control
{
    [JsonPropertyName("type")]
    public string ControlType { get; set; } = ""; // e.g. "VB.Timer", "SocketWrenchCtrl.Socket"

    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("properties")]
    public Dictionary<string, string> Properties { get; set; } = [];
}

public class Vb6TypeDef
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("fields")]
    public List<Vb6TypeField> Fields { get; set; } = [];

    [JsonPropertyName("lineStart")]
    public int LineStart { get; set; }

    [JsonPropertyName("lineEnd")]
    public int LineEnd { get; set; }

    [JsonPropertyName("annotations")]
    public Annotations Annotations { get; set; } = new();
}

public class Vb6TypeField
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("type")]
    public string FieldType { get; set; } = "";

    [JsonPropertyName("isArray")]
    public bool IsArray { get; set; }

    [JsonPropertyName("arrayBounds")]
    public string? ArrayBounds { get; set; }
}

public class Vb6Constant
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("value")]
    public string Value { get; set; } = "";

    [JsonPropertyName("visibility")]
    public string Visibility { get; set; } = "";

    [JsonPropertyName("line")]
    public int Line { get; set; }

    [JsonPropertyName("annotations")]
    public Annotations Annotations { get; set; } = new();
}

public class Vb6Variable
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("type")]
    public string VariableType { get; set; } = "";

    [JsonPropertyName("visibility")]
    public string Visibility { get; set; } = "";

    [JsonPropertyName("isArray")]
    public bool IsArray { get; set; }

    [JsonPropertyName("arrayBounds")]
    public string? ArrayBounds { get; set; }

    [JsonPropertyName("line")]
    public int Line { get; set; }

    [JsonPropertyName("annotations")]
    public Annotations Annotations { get; set; } = new();
}

public class Vb6Declare
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("lib")]
    public string Lib { get; set; } = "";

    [JsonPropertyName("alias")]
    public string? Alias { get; set; }

    [JsonPropertyName("params")]
    public string Params { get; set; } = "";

    [JsonPropertyName("returnType")]
    public string? ReturnType { get; set; }

    [JsonPropertyName("line")]
    public int Line { get; set; }
}

public class Vb6Member
{
    [JsonPropertyName("kind")]
    public string Kind { get; set; } = ""; // "sub" or "function"

    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("visibility")]
    public string Visibility { get; set; } = "";

    [JsonPropertyName("params")]
    public string Params { get; set; } = "";

    [JsonPropertyName("returnType")]
    public string? ReturnType { get; set; }

    [JsonPropertyName("lineStart")]
    public int LineStart { get; set; }

    [JsonPropertyName("lineEnd")]
    public int LineEnd { get; set; }

    [JsonPropertyName("annotations")]
    public Annotations Annotations { get; set; } = new();
}

public class Annotations
{
    [JsonPropertyName("purpose")]
    public string? Purpose { get; set; }

    [JsonPropertyName("notes")]
    public List<string> Notes { get; set; } = [];

    [JsonPropertyName("status")]
    public string Status { get; set; } = "not-started"; // not-started, in-progress, ported, skipped, partial

    [JsonPropertyName("target")]
    public string? Target { get; set; }

    [JsonPropertyName("sends")]
    public List<string> Sends { get; set; } = [];

    [JsonPropertyName("calls")]
    public List<string> Calls { get; set; } = [];

    /// <summary>
    /// Named sections within a large function (e.g., protocol command branches in a message router).
    /// Each section has its own porting status and target location.
    /// </summary>
    [JsonPropertyName("sections")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public Dictionary<string, SectionAnnotation>? Sections { get; set; }
}

public class SectionAnnotation
{
    [JsonPropertyName("status")]
    public string Status { get; set; } = "not-started";

    [JsonPropertyName("target")]
    public string? Target { get; set; }

    [JsonPropertyName("notes")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<string>? Notes { get; set; }
}

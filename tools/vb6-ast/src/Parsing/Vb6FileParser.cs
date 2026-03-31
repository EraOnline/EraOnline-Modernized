using Antlr4.Runtime;
using GCore.Antlr.Grammers.Vb6;
using Vb6Ast.Models;
using Vb6Ast.Visitors;

namespace Vb6Ast.Parsing;

public class Vb6FileParser
{
    /// <summary>
    /// Parse a VB6 .bas or .frm file and extract declarations.
    /// </summary>
    public Vb6Module Parse(string filePath, string relativePath)
    {
        var content = File.ReadAllText(filePath);
        var controls = new List<Vb6Control>();
        int lineOffset = 0;

        // For .frm files, parse form controls from header, then extract code section
        if (filePath.EndsWith(".frm", StringComparison.OrdinalIgnoreCase))
        {
            controls = ParseFormControls(content);
            (content, lineOffset) = ExtractFrmCodeSection(content);
        }

        var stream = new AntlrInputStream(content);
        var lexer = new VisualBasic6Lexer(stream);
        var tokens = new CommonTokenStream(lexer);
        var parser = new VisualBasic6Parser(tokens);

        // Suppress error output
        parser.RemoveErrorListeners();
        lexer.RemoveErrorListeners();

        var tree = parser.startRule();

        // Pass 1: Extract declarations
        var declVisitor = new DeclarationVisitor(lineOffset);
        declVisitor.Module.SourcePath = relativePath;
        declVisitor.Module.Address = Path.ChangeExtension(relativePath, null);
        declVisitor.Module.Controls = controls;
        declVisitor.Visit(tree);

        // Pass 2: Extract SendData calls and function calls
        var callVisitor = new CallGraphVisitor(lineOffset);
        callVisitor.Visit(tree);

        // Merge auto-detected calls/sends into members (without overwriting manual annotations)
        foreach (var (memberName, sends) in callVisitor.MemberSends)
        {
            var member = declVisitor.Module.Members.FirstOrDefault(m => m.Name == memberName);
            if (member != null && member.Annotations.Sends.Count == 0)
            {
                member.Annotations.Sends = sends.Distinct().ToList();
            }
        }
        foreach (var (memberName, calls) in callVisitor.MemberCalls)
        {
            var member = declVisitor.Module.Members.FirstOrDefault(m => m.Name == memberName);
            if (member != null && member.Annotations.Calls.Count == 0)
            {
                member.Annotations.Calls = calls.Distinct().ToList();
            }
        }

        // If no module name found from Attribute VB_Name, derive from filename
        if (string.IsNullOrEmpty(declVisitor.Module.Name))
        {
            declVisitor.Module.Name = Path.GetFileNameWithoutExtension(filePath);
        }

        return declVisitor.Module;
    }

    /// <summary>
    /// Parse form controls from the .frm designer section (before the code).
    /// Extracts Begin VB.Timer, Begin VB.CommandButton, etc. with their properties.
    /// </summary>
    private static List<Vb6Control> ParseFormControls(string content)
    {
        var controls = new List<Vb6Control>();
        var lines = content.Split('\n');
        var controlStack = new Stack<Vb6Control>();

        for (int i = 0; i < lines.Length; i++)
        {
            var trimmed = lines[i].Trim();

            // Stop when we hit the code section
            if (trimmed.StartsWith("Attribute ", StringComparison.OrdinalIgnoreCase))
                break;

            // Begin ControlType.Name ControlName
            if (trimmed.StartsWith("Begin ", StringComparison.OrdinalIgnoreCase))
            {
                var parts = trimmed["Begin ".Length..].Split(' ', StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length >= 2)
                {
                    var control = new Vb6Control
                    {
                        ControlType = parts[0],
                        Name = parts[1],
                    };
                    controlStack.Push(control);
                }
                else if (parts.Length == 1 && parts[0] == "BeginProperty")
                {
                    // Skip BeginProperty blocks
                }
            }
            else if (trimmed == "End" && controlStack.Count > 0)
            {
                var control = controlStack.Pop();
                // Only capture interesting controls (timers, sockets, etc.), skip the form itself
                if (control.ControlType != "VB.Form")
                {
                    controls.Add(control);
                }
            }
            else if (controlStack.Count > 0 && trimmed.Contains('='))
            {
                // Property = Value
                var eqIdx = trimmed.IndexOf('=');
                if (eqIdx > 0)
                {
                    var key = trimmed[..eqIdx].Trim();
                    var value = trimmed[(eqIdx + 1)..].Trim();
                    // Skip internal properties starting with _
                    if (!key.StartsWith('_') && !key.StartsWith("Begin"))
                    {
                        var control = controlStack.Peek();
                        control.Properties.TryAdd(key, value);
                    }
                }
            }
        }

        return controls;
    }

    /// <summary>
    /// Extract just the code section from a .frm file.
    /// Returns the code content and the line offset (number of lines removed from the top).
    /// </summary>
    private static (string Content, int LineOffset) ExtractFrmCodeSection(string content)
    {
        var lines = content.Split('\n');
        var codeStart = -1;

        for (int i = 0; i < lines.Length; i++)
        {
            var trimmed = lines[i].TrimStart();
            if (trimmed.StartsWith("Attribute ", StringComparison.OrdinalIgnoreCase))
            {
                codeStart = i;
                break;
            }
        }

        if (codeStart < 0)
        {
            // No Attribute found, try Option Explicit or first Sub/Function
            for (int i = 0; i < lines.Length; i++)
            {
                var trimmed = lines[i].TrimStart();
                if (trimmed.StartsWith("Option ", StringComparison.OrdinalIgnoreCase) ||
                    trimmed.StartsWith("Public ", StringComparison.OrdinalIgnoreCase) ||
                    trimmed.StartsWith("Private ", StringComparison.OrdinalIgnoreCase) ||
                    trimmed.StartsWith("Sub ", StringComparison.OrdinalIgnoreCase) ||
                    trimmed.StartsWith("Function ", StringComparison.OrdinalIgnoreCase))
                {
                    codeStart = i;
                    break;
                }
            }
        }

        if (codeStart < 0)
            return (content, 0);

        return (string.Join('\n', lines[codeStart..]), codeStart);
    }
}

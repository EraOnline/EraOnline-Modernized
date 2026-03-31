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

        // For .frm files, strip the form definition header (everything before the first
        // Attribute or Option statement in the code section)
        if (filePath.EndsWith(".frm", StringComparison.OrdinalIgnoreCase))
        {
            content = ExtractFrmCodeSection(content);
        }

        var stream = new AntlrInputStream(content);
        var lexer = new VisualBasic6Lexer(stream);
        var tokens = new CommonTokenStream(lexer);
        var parser = new VisualBasic6Parser(tokens);

        // Suppress error output - VB6 files may have constructs the grammar doesn't handle perfectly
        parser.RemoveErrorListeners();
        lexer.RemoveErrorListeners();

        var tree = parser.startRule();

        var visitor = new DeclarationVisitor();
        visitor.Module.SourcePath = relativePath;
        visitor.Visit(tree);

        // If no module name was found from Attribute VB_Name, derive from filename
        if (string.IsNullOrEmpty(visitor.Module.Name))
        {
            visitor.Module.Name = Path.GetFileNameWithoutExtension(filePath);
        }

        return visitor.Module;
    }

    /// <summary>
    /// Extract just the code section from a .frm file.
    /// VB6 .frm files start with form metadata (VERSION, BEGIN, object definitions)
    /// followed by the actual VB code starting with Attribute statements.
    /// </summary>
    private static string ExtractFrmCodeSection(string content)
    {
        var lines = content.Split('\n');
        var codeStart = -1;

        for (int i = 0; i < lines.Length; i++)
        {
            var trimmed = lines[i].TrimStart();
            // The code section starts with Attribute VB_Name or VERSION
            // but we need to skip the form designer section (BEGIN...END)
            if (trimmed.StartsWith("Attribute ", StringComparison.OrdinalIgnoreCase))
            {
                codeStart = i;
                break;
            }
        }

        if (codeStart < 0)
        {
            // No Attribute found, try to find Option Explicit or first Sub/Function
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
            return content; // Give up, try to parse everything

        return string.Join('\n', lines[codeStart..]);
    }
}

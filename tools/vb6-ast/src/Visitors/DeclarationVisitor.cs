using Antlr4.Runtime;
using GCore.Antlr.Grammers.Vb6;
using Vb6Ast.Models;

namespace Vb6Ast.Visitors;

/// <summary>
/// Walks the VB6 parse tree and extracts declarations:
/// types, constants, global variables, subs, functions, and API declares.
/// </summary>
public class DeclarationVisitor : VisualBasic6BaseVisitor<int>
{
    public Vb6Module Module { get; } = new();

    // Track the module name from Attribute VB_Name
    public override int VisitAttributeStmt(VisualBasic6Parser.AttributeStmtContext context)
    {
        var text = context.GetText();
        if (text.Contains("VB_Name"))
        {
            var literals = context.literal();
            if (literals.Length > 0)
            {
                Module.Name = literals[0].GetText().Trim('"');
            }
        }
        return base.VisitAttributeStmt(context);
    }

    // Type definitions
    public override int VisitTypeStmt(VisualBasic6Parser.TypeStmtContext context)
    {
        var typeDef = new Vb6TypeDef
        {
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            LineStart = context.Start.Line,
            LineEnd = context.Stop.Line,
        };

        var elements = context.typeStmt_Element();
        foreach (var element in elements)
        {
            var field = new Vb6TypeField
            {
                Name = element.ambiguousIdentifier()?.GetText() ?? "Unknown",
            };

            var asType = element.asTypeClause();
            if (asType != null)
            {
                field.FieldType = asType.type()?.GetText() ?? "";
            }

            var subscripts = element.subscripts();
            if (subscripts != null)
            {
                field.IsArray = true;
                field.ArrayBounds = subscripts.GetText();
            }

            typeDef.Fields.Add(field);
        }

        Module.Types.Add(typeDef);
        return 0;
    }

    // Constants
    public override int VisitConstStmt(VisualBasic6Parser.ConstStmtContext context)
    {
        var visibility = context.publicPrivateGlobalVisibility()?.GetText() ?? "Public";

        foreach (var sub in context.constSubStmt())
        {
            var constant = new Vb6Constant
            {
                Name = sub.ambiguousIdentifier()?.GetText() ?? "Unknown",
                Value = sub.valueStmt()?.GetText() ?? "",
                Visibility = visibility,
                Line = context.Start.Line,
            };
            Module.Constants.Add(constant);
        }

        return 0;
    }

    // Global/Public variable declarations
    public override int VisitVariableStmt(VisualBasic6Parser.VariableStmtContext context)
    {
        var visibility = context.visibility()?.GetText() ?? "";

        // Check for DIM (local) - skip those, we only want module-level
        if (context.DIM() != null && string.IsNullOrEmpty(visibility))
            return 0;

        // Only capture Public/Global variables
        if (!visibility.Equals("Public", StringComparison.OrdinalIgnoreCase) &&
            !visibility.Equals("Global", StringComparison.OrdinalIgnoreCase))
            return 0;

        var varList = context.variableListStmt();
        if (varList == null) return 0;

        foreach (var sub in varList.variableSubStmt())
        {
            var variable = new Vb6Variable
            {
                Name = sub.ambiguousIdentifier()?.GetText() ?? "Unknown",
                Visibility = visibility,
                Line = context.Start.Line,
            };

            var asType = sub.asTypeClause();
            if (asType != null)
            {
                variable.VariableType = asType.type()?.GetText() ?? "";
            }

            var subscripts = sub.subscripts();
            if (subscripts != null)
            {
                variable.IsArray = true;
                variable.ArrayBounds = subscripts.GetText();
            }

            Module.Variables.Add(variable);
        }

        return 0;
    }

    // Sub declarations
    public override int VisitSubStmt(VisualBasic6Parser.SubStmtContext context)
    {
        var member = new Vb6Member
        {
            Kind = "sub",
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            Visibility = context.visibility()?.GetText() ?? "Public",
            Params = CleanParams(context.argList()?.GetText()),
            ReturnType = null,
            LineStart = context.Start.Line,
            LineEnd = context.Stop.Line,
        };

        Module.Members.Add(member);
        return 0; // Don't descend into the body
    }

    // Function declarations
    public override int VisitFunctionStmt(VisualBasic6Parser.FunctionStmtContext context)
    {
        var member = new Vb6Member
        {
            Kind = "function",
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            Visibility = context.visibility()?.GetText() ?? "Public",
            Params = CleanParams(context.argList()?.GetText()),
            ReturnType = context.asTypeClause()?.type()?.GetText(),
            LineStart = context.Start.Line,
            LineEnd = context.Stop.Line,
        };

        Module.Members.Add(member);
        return 0;
    }

    // API Declare statements
    public override int VisitDeclareStmt(VisualBasic6Parser.DeclareStmtContext context)
    {
        var declare = new Vb6Declare
        {
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            Lib = context.STRINGLITERAL(0)?.GetText()?.Trim('"') ?? "",
            Params = CleanParams(context.argList()?.GetText()),
            ReturnType = context.asTypeClause()?.type()?.GetText(),
            Line = context.Start.Line,
        };

        // Alias is the second STRINGLITERAL if present
        var alias = context.STRINGLITERAL(1);
        if (alias != null)
        {
            declare.Alias = alias.GetText().Trim('"');
        }

        Module.Declares.Add(declare);
        return 0;
    }

    private static string CleanParams(string? raw)
    {
        if (string.IsNullOrEmpty(raw)) return "()";
        // The ANTLR GetText() strips whitespace, add it back for readability
        return raw
            .Replace(",", ", ")
            .Replace("ByVal", "ByVal ")
            .Replace("ByRef", "ByRef ")
            .Replace("As", " As ");
    }
}

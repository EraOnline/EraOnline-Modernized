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
    private readonly int _lineOffset;

    public Vb6Module Module { get; } = new();

    public DeclarationVisitor(int lineOffset = 0)
    {
        _lineOffset = lineOffset;
    }

    private int AdjustLine(int parsedLine) => parsedLine + _lineOffset;

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

    public override int VisitTypeStmt(VisualBasic6Parser.TypeStmtContext context)
    {
        var typeDef = new Vb6TypeDef
        {
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            LineStart = AdjustLine(context.Start.Line),
            LineEnd = AdjustLine(context.Stop.Line),
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
                Line = AdjustLine(context.Start.Line),
            };
            Module.Constants.Add(constant);
        }

        return 0;
    }

    public override int VisitVariableStmt(VisualBasic6Parser.VariableStmtContext context)
    {
        var visibility = context.visibility()?.GetText() ?? "";

        if (context.DIM() != null && string.IsNullOrEmpty(visibility))
            return 0;

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
                Line = AdjustLine(context.Start.Line),
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

    public override int VisitSubStmt(VisualBasic6Parser.SubStmtContext context)
    {
        var member = new Vb6Member
        {
            Kind = "sub",
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            Visibility = context.visibility()?.GetText() ?? "Public",
            Params = FormatParams(context.argList()),
            ReturnType = null,
            LineStart = AdjustLine(context.Start.Line),
            LineEnd = AdjustLine(context.Stop.Line),
        };

        Module.Members.Add(member);
        return 0;
    }

    public override int VisitFunctionStmt(VisualBasic6Parser.FunctionStmtContext context)
    {
        var member = new Vb6Member
        {
            Kind = "function",
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            Visibility = context.visibility()?.GetText() ?? "Public",
            Params = FormatParams(context.argList()),
            ReturnType = context.asTypeClause()?.type()?.GetText(),
            LineStart = AdjustLine(context.Start.Line),
            LineEnd = AdjustLine(context.Stop.Line),
        };

        Module.Members.Add(member);
        return 0;
    }

    public override int VisitDeclareStmt(VisualBasic6Parser.DeclareStmtContext context)
    {
        var declare = new Vb6Declare
        {
            Name = context.ambiguousIdentifier()?.GetText() ?? "Unknown",
            Lib = context.STRINGLITERAL(0)?.GetText()?.Trim('"') ?? "",
            Params = FormatParams(context.argList()),
            ReturnType = context.asTypeClause()?.type()?.GetText(),
            Line = AdjustLine(context.Start.Line),
        };

        var alias = context.STRINGLITERAL(1);
        if (alias != null)
        {
            declare.Alias = alias.GetText().Trim('"');
        }

        Module.Declares.Add(declare);
        return 0;
    }

    /// <summary>
    /// Format parameter list from ANTLR ArgListContext into clean readable text.
    /// </summary>
    private static string FormatParams(VisualBasic6Parser.ArgListContext? argList)
    {
        if (argList == null) return "()";

        var args = argList.arg();
        if (args == null || args.Length == 0) return "()";

        var parts = new List<string>();
        foreach (var arg in args)
        {
            var prefix = "";
            if (arg.GetText().StartsWith("ByVal", StringComparison.OrdinalIgnoreCase))
                prefix = "ByVal ";
            else if (arg.GetText().StartsWith("ByRef", StringComparison.OrdinalIgnoreCase))
                prefix = "ByRef ";
            else if (arg.GetText().StartsWith("Optional", StringComparison.OrdinalIgnoreCase))
                prefix = "Optional ";

            var name = arg.ambiguousIdentifier()?.GetText() ?? "?";
            var asType = arg.asTypeClause()?.type()?.GetText();
            var typeStr = asType != null ? $" As {asType}" : "";

            parts.Add($"{prefix}{name}{typeStr}");
        }

        return $"({string.Join(", ", parts)})";
    }
}

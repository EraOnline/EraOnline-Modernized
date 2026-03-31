using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using GCore.Antlr.Grammers.Vb6;

namespace Vb6Ast.Visitors;

/// <summary>
/// Walks the VB6 parse tree to extract:
/// 1. SendData calls within each sub/function, capturing the protocol message prefix
/// 2. All function/sub calls within each sub/function (call graph)
/// </summary>
public class CallGraphVisitor : VisualBasic6BaseVisitor<int>
{
    private readonly int _lineOffset;

    /// <summary>Maps member name -> list of protocol message prefixes sent.</summary>
    public Dictionary<string, List<string>> MemberSends { get; } = [];

    /// <summary>Maps member name -> list of functions/subs called.</summary>
    public Dictionary<string, List<string>> MemberCalls { get; } = [];

    private string? _currentMember;

    public CallGraphVisitor(int lineOffset = 0)
    {
        _lineOffset = lineOffset;
    }

    public override int VisitSubStmt(VisualBasic6Parser.SubStmtContext context)
    {
        var name = context.ambiguousIdentifier()?.GetText() ?? "Unknown";
        _currentMember = name;
        MemberSends.TryAdd(name, []);
        MemberCalls.TryAdd(name, []);

        // Visit the block (function body) to find calls
        var block = context.block();
        if (block != null)
        {
            ScanBlock(block);
        }

        _currentMember = null;
        return 0;
    }

    public override int VisitFunctionStmt(VisualBasic6Parser.FunctionStmtContext context)
    {
        var name = context.ambiguousIdentifier()?.GetText() ?? "Unknown";
        _currentMember = name;
        MemberSends.TryAdd(name, []);
        MemberCalls.TryAdd(name, []);

        var block = context.block();
        if (block != null)
        {
            ScanBlock(block);
        }

        _currentMember = null;
        return 0;
    }

    /// <summary>
    /// Scan a block of code for Call statements and SendData invocations.
    /// Uses text scanning since the ANTLR tree structure for VB6 calls is complex.
    /// </summary>
    private void ScanBlock(VisualBasic6Parser.BlockContext block)
    {
        if (_currentMember == null) return;

        // Get the raw text of the block and scan line by line
        // This is more reliable than trying to navigate the ANTLR tree for VB6 call expressions
        var text = block.GetText();
        var lines = text.Split('\n');

        foreach (var rawLine in lines)
        {
            var line = rawLine.Trim();

            // Look for Call statements: "Call FunctionName(..." or just "FunctionName ..."
            if (line.StartsWith("Call", StringComparison.OrdinalIgnoreCase))
            {
                var afterCall = line[4..].TrimStart();
                var funcName = ExtractIdentifier(afterCall);
                if (!string.IsNullOrEmpty(funcName) && funcName != _currentMember)
                {
                    MemberCalls[_currentMember].Add(funcName);

                    // Check if this is a SendData call and extract the message prefix
                    if (funcName.Equals("SendData", StringComparison.OrdinalIgnoreCase))
                    {
                        var prefix = ExtractSendDataPrefix(afterCall);
                        if (prefix != null)
                        {
                            MemberSends[_currentMember].Add(prefix);
                        }
                    }
                }
            }

            // Also look for non-Call invocations: "SendData ToIndex, ..."
            // VB6 allows calling subs without the "Call" keyword
            if (line.StartsWith("SendData", StringComparison.OrdinalIgnoreCase) && !line.StartsWith("SendData="))
            {
                if (!MemberCalls[_currentMember].Contains("SendData"))
                    MemberCalls[_currentMember].Add("SendData");

                var prefix = ExtractSendDataPrefix(line);
                if (prefix != null)
                {
                    MemberSends[_currentMember].Add(prefix);
                }
            }

            // Standalone function calls (no Call keyword, no assignment)
            // Pattern: identifier followed by space and arguments
            // Skip keywords and assignments
            if (!line.StartsWith("Call", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("If", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("For", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Do", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Select", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("End", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Exit", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Dim", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Set", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("'") &&
                !line.StartsWith("Else", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Next", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Loop", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Case", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("With", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Open", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Close", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Print", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("ReDim", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("On", StringComparison.OrdinalIgnoreCase) &&
                !line.Contains('=') &&
                line.Length > 0)
            {
                var funcName = ExtractIdentifier(line);
                if (!string.IsNullOrEmpty(funcName) &&
                    funcName != _currentMember &&
                    funcName.Length > 1 &&
                    char.IsUpper(funcName[0]) &&
                    !IsVb6Keyword(funcName))
                {
                    MemberCalls[_currentMember].Add(funcName);
                }
            }
        }
    }

    /// <summary>
    /// Extract the protocol message prefix from a SendData call.
    /// Looks for string literals like "CHC", "@", "DEA", "PLW", etc.
    /// </summary>
    private static string? ExtractSendDataPrefix(string callText)
    {
        // Find the first quoted string after the routing arguments
        // Pattern: SendData(route, index, map, "PREFIX...)
        // or: SendData route, index, map, "PREFIX..."
        var quoteIdx = callText.IndexOf('"');
        if (quoteIdx < 0) return null;

        var afterQuote = callText[(quoteIdx + 1)..];

        // Extract prefix up to the first non-letter character or quote or &
        var prefix = "";
        foreach (var c in afterQuote)
        {
            if (c == '"' || c == '&' || c == '~' || c == ',')
                break;
            prefix += c;
        }

        prefix = prefix.Trim();

        // Filter out non-protocol strings (full messages, etc.)
        if (prefix.Length == 0 || prefix.Length > 5 || prefix.Contains(' '))
            return null;

        return prefix;
    }

    private static string ExtractIdentifier(string text)
    {
        var result = "";
        foreach (var c in text)
        {
            if (char.IsLetterOrDigit(c) || c == '_')
                result += c;
            else
                break;
        }
        return result;
    }

    private static bool IsVb6Keyword(string word)
    {
        return word.ToUpperInvariant() switch
        {
            "IF" or "THEN" or "ELSE" or "ELSEIF" or "END" or "FOR" or "NEXT" or "DO" or "LOOP" or
            "WHILE" or "WEND" or "SELECT" or "CASE" or "WITH" or "EXIT" or "SUB" or "FUNCTION" or
            "DIM" or "SET" or "LET" or "CALL" or "GOTO" or "GOSUB" or "RETURN" or "RESUME" or
            "NOT" or "AND" or "OR" or "XOR" or "TRUE" or "FALSE" or "NOTHING" or "NULL" or
            "BYVAL" or "BYREF" or "OPTIONAL" or "STATIC" or "PUBLIC" or "PRIVATE" or "GLOBAL" or
            "TYPE" or "ENUM" or "CONST" or "DECLARE" or "PROPERTY" or "EVENT" or "REDIM" or
            "ERASE" or "PRESERVE" or "OPTION" or "EXPLICIT" or "ATTRIBUTE" or "UNLOAD" or
            "LOAD" => true,
            _ => false
        };
    }
}

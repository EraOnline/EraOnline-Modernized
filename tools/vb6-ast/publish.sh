#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotnet publish "$SCRIPT_DIR/src/vb6-ast.csproj" -c Release -o "$SCRIPT_DIR/bin/" --nologo -v quiet

echo "Published to $SCRIPT_DIR/bin/vb6-ast"
echo "Run with: $SCRIPT_DIR/bin/vb6-ast"

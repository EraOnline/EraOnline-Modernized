#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotnet publish "$SCRIPT_DIR/src/vb6-ast.csproj" -c Release -o "$SCRIPT_DIR/bin/" --nologo -v quiet --self-contained -r linux-x64

# Create a simple wrapper script
cat > "$SCRIPT_DIR/bin/vb6-ast.sh" << 'WRAPPER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/vb6-ast" "$@"
WRAPPER
chmod +x "$SCRIPT_DIR/bin/vb6-ast.sh"

echo "Published to $SCRIPT_DIR/bin/vb6-ast"
echo "Run with: $SCRIPT_DIR/bin/vb6-ast"

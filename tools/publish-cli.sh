#!/usr/bin/env bash
# Build and install the Era Online CLI tool.
# Installs to ~/.local/bin/eraonline (XDG compliant).
# Also copies game data to ~/.local/share/eraonline/data/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT="$REPO_ROOT/src/Client.CLI/EraOnline.Client.CLI.csproj"
DATA_SRC="$REPO_ROOT/src/Client.Web/wwwroot/data"

# Determine OS/arch for self-contained build
case "$(uname -s)" in
    Linux*)  RID="linux-x64" ;;
    Darwin*) RID="osx-x64" ;;
    *)       echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

# Target directories (XDG)
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/eraonline/data"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eraonline"
PUBLISH_DIR="$REPO_ROOT/src/Client.CLI/bin/publish"

echo "Building Era Online CLI for $RID..."
dotnet publish "$PROJECT" \
    --configuration Release \
    --runtime "$RID" \
    --self-contained \
    --output "$PUBLISH_DIR" \
    /p:PublishSingleFile=true \
    /p:IncludeNativeLibrariesForSelfExtract=true \
    2>&1

# Install binary
mkdir -p "$BIN_DIR"
cp "$PUBLISH_DIR/EraOnline.Client.CLI" "$BIN_DIR/eraonline"
chmod +x "$BIN_DIR/eraonline"
echo "Installed binary to $BIN_DIR/eraonline"

# Copy game data (maps, sprites, JSON definitions)
echo "Copying game data to $DATA_DIR..."
mkdir -p "$DATA_DIR"
# Copy JSON files
for f in "$DATA_SRC"/*.json; do
    [ -f "$f" ] && cp "$f" "$DATA_DIR/"
done
# Copy map data
if [ -d "$DATA_SRC/maps" ]; then
    mkdir -p "$DATA_DIR/maps"
    cp "$DATA_SRC/maps"/*.json "$DATA_DIR/maps/" 2>/dev/null || true
fi
# Copy sprite sheets (needed for headless renderer later)
if [ -d "$DATA_SRC/grh" ]; then
    mkdir -p "$DATA_DIR/grh"
    cp "$DATA_SRC/grh"/*.png "$DATA_DIR/grh/" 2>/dev/null || true
fi

# Create default config if it doesn't exist
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    echo '{"server": "http://localhost:5000", "port": "19999"}' > "$CONFIG_DIR/config.json"
    echo "Created default config at $CONFIG_DIR/config.json"
fi

echo ""
echo "Done! Run 'eraonline help' to get started."
echo "Make sure $BIN_DIR is in your PATH."

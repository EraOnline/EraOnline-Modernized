#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotnet publish "$SCRIPT_DIR/src/eo-data-converter.csproj" -c Release -o "$SCRIPT_DIR/bin/" --nologo -v quiet --self-contained -r linux-x64

echo "Published to $SCRIPT_DIR/bin/eo-data-converter"
echo "Run with: $SCRIPT_DIR/bin/eo-data-converter"

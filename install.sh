#!/bin/bash
# Installation script for pdf2tns

set -e

INSTALL_DIR="/home/oglis/pdf2tns"
BIN_LINK="/home/oglis/.local/bin/pdf2tns"

echo "═══════════════════════════════════════"
echo "  PDF2TNS Installation"
echo "═══════════════════════════════════════"
echo ""

# Create .local/bin if not exists
mkdir -p ~/.local/bin

# Create symlink
if [ -L "$BIN_LINK" ]; then
    echo "✓ Symlink already exists"
else
    ln -s "$INSTALL_DIR/pdf2tns.sh" "$BIN_LINK"
    echo "✓ Created symlink: $BIN_LINK"
fi

# Check if .local/bin is in PATH
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    echo "✓ ~/.local/bin is in PATH"
else
    echo "⚠ Adding ~/.local/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "  Run: source ~/.bashrc"
fi

echo ""
echo "═══════════════════════════════════════"
echo "✓ Installation complete!"
echo ""
echo "Usage:"
echo "  pdf2tns ~/Downloads/datei.pdf"
echo "  pdf2tns --all"
echo ""
echo "Or use directly:"
echo "  $INSTALL_DIR/pdf2tns.sh"
echo "═══════════════════════════════════════"

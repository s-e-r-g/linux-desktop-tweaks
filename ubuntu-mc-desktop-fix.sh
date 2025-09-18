#!/usr/bin/env bash
set -e

DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/mc.desktop"

mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_FILE" <<'EOF'
[Desktop Entry]
Name=Midnight Commander
Comment=File Manager
Exec=gnome-terminal --class=mc --geometry=170x44 -- bash -c "mc; exec bash"
Icon=mc
Terminal=false
Type=Application
Categories=System;FileManager;
StartupWMClass=mc
StartupNotify=true

Actions=new-window;

[Desktop Action new-window]
Name=New Window
Exec=gnome-terminal --class=mc --geometry=170x44 -- bash -c "mc; exec bash"
EOF

echo "[✔] mc.desktop created at $DESKTOP_FILE"

# Update desktop file database
update-desktop-database "$DESKTOP_DIR" || true

echo "[✔] Desktop database updated"

# User info
echo
echo "✅ Done! You can now find 'Midnight Commander' in your applications menu,"
echo "   pin it to your dock, and use it as a launcher."
echo
echo "ℹ️  If it doesn’t show up immediately, log out and back in,"
echo "   or press Alt+F2 → type 'r' → Enter (to restart GNOME Shell)."

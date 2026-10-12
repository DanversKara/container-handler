#!/usr/bin/env bash
# Registers brave-container-open as the handler for ext+container:// links (Linux).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
bin_dir="$HOME/.local/bin"
app_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

mkdir -p "$bin_dir" "$app_dir"
install -m 755 "$here/brave-container-open" "$bin_dir/brave-container-open"

cat > "$app_dir/brave-container-open.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Brave Container Links
Comment=Opens ext+container:// links in a Brave container
Exec=$bin_dir/brave-container-open %u
MimeType=x-scheme-handler/ext+container;
NoDisplay=true
Terminal=false
EOF

xdg-mime default brave-container-open.desktop x-scheme-handler/ext+container
update-desktop-database "$app_dir" >/dev/null 2>&1 || true

echo "Installed. Handler for ext+container: $(xdg-mime query default x-scheme-handler/ext+container)"
echo "Test: xdg-open 'ext+container://GOOGLE/https://claude.ai/new'"

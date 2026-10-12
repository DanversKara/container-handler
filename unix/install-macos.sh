#!/usr/bin/env bash
# Builds a tiny background app that handles ext+container:// links (macOS).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
app="$HOME/Applications/Brave Container Links.app"
plist="$app/Contents/Info.plist"
pb=/usr/libexec/PlistBuddy

mkdir -p "$HOME/Applications"
rm -rf "$app"

script_file="$(mktemp -t bcl).applescript"
cat > "$script_file" <<'EOF'
on open location theURL
	set handler to (POSIX path of (path to me)) & "Contents/Resources/brave-container-open"
	do shell script quoted form of handler & " " & quoted form of theURL & " > /dev/null 2>&1 &"
end open location
EOF
osacompile -o "$app" "$script_file"
rm -f "$script_file"

install -m 755 "$here/brave-container-open" "$app/Contents/Resources/brave-container-open"

$pb -c "Set :CFBundleIdentifier local.brave-container-links" "$plist" 2>/dev/null \
  || $pb -c "Add :CFBundleIdentifier string local.brave-container-links" "$plist"
$pb -c "Add :LSUIElement bool true" "$plist"
$pb -c "Add :CFBundleURLTypes array" "$plist"
$pb -c "Add :CFBundleURLTypes:0 dict" "$plist"
$pb -c "Add :CFBundleURLTypes:0:CFBundleURLName string Brave container link" "$plist"
$pb -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$plist"
$pb -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string ext+container" "$plist"

# Editing Info.plist breaks the ad-hoc signature osacompile made; re-sign it.
codesign --force --deep --sign - "$app" >/dev/null 2>&1 || true

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"

echo "Installed: $app"
echo "Test: open 'ext+container://GOOGLE/https://claude.ai/new'"

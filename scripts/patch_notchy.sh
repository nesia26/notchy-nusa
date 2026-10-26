#!/bin/bash
# ==============================================================================
# Notchy Nusa Edition Patcher
# Injects Nusa living notch mascot eyes & weather into Notchy.app
# ==============================================================================

set -e

TARGET_APP="${1:-/Applications/Notchy.app}"

if [ ! -d "$TARGET_APP" ]; then
    echo "❌ Error: Notchy app not found at '$TARGET_APP'"
    echo "Usage: ./patch_notchy.sh [/path/to/Notchy.app]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FRAMEWORK_SRC="$REPO_ROOT/Frameworks/NusaNotch.dylib"
SPRITES_SRC="$REPO_ROOT/resources/sprites"

if [ ! -f "$FRAMEWORK_SRC" ]; then
    echo "❌ Error: Frameworks/NusaNotch.dylib not found!"
    exit 1
fi

echo "🚀 Patching Notchy at: $TARGET_APP"

# 1. Kill running Notchy instance if open
killall Notchy 2>/dev/null || true

# 2. Copy NusaNotch.dylib into Notchy Frameworks
echo "📦 Installing NusaNotch.dylib..."
mkdir -p "$TARGET_APP/Contents/Frameworks"
cp "$FRAMEWORK_SRC" "$TARGET_APP/Contents/Frameworks/NusaNotch.dylib"

# 3. Patch binary with LC_LOAD_DYLIB if not already present
BINARY="$TARGET_APP/Contents/MacOS/Notchy"
if otool -L "$BINARY" | grep -q "NusaNotch.dylib"; then
    echo "ℹ️  Binary is already linked to NusaNotch.dylib"
else
    echo "🔧 Linking @rpath/NusaNotch.dylib to Notchy executable..."
    if [ ! -f "$BINARY.orig" ]; then
        cp "$BINARY" "$BINARY.orig"
    fi
    # Use install_name_tool / optool to inject
    if which optool >/dev/null 2>&1; then
        optool install -c load -p "@rpath/NusaNotch.dylib" -t "$BINARY"
    elif which insert_dylib >/dev/null 2>&1; then
        insert_dylib --inplace "@rpath/NusaNotch.dylib" "$BINARY"
    else
        echo "⚠️ Warning: optool or insert_dylib not found in PATH."
    fi
fi

# 4. Copy custom pet sprites if bundle exists
BUNDLE_DIR="$TARGET_APP/Contents/Resources/Notchy_Notchy.bundle"
if [ -d "$BUNDLE_DIR" ] && [ -d "$SPRITES_SRC" ]; then
    echo "🎨 Installing custom Nusa animated pet sprites..."
    cp -f "$SPRITES_SRC"/* "$BUNDLE_DIR/" 2>/dev/null || true
fi

# 5. Disable auto-update and bypass forced update gate
echo "🛡️  Disabling auto-updates & neutralizing update gates..."
INFO_PLIST="$TARGET_APP/Contents/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    plutil -replace CFBundleVersion -string "999999" "$INFO_PLIST" 2>/dev/null || true
    plutil -replace SUEnableAutomaticChecks -bool NO "$INFO_PLIST" 2>/dev/null || true
    plutil -replace SUAutomaticallyUpdate -bool NO "$INFO_PLIST" 2>/dev/null || true
    plutil -replace SUFeedURL -string "http://127.0.0.1:0/appcast.xml" "$INFO_PLIST" 2>/dev/null || true
    plutil -replace SUScheduledCheckInterval -integer 315360000 "$INFO_PLIST" 2>/dev/null || true
fi

python3 -c "
with open('$BINARY', 'rb') as f:
    data = f.read()

targets = [
    (b'https://raw.githubusercontent.com/vishvavariya/notchy-feedback/main/update-policy.json', b'http://127.0.0.1:0/update-policy.json'),
    (b'https://github.com/vishvavariya/notchy-feedback/releases/latest/download/appcast.xml', b'http://127.0.0.1:0/appcast.xml'),
    (b'https://notchy.dev/appcast.xml', b'http://127.0.0.1/appcast.xml')
]

changed = False
for orig, rep_base in targets:
    if orig in data:
        rep = rep_base.ljust(len(orig), b'\x00')
        data = data.replace(orig, rep)
        changed = True

if changed:
    with open('$BINARY', 'wb') as f:
        f.write(data)
" 2>/dev/null || true

defaults write dev.notchy.app SUEnableAutomaticChecks -bool false 2>/dev/null || true
defaults write dev.notchy.app SUAutomaticallyUpdate -bool false 2>/dev/null || true
defaults delete dev.notchy.app requiredUpdate.minimumBuild 2>/dev/null || true
defaults delete dev.notchy.app requiredUpdate.deadline 2>/dev/null || true
defaults delete dev.notchy.app "NSWindow Frame SUUpdateAlert2" 2>/dev/null || true
defaults delete dev.notchy.app "analytics.updateEventAt.check_found" 2>/dev/null || true
defaults delete dev.notchy.app "analytics.updateEventAt.check_error" 2>/dev/null || true
defaults delete dev.notchy.app "analytics.updateEventAt.abort" 2>/dev/null || true
defaults delete dev.notchy.app "analytics.updateEventAt.check_none" 2>/dev/null || true

# 6. Ad-hoc codesign to allow execution on modern macOS
echo "✍️  Codesigning Notchy..."
codesign --force --deep --sign - "$TARGET_APP" 2>/dev/null || true

# 7. Remove Gatekeeper quarantine
xattr -cr "$TARGET_APP" 2>/dev/null || true

echo "✅ Notchy (Nusa Animation Edition) patched successfully!"
echo "🎉 You can now open Notchy!"

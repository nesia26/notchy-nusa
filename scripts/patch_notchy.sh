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

# 5. Ad-hoc codesign to allow execution on modern macOS
echo "✍️  Codesigning Notchy..."
codesign --force --deep --sign - "$TARGET_APP" 2>/dev/null || true

# 6. Remove Gatekeeper quarantine
xattr -cr "$TARGET_APP" 2>/dev/null || true

echo "✅ Notchy (Nusa Animation Edition) patched successfully!"
echo "🎉 You can now open Notchy!"

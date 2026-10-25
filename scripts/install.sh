#!/bin/bash
# ==============================================================================
# Notchy Nusa Edition Installer & Launcher
# Removes Gatekeeper quarantine and launches Notchy
# ==============================================================================

set -e

APP_PATH="/Applications/Notchy.app"

if [ ! -d "$APP_PATH" ]; then
    if [ -d "./Notchy.app" ]; then
        echo "📂 Moving Notchy.app to /Applications..."
        cp -R "./Notchy.app" /Applications/
    else
        echo "❌ Error: Notchy.app not found. Please download from GitHub Releases."
        exit 1
    fi
fi

echo "🔓 Removing Gatekeeper quarantine..."
xattr -cr "$APP_PATH" 2>/dev/null || true

echo "✍️  Re-signing ad-hoc..."
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true

echo "🚀 Launching Notchy Nusa Edition..."
open "$APP_PATH"

echo "✅ Done! Enjoy Notchy with Nusa Animation!"

#!/bin/bash
# ==============================================================================
# Build Universal NusaNotch.dylib (x86_64 + arm64)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$REPO_ROOT/src"
OUT_DYLIB="$REPO_ROOT/Frameworks/NusaNotch.dylib"

if [ ! -f "$SRC_DIR/NusaNotch.swift" ] || [ ! -f "$SRC_DIR/entry.c" ]; then
    echo "❌ Error: Source files not found in $SRC_DIR"
    exit 1
fi

echo "🔨 Building universal NusaNotch.dylib from source..."
BUILD_TMP="/tmp/nusa_dylib_build"
mkdir -p "$BUILD_TMP"
cd "$BUILD_TMP"

# 1. Compile x86_64
echo "⚙️  Compiling for x86_64..."
swiftc -emit-object -O -target x86_64-apple-macos14.0 -framework AppKit -framework SwiftUI -framework Foundation "$SRC_DIR/NusaNotch.swift" -o NusaNotch_x86_64.o
clang -c -target x86_64-apple-macos14.0 "$SRC_DIR/entry.c" -o entry_x86_64.o
swiftc -emit-library -target x86_64-apple-macos14.0 -framework AppKit -framework SwiftUI -framework Foundation NusaNotch_x86_64.o entry_x86_64.o -o NusaNotch_x86_64.dylib

# 2. Compile arm64 (Apple Silicon)
echo "⚙️  Compiling for arm64 (Apple Silicon)..."
swiftc -emit-object -O -target arm64-apple-macos14.0 -framework AppKit -framework SwiftUI -framework Foundation "$SRC_DIR/NusaNotch.swift" -o NusaNotch_arm64.o
clang -c -target arm64-apple-macos14.0 "$SRC_DIR/entry.c" -o entry_arm64.o
swiftc -emit-library -target arm64-apple-macos14.0 -framework AppKit -framework SwiftUI -framework Foundation NusaNotch_arm64.o entry_arm64.o -o NusaNotch_arm64.dylib

# 3. Combine into Universal Binary
echo "🔗 Creating Universal Binary..."
mkdir -p "$(dirname "$OUT_DYLIB")"
lipo -create NusaNotch_x86_64.dylib NusaNotch_arm64.dylib -output "$OUT_DYLIB"
rm -rf "$BUILD_TMP"

echo "✅ Success! Universal NusaNotch.dylib compiled at:"
echo "   $OUT_DYLIB"
file "$OUT_DYLIB"

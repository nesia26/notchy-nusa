#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "=========================================="
echo " 🏝️ Building Notchy Nusa Edition for iPadOS"
echo "    (with WidgetKit Extension)"
echo "=========================================="

# 1. Generate Xcode Project with xcodegen
echo "--> [1/4] Generating Xcode project with Host App & Widget..."
xcodegen generate

# 2. Build for iOS / iPadOS Release
echo "--> [2/4] Building iPad application & NotchyWidget.appex (arm64)..."
xcodebuild build \
  -project NotchyPad.xcodeproj \
  -scheme NotchyPad \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  -derivedDataPath ./build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

# 3. Create Payload Directory
echo "--> [3/4] Creating IPA Payload & Signing PlugIns..."
PAYLOAD_DIR="/tmp/notchypad_payload"
rm -rf "${PAYLOAD_DIR}"
mkdir -p "${PAYLOAD_DIR}/Payload"

BUILT_APP="${SCRIPT_DIR}/build/DerivedData/Build/Products/Release-iphoneos/Notchy.app"
cp -R "${BUILT_APP}" "${PAYLOAD_DIR}/Payload/"

# Strip Gatekeeper & ad-hoc sign extension then app
xattr -cr "${PAYLOAD_DIR}/Payload/Notchy.app"
if [ -d "${PAYLOAD_DIR}/Payload/Notchy.app/PlugIns/NotchyWidget.appex" ]; then
    echo "    Signing PlugIns/NotchyWidget.appex..."
    codesign --force --sign - "${PAYLOAD_DIR}/Payload/Notchy.app/PlugIns/NotchyWidget.appex"
fi
codesign --force --sign - "${PAYLOAD_DIR}/Payload/Notchy.app"

# 4. Package into .ipa
echo "--> [4/4] Packaging into .ipa..."
OUTPUT_IPA="${SCRIPT_DIR}/Notchy_iPad.ipa"
(cd "${PAYLOAD_DIR}" && zip -qr "${OUTPUT_IPA}" Payload)
rm -rf "${PAYLOAD_DIR}"

ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
cp -f "${OUTPUT_IPA}" "${ROOT_DIR}/Notchy_iPad.ipa"

echo "=========================================="
echo " 🎉 Selesai! iPadOS IPA + Widget berhasil dibuat:"
echo " - File: ${ROOT_DIR}/Notchy_iPad.ipa"
echo " - Termasuk: Host App + NotchyWidget.appex"
echo " - Siap di-install via Sideloadly / TrollStore / AltStore!"
echo "=========================================="

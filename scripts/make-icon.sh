#!/usr/bin/env bash
# Render the Kaji app icon and pack it into Resources/AppIcon.icns.
#
# Renders scripts/appicon.swift (SwiftUI ImageRenderer) to a 1024 master, then
# sips-downscales the macOS iconset sizes and iconutil-packs the .icns. The
# committed AppIcon.icns is what build-app.sh / CI ship — this script only needs
# running when the icon design changes.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

MASTER="$TMP/icon-1024.png"
ICONSET="$TMP/AppIcon.iconset"
mkdir -p "$ICONSET"

echo "==> rendering 1024 master"
swiftc -O -parse-as-library scripts/appicon.swift -o "$TMP/iconapp"
"$TMP/iconapp" "$MASTER"

echo "==> generating iconset sizes"
gen() { sips -z "$2" "$2" "$MASTER" --out "$ICONSET/$1" >/dev/null; }
gen icon_16x16.png        16
gen icon_16x16@2x.png     32
gen icon_32x32.png        32
gen icon_32x32@2x.png     64
gen icon_128x128.png      128
gen icon_128x128@2x.png   256
gen icon_256x256.png      256
gen icon_256x256@2x.png   512
gen icon_512x512.png      512
cp "$MASTER" "$ICONSET/icon_512x512@2x.png"   # 1024

echo "==> packing Resources/AppIcon.icns"
mkdir -p Resources
iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns
echo "    done: Resources/AppIcon.icns"

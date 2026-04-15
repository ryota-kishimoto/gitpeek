#!/bin/bash

# GitPeek Build Script
# Builds a standalone macOS application without Xcode

set -e

echo "🔨 Building GitPeek..."

# Clean previous builds
rm -rf .build
rm -rf GitPeek.app

# Build in release mode
echo "📦 Compiling Swift code..."
swift build -c release --arch arm64 --arch x86_64

# Create app bundle structure
echo "📱 Creating app bundle..."
mkdir -p GitPeek.app/Contents/MacOS
mkdir -p GitPeek.app/Contents/Resources
mkdir -p GitPeek.app/Contents/Frameworks

# Copy executable
cp .build/apple/Products/Release/GitPeek GitPeek.app/Contents/MacOS/

# Copy Sparkle framework
echo "📦 Copying Sparkle framework..."
if [ -d ".build/apple/Products/Release/Sparkle.framework" ]; then
    cp -R .build/apple/Products/Release/Sparkle.framework GitPeek.app/Contents/Frameworks/
fi

# Fix rpath for Sparkle framework
echo "🔧 Fixing rpath..."
install_name_tool -add_rpath "@executable_path/../Frameworks" GitPeek.app/Contents/MacOS/GitPeek 2>/dev/null || true

# Start from the source Info.plist so there is a single source of truth for
# things like Sparkle keys, copyright, and usage descriptions. Then patch the
# fields that can't use build-setting variables at runtime (CFBundleExecutable,
# CFBundleIdentifier, LSMinimumSystemVersion).
SOURCE_PLIST="GitPeek/Info.plist"
DEST_PLIST="GitPeek.app/Contents/Info.plist"

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$SOURCE_PLIST" 2>/dev/null || echo "1.0.0")

cp "$SOURCE_PLIST" "$DEST_PLIST"

plist_set() {
    local key="$1"
    local type="$2"
    local value="$3"
    /usr/libexec/PlistBuddy -c "Set :$key $value" "$DEST_PLIST" 2>/dev/null \
        || /usr/libexec/PlistBuddy -c "Add :$key $type $value" "$DEST_PLIST"
}

plist_set "CFBundleExecutable" "string" "GitPeek"
plist_set "CFBundleIdentifier" "string" "com.gitpeek.GitPeek"
plist_set "CFBundleName" "string" "GitPeek"
plist_set "CFBundlePackageType" "string" "APPL"
plist_set "CFBundleShortVersionString" "string" "$VERSION"
plist_set "CFBundleVersion" "string" "$VERSION"
plist_set "LSMinimumSystemVersion" "string" "13.0"
plist_set "NSSupportsAutomaticTermination" "bool" "false"

# Generate all icons from SVG source
ICON_SVG="gitpeek-icon.svg"
MENUBAR_SVG="gitpeek-menubar.svg"

if [ -f "$ICON_SVG" ]; then
    # App icon (.icns) - transparent background, cyan
    echo "🎨 Creating app icon..."
    ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
    mkdir -p "$ICONSET_DIR"
    magick -background none "$ICON_SVG" -resize 16x16     PNG32:"$ICONSET_DIR/icon_16x16.png"
    magick -background none "$ICON_SVG" -resize 32x32     PNG32:"$ICONSET_DIR/icon_16x16@2x.png"
    magick -background none "$ICON_SVG" -resize 32x32     PNG32:"$ICONSET_DIR/icon_32x32.png"
    magick -background none "$ICON_SVG" -resize 64x64     PNG32:"$ICONSET_DIR/icon_32x32@2x.png"
    magick -background none "$ICON_SVG" -resize 128x128   PNG32:"$ICONSET_DIR/icon_128x128.png"
    magick -background none "$ICON_SVG" -resize 256x256   PNG32:"$ICONSET_DIR/icon_128x128@2x.png"
    magick -background none "$ICON_SVG" -resize 256x256   PNG32:"$ICONSET_DIR/icon_256x256.png"
    magick -background none "$ICON_SVG" -resize 512x512   PNG32:"$ICONSET_DIR/icon_256x256@2x.png"
    magick -background none "$ICON_SVG" -resize 512x512   PNG32:"$ICONSET_DIR/icon_512x512.png"
    magick -background none "$ICON_SVG" -resize 1024x1024 PNG32:"$ICONSET_DIR/icon_512x512@2x.png"
    iconutil -c icns "$ICONSET_DIR" -o GitPeek.app/Contents/Resources/AppIcon.icns
    rm -rf "$(dirname "$ICONSET_DIR")"

    # In-app icon (color, transparent)
    echo "🎨 Copying in-app icon..."
    magick -background none "$ICON_SVG" -resize 64x64 PNG32:GitPeek.app/Contents/Resources/AppIconColor.png
    magick -background none "$ICON_SVG" -resize 128x128 PNG32:GitPeek.app/Contents/Resources/AppIconColor@2x.png
else
    echo "⚠️  gitpeek-icon.svg not found, skipping icons"
fi

if [ -f "$MENUBAR_SVG" ]; then
    # Menu bar icon (black template, transparent).
    # rsvg-convert handles stroke-width and complex beziers more faithfully
    # than ImageMagick at tiny sizes, so the 18/36px output is slightly less
    # fuzzy. Falls back to magick if rsvg-convert is unavailable.
    echo "🎨 Copying menu bar icon..."
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 18 -h 18 "$MENUBAR_SVG" -o GitPeek.app/Contents/Resources/MenuBarIcon.png
        rsvg-convert -w 36 -h 36 "$MENUBAR_SVG" -o GitPeek.app/Contents/Resources/MenuBarIcon@2x.png
    else
        echo "⚠️  rsvg-convert not found, falling back to magick (may look fuzzier)"
        magick -background none "$MENUBAR_SVG" -resize 18x18 PNG32:GitPeek.app/Contents/Resources/MenuBarIcon.png
        magick -background none "$MENUBAR_SVG" -resize 36x36 PNG32:GitPeek.app/Contents/Resources/MenuBarIcon@2x.png
    fi
else
    echo "⚠️  gitpeek-menubar.svg not found, skipping menu bar icon"
fi

echo "✅ Build complete!"
echo ""
echo "📍 Application created at: $(pwd)/GitPeek.app"
echo ""
echo "To run GitPeek:"
echo "  1. Double-click GitPeek.app in Finder"
echo "  2. Or run: open GitPeek.app"
echo ""
echo "To install to Applications:"
echo "  cp -r GitPeek.app /Applications/"
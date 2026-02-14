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

# Get version from source Info.plist  
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "GitPeek/Info.plist" 2>/dev/null || echo "1.0.0")

# Create Info.plist
cat > GitPeek.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>GitPeek</string>
    <key>CFBundleIdentifier</key>
    <string>com.gitpeek.GitPeek</string>
    <key>CFBundleName</key>
    <string>GitPeek</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>SUFeedURL</key>
    <string>https://raw.githubusercontent.com/ryota-kishimoto/gitpeek/main/appcast.xml</string>
    <key>SUEnableAutomaticChecks</key>
    <true/>
    <key>SUScheduledCheckInterval</key>
    <integer>86400</integer>
    <key>SUPublicEDKey</key>
    <string>VuF1RDfpkALoNuceWkjdqQC8tKsTRcPEBgWnD1iIkOY=</string>
</dict>
</plist>
EOF

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
    # Menu bar icon (black template, transparent)
    echo "🎨 Copying menu bar icon..."
    magick -background none "$MENUBAR_SVG" -resize 18x18 PNG32:GitPeek.app/Contents/Resources/MenuBarIcon.png
    magick -background none "$MENUBAR_SVG" -resize 36x36 PNG32:GitPeek.app/Contents/Resources/MenuBarIcon@2x.png
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
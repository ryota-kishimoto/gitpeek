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

# Copy executable
cp .build/apple/Products/Release/GitPeek GitPeek.app/Contents/MacOS/

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
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
</dict>
</plist>
EOF

# Create a simple icon (optional)
echo "🎨 Creating default icon..."
cat > GitPeek.app/Contents/Resources/AppIcon.icns << EOF
# Placeholder for icon
EOF

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
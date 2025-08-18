#!/bin/bash

# GitPeek Release Script
# Creates a GitHub release with a DMG installer

set -e

# Configuration
APP_NAME="GitPeek"
VERSION="1.0.0"
RELEASE_NAME="GitPeek v${VERSION}"
RELEASE_TAG="v${VERSION}"

echo "🚀 Creating Release: ${RELEASE_NAME}"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it with: brew install gh"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ Not logged in to GitHub."
    echo "Run: gh auth login"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf "${APP_NAME}.app"
rm -rf "${APP_NAME}-${VERSION}.dmg"
rm -rf release-tmp

# Build the app
echo "🔨 Building ${APP_NAME}..."
./build.sh

# Create a temporary directory for DMG contents
echo "📁 Preparing DMG contents..."
mkdir -p release-tmp
cp -r "${APP_NAME}.app" release-tmp/
ln -s /Applications release-tmp/Applications

# Create DMG
echo "💿 Creating DMG installer..."
hdiutil create -volname "${APP_NAME}" \
    -srcfolder release-tmp \
    -ov -format UDZO \
    "${APP_NAME}-${VERSION}.dmg"

# Calculate checksums
echo "🔐 Calculating checksums..."
shasum -a 256 "${APP_NAME}-${VERSION}.dmg" > "${APP_NAME}-${VERSION}.dmg.sha256"

# Create release notes
echo "📝 Creating release notes..."
cat > release_notes.md << EOF
# ${RELEASE_NAME}

## 🎉 First Release!

GitPeek is a lightweight macOS menu bar application for managing multiple Git repositories.

### ✨ Features

- 📊 Multiple repository management
- 🔄 Real-time status updates (30-second intervals)
- 🌿 Current branch display
- 📝 Change count visualization
- 🚀 Quick actions (Cursor, Terminal, GitHub, SourceTree)
- ⚙️ Customizable settings
- 🌙 Dark mode support

### 📦 Installation

1. Download \`${APP_NAME}-${VERSION}.dmg\`
2. Open the DMG file
3. Drag GitPeek to your Applications folder
4. Launch GitPeek from Applications
5. The GitPeek icon will appear in your menu bar

### 🔧 Requirements

- macOS 13.0 (Ventura) or later
- Git installed on your system

### 🛠️ Build Information

- Architecture: Universal (Intel + Apple Silicon)
- Swift Version: 5.9+
- Minimum macOS: 13.0

### 📝 Changelog

#### New Features
- Repository management system
- Git status monitoring
- External app integration
- Settings screen
- Auto-refresh functionality

### 🔐 Checksums

\`\`\`
$(cat "${APP_NAME}-${VERSION}.dmg.sha256")
\`\`\`

### 🙏 Acknowledgments

Built with SwiftUI and love for the macOS developer community.

---

**Full Changelog**: https://github.com/gitpeek/gitpeek/commits/${RELEASE_TAG}
EOF

# Create GitHub release
echo "🌐 Creating GitHub release..."
gh release create "${RELEASE_TAG}" \
    --title "${RELEASE_NAME}" \
    --notes-file release_notes.md \
    --draft \
    "${APP_NAME}-${VERSION}.dmg" \
    "${APP_NAME}-${VERSION}.dmg.sha256"

# Clean up
echo "🧹 Cleaning up..."
rm -rf release-tmp
rm -f release_notes.md

echo ""
echo "✅ Release draft created successfully!"
echo ""
echo "📍 Next steps:"
echo "1. Review the draft release at: https://github.com/gitpeek/gitpeek/releases"
echo "2. Edit release notes if needed"
echo "3. Publish the release when ready"
echo ""
echo "📦 Artifacts uploaded:"
echo "  - ${APP_NAME}-${VERSION}.dmg"
echo "  - ${APP_NAME}-${VERSION}.dmg.sha256"
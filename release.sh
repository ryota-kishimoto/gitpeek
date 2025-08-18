#!/bin/bash

# GitPeek Release Script
# Creates a GitHub release with a DMG installer

set -e

# Configuration
APP_NAME="GitPeek"
VERSION="1.2.0"
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
if [ -f "release_notes_1.2.0.md" ]; then
    cp release_notes_1.2.0.md release_notes.md
    # Add checksums to the release notes
    echo "" >> release_notes.md
    echo "### 🔐 Checksums" >> release_notes.md
    echo "" >> release_notes.md
    echo "\`\`\`" >> release_notes.md
    cat "${APP_NAME}-${VERSION}.dmg.sha256" >> release_notes.md
    echo "\`\`\`" >> release_notes.md
else
    cat > release_notes.md << EOF
# ${RELEASE_NAME}

## 🎉 Major Update with Stability Improvements!

This release brings significant improvements to stability, UI/UX, and introduces Git worktree support.

### ✨ New Features

- **Git Worktree Support** - Detect and display Git worktrees with visual indicators
- **Simplified Theme System** - Clean, modern white-background UI optimized for readability
- **Enhanced Repository Management** - Improved file dialog for adding repositories

### 🐛 Bug Fixes

- Fixed popover dismissal when clicking outside
- Fixed Terminal app integration issues  
- Fixed Cursor editor integration to open properly
- Fixed file dialog crashes when selecting Desktop folder
- Resolved repository data persistence issues
- Fixed app startup crashes

### 🎨 UI/UX Improvements

- Changed Clean status color to mint for better visibility
- Staged files now shown in blue
- Single file modifications shown in gray for clarity
- Improved hover and selection states
- Added version display in menu header
- Better visual hierarchy with subtle backgrounds

### 🔧 Technical Improvements

- Removed non-functional dark mode to simplify codebase
- Reduced code complexity by ~200 lines
- Improved build system for standalone app creation
- Better error handling throughout
- Enhanced AppleScript integration for Terminal

### 📦 Installation

1. Download \`${APP_NAME}-${VERSION}.dmg\`
2. Open the DMG file
3. Drag GitPeek to your Applications folder
4. Launch GitPeek from Applications
5. The GitPeek icon will appear in your menu bar

### 🔧 Requirements

- macOS 13.0 (Ventura) or later
- Git installed on your system

### 🔐 Checksums

\`\`\`
$(cat "${APP_NAME}-${VERSION}.dmg.sha256")
\`\`\`

### 🙏 Acknowledgments

Thanks to all users for their feedback and patience while we improved GitPeek!

---

**Full Changelog**: https://github.com/gitpeek/gitpeek/compare/v1.0.0...v1.2.0
EOF
fi

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
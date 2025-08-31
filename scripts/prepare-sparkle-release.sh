#!/bin/bash

# Sparkle Release Preparation Script
# This script prepares a release for Sparkle auto-update

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.3.0"
    exit 1
fi

VERSION=$1
DMG_FILE="GitPeek-${VERSION}.dmg"

echo "📦 Preparing Sparkle release for version ${VERSION}"

# Check if DMG exists
if [ ! -f "$DMG_FILE" ]; then
    echo "❌ DMG file not found: $DMG_FILE"
    echo "Please build the DMG first using release.sh"
    exit 1
fi

# Get file size
FILE_SIZE=$(stat -f%z "$DMG_FILE")
echo "📏 DMG size: $FILE_SIZE bytes"

# Sign the update using Sparkle tools
echo "✍️  Signing the update..."
SIGNATURE=$(~/.sparkle/bin/sign_update "$DMG_FILE" 2>&1 | tail -1)

if [ $? -ne 0 ]; then
    echo "❌ Failed to sign update"
    echo "Make sure you have generated keys with: ~/.sparkle/bin/generate_keys"
    exit 1
fi

echo "✅ Signature: $SIGNATURE"

# Generate appcast entry
echo ""
echo "📝 Add this to appcast.xml:"
echo ""
cat << EOF
<item>
    <title>Version ${VERSION}</title>
    <description><![CDATA[
        <h2>What's New</h2>
        <ul>
            <li>Add your release notes here</li>
        </ul>
    ]]></description>
    <pubDate>$(date -R)</pubDate>
    <sparkle:version>${VERSION}</sparkle:version>
    <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
    <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
    <enclosure 
        url="https://github.com/ryota-kishimoto/gitpeek/releases/download/v${VERSION}/GitPeek-${VERSION}.dmg"
        sparkle:edSignature="${SIGNATURE}"
        length="${FILE_SIZE}"
        type="application/octet-stream" />
</item>
EOF

echo ""
echo "📋 Next steps:"
echo "1. Copy the appcast entry above to appcast.xml"
echo "2. Create GitHub release and upload the DMG"
echo "3. Commit and push appcast.xml to main branch"
echo ""
echo "🔒 Signature has been automatically generated and included!"
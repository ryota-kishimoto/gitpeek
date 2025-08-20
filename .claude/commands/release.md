# /release

Create a new release with tag and GitHub release.

## Important Notes

- **リリースの実行はユーザーが最終決定する**
- このコマンドは自動的にタグをプッシュしない
- ユーザーの確認を得てから実行する
- ローカルビルドも実行して、アプリを自動更新

## Steps to execute:

1. Ask the user for the version number (e.g., v1.2.2)
2. Show recent commits for release notes
3. Generate release notes from commits
4. **Ask user for confirmation before proceeding**
5. Build Release version locally
6. Create DMG installer in build/ directory
7. Replace local app with new version
8. Create and push a git tag
9. Monitor GitHub Actions workflow
10. Provide links to the release page

## Local Build Process:

```bash
# Clean build directory
rm -rf build/
mkdir -p build

# Kill existing GitPeek
pkill -f GitPeek || true

# Build Release version
xcodebuild -scheme GitPeek \
  -configuration Release \
  -derivedDataPath build_release \
  -destination 'platform=macOS,arch=arm64' \
  clean build

# Create app bundle structure
mkdir -p build/GitPeek.app/Contents/MacOS
mkdir -p build/GitPeek.app/Contents/Resources

# Copy executable
cp build_release/Build/Products/Release/GitPeek build/GitPeek.app/Contents/MacOS/

# Create Info.plist with version
cat > build/GitPeek.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>GitPeek</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.gitpeek.GitPeek</string>
    <key>CFBundleName</key>
    <string>GitPeek</string>
    <key>CFBundleDisplayName</key>
    <string>GitPeek</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Sign the app
chmod +x build/GitPeek.app/Contents/MacOS/GitPeek
codesign --force --deep --sign - build/GitPeek.app

# Create DMG
mkdir -p build/dmg_contents
cp -R build/GitPeek.app build/dmg_contents/
ln -s /Applications build/dmg_contents/Applications
hdiutil create -volname "GitPeek" \
  -srcfolder build/dmg_contents \
  -ov -format UDZO \
  -fs HFS+ \
  build/GitPeek-vX.X.X.dmg

# Clean up DMG contents
rm -rf build/dmg_contents

# Install new version to Applications
rm -rf /Applications/GitPeek.app
cp -R build/GitPeek.app /Applications/

# Launch new version
open /Applications/GitPeek.app
```

## Git Commands:

```bash
# Create annotated tag (after user confirmation)
git tag -a vX.X.X -m "Release vX.X.X with release notes"

# Push the tag
git push origin vX.X.X

# Check workflow status
gh run list --workflow=release.yml --limit=1
```

## GitHub Actions Workflow

The workflow will automatically:
- Build the Release version for macOS
- Create DMG installer
- Generate SHA256 checksum
- Create GitHub Release with release notes
- Upload assets (DMG and SHA256)

## Release Checklist

Before releasing, ensure:
- [ ] All tests pass
- [ ] No uncommitted changes
- [ ] User has reviewed and confirmed the release
- [ ] Version number is correct

## File Structure After Release

```
build/
├── GitPeek.app/          # Built application
└── GitPeek-vX.X.X.dmg    # DMG installer
```
# /restart

Rebuild and restart GitPeek with the latest changes.

## Important Notes

- アプリを再ビルドして再起動
- /Applications/GitPeek.appを更新
- 開発中の動作確認に便利

## Steps to execute:

1. Kill existing GitPeek process
2. Build Debug version
3. Create app bundle
4. Replace /Applications/GitPeek.app
5. Launch new version

## Commands to run:

```bash
# Kill existing GitPeek
pkill -f GitPeek || true

# Build Debug version
xcodebuild -scheme GitPeek \
  -configuration Debug \
  -derivedDataPath build \
  -destination 'platform=macOS,arch=arm64' \
  clean build

# Create app bundle structure
rm -rf build/GitPeek.app
mkdir -p build/GitPeek.app/Contents/MacOS
mkdir -p build/GitPeek.app/Contents/Resources

# Copy executable
cp build/Build/Products/Debug/GitPeek build/GitPeek.app/Contents/MacOS/

# Create Info.plist with current version
CURRENT_VERSION=$(grep -A1 "CFBundleShortVersionString" GitPeek/Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>/\1/')
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
    <string>${CURRENT_VERSION}</string>
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

# Replace app in Applications
rm -rf /Applications/GitPeek.app
cp -R build/GitPeek.app /Applications/

# Launch new version
open /Applications/GitPeek.app
```

## Usage

このコマンドは以下の場合に使用：
- コード変更後の動作確認
- デバッグビルドのテスト
- リリース前の最終確認

## Note

- Debug版のビルドなので、リリース版より若干遅い可能性があります
- 本番リリースには `/release` コマンドを使用してください
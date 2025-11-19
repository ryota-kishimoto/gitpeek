# GitPeek Build Guide

## Quick Start

### Build Standalone App
```bash
./build.sh
```

Output: `GitPeek.app` in project root

### Install to Applications
```bash
cp -r GitPeek.app /Applications/
```

## Build Methods

### 1. build.sh (Recommended)

**Pros**:
- ✅ Fastest build method
- ✅ Generates standalone .app
- ✅ Includes Sparkle.framework
- ✅ Universal binary (arm64 + x86_64)
- ✅ Production-ready

**Command**:
```bash
./build.sh
```

**Output**:
- `GitPeek.app` - Ready to use
- Universal binary in `GitPeek.app/Contents/MacOS/GitPeek`
- Sparkle framework in `GitPeek.app/Contents/Frameworks/`

### 2. Xcode (Development)

**Pros**:
- ✅ Best for development
- ✅ Integrated debugging
- ✅ Live preview

**Steps**:
1. Open project: `open Package.swift` or `xed .`
2. Select "GitPeek" scheme
3. Select "My Mac" destination
4. Press Command + R to run

**Note**: Xcode builds to DerivedData, not a standalone .app

### 3. Swift Package Manager

**For CLI tools**:
```bash
swift build -c release
```

**Output**:
- Binary at `.build/apple/Products/Release/GitPeek`
- Not an app bundle
- Requires manual framework bundling

### 4. Makefile

**Available targets**:
```bash
make app      # Build standalone app (uses build.sh)
make install  # Build and install to /Applications
make build    # Debug build (SPM)
make clean    # Clean build artifacts
```

## Build Script Details

### build.sh Workflow

1. **Compile** - Swift Package Manager
   ```bash
   swift build -c release --arch arm64 --arch x86_64
   ```

2. **Create Bundle Structure**
   ```
   GitPeek.app/
   ├── Contents/
   │   ├── MacOS/
   │   │   └── GitPeek (universal binary)
   │   ├── Frameworks/
   │   │   └── Sparkle.framework/
   │   ├── Resources/
   │   │   └── AppIcon.icns
   │   └── Info.plist
   ```

3. **Copy Executable**
   ```bash
   cp .build/apple/Products/Release/GitPeek GitPeek.app/Contents/MacOS/
   ```

4. **Bundle Sparkle Framework**
   ```bash
   cp -R .build/apple/Products/Release/Sparkle.framework GitPeek.app/Contents/Frameworks/
   ```

5. **Fix rpath**
   ```bash
   install_name_tool -add_rpath "@executable_path/../Frameworks" GitPeek.app/Contents/MacOS/GitPeek
   ```

6. **Generate Info.plist**
   - Reads version from `GitPeek/Info.plist`
   - Adds Sparkle update configuration
   - Sets bundle identifiers

## Version Management

### Current Version Location
`GitPeek/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.3.2</string>
```

### Update Version
1. Edit `GitPeek/Info.plist`
2. Update `CFBundleShortVersionString`
3. Update `CFBundleVersion`
4. Rebuild: `./build.sh`

## Troubleshooting

### Common Issues

#### 1. Sparkle Framework Not Found
```
dyld: Library not loaded: @rpath/Sparkle.framework
```

**Solution**: Run build.sh (it fixes rpath automatically)

#### 2. Version Shows 1.0.0
**Cause**: Info.plist not being read

**Check**:
```bash
cat GitPeek.app/Contents/Info.plist | grep -A 1 "CFBundleShortVersionString"
```

**Fix**: Rebuild with `./build.sh`

#### 3. App Won't Launch
**Debug**:
```bash
GitPeek.app/Contents/MacOS/GitPeek
```

Check console output for errors.

#### 4. Permission Denied
```bash
chmod +x build.sh
./build.sh
```

## Build Configurations

### Debug Build
```bash
swift build -c debug
```
- Includes debug symbols
- No optimizations
- Faster compile time

### Release Build
```bash
swift build -c release
```
- Optimized
- Stripped symbols
- Smaller binary

### Universal Binary
```bash
swift build -c release --arch arm64 --arch x86_64
```
- Supports Intel and Apple Silicon
- Larger binary size

## Distribution

### Create DMG
```bash
./release.sh
```

Generates:
- `GitPeek-1.3.2.dmg`
- `GitPeek-1.3.2.dmg.sha256`

### Manual DMG Creation
```bash
hdiutil create -volname "GitPeek" \
    -srcfolder GitPeek.app \
    -ov -format UDZO \
    GitPeek-1.3.2.dmg
```

## CI/CD

### GitHub Actions
See `.github/workflows/` for automated builds

### Local Testing
```bash
make ci  # Run CI checks locally
```

## Clean Build

### Remove All Build Artifacts
```bash
make reset
```

Or manually:
```bash
rm -rf .build
rm -rf GitPeek.app
rm -rf ~/Library/Developer/Xcode/DerivedData/gitpeek-*
```

## Dependencies

### Build Requirements
- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

### Runtime Requirements
- macOS 13.0+
- Git (for repository operations)

## Performance

### Build Times (M1 Mac)
- First build: ~30-60s
- Incremental: ~5-10s
- Clean build: ~30s

### Binary Size
- Universal binary: ~1.5 MB
- With Sparkle: ~3 MB total
- DMG: ~1.5 MB (compressed)

## Advanced

### Custom Build Flags
```bash
swift build -c release \
    -Xswiftc -O \
    -Xswiftc -whole-module-optimization
```

### Profiling Build
```bash
swift build -c release --verbose
```

### Check Architecture
```bash
lipo -info GitPeek.app/Contents/MacOS/GitPeek
```

Expected output:
```
Architectures in the fat file: GitPeek are: x86_64 arm64
```

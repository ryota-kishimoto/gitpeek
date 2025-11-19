# macOS 26 Compatibility Guide

## Overview

GitPeek v1.3.2+ includes full support for macOS 26 (Sequoia) with improved visual appearance and compatibility.

## Changes Made

### 1. Text Visibility Fixes

**Problem**: White text on white background in macOS 26
- SwiftUI's `Color.primary` and `Color.secondary` had unexpected behavior in macOS 26
- Text was rendering with insufficient contrast

**Solution**: Use explicit NSColor system colors
```swift
// Before
static let primaryText = Color.primary
static let secondaryText = Color.secondary

// After
static let primaryText = Color(nsColor: .labelColor)
static let secondaryText = Color(nsColor: .secondaryLabelColor)
```

### 2. Adaptive Color System

All colors now use macOS system colors for better compatibility:

| Purpose | NSColor Used | Description |
|---------|--------------|-------------|
| Primary Background | `.controlBackgroundColor` | Adaptive background |
| Text (Primary) | `.labelColor` | High contrast text |
| Text (Secondary) | `.secondaryLabelColor` | Secondary text |
| Hover State | `.selectedControlColor` | Interactive elements |
| Dividers | `.separatorColor` | Borders and dividers |

### 3. Liquid Glass (Vibrancy) Effect

**Implementation**: Custom `VisualEffectView` wrapper
- File: `GitPeek/Utils/VisualEffectView.swift`
- Material: `.menu` for optimal visibility
- Blending Mode: `.behindWindow`

**Usage**:
```swift
.background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
```

**Available Materials**:
- `.menu` - Recommended for popovers (current)
- `.popover` - Alternative for popovers
- `.hudWindow` - More transparent
- `.sidebar` - For sidebar-style UI

## Building for macOS 26

### Standard Build
```bash
./build.sh
```

This generates `GitPeek.app` with:
- ✅ Sparkle.framework bundled
- ✅ Correct rpath configuration
- ✅ Version 1.3.2
- ✅ Universal binary (arm64 + x86_64)

### Xcode Build
```bash
xcodebuild -scheme GitPeek -configuration Release -destination 'platform=macOS' build
```

### Installation
```bash
cp -r GitPeek.app /Applications/
```

## Testing Checklist

- [ ] Text is clearly visible in light mode
- [ ] Text is clearly visible in dark mode (if supported)
- [ ] Vibrancy effect shows background blur
- [ ] All UI elements have proper contrast
- [ ] Version displays correctly (v1.3.2)
- [ ] App launches without dyld errors

## Troubleshooting

### Issue: "Library not loaded: Sparkle.framework"

**Cause**: Missing or incorrect rpath

**Solution**:
```bash
install_name_tool -add_rpath "@executable_path/../Frameworks" GitPeek.app/Contents/MacOS/GitPeek
```

Or rebuild with updated `build.sh` which includes this fix.

### Issue: White text on white background

**Cause**: Old version without macOS 26 fixes

**Solution**: Update to v1.3.2+ or rebuild from source with latest changes.

### Issue: No vibrancy effect visible

**Check**:
1. Background wallpaper has contrast
2. Reduced transparency is disabled in System Settings
3. Material type is appropriate (`.menu` recommended)

## Version History

### v1.3.2+
- ✅ macOS 26 compatibility
- ✅ Liquid glass vibrancy effect
- ✅ Adaptive system colors
- ✅ Improved text contrast

### v1.3.2 (Original)
- ❌ White text issues on macOS 26
- ❌ No vibrancy effect
- ✅ Sparkle auto-update support

## References

- [NSVisualEffectView Documentation](https://developer.apple.com/documentation/appkit/nsvisualeffectview)
- [NSColor System Colors](https://developer.apple.com/documentation/appkit/nscolor/ui_element_colors)
- [Human Interface Guidelines - macOS](https://developer.apple.com/design/human-interface-guidelines/macos)

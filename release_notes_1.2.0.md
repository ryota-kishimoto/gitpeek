# GitPeek v1.2.0

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

1. Download `GitPeek-1.2.0.dmg`
2. Open the DMG file
3. Drag GitPeek to your Applications folder
4. Launch GitPeek from Applications
5. The GitPeek icon will appear in your menu bar

### 🔧 Requirements

- macOS 13.0 (Ventura) or later
- Git installed on your system

### 📝 Full Changelog

#### Added
- Git worktree detection and display
- Version number in UI
- Standalone build script without Xcode
- NSOpenPanel for reliable folder selection

#### Changed
- Simplified theme to single light mode
- Improved color scheme for better visibility
- Updated status colors (Clean→mint, Staged→blue)
- Enhanced popover behavior

#### Fixed
- Repository data persistence
- External app launching (Terminal, Cursor)
- File dialog stability
- Outside click dismissal
- App startup issues

#### Removed
- Dark mode implementation (non-functional)
- Complex theme management system
- Unnecessary Combine dependencies

### 🙏 Acknowledgments

Thanks to all users for their feedback and patience while we improved GitPeek!

---

**Full Changelog**: https://github.com/ryota-kishimoto/gitpeek/compare/v1.0.0...v1.2.0
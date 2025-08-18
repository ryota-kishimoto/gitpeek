# Changelog

All notable changes to GitPeek will be documented in this file.

## [1.2.0] - 2025-01-18

### Added
- Git worktree detection and display with visual indicators
- Version number display in menu header
- Standalone build script for building without Xcode
- NSOpenPanel for reliable folder selection
- Improved error messages and handling

### Changed
- Simplified theme system to single light mode for better stability
- Updated color scheme for improved visibility:
  - Clean status: mint (previously green)
  - Staged files: blue
  - Single file modifications: gray
- Enhanced popover behavior with proper dismissal on outside clicks
- Improved Terminal integration with better AppleScript handling
- Updated all GitHub repository URLs to use generic organization name

### Fixed
- Repository data persistence issues when adding worktrees
- External app launching (Terminal, Cursor)
- File dialog crashes when selecting Desktop folder
- Popover dismissal when clicking outside
- App startup crashes related to theme system
- Cursor editor integration to open in new window

### Removed
- Dark mode theme system (non-functional)
- Complex theme management code
- Unnecessary Combine dependencies

## [1.0.8] - 2025-01-18

### Changed
- Adjusted UI colors to white background for better readability
- Updated status colors for improved visibility

## [1.0.7] - 2025-01-18

### Fixed
- File dialog crashes when selecting Desktop folder
- Replaced SwiftUI fileImporter with NSOpenPanel

## [1.0.6] - 2025-01-18

### Fixed
- Popover dismissal before showing file dialog

## [1.0.5] - 2025-01-18

### Added
- Git worktree support

### Fixed
- Repository data persistence issues

## [1.0.4] - 2025-01-18

### Fixed
- Menu bar popover dismissal on outside clicks
- Color adjustments for better visibility

## [1.0.3] - 2025-01-18

### Fixed
- Terminal app integration
- Cursor editor integration

## [1.0.2] - 2025-01-18

### Fixed
- App launch issues
- Auto-refresh functionality

## [1.0.1] - 2025-01-18

### Added
- Version display in UI
- Improved status indicators

## [1.0.0] - 2025-01-18

### Initial Release
- Multiple repository management
- Real-time status updates
- Branch information display
- Quick actions (Cursor, Terminal, GitHub, SourceTree)
- Settings screen
- Auto-refresh functionality (30-second intervals)
- Native macOS menu bar integration
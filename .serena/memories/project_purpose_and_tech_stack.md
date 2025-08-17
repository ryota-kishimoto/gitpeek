# GitPeek Project Overview

## Project Purpose
GitPeek is a lightweight macOS menu bar application for managing multiple Git repositories. It provides:
- Real-time status monitoring of Git repositories
- Quick actions to open repositories in external tools (Cursor, SourceTree, Terminal)
- Native macOS experience with SwiftUI
- Automatic refresh every 30 seconds

## Tech Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Minimum OS**: macOS 13.0 (Ventura)
- **Dependency Management**: Swift Package Manager
- **Development Methodology**: Test-Driven Development (TDD)

## Key Features
- Multiple repository management
- Branch information display
- Change preview (modified files and counts)
- External tool integration (Cursor, SourceTree, GitHub/GitLab)
- Dark mode support
- Native macOS menu bar integration

## Project Structure
```
GitPeek/
├── App/                 # Application entry point
├── Views/              # SwiftUI views
├── ViewModels/         # Business logic
├── Models/             # Data models
├── Utils/              # Utilities
└── Resources/          # Resource files
```
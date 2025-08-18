# GitPeek 🔍

<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="GitPeek Icon">
</p>

<p align="center">
  A lightweight menu bar Git repository manager for macOS
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2013.0+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</p>

## 📸 Screenshots

<p align="center">
  <img src="assets/screenshot-main.png" width="400" alt="Main View">
  <img src="assets/screenshot-menu.png" width="400" alt="Context Menu">
</p>

## ✨ Features

- 📊 **Multiple Repository Management** - Monitor all your Git repositories from one place
- 🔄 **Real-time Status Updates** - Automatic refresh every 30 seconds
- 🌿 **Branch Information** - Current branch name at a glance
- 📝 **Change Preview** - See modified files and change counts
- 🚀 **Quick Actions** - Open in your favorite tools with one click
  - Cursor
  - SourceTree
  - Terminal
  - GitHub/GitLab/Bitbucket
- 🎨 **Native macOS Experience** - Built with SwiftUI for seamless integration
- 🌙 **Dark Mode Support** - Automatically adapts to your system theme

## 📋 Requirements

- macOS 13.0 (Ventura) or later
- Git installed on your system

## 📦 Installation

### Homebrew (Recommended)

```bash
brew install --cask gitpeek
```

### Direct Download

1. Download the latest release from [Releases](https://github.com/gitpeek/gitpeek/releases)
2. Open the DMG file
3. Drag GitPeek to your Applications folder
4. Launch GitPeek from Applications

### Build from Source

```bash
# Clone the repository
git clone https://github.com/gitpeek/gitpeek.git
cd gitpeek

# Open in Xcode
open GitPeek.xcodeproj

# Build and run (⌘+R)
```

## 🚀 Usage

### Getting Started

1. **Launch GitPeek** - The icon will appear in your menu bar
2. **Add Repositories** - Click the GitPeek icon and select "Add Repository"
3. **Monitor Changes** - See real-time status of all your repositories
4. **Take Actions** - Right-click on any repository for quick actions

### Keyboard Shortcuts

- `⌘+R` - Refresh all repositories
- `⌘+,` - Open preferences
- `⌘+Q` - Quit GitPeek

### Features in Detail

#### Repository Management
- Add unlimited Git repositories
- Remove repositories you no longer need
- Repositories are saved between sessions

#### Status Display
- Current branch name
- Number of modified files
- Staged vs unstaged changes
- Visual indicators for repository state

#### Quick Actions
- **Open in Cursor** - Launch Cursor IDE with the repository
- **Open in SourceTree** - View in SourceTree Git client
- **Open in Terminal** - Start a terminal session in the repository
- **Open on GitHub** - View the repository in your browser
- **Copy Branch Name** - Copy current branch to clipboard

## ⚙️ Configuration

GitPeek stores its configuration in:
```
~/Library/Application Support/GitPeek/
```

### Settings

- **Update Interval** - How often to check for changes (10s - 5min)
- **Show Badge** - Display change count badge
- **Default Editor** - Choose your preferred code editor
- **Default Terminal** - Select Terminal.app or iTerm2

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

```bash
# Install SwiftLint
brew install swiftlint

# Run tests
xcodebuild test -scheme GitPeek -destination 'platform=macOS'

# Run linter
swiftlint
```

## 🐛 Known Issues

- Large repositories (1000+ files) may experience slower refresh rates
- Some Git submodules might not be detected properly

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Inspired by the developer community's need for quick Git status monitoring

## 📮 Support

- **Bug Reports**: [GitHub Issues](https://github.com/gitpeek/gitpeek/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/gitpeek/gitpeek/discussions)
- **Security Issues**: Please email security@gitpeek.app

## 🗺️ Roadmap

- [ ] Pull request status integration
- [ ] Simple commit functionality
- [ ] Branch search and switching
- [ ] Custom action configuration
- [ ] Team settings sync
- [ ] Multiple remote support
- [ ] Conflict detection and resolution helpers

---

<p align="center">
  Made with ❤️ for the macOS developer community
</p>
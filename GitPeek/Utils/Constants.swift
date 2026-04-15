import Foundation

/// Single source of truth for shared constants across the app.
internal enum AppConstants {

    internal enum Defaults {
        static let refreshInterval: Double = 30.0
        static let gitCommandTimeout: Double = 30.0
        static let gitFetchTimeout: Double = 30.0
        static let gitPullTimeout: Double = 60.0
        static let gitMonitorFallbackInterval: Double = 10.0
        static let showNotifications = false
        static let debugLogging = false
        static let terminal = Terminal.terminal
        static let editor = Editor.cursor
    }

    internal enum UserDefaultsKey {
        static let refreshInterval = "refreshInterval"
        static let showNotifications = "showNotifications"
        static let defaultTerminal = "defaultTerminal"
        static let defaultEditor = "defaultEditor"
        static let gitCommandTimeout = "gitCommandTimeout"
        static let debugLogging = "debugLogging"
    }

    internal enum Terminal {
        static let terminal = "Terminal"
        static let iterm2 = "iTerm2"
        static let warp = "Warp"
        static let hyper = "Hyper"
    }

    internal enum Editor {
        static let cursor = "Cursor"
        static let vscode = "VSCode"
        static let sublime = "Sublime"
        static let xcode = "Xcode"
        static let nova = "Nova"
    }

    internal enum URLScheme {
        static let vscodeFile = "vscode://file/"
        static let sublime = "subl://"
        static let nova = "nova://"

        static func warpNewTab(path: String) -> String { "warp://action/new_tab?path=\(path)" }
        static func hyperCD(path: String) -> String { "hyper://cd?path=\(path)" }
    }

    internal enum ExternalAppPath {
        static let xcode = "/Applications/Xcode.app"
        static let sourceTree = "/Applications/SourceTree.app"
        static let bash = "/bin/bash"
        static let open = "/usr/bin/open"
        static let cursorCLICandidates: [String] = [
            "/usr/local/bin/cursor",
            "\(NSHomeDirectory())/bin/cursor",
            "/opt/homebrew/bin/cursor"
        ]
    }

    internal enum Persistence {
        static let appSupportDirectoryName = "GitPeek"
        static let repositoriesFileName = "repositories.json"
        static let repositoriesKey = "com.gitpeek.repositories"

        static var repositoriesFileURL: URL {
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(appSupportDirectoryName)
                .appendingPathComponent(repositoriesFileName)
        }
    }

    internal enum GitHub {
        static let repositoryURL = "https://github.com/ryota-kishimoto/gitpeek"
        static let issuesURL = "\(repositoryURL)/issues"
        static let licenseURL = "\(repositoryURL)/blob/main/LICENSE"
    }

    internal enum Layout {
        static let refreshIntervalRange: ClosedRange<Double> = 10...300
        static let refreshIntervalStep: Double = 10
        static let settingsWindowWidth: CGFloat = 500
        static let settingsWindowHeight: CGFloat = 450
        static let aboutWindowWidth: CGFloat = 350
        static let aboutWindowHeight: CGFloat = 450
        static let versionFallback = "1.0.0"
        static let copyrightText = "© 2025 GitPeek. All rights reserved."
    }
}

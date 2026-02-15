import SwiftUI
import Combine

@MainActor
final class MenuBarViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isShowingPopover = false
    @Published var repositories: [Repository] = []
    @Published var isRefreshing = false
    @Published var selectedRepository: Repository?
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let repositoryStore = RepositoryStore()
    private let gitMonitor: GitMonitor

    // MARK: - Computed Properties

    var statusBarTitle: String {
        if repositories.isEmpty {
            return "GitPeek"
        } else {
            return "GitPeek (\(repositories.count))"
        }
    }

    var statusBarImage: String {
        if repositories.contains(where: { $0.gitStatus?.hasChanges == true }) {
            return "folder.badge.gear" // Has changes
        } else {
            return "folder" // Clean
        }
    }

    // MARK: - Initialization

    init() {
        gitMonitor = GitMonitor(repositoryStore: repositoryStore)

        // Clear any existing repositories in test environment
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            repositoryStore.clearAll()
        }
        #endif
        loadRepositories()
        gitMonitor.start()
    }

    deinit {
        // GitMonitor will clean up in its own deinit
    }

    // MARK: - Public Methods

    func togglePopover() {
        isShowingPopover.toggle()
        // Auto-refresh when opening the popover (immediate, not delayed)
        if isShowingPopover {
            Task { @MainActor in
                await refreshAll()
            }
        }
    }

    func addRepository(path: String) async throws {
        do {
            try await repositoryStore.add(path)
            loadRepositories()
            // Refresh only the newly added repository
            if let newRepo = repositories.first(where: { $0.path == path }) {
                await refreshRepository(newRepo)
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func selectRepositoryFolder(onComplete: (() -> Void)? = nil) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Git Repository"
        openPanel.message = "Choose a Git repository folder to add to GitPeek"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = true
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false

        // Bring dialog to front
        openPanel.level = .modalPanel
        NSApp.activate(ignoringOtherApps: true)

        // Use runModal for immediate display
        let response = openPanel.runModal()
        if response == .OK, let url = openPanel.url {
            Task { @MainActor in
                do {
                    try await self.addRepository(path: url.path)
                    // Notify completion
                    onComplete?()
                } catch {
                    self.errorMessage = error.localizedDescription
                    // Still call onComplete even on error
                    onComplete?()
                }
            }
        } else {
            // User cancelled - still call onComplete
            onComplete?()
        }
    }

    func removeRepository(_ repository: Repository) {
        repositoryStore.remove(repository.id)
        loadRepositories()

        if selectedRepository?.id == repository.id {
            selectedRepository = nil
        }
    }

    func selectRepository(_ repository: Repository) {
        selectedRepository = repository
    }

    func refreshAll() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        await gitMonitor.forceUpdate()
        loadRepositories()
    }

    func refreshRepository(_ repository: Repository) async {
        await gitMonitor.updateRepository(repository)
        loadRepositories()
    }

    func openInFinder(repository: Repository) {
        let url = URL(fileURLWithPath: repository.path)
        NSWorkspace.shared.open(url)
    }

    func openInTerminal(repository: Repository) {
        let terminal = UserDefaults.standard.string(forKey: "defaultTerminal") ?? "Terminal"
        Logger.debug("Opening in \(terminal): \(repository.path)")

        let script: String
        switch terminal {
        case "iTerm2":
            script = """
                tell application "iTerm"
                    activate
                    create window with default profile
                    tell current session of current window
                        write text "cd '\(repository.path)'"
                    end tell
                end tell
            """
        case "Warp":
            // Warp doesn't have AppleScript support, use URL scheme
            let escapedPath = repository.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? repository.path
            if let url = URL(string: "warp://action/new_tab?path=\(escapedPath)") {
                NSWorkspace.shared.open(url)
            }
            return
        case "Hyper":
            // Hyper doesn't have good AppleScript support
            let escapedPath = repository.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? repository.path
            if let url = URL(string: "hyper://cd?path=\(escapedPath)") {
                NSWorkspace.shared.open(url)
            }
            return
        default: // Terminal
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            task.arguments = ["-a", "Terminal", repository.path]

            do {
                try task.run()
                task.waitUntilExit()

                // Now send the cd command using AppleScript
                let repositoryPath = repository.path
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let cdScript = """
                        tell application "Terminal"
                            if (count of windows) > 0 then
                                do script "cd '\(repositoryPath.replacingOccurrences(of: "'", with: "'\\''"))'" in window 1
                            end if
                        end tell
                    """

                    if let scriptObject = NSAppleScript(source: cdScript) {
                        var error: NSDictionary?
                        scriptObject.executeAndReturnError(&error)
                        if let error = error {
                            Logger.error("Error sending cd command: \(error)")
                        }
                    }
                }
                Logger.debug("Opened Terminal for: \(repository.path)")
            } catch {
                Logger.error("Failed to open Terminal: \(error)")
                errorMessage = "Failed to open Terminal: \(error.localizedDescription)"
            }
            return
        }

        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)

            if let error = error {
                Logger.error("Error opening \(terminal): \(error)")
                errorMessage = "Failed to open Terminal"
            }
        }
    }

    func openInCursor(repository: Repository) {
        let editor = UserDefaults.standard.string(forKey: "defaultEditor") ?? "Cursor"
        Logger.debug("Opening in \(editor): \(repository.path)")
        let escapedPath = repository.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? repository.path

        let urlString: String
        switch editor {
        case "VSCode":
            urlString = "vscode://file/\(escapedPath)"
        case "Sublime":
            urlString = "subl://\(escapedPath)"
        case "Xcode":
            // Open with Xcode using NSWorkspace
            let url = URL(fileURLWithPath: repository.path)
            NSWorkspace.shared.open(
                [url],
                withApplicationAt: URL(fileURLWithPath: "/Applications/Xcode.app"),
                configuration: NSWorkspace.OpenConfiguration()
            )
            return
        case "Nova":
            urlString = "nova://\(escapedPath)"
        default: // Cursor
            // First check if cursor CLI is available
            let cursorPaths = [
                "/usr/local/bin/cursor",
                "\(NSHomeDirectory())/bin/cursor",
                "/opt/homebrew/bin/cursor"
            ]

            var cursorCLI: String?
            for path in cursorPaths {
                if FileManager.default.fileExists(atPath: path) {
                    cursorCLI = path
                    break
                }
            }

            if let cursorPath = cursorCLI {
                // Use cursor CLI with -n flag to force new window
                let task = Process()
                task.executableURL = URL(fileURLWithPath: cursorPath)
                task.arguments = ["-n", repository.path]

                do {
                    try task.run()
                    task.waitUntilExit()
                    Logger.debug("Opened in new Cursor window via CLI: \(repository.path)")
                    return
                } catch {
                    Logger.debug("Failed to use cursor CLI, trying fallback: \(error)")
                }
            }

            // Fallback: Use open command with -n flag to force new instance
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            task.arguments = ["-n", "-a", "Cursor", repository.path]

            do {
                try task.run()
                task.waitUntilExit()
                Logger.debug("Opened in new Cursor instance: \(repository.path)")
            } catch {
                Logger.error("Failed to open Cursor: \(error)")
                errorMessage = "Failed to open in Cursor"
            }
            return
        }

        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        } else {
            Logger.error("Failed to create URL: \(urlString)")
            errorMessage = "Failed to open in \(editor)"
        }
    }

    func pullRepository(_ repository: Repository) async {
        do {
            let result = try await repositoryStore.pullRepository(repository.id)
            Logger.debug("Pull result for \(repository.name): \(result)")

            // Refresh only this repository
            await refreshRepository(repository)
        } catch {
            Logger.error("Failed to pull \(repository.name): \(error)")
            errorMessage = "Failed to pull: \(error.localizedDescription)"
        }
    }

    func openInSourceTree(repository: Repository) {
        let url = URL(fileURLWithPath: repository.path)
        let sourceTreeURL = URL(fileURLWithPath: "/Applications/SourceTree.app")

        if FileManager.default.fileExists(atPath: sourceTreeURL.path) {
            NSWorkspace.shared.open(
                [url],
                withApplicationAt: sourceTreeURL,
                configuration: NSWorkspace.OpenConfiguration()
            )
        } else {
            errorMessage = "SourceTree is not installed"
        }
    }

    func openOnGitHub(repository: Repository) {
        guard let remoteURL = repository.remoteURL else {
            errorMessage = "No remote URL configured"
            return
        }

        // Convert SSH to HTTPS
        let httpsURL: String
        if remoteURL.hasPrefix("git@github.com:") {
            httpsURL = remoteURL
                .replacingOccurrences(of: "git@github.com:", with: "https://github.com/")
                .replacingOccurrences(of: ".git", with: "")
        } else if remoteURL.hasPrefix("https://") {
            httpsURL = remoteURL.replacingOccurrences(of: ".git", with: "")
        } else {
            httpsURL = remoteURL
        }

        if let url = URL(string: httpsURL) {
            NSWorkspace.shared.open(url)
        }
    }

    func copyBranchName(repository: Repository) {
        guard let branch = repository.currentBranch else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(branch, forType: .string)
    }

    // MARK: - Private Methods

    private func loadRepositories() {
        repositories = repositoryStore.repositories
    }
}

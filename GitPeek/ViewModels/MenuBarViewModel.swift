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
    }
    
    func addRepository(path: String) async throws {
        do {
            try await repositoryStore.add(path)
            loadRepositories()
        } catch {
            errorMessage = error.localizedDescription
            throw error
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
        isRefreshing = true
        await gitMonitor.forceUpdate()
        loadRepositories()
        isRefreshing = false
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
            script = """
                tell application "Terminal"
                    activate
                    do script "cd '\(repository.path)'"
                end tell
            """
        }
        
        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            
            if let error = error {
                print("Error opening \(terminal): \(error)")
            }
        }
    }
    
    func openInCursor(repository: Repository) {
        let editor = UserDefaults.standard.string(forKey: "defaultEditor") ?? "Cursor"
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
            urlString = "cursor://open?path=\(escapedPath)"
        }
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
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
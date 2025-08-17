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
    private var refreshTimer: Timer?
    private let refreshInterval: TimeInterval = 30.0
    
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
        // Clear any existing repositories in test environment
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            repositoryStore.clearAll()
        }
        #endif
        loadRepositories()
        startAutoRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
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
        await repositoryStore.updateAll()
        loadRepositories()
        isRefreshing = false
    }
    
    func refreshRepository(_ repository: Repository) async {
        await repositoryStore.updateRepository(repository.id)
        loadRepositories()
    }
    
    func openInFinder(repository: Repository) {
        let url = URL(fileURLWithPath: repository.path)
        NSWorkspace.shared.open(url)
    }
    
    func openInTerminal(repository: Repository) {
        let script = """
            tell application "Terminal"
                activate
                do script "cd '\(repository.path)'"
            end tell
        """
        
        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            
            if let error = error {
                print("Error opening Terminal: \(error)")
            }
        }
    }
    
    func openInCursor(repository: Repository) {
        let escapedPath = repository.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? repository.path
        if let url = URL(string: "cursor://open?path=\(escapedPath)") {
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
    
    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task { @MainActor in
                await self.refreshAll()
            }
        }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
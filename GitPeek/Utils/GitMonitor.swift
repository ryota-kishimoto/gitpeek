import Foundation
import Combine

/// Monitors Git repositories for changes
@MainActor
final class GitMonitor: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var isMonitoring = false
    @Published private(set) var lastUpdateTime: Date?
    
    private var timer: Timer?
    private let updateInterval: TimeInterval
    private let gitCommand = GitCommand()
    private weak var repositoryStore: RepositoryStore?
    
    // MARK: - Initialization
    
    init(repositoryStore: RepositoryStore, updateInterval: TimeInterval? = nil) {
        self.repositoryStore = repositoryStore
        // Use the stored preference or default to 10 seconds for more real-time updates
        let interval = updateInterval ?? UserDefaults.standard.double(forKey: "refreshInterval")
        self.updateInterval = interval > 0 ? interval : 10.0
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring repositories
    func start() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        print("[GitMonitor] Starting with interval: \(updateInterval) seconds")
        
        // Initial update
        Task {
            await updateAllRepositories()
        }
        
        // Schedule periodic updates
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            print("[GitMonitor] Timer fired - updating repositories")
            Task { @MainActor in
                await self.updateAllRepositories()
            }
        }
    }
    
    /// Stops monitoring repositories
    func stop() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }
    
    /// Forces an immediate update of all repositories
    func forceUpdate() async {
        await updateAllRepositories()
    }
    
    /// Updates a specific repository
    func updateRepository(_ repository: Repository) async {
        guard let store = repositoryStore else { return }
        
        // Update only this specific repository through the store
        await store.updateRepository(repository.id)
    }
    
    // MARK: - Private Methods
    
    private func updateAllRepositories() async {
        guard let store = repositoryStore else { return }
        
        print("[GitMonitor] Updating all repositories...")
        // Update all repositories directly via store
        await store.updateAllRepositories()
        
        lastUpdateTime = Date()
        store.save()
        if let time = lastUpdateTime {
            print("[GitMonitor] Update complete at \(time)")
        }
    }
}

// MARK: - File System Watcher (Future Enhancement)

extension GitMonitor {
    /// Sets up file system watching for a repository (future enhancement)
    /// This would use FSEvents or similar to detect changes immediately
    func watchRepository(_ repository: Repository) {
        // TODO: Implement file system watching for real-time updates
        // This would use FSEvents API to monitor the repository directory
        // and trigger updates when files change
    }
}
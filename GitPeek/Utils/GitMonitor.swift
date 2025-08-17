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
    
    init(repositoryStore: RepositoryStore, updateInterval: TimeInterval = 30.0) {
        self.repositoryStore = repositoryStore
        self.updateInterval = updateInterval
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring repositories
    func start() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        
        // Initial update
        Task {
            await updateAllRepositories()
        }
        
        // Schedule periodic updates
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
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
        
        // Update the repository through the store
        await store.updateRepository(repository.id)
    }
    
    // MARK: - Private Methods
    
    private func updateAllRepositories() async {
        guard let store = repositoryStore else { return }
        
        // Update all repositories in parallel
        await withTaskGroup(of: Void.self) { group in
            for repository in store.repositories {
                group.addTask {
                    await self.updateRepository(repository)
                }
            }
        }
        
        lastUpdateTime = Date()
        store.save()
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
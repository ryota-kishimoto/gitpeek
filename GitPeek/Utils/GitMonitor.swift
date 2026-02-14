import Foundation
import Combine
import UserNotifications

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
    private var previousStatuses: [UUID: GitStatus] = [:]

    // MARK: - Initialization

    init(repositoryStore: RepositoryStore, updateInterval: TimeInterval? = nil) {
        self.repositoryStore = repositoryStore
        // Use the stored preference or default to 10 seconds for more real-time updates
        let interval = updateInterval ?? UserDefaults.standard.double(forKey: "refreshInterval")
        self.updateInterval = interval > 0 ? interval : 10.0

        requestNotificationPermission()
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
    
    /// Forces an immediate update of all repositories (with fetch)
    func forceUpdate() async {
        await updateAllRepositories(shouldFetch: true)
    }

    /// Updates a specific repository
    func updateRepository(_ repository: Repository, shouldFetch: Bool = false) async {
        guard let store = repositoryStore else { return }

        // Update only this specific repository through the store
        await store.updateRepository(repository.id, shouldFetch: shouldFetch)
    }
    
    // MARK: - Private Methods

    private func updateAllRepositories(shouldFetch: Bool = false) async {
        guard let store = repositoryStore else { return }

        // Capture previous statuses before update
        let oldStatuses = Dictionary(uniqueKeysWithValues: store.repositories.compactMap { repo -> (UUID, GitStatus)? in
            guard let status = repo.gitStatus else { return nil }
            return (repo.id, status)
        })

        print("[GitMonitor] Updating all repositories (fetch: \(shouldFetch))...")
        await store.updateAllRepositories(shouldFetch: shouldFetch)

        // Check for changes and send notifications
        let showNotifications = UserDefaults.standard.bool(forKey: "showNotifications")
        if showNotifications {
            for repo in store.repositories {
                guard let newStatus = repo.gitStatus else { continue }
                let oldStatus = oldStatuses[repo.id]
                checkAndNotify(repository: repo, oldStatus: oldStatus, newStatus: newStatus)
            }
        }

        lastUpdateTime = Date()
        store.save()
        if let time = lastUpdateTime {
            print("[GitMonitor] Update complete at \(time)")
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("[GitMonitor] Notification permission error: \(error)")
            }
        }
    }

    private func checkAndNotify(repository: Repository, oldStatus: GitStatus?, newStatus: GitStatus) {
        // Skip if this is the first check (no previous status)
        guard let oldStatus = oldStatus else { return }

        // Only notify if changes increased (new changes appeared)
        let oldTotal = oldStatus.totalChangedFiles
        let newTotal = newStatus.totalChangedFiles

        if newTotal > oldTotal {
            let diff = newTotal - oldTotal
            sendNotification(
                title: repository.name,
                body: "\(diff) new change\(diff == 1 ? "" : "s") detected (\(newStatus.description))"
            )
        } else if oldStatus.isClean && !newStatus.isClean {
            sendNotification(
                title: repository.name,
                body: "New changes detected (\(newStatus.description))"
            )
        }
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "GitPeek: \(title)"
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[GitMonitor] Failed to send notification: \(error)")
            }
        }
    }
}

// MARK: - File System Watcher (Future Enhancement)

extension GitMonitor {
    /// Sets up file system watching for a repository
    /// Uses FSEvents API to detect changes immediately instead of polling
    func watchRepository(_ repository: Repository) {
        // Future: Use DispatchSource.makeFileSystemObjectSource or FSEventStream
        // to monitor the repository directory and trigger updates on file changes.
        // Current approach uses timer-based polling which is sufficient for most use cases.
    }
}
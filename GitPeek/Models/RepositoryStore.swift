import Foundation
import Combine

/// Manages the collection of repositories
@MainActor
final class RepositoryStore: ObservableObject {
    @Published private(set) var repositories: [Repository] = []
    
    private let gitCommand = GitCommand()
    private let persistenceKey = "com.gitpeek.repositories"
    private let fileManager = FileManager.default
    
    private var saveURL: URL {
        fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GitPeek")
            .appendingPathComponent("repositories.json")
    }
    
    init() {
        load()
    }
    
    // MARK: - Public Methods
    
    /// Adds a new repository
    /// - Parameter path: Path to the Git repository
    /// - Throws: RepositoryError if validation fails
    func add(_ path: String) async throws {
        // Check if already exists
        if repositories.contains(where: { $0.path == path }) {
            throw RepositoryError.alreadyExists
        }

        // Validate it's a Git repository
        guard GitCommand.isValidRepository(at: path) else {
            throw RepositoryError.notAGitRepository
        }

        // Create and add repository immediately (fast)
        let repository = Repository(path: path)
        repositories.append(repository)
        save()

        // Fetch status asynchronously in background (don't wait)
        Task {
            await self.updateRepository(repository.id)
        }
    }
    
    /// Removes a repository
    /// - Parameter id: Repository ID to remove
    func remove(_ id: UUID) {
        repositories.removeAll { $0.id == id }
        save()
    }
    
    /// Updates the status of a repository
    /// - Parameter id: Repository ID to update
    /// - Parameter shouldFetch: Whether to fetch from remote (default: false for speed)
    func updateRepository(_ id: UUID, shouldFetch: Bool = false) async {
        guard let repository = repositories.first(where: { $0.id == id }) else { return }
        let path = repository.path

        do {
            // Run fast local git commands in parallel
            async let status = gitCommand.getStatus(at: path)
            async let branch = gitCommand.getCurrentBranch(at: path)
            async let remoteURL = gitCommand.getRemoteURL(at: path)
            async let worktrees = gitCommand.getWorktrees(at: path)
            async let commitDiff = gitCommand.getCommitDifference(at: path)

            // Wait for all results
            let (statusResult, branchResult, remoteURLResult, worktreesResult, commitDiffResult) =
                try await (status, branch, remoteURL, worktrees, commitDiff)

            if let index = repositories.firstIndex(where: { $0.id == id }) {
                var updated = repositories[index]
                updated.updateStatus(statusResult, branch: branchResult)
                updated.updateRemoteURL(remoteURLResult)
                updated.updateWorktrees(worktreesResult)
                updated.updateCommitDifference(behind: commitDiffResult.behind, ahead: commitDiffResult.ahead)
                repositories[index] = updated
            }

            // Optionally fetch in background (slow, but updates remote info)
            if shouldFetch {
                Task { @MainActor in
                    try? await gitCommand.fetch(at: path)
                    // Re-check commit difference after fetch
                    if let newCommitDiff = try? await gitCommand.getCommitDifference(at: path) {
                        self.applyCommitDifference(
                            id: id,
                            behind: newCommitDiff.behind,
                            ahead: newCommitDiff.ahead
                        )
                    }
                }
            }
        } catch {
            Logger.error("Failed to update repository \(repository.name): \(error)")
        }
    }
    
    /// Updates all repositories
    func updateAll(shouldFetch: Bool = false) async {
        await withTaskGroup(of: Void.self) { group in
            for repository in repositories {
                group.addTask {
                    await self.updateRepository(repository.id, shouldFetch: shouldFetch)
                }
            }
        }
    }

    /// Updates all repositories (alias for GitMonitor compatibility)
    func updateAllRepositories(shouldFetch: Bool = false) async {
        await updateAll(shouldFetch: shouldFetch)
    }
    
    /// Pulls changes for a repository
    /// - Parameter id: Repository ID to pull
    /// - Returns: Pull result message
    func pullRepository(_ id: UUID) async throws -> String {
        guard let index = repositories.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }

        let path = repositories[index].path

        // Set pulling state
        setPulling(id: id, value: true)

        do {
            let result = try await gitCommand.pull(at: path)
            await updateRepository(id)
            setPulling(id: id, value: false)
            return result
        } catch {
            setPulling(id: id, value: false)
            throw error
        }
    }

    private func setPulling(id: UUID, value: Bool) {
        guard let index = repositories.firstIndex(where: { $0.id == id }) else { return }
        var updated = repositories[index]
        updated.isPulling = value
        repositories[index] = updated
    }

    private func applyCommitDifference(id: UUID, behind: Int, ahead: Int) {
        guard let index = repositories.firstIndex(where: { $0.id == id }) else { return }
        var updated = repositories[index]
        updated.updateCommitDifference(behind: behind, ahead: ahead)
        repositories[index] = updated
    }
    
    /// Clears all repositories
    func clearAll() {
        repositories.removeAll()
        save()
    }
    
    // MARK: - Persistence
    
    /// Saves repositories to disk
    func save() {
        do {
            // Create directory if needed
            let directory = saveURL.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            // Encode and save
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(repositories)
            try data.write(to: saveURL)
        } catch {
            Logger.error("Failed to save repositories: \(error)")
        }
    }
    
    /// Loads repositories from disk
    func load() {
        guard fileManager.fileExists(atPath: saveURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: saveURL)
            let decoder = JSONDecoder()
            repositories = try decoder.decode([Repository].self, from: data)
        } catch {
            Logger.error("Failed to load repositories: \(error)")
        }
    }
}
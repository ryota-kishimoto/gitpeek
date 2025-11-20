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
        guard let index = repositories.firstIndex(where: { $0.id == id }) else { return }

        let repository = repositories[index]

        do {
            // Run fast local git commands in parallel
            async let status = gitCommand.getStatus(at: repository.path)
            async let branch = gitCommand.getCurrentBranch(at: repository.path)
            async let remoteURL = gitCommand.getRemoteURL(at: repository.path)
            async let worktrees = gitCommand.getWorktrees(at: repository.path)
            async let commitDiff = gitCommand.getCommitDifference(at: repository.path)

            // Wait for all results
            let (statusResult, branchResult, remoteURLResult, worktreesResult, commitDiffResult) =
                try await (status, branch, remoteURL, worktrees, commitDiff)

            repositories[index].updateStatus(statusResult, branch: branchResult)
            repositories[index].updateRemoteURL(remoteURLResult)
            repositories[index].updateWorktrees(worktreesResult)
            repositories[index].updateCommitDifference(behind: commitDiffResult.behind, ahead: commitDiffResult.ahead)

            // Optionally fetch in background (slow, but updates remote info)
            if shouldFetch {
                Task {
                    try? await gitCommand.fetch(at: repository.path)
                    // Re-check commit difference after fetch
                    if let newCommitDiff = try? await gitCommand.getCommitDifference(at: repository.path) {
                        await MainActor.run {
                            if let currentIndex = repositories.firstIndex(where: { $0.id == id }) {
                                repositories[currentIndex].updateCommitDifference(
                                    behind: newCommitDiff.behind,
                                    ahead: newCommitDiff.ahead
                                )
                            }
                        }
                    }
                }
            }
        } catch {
            print("Failed to update repository \(repository.name): \(error)")
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

        // Set pulling state
        repositories[index].isPulling = true

        do {
            let result = try await gitCommand.pull(at: repositories[index].path)
            await updateRepository(id)
            repositories[index].isPulling = false
            return result
        } catch {
            repositories[index].isPulling = false
            throw error
        }
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
            print("Failed to save repositories: \(error)")
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
            print("Failed to load repositories: \(error)")
        }
    }
}
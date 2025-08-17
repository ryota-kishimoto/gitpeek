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
        
        // Create and add repository
        var repository = Repository(path: path)
        
        // Fetch initial status
        do {
            let status = try await gitCommand.getStatus(at: path)
            let branch = try await gitCommand.getCurrentBranch(at: path)
            let remoteURL = try await gitCommand.getRemoteURL(at: path)
            
            repository.updateStatus(status, branch: branch)
            repository.updateRemoteURL(remoteURL)
        } catch {
            // Still add the repository even if initial fetch fails
            print("Failed to fetch initial status: \(error)")
        }
        
        repositories.append(repository)
        save()
    }
    
    /// Removes a repository
    /// - Parameter id: Repository ID to remove
    func remove(_ id: UUID) {
        repositories.removeAll { $0.id == id }
        save()
    }
    
    /// Updates the status of a repository
    /// - Parameter id: Repository ID to update
    func updateRepository(_ id: UUID) async {
        guard let index = repositories.firstIndex(where: { $0.id == id }) else { return }
        
        let repository = repositories[index]
        
        do {
            let status = try await gitCommand.getStatus(at: repository.path)
            let branch = try await gitCommand.getCurrentBranch(at: repository.path)
            let remoteURL = try await gitCommand.getRemoteURL(at: repository.path)
            
            repositories[index].updateStatus(status, branch: branch)
            repositories[index].updateRemoteURL(remoteURL)
        } catch {
            print("Failed to update repository \(repository.name): \(error)")
        }
    }
    
    /// Updates all repositories
    func updateAll() async {
        await withTaskGroup(of: Void.self) { group in
            for repository in repositories {
                group.addTask {
                    await self.updateRepository(repository.id)
                }
            }
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
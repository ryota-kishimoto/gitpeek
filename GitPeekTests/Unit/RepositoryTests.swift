import XCTest
@testable import GitPeek

final class RepositoryTests: XCTestCase {
    
    // MARK: - RED Phase: Repository Model Tests
    
    func testRepositoryCreation_withValidPath_succeeds() throws {
        // Arrange
        let path = "/Users/test/valid-repo"
        let name = "valid-repo"
        
        // Act
        let repository = Repository(path: path, name: name)
        
        // Assert
        XCTAssertNotNil(repository.id)
        XCTAssertEqual(repository.path, path)
        XCTAssertEqual(repository.name, name)
        XCTAssertNil(repository.currentBranch)
        XCTAssertNil(repository.lastFetchedAt)
    }
    
    func testRepositoryCreation_automaticallyExtractsName() throws {
        // Arrange
        let path = "/Users/test/my-awesome-project"
        
        // Act
        let repository = Repository(path: path)
        
        // Assert
        XCTAssertEqual(repository.name, "my-awesome-project")
    }
    
    func testRepository_conformsToCodable() throws {
        // Arrange
        let repository = Repository(path: "/test/repo", name: "test-repo")
        
        // Act - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(repository)
        
        // Act - Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Repository.self, from: data)
        
        // Assert
        XCTAssertEqual(repository.id, decoded.id)
        XCTAssertEqual(repository.path, decoded.path)
        XCTAssertEqual(repository.name, decoded.name)
    }
    
    func testRepository_conformsToEquatable() {
        // Arrange
        let repo1 = Repository(path: "/test/repo", name: "test")
        let repo2 = Repository(path: "/test/repo", name: "test", id: repo1.id)
        let repo3 = Repository(path: "/other/repo", name: "other")
        
        // Assert
        XCTAssertEqual(repo1, repo2)
        XCTAssertNotEqual(repo1, repo3)
    }
    
    func testRepository_updateStatus() {
        // Arrange
        var repository = Repository(path: "/test/repo")
        let status = GitStatus(
            hasChanges: true,
            stagedFiles: ["file1.txt"],
            modifiedFiles: ["file2.txt"],
            untrackedFiles: []
        )
        
        // Act
        repository.updateStatus(status, branch: "main")
        
        // Assert
        XCTAssertEqual(repository.currentBranch, "main")
        XCTAssertEqual(repository.gitStatus, status)
        XCTAssertNotNil(repository.lastFetchedAt)
    }
}

// MARK: - RepositoryStore Tests

@MainActor
final class RepositoryStoreTests: XCTestCase {
    var store: RepositoryStore!
    var testDirectory: URL!
    
    override func setUp() {
        super.setUp()
        store = RepositoryStore()
        
        // Create temporary directory for testing
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repos_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up
        try? FileManager.default.removeItem(at: testDirectory)
        store.clearAll()
    }
    
    func testAddRepository_withValidPath_succeeds() async throws {
        // Arrange
        let repoPath = testDirectory.appendingPathComponent("test-repo")
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)
        
        // Initialize as git repo
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = repoPath
        try process.run()
        process.waitUntilExit()
        
        // Act
        try await store.add(repoPath.path)
        
        // Assert
        XCTAssertEqual(store.repositories.count, 1)
        XCTAssertEqual(store.repositories.first?.path, repoPath.path)
    }
    
    func testAddRepository_withInvalidPath_throws() async {
        // Arrange
        let invalidPath = "/non/existent/path"
        
        // Act & Assert
        do {
            try await store.add(invalidPath)
            XCTFail("Should throw error for invalid path")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
    
    func testAddRepository_preventsDuplicates() async throws {
        // Arrange
        let repoPath = testDirectory.appendingPathComponent("test-repo")
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)
        
        // Initialize as git repo
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = repoPath
        try process.run()
        process.waitUntilExit()
        
        // Act - Add twice
        try await store.add(repoPath.path)
        
        do {
            try await store.add(repoPath.path)
            XCTFail("Should throw error for duplicate")
        } catch let error as RepositoryError {
            // Assert
            XCTAssertEqual(error, RepositoryError.alreadyExists)
        }
    }
    
    func testRemoveRepository() async throws {
        // Arrange - Add a repository first
        let repoPath = testDirectory.appendingPathComponent("test-repo")
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = repoPath
        try process.run()
        process.waitUntilExit()
        
        try await store.add(repoPath.path)
        guard let repositoryId = store.repositories.first?.id else {
            XCTFail("Repository not found")
            return
        }
        
        // Act
        store.remove(repositoryId)
        
        // Assert
        XCTAssertTrue(store.repositories.isEmpty)
    }
    
    func testPersistence_savesAndLoads() async throws {
        // Arrange
        let repoPath = testDirectory.appendingPathComponent("test-repo")
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = repoPath
        try process.run()
        process.waitUntilExit()
        
        // Act - Add and save
        try await store.add(repoPath.path)
        store.save()
        
        // Act - Create new store and load
        let newStore = RepositoryStore()
        newStore.load()
        
        // Assert
        XCTAssertEqual(newStore.repositories.count, 1)
        XCTAssertEqual(newStore.repositories.first?.path, repoPath.path)
    }
}
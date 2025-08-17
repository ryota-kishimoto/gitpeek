import XCTest
@testable import GitPeek

final class GitCommandTests: XCTestCase {
    var testRepoPath: String!
    
    override func setUpWithError() throws {
        // Create temporary test repository
        testRepoPath = NSTemporaryDirectory() + "test_repo_\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: testRepoPath, withIntermediateDirectories: true)
        
        // Initialize git repo
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = URL(fileURLWithPath: testRepoPath)
        try process.run()
        process.waitUntilExit()
    }
    
    override func tearDownWithError() throws {
        // Clean up test repository
        try? FileManager.default.removeItem(atPath: testRepoPath)
    }
    
    // MARK: - RED Phase: These tests should fail initially
    
    func testGetCurrentBranch_returnsMainForNewRepository() async throws {
        // Arrange
        let gitCommand = GitCommand()
        
        // Act
        let branch = try await gitCommand.getCurrentBranch(at: testRepoPath)
        
        // Assert
        XCTAssertEqual(branch, "main", "New repository should have 'main' as current branch")
    }
    
    func testGetStatus_returnsCleanForNewRepository() async throws {
        // Arrange
        let gitCommand = GitCommand()
        
        // Act
        let status = try await gitCommand.getStatus(at: testRepoPath)
        
        // Assert
        XCTAssertFalse(status.hasChanges, "New repository should have no changes")
        XCTAssertTrue(status.stagedFiles.isEmpty, "Should have no staged files")
        XCTAssertTrue(status.modifiedFiles.isEmpty, "Should have no modified files")
        XCTAssertTrue(status.untrackedFiles.isEmpty, "Should have no untracked files")
    }
    
    func testIsValidRepository_returnsTrueForGitRepo() throws {
        // Act
        let isValid = GitCommand.isValidRepository(at: testRepoPath)
        
        // Assert
        XCTAssertTrue(isValid, "Should recognize valid git repository")
    }
    
    func testIsValidRepository_returnsFalseForNonGitDirectory() throws {
        // Arrange
        let nonGitPath = NSTemporaryDirectory() + "non_git_\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: nonGitPath, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: nonGitPath) }
        
        // Act
        let isValid = GitCommand.isValidRepository(at: nonGitPath)
        
        // Assert
        XCTAssertFalse(isValid, "Should return false for non-git directory")
    }
    
    func testGetRemoteURL_returnsNilForNoRemote() async throws {
        // Arrange
        let gitCommand = GitCommand()
        
        // Act
        let remoteURL = try await gitCommand.getRemoteURL(at: testRepoPath)
        
        // Assert
        XCTAssertNil(remoteURL, "Repository without remote should return nil")
    }
}
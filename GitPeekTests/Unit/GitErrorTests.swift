import XCTest
@testable import GitPeek

final class GitErrorTests: XCTestCase {
    
    func testErrorDescription() {
        // Test commandFailed
        let commandFailedError = GitError.commandFailed(
            command: "git status",
            output: "fatal: not a git repository",
            exitCode: 128
        )
        XCTAssertEqual(
            commandFailedError.errorDescription,
            "Git command 'git status' failed with exit code 128: fatal: not a git repository"
        )
        
        // Test invalidRepository
        let invalidRepoError = GitError.invalidRepository(path: "/path/to/repo")
        XCTAssertEqual(
            invalidRepoError.errorDescription,
            "Not a valid Git repository at: /path/to/repo"
        )
        
        // Test timeout
        let timeoutError = GitError.timeout(command: "git clone")
        XCTAssertEqual(
            timeoutError.errorDescription,
            "Git command timed out: git clone"
        )
        
        // Test gitNotFound
        let gitNotFoundError = GitError.gitNotFound
        XCTAssertEqual(
            gitNotFoundError.errorDescription,
            "Git executable not found"
        )
        
        // Test invalidPath
        let invalidPathError = GitError.invalidPath("/invalid/path")
        XCTAssertEqual(
            invalidPathError.errorDescription,
            "Invalid path: /invalid/path"
        )
        
        // Test permissionDenied
        let permissionError = GitError.permissionDenied(path: "/restricted/path")
        XCTAssertEqual(
            permissionError.errorDescription,
            "Permission denied accessing: /restricted/path"
        )
    }
    
    func testFailureReason() {
        // Test commandFailed with output
        let commandFailedError = GitError.commandFailed(
            command: "git push",
            output: "Authentication failed",
            exitCode: 1
        )
        XCTAssertEqual(commandFailedError.failureReason, "Authentication failed")
        
        // Test commandFailed with empty output
        let commandFailedEmptyError = GitError.commandFailed(
            command: "git push",
            output: "",
            exitCode: 1
        )
        XCTAssertNil(commandFailedEmptyError.failureReason)
        
        // Test invalidRepository
        let invalidRepoError = GitError.invalidRepository(path: "/path")
        XCTAssertEqual(
            invalidRepoError.failureReason,
            "The specified directory does not contain a .git folder"
        )
        
        // Test timeout
        let timeoutError = GitError.timeout(command: "git fetch")
        XCTAssertEqual(
            timeoutError.failureReason,
            "The operation took too long to complete"
        )
        
        // Test gitNotFound
        let gitNotFoundError = GitError.gitNotFound
        XCTAssertEqual(
            gitNotFoundError.failureReason,
            "Please ensure Git is installed and accessible"
        )
        
        // Test invalidPath
        let invalidPathError = GitError.invalidPath("/path")
        XCTAssertEqual(
            invalidPathError.failureReason,
            "The specified path does not exist or is not accessible"
        )
        
        // Test permissionDenied
        let permissionError = GitError.permissionDenied(path: "/path")
        XCTAssertEqual(
            permissionError.failureReason,
            "Check file permissions for the repository"
        )
    }
}
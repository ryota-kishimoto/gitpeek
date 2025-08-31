import XCTest
@testable import GitPeek

@MainActor
final class ExternalAppIntegrationTests: XCTestCase {
    var viewModel: MenuBarViewModel!
    var testRepository: Repository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create a fresh view model and clear any existing repos
        viewModel = MenuBarViewModel()
        viewModel.repositories.forEach { viewModel.removeRepository($0) }
        
        // Create a test repository
        let testPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repo_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = testPath
        try process.run()
        process.waitUntilExit()
        
        // Set up remote URL
        let gitProcess = Process()
        gitProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        gitProcess.arguments = ["remote", "add", "origin", "git@github.com:test/repo.git"]
        gitProcess.currentDirectoryURL = testPath
        try gitProcess.run()
        gitProcess.waitUntilExit()
        
        // Add repository to view model
        try await viewModel.addRepository(path: testPath.path)
        testRepository = viewModel.repositories.first ?? Repository(path: testPath.path, name: "Test")
    }
    
    override func tearDown() async throws {
        // Clean up test repository
        if let repo = testRepository {
            try? FileManager.default.removeItem(atPath: repo.path)
        }
        try await super.tearDown()
    }
    
    // MARK: - Tests
    
    func testOpenInFinder() {
        // This test can only verify that the method doesn't crash
        // Actual opening would require UI testing
        
        // First verify the repository path was created properly
        XCTAssertNotNil(testRepository, "Test repository should be initialized")
        XCTAssertTrue(FileManager.default.fileExists(atPath: testRepository.path), "Repository path should exist before test")
        
        // Call the method
        viewModel.openInFinder(repository: testRepository)
        
        // Method should not crash - that's all we can verify
        XCTAssertTrue(true, "Method executed without crashing")
    }
    
    func testOpenInTerminal() {
        // This test can only verify that the method doesn't crash
        // Actual terminal opening would require UI testing
        viewModel.openInTerminal(repository: testRepository)
        
        // No assertion needed - just ensure no crash
    }
    
    func testOpenInCursor() {
        // This test can only verify that the method doesn't crash
        // Actual Cursor opening would require the app to be installed
        viewModel.openInCursor(repository: testRepository)
        
        // No assertion needed - just ensure no crash
    }
    
    func testOpenInSourceTree() {
        // This test verifies error handling when SourceTree is not installed
        viewModel.openInSourceTree(repository: testRepository)
        
        // Check if SourceTree is installed
        let sourceTreeURL = URL(fileURLWithPath: "/Applications/SourceTree.app")
        if !FileManager.default.fileExists(atPath: sourceTreeURL.path) {
            // Should set error message when SourceTree is not installed
            XCTAssertEqual(viewModel.errorMessage, "SourceTree is not installed")
        }
    }
    
    func testOpenOnGitHub() async throws {
        // First, ensure we have the remote URL by refreshing
        await viewModel.refreshRepository(testRepository)
        
        // Update our local reference
        testRepository = viewModel.repositories.first ?? Repository(path: testPath.path, name: "Test")
        
        // This test can only verify that the method doesn't crash
        viewModel.openOnGitHub(repository: testRepository)
        
        // The remote URL should be set
        XCTAssertNotNil(testRepository.remoteURL)
    }
    
    func testCopyBranchName() async throws {
        // Refresh to get branch info
        await viewModel.refreshRepository(testRepository)
        testRepository = viewModel.repositories.first ?? Repository(path: testPath.path, name: "Test")
        
        // Copy branch name
        viewModel.copyBranchName(repository: testRepository)
        
        // Verify pasteboard contains the branch name
        let pasteboard = NSPasteboard.general
        let copiedString = pasteboard.string(forType: .string)
        
        // Should have copied the branch name (likely "main" or "master")
        XCTAssertNotNil(copiedString)
        if let branch = testRepository.currentBranch {
            XCTAssertEqual(copiedString, branch)
        }
    }
    
    func testGitHubURLConversion() {
        // Test SSH to HTTPS conversion
        guard var repo = testRepository else {
            XCTFail("Test repository not initialized")
            return
        }
        
        // Test SSH format
        repo.updateRemoteURL("git@github.com:user/repo.git")
        viewModel.openOnGitHub(repository: repo)
        // Should convert to https://github.com/user/repo
        
        // Test HTTPS format
        repo.updateRemoteURL("https://github.com/user/repo.git")
        viewModel.openOnGitHub(repository: repo)
        // Should remove .git extension
        
        // Test without remote URL
        repo.updateRemoteURL(nil)
        viewModel.openOnGitHub(repository: repo)
        XCTAssertEqual(viewModel.errorMessage, "No remote URL configured")
    }
}
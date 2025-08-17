import XCTest
@testable import GitPeek

@MainActor
final class MenuBarViewModelTests: XCTestCase {
    var viewModel: MenuBarViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MenuBarViewModel()
    }
    
    // MARK: - RED Phase: MenuBarViewModel Tests
    
    func testInitialState() {
        // Assert
        XCTAssertFalse(viewModel.isShowingPopover)
        XCTAssertTrue(viewModel.repositories.isEmpty)
        XCTAssertFalse(viewModel.isRefreshing)
        XCTAssertNil(viewModel.selectedRepository)
    }
    
    func testTogglePopover() {
        // Act
        viewModel.togglePopover()
        
        // Assert
        XCTAssertTrue(viewModel.isShowingPopover)
        
        // Act again
        viewModel.togglePopover()
        
        // Assert
        XCTAssertFalse(viewModel.isShowingPopover)
    }
    
    func testAddRepository() async throws {
        // Arrange
        let testPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repo_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
        
        // Initialize as git repo
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = testPath
        try process.run()
        process.waitUntilExit()
        
        // Act
        try await viewModel.addRepository(path: testPath.path)
        
        // Assert
        XCTAssertEqual(viewModel.repositories.count, 1)
        XCTAssertEqual(viewModel.repositories.first?.path, testPath.path)
        
        // Clean up
        try? FileManager.default.removeItem(at: testPath)
    }
    
    func testRefreshAll() async {
        // Arrange
        let testPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repo_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = testPath
        try? process.run()
        process.waitUntilExit()
        
        try? await viewModel.addRepository(path: testPath.path)
        
        // Act
        await viewModel.refreshAll()
        
        // Assert
        XCTAssertFalse(viewModel.isRefreshing) // Should be false after completion
        
        // Clean up
        try? FileManager.default.removeItem(at: testPath)
    }
    
    func testSelectRepository() async throws {
        // Arrange
        let testPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repo_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = testPath
        try process.run()
        process.waitUntilExit()
        
        try await viewModel.addRepository(path: testPath.path)
        let repository = viewModel.repositories.first!
        
        // Act
        viewModel.selectRepository(repository)
        
        // Assert
        XCTAssertEqual(viewModel.selectedRepository?.id, repository.id)
        
        // Clean up
        try? FileManager.default.removeItem(at: testPath)
    }
    
    func testRemoveRepository() async throws {
        // Arrange
        let testPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repo_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = testPath
        try process.run()
        process.waitUntilExit()
        
        try await viewModel.addRepository(path: testPath.path)
        let repository = viewModel.repositories.first!
        
        // Act
        viewModel.removeRepository(repository)
        
        // Assert
        XCTAssertTrue(viewModel.repositories.isEmpty)
        
        // Clean up
        try? FileManager.default.removeItem(at: testPath)
    }
    
    func testStatusBarTitle() async throws {
        // Initially should show app name
        XCTAssertEqual(viewModel.statusBarTitle, "GitPeek")
        
        // Add a repository
        let testPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_repo_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = testPath
        try process.run()
        process.waitUntilExit()
        
        try await viewModel.addRepository(path: testPath.path)
        
        // Should show repository count
        XCTAssertEqual(viewModel.statusBarTitle, "GitPeek (1)")
        
        // Clean up
        try? FileManager.default.removeItem(at: testPath)
    }
}
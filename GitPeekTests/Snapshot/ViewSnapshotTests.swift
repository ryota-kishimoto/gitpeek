import XCTest
import SnapshotTesting
import SwiftUI
import AppKit
@testable import GitPeek

@MainActor
final class ViewSnapshotTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Skip snapshot tests in CI environment
        guard ProcessInfo.processInfo.environment["CI"] == nil else {
            throw XCTSkip("Skipping snapshot tests in CI environment")
        }
        // isRecording = true // Uncomment to regenerate snapshots
    }
    
    // MARK: - Settings View Tests
    
    func testSettingsView() async {
        let view = SettingsView()
            .frame(width: 450, height: 400)
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 450, height: 400)
        assertSnapshot(of: hostingController, as: .image)
    }
    
    func testSettingsView_DarkMode() async {
        let view = SettingsView()
            .frame(width: 450, height: 400)
            .environment(\.colorScheme, .dark)
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 450, height: 400)
        assertSnapshot(of: hostingController, as: .image)
    }
    
    // MARK: - Menu Bar View Tests
    
    func testMenuBarView_Empty() async {
        let viewModel = MenuBarViewModel()
        let view = MenuBarView(closePopover: {})
            .environmentObject(viewModel)
            .frame(width: 400, height: 600)
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 400, height: 600)
        assertSnapshot(of: hostingController, as: .image)
    }
    
    func testMenuBarView_DarkMode() async {
        let viewModel = MenuBarViewModel()
        let view = MenuBarView(closePopover: {})
            .environmentObject(viewModel)
            .frame(width: 400, height: 600)
            .environment(\.colorScheme, .dark)
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 400, height: 600)
        assertSnapshot(of: hostingController, as: .image)
    }
    
    // MARK: - Content View Tests
    
    func testContentView_Empty() async {
        let store = RepositoryStore()
        let view = ContentView()
            .environmentObject(store)
            .frame(width: 600, height: 400)
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 600, height: 400)
        assertSnapshot(of: hostingController, as: .image)
    }
    
    func testContentView_DarkMode() async {
        let store = RepositoryStore()
        let view = ContentView()
            .environmentObject(store)
            .frame(width: 600, height: 400)
            .environment(\.colorScheme, .dark)
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 600, height: 400)
        assertSnapshot(of: hostingController, as: .image)
    }
}
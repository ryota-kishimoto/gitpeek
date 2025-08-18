import SwiftUI
import Combine

@main
struct GitPeekApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover = NSPopover()
    private var eventMonitor: Any?
    private var themeManager = ThemeManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    nonisolated func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            setupMenuBar()
            setupThemeObserver()
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: "GitPeek")
            button.action = #selector(togglePopover)
        }
        
        let menuBarView = MenuBarView(closePopover: { [weak self] in
            self?.closePopover()
        })
        .environmentObject(themeManager)
        .environment(\.theme, themeManager.currentTheme)
        popover.contentViewController = NSHostingController(rootView: AnyView(menuBarView))
        popover.behavior = .applicationDefined  // 完全に手動制御
        popover.animates = true
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if popover.isShown {
            closePopover()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            startEventMonitor()
        }
    }
    
    private func closePopover() {
        popover.performClose(nil)
        stopEventMonitor()
    }
    
    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self = self, self.popover.isShown {
                self.closePopover()
            }
        }
    }
    
    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func setupThemeObserver() {
        themeManager.$isDarkMode
            .sink { [weak self] isDark in
                guard let self = self else { return }
                // Update the current theme
                let newTheme: Theme = isDark ? DarkTheme() : LightTheme()
                
                // Recreate the view with new theme
                if let contentViewController = self.popover.contentViewController as? NSHostingController<AnyView> {
                    let menuBarView = MenuBarView(closePopover: { [weak self] in
                        self?.closePopover()
                    })
                    .environmentObject(self.themeManager)
                    .environment(\.theme, newTheme)
                    
                    contentViewController.rootView = AnyView(menuBarView)
                }
            }
            .store(in: &cancellables)
    }
}
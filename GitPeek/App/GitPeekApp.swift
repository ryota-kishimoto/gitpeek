import SwiftUI
import Sparkle

@main
struct GitPeekApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    appDelegate.updaterController.updater.checkForUpdates()
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover = NSPopover()
    private var eventMonitor: Any?
    
    // Sparkle updater controller
    lazy var updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            if let iconPath = Bundle.main.path(forResource: "MenuBarIcon", ofType: "png"),
               let icon = NSImage(contentsOfFile: iconPath) {
                icon.isTemplate = true
                icon.size = NSSize(width: 18, height: 18)
                button.image = icon
            } else {
                button.image = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: "GitPeek")
            }
            button.action = #selector(togglePopover)
        }
        
        let menuBarView = MenuBarView(
            closePopover: { [weak self] in
                self?.closePopover()
            },
            openPopover: { [weak self] in
                self?.openPopover()
            }
        )
        popover.contentViewController = NSHostingController(rootView: menuBarView)
        popover.behavior = .applicationDefined  // 完全に手動制御
        popover.animates = true
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button else {
            return
        }
        
        if popover.isShown {
            closePopover()
        } else {
            // Notify the view that popover will show
            NotificationCenter.default.post(name: NSNotification.Name("PopoverWillShow"), object: nil)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            startEventMonitor()
        }
    }
    
    private func openPopover() {
        guard let button = statusItem?.button else { return }
        if !popover.isShown {
            NotificationCenter.default.post(name: NSNotification.Name("PopoverWillShow"), object: nil)
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
}
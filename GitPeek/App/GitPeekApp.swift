import SwiftUI

@main
struct GitPeekApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover = NSPopover()
    private var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
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
        popover.contentViewController = NSHostingController(rootView: menuBarView)
        popover.behavior = .applicationDefined  // 完全に手動制御
        popover.animates = true
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if popover.isShown {
            closePopover()
        } else {
            // Notify the view that popover will show
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
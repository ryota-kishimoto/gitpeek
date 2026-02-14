import SwiftUI
import Sparkle
import ServiceManagement

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval: Double = 30.0
    @AppStorage("showNotifications") private var showNotifications: Bool = false
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @AppStorage("defaultTerminal") private var defaultTerminal: String = "Terminal"
    @AppStorage("defaultEditor") private var defaultEditor: String = "Cursor"
    
    @State private var showingAbout = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // タイトルバー
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            
            TabView {
                generalSettings
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                
                externalAppsSettings
                    .tabItem {
                        Label("External Apps", systemImage: "app.dashed")
                    }
                
                advancedSettings
                    .tabItem {
                        Label("Advanced", systemImage: "wrench.and.screwdriver")
                    }
            }
        }
        .frame(width: 500, height: 450)
    }
    
    // MARK: - General Settings
    
    private var generalSettings: some View {
        Form {
            Section {
                HStack {
                    Text("Refresh Interval:")
                    Slider(value: $refreshInterval, in: 10...300, step: 10)
                        .frame(width: 200)
                    Text("\(Int(refreshInterval)) seconds")
                        .frame(width: 80, alignment: .trailing)
                }
                
                Toggle("Show notifications for changes", isOn: $showNotifications)
                
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = !newValue
                        }
                    }
            } header: {
                Text("General Settings")
                    .font(.headline)
            }
            
            Spacer()
            
            HStack {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                
                Spacer()
                
                Button("About GitPeek") {
                    showingAbout = true
                }
            }
        }
        .padding(20)
        .sheet(isPresented: $showingAbout) {
            AboutView(isPresented: $showingAbout)
        }
    }
    
    // MARK: - External Apps Settings
    
    private var externalAppsSettings: some View {
        Form {
            Section {
                Picker("Default Terminal:", selection: $defaultTerminal) {
                    Text("Terminal").tag("Terminal")
                    Text("iTerm2").tag("iTerm2")
                    Text("Warp").tag("Warp")
                    Text("Hyper").tag("Hyper")
                }
                
                Picker("Default Editor:", selection: $defaultEditor) {
                    Text("Cursor").tag("Cursor")
                    Text("VSCode").tag("VSCode")
                    Text("Sublime Text").tag("Sublime")
                    Text("Xcode").tag("Xcode")
                    Text("Nova").tag("Nova")
                }
            } header: {
                Text("External Applications")
                    .font(.headline)
            }
            
            Section {
                Text("Configure which applications open when you click the corresponding buttons in GitPeek.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Advanced Settings
    
    private var advancedSettings: some View {
        Form {
            Section {
                HStack {
                    Text("Git Command Timeout:")
                    TextField("", value: .constant(30.0), format: .number)
                        .frame(width: 60)
                    Text("seconds")
                }
                
                Toggle("Enable debug logging", isOn: .constant(false))
                
                Button("Clear repository cache") {
                    clearCache()
                }
            } header: {
                Text("Advanced Settings")
                    .font(.headline)
            }
            
            Section {
                Text("⚠️ These settings are for advanced users only.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Actions
    
    private func resetToDefaults() {
        refreshInterval = 30.0
        showNotifications = false
        if launchAtLogin {
            launchAtLogin = false
            try? SMAppService.mainApp.unregister()
        }
        defaultTerminal = "Terminal"
        defaultEditor = "Cursor"
    }
    
    private func clearCache() {
        // This would clear the repository cache
        // Implementation would connect to the actual cache clearing logic
    }
}

// MARK: - About View

struct AboutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            AppIconView(size: 64)
            
            Text("GitPeek")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("A macOS menu bar app for managing Git repositories")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 8) {
                if let url = URL(string: "https://github.com/ryota-kishimoto/gitpeek") {
                    Link("GitHub Repository", destination: url)
                }
                if let url = URL(string: "https://github.com/ryota-kishimoto/gitpeek/issues") {
                    Link("Report an Issue", destination: url)
                }
                if let url = URL(string: "https://github.com/ryota-kishimoto/gitpeek/blob/main/LICENSE") {
                    Link("License: MIT", destination: url)
                }
            }
            
            Spacer()
            
            // Auto-update check button
            if let appDelegate = NSApp.delegate as? AppDelegate {
                Button("Check for Updates...") {
                    appDelegate.updaterController.updater.checkForUpdates()
                }
                .padding(.bottom, 8)
            }
            
            Text("© 2025 GitPeek. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Close") {
                isPresented = false
            }
            .padding(.bottom)
        }
        .padding(20)
        .frame(width: 350, height: 450)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
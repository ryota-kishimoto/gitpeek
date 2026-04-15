import SwiftUI
import Sparkle
import ServiceManagement

struct SettingsView: View {
    @AppStorage(AppConstants.UserDefaultsKey.refreshInterval)
    private var refreshInterval: Double = AppConstants.Defaults.refreshInterval
    @AppStorage(AppConstants.UserDefaultsKey.showNotifications)
    private var showNotifications: Bool = AppConstants.Defaults.showNotifications
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @AppStorage(AppConstants.UserDefaultsKey.defaultTerminal)
    private var defaultTerminal: String = AppConstants.Defaults.terminal
    @AppStorage(AppConstants.UserDefaultsKey.defaultEditor)
    private var defaultEditor: String = AppConstants.Defaults.editor
    @AppStorage(AppConstants.UserDefaultsKey.gitCommandTimeout)
    private var gitCommandTimeout: Double = AppConstants.Defaults.gitCommandTimeout
    @AppStorage(AppConstants.UserDefaultsKey.debugLogging)
    private var debugLogging: Bool = AppConstants.Defaults.debugLogging
    
    @State private var showingAbout = false
    @State private var showingCacheCleared = false
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
        .frame(width: AppConstants.Layout.settingsWindowWidth, height: AppConstants.Layout.settingsWindowHeight)
    }
    
    // MARK: - General Settings
    
    private var generalSettings: some View {
        Form {
            Section {
                HStack {
                    Text("Refresh Interval:")
                    Slider(
                        value: $refreshInterval,
                        in: AppConstants.Layout.refreshIntervalRange,
                        step: AppConstants.Layout.refreshIntervalStep
                    )
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

            Section {
                HStack {
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? AppConstants.Layout.versionFallback)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Check for Updates…") {
                        SparkleUpdater.shared.checkForUpdates()
                    }
                }
            } header: {
                Text("Updates")
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
                    Text("Terminal").tag(AppConstants.Terminal.terminal)
                    Text("iTerm2").tag(AppConstants.Terminal.iterm2)
                    Text("Warp").tag(AppConstants.Terminal.warp)
                    Text("Hyper").tag(AppConstants.Terminal.hyper)
                }

                Picker("Default Editor:", selection: $defaultEditor) {
                    Text("Cursor").tag(AppConstants.Editor.cursor)
                    Text("VSCode").tag(AppConstants.Editor.vscode)
                    Text("Sublime Text").tag(AppConstants.Editor.sublime)
                    Text("Xcode").tag(AppConstants.Editor.xcode)
                    Text("Nova").tag(AppConstants.Editor.nova)
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
                    TextField("", value: $gitCommandTimeout, format: .number)
                        .frame(width: 60)
                    Text("seconds")
                }

                Toggle("Enable debug logging", isOn: $debugLogging)
                
                Button("Clear repository cache") {
                    clearCache()
                }
                .alert("Cache Cleared", isPresented: $showingCacheCleared) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Repository cache has been cleared. Repositories will be refreshed on next update.")
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
        refreshInterval = AppConstants.Defaults.refreshInterval
        showNotifications = AppConstants.Defaults.showNotifications
        if launchAtLogin {
            launchAtLogin = false
            try? SMAppService.mainApp.unregister()
        }
        defaultTerminal = AppConstants.Defaults.terminal
        defaultEditor = AppConstants.Defaults.editor
        gitCommandTimeout = AppConstants.Defaults.gitCommandTimeout
        debugLogging = AppConstants.Defaults.debugLogging
    }

    private func clearCache() {
        let fileManager = FileManager.default
        let cacheFile = AppConstants.Persistence.repositoriesFileURL

        if fileManager.fileExists(atPath: cacheFile.path) {
            try? fileManager.removeItem(at: cacheFile)
        }
        showingCacheCleared = true
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
            
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? AppConstants.Layout.versionFallback)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("A macOS menu bar app for managing Git repositories")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 8) {
                if let url = URL(string: AppConstants.GitHub.repositoryURL) {
                    Link("GitHub Repository", destination: url)
                }
                if let url = URL(string: AppConstants.GitHub.issuesURL) {
                    Link("Report an Issue", destination: url)
                }
                if let url = URL(string: AppConstants.GitHub.licenseURL) {
                    Link("License: MIT", destination: url)
                }
            }
            
            Spacer()
            
            Button("Check for Updates…") {
                SparkleUpdater.shared.checkForUpdates()
            }
            .padding(.bottom, 8)
            
            Text(AppConstants.Layout.copyrightText)
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Close") {
                isPresented = false
            }
            .padding(.bottom)
        }
        .padding(20)
        .frame(width: AppConstants.Layout.aboutWindowWidth, height: AppConstants.Layout.aboutWindowHeight)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
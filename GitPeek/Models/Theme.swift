import SwiftUI

// MARK: - Theme Protocol

protocol Theme {
    // Background colors
    var primaryBackground: Color { get }
    var secondaryBackground: Color { get }
    var tertiaryBackground: Color { get }
    
    // Text colors
    var primaryText: Color { get }
    var secondaryText: Color { get }
    
    // Status colors
    var cleanStatus: Color { get }
    var modifiedStatus: Color { get }
    var stagedStatus: Color { get }
    var untrackedStatus: Color { get }
    
    // Interactive colors
    var accentColor: Color { get }
    var hoverBackground: Color { get }
    var selectedBackground: Color { get }
    
    // Border and divider colors
    var dividerColor: Color { get }
    var borderColor: Color { get }
    
    // Component specific
    var branchTagBackground: Color { get }
    var headerFooterBackground: Color { get }
}

// MARK: - Light Theme

struct LightTheme: Theme {
    let primaryBackground = Color.white
    let secondaryBackground = Color.gray.opacity(0.05)
    let tertiaryBackground = Color.gray.opacity(0.02)
    
    let primaryText = Color.primary
    let secondaryText = Color.secondary
    
    let cleanStatus = Color.mint
    let modifiedStatus = Color.orange
    let stagedStatus = Color.blue
    let untrackedStatus = Color.gray
    
    let accentColor = Color.accentColor
    let hoverBackground = Color.gray.opacity(0.05)
    let selectedBackground = Color.blue.opacity(0.08)
    
    let dividerColor = Color.gray.opacity(0.2)
    let borderColor = Color.gray.opacity(0.15)
    
    let branchTagBackground = Color.accentColor.opacity(0.2)
    let headerFooterBackground = Color.gray.opacity(0.05)
}

// MARK: - Dark Theme

struct DarkTheme: Theme {
    let primaryBackground = Color(NSColor.windowBackgroundColor)
    let secondaryBackground = Color.white.opacity(0.05)
    let tertiaryBackground = Color.white.opacity(0.02)
    
    let primaryText = Color.primary
    let secondaryText = Color.secondary
    
    let cleanStatus = Color.mint.opacity(0.9)
    let modifiedStatus = Color.orange.opacity(0.9)
    let stagedStatus = Color.blue.opacity(0.9)
    let untrackedStatus = Color.gray.opacity(0.9)
    
    let accentColor = Color.accentColor
    let hoverBackground = Color.white.opacity(0.08)
    let selectedBackground = Color.blue.opacity(0.15)
    
    let dividerColor = Color.white.opacity(0.1)
    let borderColor = Color.white.opacity(0.08)
    
    let branchTagBackground = Color.accentColor.opacity(0.25)
    let headerFooterBackground = Color.white.opacity(0.03)
}

// MARK: - Theme Manager

@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    @Published var isDarkMode: Bool {
        didSet {
            currentTheme = isDarkMode ? DarkTheme() : LightTheme()
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    static let shared = ThemeManager()
    
    private init() {
        let savedDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let useDarkMode: Bool
        
        // Optionally sync with system appearance
        if UserDefaults.standard.object(forKey: "isDarkMode") == nil {
            useDarkMode = NSApp.effectiveAppearance.name == .darkAqua
        } else {
            useDarkMode = savedDarkMode
        }
        
        self.isDarkMode = useDarkMode
        self.currentTheme = useDarkMode ? DarkTheme() : LightTheme()
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
}

// MARK: - Theme Environment Key

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = LightTheme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func themedBackground(_ keyPath: KeyPath<Theme, Color>) -> some View {
        self.modifier(ThemedBackgroundModifier(colorKeyPath: keyPath))
    }
    
    func themedForeground(_ keyPath: KeyPath<Theme, Color>) -> some View {
        self.modifier(ThemedForegroundModifier(colorKeyPath: keyPath))
    }
}

struct ThemedBackgroundModifier: ViewModifier {
    @Environment(\.theme) var theme
    let colorKeyPath: KeyPath<Theme, Color>
    
    func body(content: Content) -> some View {
        content.background(theme[keyPath: colorKeyPath])
    }
}

struct ThemedForegroundModifier: ViewModifier {
    @Environment(\.theme) var theme
    let colorKeyPath: KeyPath<Theme, Color>
    
    func body(content: Content) -> some View {
        content.foregroundColor(theme[keyPath: colorKeyPath])
    }
}
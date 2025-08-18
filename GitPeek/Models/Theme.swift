import SwiftUI

// MARK: - App Theme

struct AppTheme {
    // Background colors
    static let primaryBackground = Color.white
    static let secondaryBackground = Color.gray.opacity(0.05)
    static let tertiaryBackground = Color.gray.opacity(0.02)
    
    // Text colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    
    // Status colors
    static let cleanStatus = Color.mint
    static let modifiedStatus = Color.orange
    static let stagedStatus = Color.blue
    static let untrackedStatus = Color.gray
    
    // Interactive colors
    static let accentColor = Color.accentColor
    static let hoverBackground = Color.gray.opacity(0.05)
    static let selectedBackground = Color.blue.opacity(0.08)
    
    // Border and divider colors
    static let dividerColor = Color.gray.opacity(0.2)
    static let borderColor = Color.gray.opacity(0.15)
    
    // Component specific
    static let branchTagBackground = Color.accentColor.opacity(0.2)
    static let headerFooterBackground = Color.gray.opacity(0.05)
}
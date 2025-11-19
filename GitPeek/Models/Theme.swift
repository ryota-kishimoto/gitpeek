import SwiftUI

// MARK: - App Theme

struct AppTheme {
    // Background colors - Using adaptive colors for better macOS compatibility
    static let primaryBackground = Color(nsColor: .controlBackgroundColor)
    static let secondaryBackground = Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
    static let tertiaryBackground = Color(nsColor: .controlBackgroundColor).opacity(0.5)

    // Text colors - Explicit colors to avoid white-on-white issues
    static let primaryText = Color(nsColor: .labelColor)
    static let secondaryText = Color(nsColor: .secondaryLabelColor)

    // Status colors
    static let cleanStatus = Color.mint
    static let modifiedStatus = Color.orange
    static let stagedStatus = Color.blue
    static let untrackedStatus = Color.gray

    // Interactive colors
    static let accentColor = Color.accentColor
    static let hoverBackground = Color(nsColor: .selectedControlColor).opacity(0.3)
    static let selectedBackground = Color(nsColor: .selectedControlColor).opacity(0.5)

    // Border and divider colors
    static let dividerColor = Color(nsColor: .separatorColor)
    static let borderColor = Color(nsColor: .separatorColor).opacity(0.5)

    // Component specific
    static let branchTagBackground = Color.accentColor.opacity(0.2)
    static let headerFooterBackground = Color(nsColor: .controlBackgroundColor).opacity(0.8)
}
import Foundation

/// Represents the current status of a Git repository
struct GitStatus: Equatable, Codable, CustomStringConvertible {
    let hasChanges: Bool
    let stagedFiles: [String]
    let modifiedFiles: [String]
    let untrackedFiles: [String]
    
    /// Total number of changed files across all categories
    var totalChangedFiles: Int {
        stagedFiles.count + modifiedFiles.count + untrackedFiles.count
    }
    
    /// Whether the repository is in a clean state (no changes)
    var isClean: Bool {
        !hasChanges
    }
    
    /// All changed files combined
    var allChangedFiles: [String] {
        stagedFiles + modifiedFiles + untrackedFiles
    }
    
    var description: String {
        "GitStatus(staged: \(stagedFiles.count), modified: \(modifiedFiles.count), untracked: \(untrackedFiles.count))"
    }
}
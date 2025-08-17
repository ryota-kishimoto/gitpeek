import Foundation

// MARK: - Repository

/// Represents a Git repository
struct Repository: Identifiable, Codable, Equatable {
    let id: UUID
    let path: String
    let name: String
    var currentBranch: String?
    var gitStatus: GitStatus?
    var lastFetchedAt: Date?
    var remoteURL: String?
    
    init(path: String, name: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.path = path
        self.name = name ?? URL(fileURLWithPath: path).lastPathComponent
        self.currentBranch = nil
        self.gitStatus = nil
        self.lastFetchedAt = nil
        self.remoteURL = nil
    }
    
    mutating func updateStatus(_ status: GitStatus, branch: String) {
        self.gitStatus = status
        self.currentBranch = branch
        self.lastFetchedAt = Date()
    }
    
    mutating func updateRemoteURL(_ url: String?) {
        self.remoteURL = url
    }
}

// MARK: - RepositoryError

enum RepositoryError: LocalizedError, Equatable {
    case invalidPath
    case notAGitRepository
    case alreadyExists
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .invalidPath:
            return "The specified path is invalid"
        case .notAGitRepository:
            return "The specified path is not a Git repository"
        case .alreadyExists:
            return "This repository has already been added"
        case .notFound:
            return "Repository not found"
        }
    }
}
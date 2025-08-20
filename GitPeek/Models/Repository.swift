import Foundation

// MARK: - Worktree

/// Represents a Git worktree
struct Worktree: Codable, Equatable {
    let path: String
    let branch: String
    let commit: String
    let isMain: Bool
    
    init(path: String, branch: String, commit: String, isMain: Bool = false) {
        self.path = path
        self.branch = branch
        self.commit = commit
        self.isMain = isMain
    }
}

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
    var worktrees: [Worktree]?
    var isWorktree: Bool?
    var mainWorktreePath: String?
    var commitsBehind: Int?
    var commitsAhead: Int?
    
    init(path: String, name: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.path = path
        self.name = name ?? URL(fileURLWithPath: path).lastPathComponent
        self.currentBranch = nil
        self.gitStatus = nil
        self.lastFetchedAt = nil
        self.remoteURL = nil
        self.worktrees = nil
        self.isWorktree = false
        self.mainWorktreePath = nil
        self.commitsBehind = nil
        self.commitsAhead = nil
    }
    
    mutating func updateStatus(_ status: GitStatus, branch: String) {
        self.gitStatus = status
        self.currentBranch = branch
        self.lastFetchedAt = Date()
    }
    
    mutating func updateRemoteURL(_ url: String?) {
        self.remoteURL = url
    }
    
    mutating func updateWorktrees(_ worktrees: [Worktree]) {
        self.worktrees = worktrees
        // Check if current path is a worktree
        if let firstWorktree = worktrees.first {
            self.isWorktree = (path != firstWorktree.path)
            self.mainWorktreePath = firstWorktree.path
        }
    }
    
    mutating func updateCommitDifference(behind: Int, ahead: Int) {
        self.commitsBehind = behind
        self.commitsAhead = ahead
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
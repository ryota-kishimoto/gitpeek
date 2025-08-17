import Foundation

// MARK: - GitStatus

/// Represents the current status of a Git repository
struct GitStatus: Equatable, CustomStringConvertible {
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

// MARK: - GitError

/// Errors that can occur during Git operations
enum GitError: LocalizedError {
    case commandFailed(command: String, output: String, exitCode: Int32)
    case invalidRepository(path: String)
    case timeout(command: String)
    case gitNotFound
    case invalidPath(String)
    case permissionDenied(path: String)
    
    var errorDescription: String? {
        switch self {
        case .commandFailed(let command, let output, let code):
            return "Git command '\(command)' failed with exit code \(code): \(output)"
        case .invalidRepository(let path):
            return "Not a valid Git repository at: \(path)"
        case .timeout(let command):
            return "Git command timed out: \(command)"
        case .gitNotFound:
            return "Git executable not found"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .permissionDenied(let path):
            return "Permission denied accessing: \(path)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .commandFailed(_, let output, _):
            return output.isEmpty ? nil : output
        case .invalidRepository:
            return "The specified directory does not contain a .git folder"
        case .timeout:
            return "The operation took too long to complete"
        case .gitNotFound:
            return "Please ensure Git is installed and accessible"
        case .invalidPath:
            return "The specified path does not exist or is not accessible"
        case .permissionDenied:
            return "Check file permissions for the repository"
        }
    }
}

// MARK: - GitCommand

/// Manages Git operations for repositories
final class GitCommand {
    
    // MARK: - Properties
    
    private let defaultTimeout: TimeInterval = 30.0
    private var validationCache: [String: Bool] = [:]
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    /// Gets the current branch name of a repository
    /// - Parameter path: The path to the Git repository
    /// - Returns: The current branch name
    /// - Throws: GitError if the operation fails
    func getCurrentBranch(at path: String) async throws -> String {
        try validateRepositoryPath(path)
        
        let output = try await execute("git branch --show-current", at: path)
        let branch = output.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle detached HEAD state or empty output
        if branch.isEmpty {
            // Try alternative command for older Git versions
            let alternativeOutput = try await execute("git rev-parse --abbrev-ref HEAD", at: path)
            let alternativeBranch = alternativeOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            return alternativeBranch.isEmpty ? "main" : alternativeBranch
        }
        
        return branch
    }
    
    /// Gets the status of a repository
    /// - Parameter path: The path to the Git repository
    /// - Returns: A GitStatus object representing the repository status
    /// - Throws: GitError if the operation fails
    func getStatus(at path: String) async throws -> GitStatus {
        try validateRepositoryPath(path)
        
        let output = try await execute("git status --porcelain", at: path)
        return parseGitStatusOutput(output)
    }
    
    /// Checks if a directory is a valid Git repository
    /// - Parameter path: The path to check
    /// - Returns: true if the path contains a valid Git repository
    static func isValidRepository(at path: String) -> Bool {
        let gitPath = URL(fileURLWithPath: path).appendingPathComponent(".git")
        var isDirectory: ObjCBool = false
        
        // Check if .git exists (as either file or directory)
        if FileManager.default.fileExists(atPath: gitPath.path, isDirectory: &isDirectory) {
            // .git can be a directory (normal repo) or a file (worktree)
            return true
        }
        
        return false
    }
    
    /// Gets the remote URL for the origin remote
    /// - Parameter path: The path to the Git repository
    /// - Returns: The remote URL if configured, nil otherwise
    /// - Throws: GitError if the operation fails (other than missing remote)
    func getRemoteURL(at path: String) async throws -> String? {
        try validateRepositoryPath(path)
        
        do {
            let output = try await execute("git remote get-url origin", at: path)
            let url = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return url.isEmpty ? nil : url
        } catch let error as GitError {
            // If the command failed because there's no remote, return nil
            if case .commandFailed(_, let output, _) = error,
               output.contains("No such remote") || output.contains("not a git repository") {
                return nil
            }
            throw error
        }
    }
    
    /// Clears the validation cache
    func clearCache() {
        validationCache.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func validateRepositoryPath(_ path: String) throws {
        // Check if path exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw GitError.invalidPath(path)
        }
        
        // Check if it's a directory
        guard isDirectory.boolValue else {
            throw GitError.invalidPath(path)
        }
        
        // Check if it's a valid repository (use cache for performance)
        if let cached = validationCache[path] {
            if !cached {
                throw GitError.invalidRepository(path: path)
            }
        } else {
            let isValid = Self.isValidRepository(at: path)
            validationCache[path] = isValid
            if !isValid {
                throw GitError.invalidRepository(path: path)
            }
        }
    }
    
    private func parseGitStatusOutput(_ output: String) -> GitStatus {
        var staged: [String] = []
        var modified: [String] = []
        var untracked: [String] = []
        
        let lines = output.components(separatedBy: .newlines)
        for line in lines where !line.isEmpty {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.count > 3 else { continue }
            
            let statusCode = String(trimmed.prefix(2))
            let fileName = String(trimmed.dropFirst(3))
            
            switch statusCode {
            case "A ", "AM", "AD":
                staged.append(fileName)
            case " M", "MM", "MD":
                modified.append(fileName)
            case "??":
                untracked.append(fileName)
            case "M ", "MA":
                staged.append(fileName)
            case "D ", "DA":
                staged.append(fileName)
            case " D":
                modified.append(fileName)
            case "R ", "RM":
                // Renamed files
                let parts = fileName.components(separatedBy: " -> ")
                staged.append(parts.last ?? fileName)
            case "C ", "CM":
                // Copied files
                staged.append(fileName)
            default:
                // Handle other cases as modified
                if !fileName.isEmpty {
                    modified.append(fileName)
                }
            }
        }
        
        return GitStatus(
            hasChanges: !staged.isEmpty || !modified.isEmpty || !untracked.isEmpty,
            stagedFiles: staged,
            modifiedFiles: modified,
            untrackedFiles: untracked
        )
    }
    
    private func execute(_ command: String, at path: String, timeout: TimeInterval? = nil) async throws -> String {
        let actualTimeout = timeout ?? defaultTimeout
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Start the command execution task
            group.addTask {
                try await self.executeCommand(command, at: path)
            }
            
            // Start the timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(actualTimeout * 1_000_000_000))
                throw GitError.timeout(command: command)
            }
            
            // Return the first result (either success or timeout)
            guard let result = try await group.next() else {
                throw GitError.commandFailed(command: command, output: "No output", exitCode: -1)
            }
            
            // Cancel remaining tasks
            group.cancelAll()
            
            return result
        }
    }
    
    private func executeCommand(_ command: String, at path: String) async throws -> String {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus == 0 {
            return output
        } else {
            let combinedOutput = errorOutput.isEmpty ? output : errorOutput
            throw GitError.commandFailed(
                command: command,
                output: combinedOutput,
                exitCode: process.terminationStatus
            )
        }
    }
}
import Foundation

struct GitStatus {
    let hasChanges: Bool
    let stagedFiles: [String]
    let modifiedFiles: [String]
    let untrackedFiles: [String]
}

class GitCommand {
    
    // MARK: - Public Methods
    
    func getCurrentBranch(at path: String) async throws -> String {
        let output = try await execute("git branch --show-current", at: path)
        let branch = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return branch.isEmpty ? "main" : branch
    }
    
    func getStatus(at path: String) async throws -> GitStatus {
        let output = try await execute("git status --porcelain", at: path)
        
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
            case "A ", "AM":
                staged.append(fileName)
            case " M", "MM":
                modified.append(fileName)
            case "??":
                untracked.append(fileName)
            default:
                break
            }
        }
        
        return GitStatus(
            hasChanges: !staged.isEmpty || !modified.isEmpty || !untracked.isEmpty,
            stagedFiles: staged,
            modifiedFiles: modified,
            untrackedFiles: untracked
        )
    }
    
    static func isValidRepository(at path: String) -> Bool {
        let gitPath = URL(fileURLWithPath: path).appendingPathComponent(".git").path
        return FileManager.default.fileExists(atPath: gitPath)
    }
    
    func getRemoteURL(at path: String) async throws -> String? {
        do {
            let output = try await execute("git remote get-url origin", at: path)
            let url = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return url.isEmpty ? nil : url
        } catch {
            // No remote configured
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func execute(_ command: String, at path: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                let process = Process()
                let pipe = Pipe()
                
                process.executableURL = URL(fileURLWithPath: "/bin/bash")
                process.arguments = ["-c", command]
                process.currentDirectoryURL = URL(fileURLWithPath: path)
                process.standardOutput = pipe
                process.standardError = pipe
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    
                    if process.terminationStatus == 0 {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(throwing: GitError.commandFailed(output))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum GitError: LocalizedError {
    case commandFailed(String)
    case invalidRepository
    
    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return "Git command failed: \(message)"
        case .invalidRepository:
            return "Not a valid Git repository"
        }
    }
}
import Foundation

/// Simple logger that respects the debugLogging user preference
enum Logger {
    static func debug(_ message: @autoclosure () -> String) {
        guard UserDefaults.standard.bool(forKey: "debugLogging") else { return }
        print("[GitPeek] \(message())")
    }

    static func error(_ message: @autoclosure () -> String) {
        print("[GitPeek] ERROR: \(message())")
    }
}

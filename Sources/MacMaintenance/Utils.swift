import Foundation

// MARK: - Utility Functions

enum Utils {
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    static func askForConfirmation(_ message: String) -> Bool {
        print("\(message) (y/n): ", terminator: "")
        fflush(stdout)

        guard let input = readLine()?.lowercased() else { return false }
        return input == "y" || input == "yes"
    }

    static func executeCommand(_ launchPath: String, arguments: [String]) -> (
        exitCode: Int32, output: String
    ) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: launchPath)
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()

            let output = String(data: data, encoding: .utf8) ?? ""
            return (task.terminationStatus, output)
        } catch {
            return (-1, "Error: \(error)")
        }
    }
}

// MARK: - Logging

struct Logger {
    private static let logDirectory = "\(NSHomeDirectory())/.mac-maintenance/logs"
    private static let logFile = "\(logDirectory)/maintenance.log"

    static func setup() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: logDirectory) {
            try? fileManager.createDirectory(
                atPath: logDirectory, withIntermediateDirectories: true)
        }
    }

    static func log(_ message: String, level: LogLevel = .info) {
        let timestamp = DateFormatter.localizedString(
            from: Date(), dateStyle: .short, timeStyle: .medium)
        let logMessage = "[\(timestamp)] [\(level.rawValue)] \(message)\n"

        // Print to console
        if level == .error {
            print("❌ \(message)")
        }

        // Write to file
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile) {
                if let fileHandle = FileHandle(forWritingAtPath: logFile) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: URL(fileURLWithPath: logFile))
            }
        }
    }

    enum LogLevel: String {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case success = "SUCCESS"
    }
}

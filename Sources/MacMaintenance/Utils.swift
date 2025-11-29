import Foundation

// Utility functions used across modules
func formatBytes(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [. useMB, .useGB]
    formatter.countStyle = . file
    return formatter.string(fromByteCount: bytes)
}

func askForConfirmation(_ message: String) -> Bool {
    print("\(message) (y/n): ", terminator: "")
    fflush(stdout)
    
    guard let input = readLine()?.lowercased() else { return false }
    return input == "y" || input == "yes"
}

func executeCommand(_ launchPath: String, arguments: [String]) -> (exitCode: Int32, output: String) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task. standardOutput = pipe
    task. standardError = pipe
    
    do {
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        let output = String(data: data, encoding: .utf8) ?? ""
        return (task. terminationStatus, output)
    } catch {
        return (-1, "Error: \(error)")
    }
}
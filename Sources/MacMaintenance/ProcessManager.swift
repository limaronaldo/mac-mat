import Foundation

enum ProcessManager {
    static func restartProcess(_ processName: String) {
        print("\n🔄 Attempting to restart \(processName)...\n")

        // Confirm with user
        print("⚠️  This will force-quit \(processName).Continue? (y/n): ", terminator: "")
        fflush(stdout)

        guard let input = readLine()?.lowercased(), input == "y" else {
            print("❌ Operation cancelled.\n")
            return
        }

        // Kill the process
        let killTask = Process()
        killTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killTask.arguments = [processName]

        do {
            try killTask.run()
            killTask.waitUntilExit()

            if killTask.terminationStatus == 0 {
                print("✅ Successfully killed \(processName)")
                Logger.log("Killed process: \(processName)", level: .success)

                // Give it a moment to respawn naturally
                sleep(2)
                print("✅ \(processName) should restart automatically\n")
            } else {
                print("❌ Failed to kill \(processName).It may not be running.\n")
                Logger.log("Failed to kill process: \(processName)", level: .warning)
            }
        } catch {
            print("❌ Error: \(error)\n")
            Logger.log("Error killing process \(processName): \(error)", level: .error)
        }
    }

    static func killProcess(byPID pid: Int32) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = ["-9", "\(pid)"]

        do {
            try task.run()
            task.waitUntilExit()
            Logger.log("Killed process with PID: \(pid)", level: .info)
        } catch {
            print("Error killing process: \(error)")
            Logger.log("Error killing PID \(pid): \(error)", level: .error)
        }
    }

    static func listProcessesByName(_ name: String) -> [Int32] {
        let (exitCode, output) = Utils.executeCommand("/usr/bin/pgrep", arguments: [name])

        guard exitCode == 0 else { return [] }

        return output.split(separator: "\n")
            .compactMap { Int32($0.trimmingCharacters(in: .whitespaces)) }
    }

    static func isProcessRunning(_ processName: String) -> Bool {
        return !listProcessesByName(processName).isEmpty
    }
}

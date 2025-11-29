import Foundation

enum ProcessManager {
    static func restartProcess(_ processName: String) {
        print("\n🔄 Attempting to restart \(processName).. .\n")
        
        // Confirm with user
        print("⚠️  This will force-quit \(processName). Continue? (y/n): ", terminator: "")
        fflush(stdout)
        
        guard let input = readLine()?.lowercased(), input == "y" else {
            print("❌ Operation cancelled.\n")
            return
        }
        
        // Kill the process
        let killTask = Process()
        killTask. launchPath = "/usr/bin/killall"
        killTask.arguments = [processName]
        
        do {
            try killTask.run()
            killTask.waitUntilExit()
            
            if killTask.terminationStatus == 0 {
                print("✅ Successfully killed \(processName)")
                
                // Give it a moment to respawn naturally
                sleep(2)
                print("✅ \(processName) should restart automatically\n")
            } else {
                print("❌ Failed to kill \(processName). It may not be running.\n")
            }
        } catch {
            print("❌ Error: \(error)\n")
        }
    }
    
    static func killProcess(byPID pid: Int32) {
        let task = Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(pid)"]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Error killing process: \(error)")
        }
    }
}
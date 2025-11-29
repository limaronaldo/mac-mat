import Foundation

enum SyncManager {
    static func pauseICloud() {
        print("\n⏸️  Pausing iCloud synchronization...\n")
        
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["unload", "-w", "~/Library/LaunchAgents/com.apple. bird.plist"]
        
        do {
            try task.run()
            task.waitUntilExit()
            print("✅ iCloud sync paused (may require restart)\n")
        } catch {
            print("❌ Error: \(error)\n")
        }
    }
    
    static func resumeICloud() {
        print("\n▶️  Resuming iCloud synchronization...\n")
        
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", "-w", "~/Library/LaunchAgents/com.apple.bird.plist"]
        
        do {
            try task.run()
            task.waitUntilExit()
            print("✅ iCloud sync resumed\n")
        } catch {
            print("❌ Error: \(error)\n")
        }
    }
}
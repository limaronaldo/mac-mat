import Foundation

enum SyncManager {
    static func pauseICloud() {
        print("\n⏸️  Pausing iCloud synchronization...\n")
        print("⚠️  Note: To fully pause iCloud, you may need to:\n")
        print("   1.Go to System Settings > Apple ID > iCloud\n")
        print("   2.Toggle off iCloud Drive temporarily\n\n")

        // Kill bird (iCloud sync daemon) temporarily
        if ProcessManager.isProcessRunning("bird") {
            print("Stopping iCloud sync daemon (bird)...")
            ProcessManager.restartProcess("bird")
            Logger.log("Paused iCloud by killing bird process", level: .info)
        } else {
            print("❌ iCloud sync daemon not running\n")
        }
    }

    static func resumeICloud() {
        print("\n▶️  Resuming iCloud synchronization...\n")
        print("iCloud will resume automatically.\n")
        print("If issues persist, restart from System Settings > Apple ID > iCloud\n")
        Logger.log("iCloud resume requested", level: .info)
    }

    static func showSyncStatus() {
        print("\n📊 File Sync Status\n")

        // Check iCloud status
        let iCloudPath = "\(NSHomeDirectory())/Library/Mobile Documents"
        if FileManager.default.fileExists(atPath: iCloudPath) {
            if let size = getDirectorySize(iCloudPath) {
                print("☁️  iCloud Drive: \(Utils.formatBytes(size))")
            }

            // Check if bird is running
            if ProcessManager.isProcessRunning("bird") {
                print("   Status: ✅ Active")
            } else {
                print("   Status: ⏸️  Paused/Not running")
            }
        }

        // Check Google Drive
        let googleDrivePath = "\(NSHomeDirectory())/Google Drive"
        if FileManager.default.fileExists(atPath: googleDrivePath) {
            if let size = getDirectorySize(googleDrivePath) {
                print("📁 Google Drive: \(Utils.formatBytes(size))")
            }
        }

        // Check Dropbox
        let dropboxPath = "\(NSHomeDirectory())/Dropbox"
        if FileManager.default.fileExists(atPath: dropboxPath) {
            if let size = getDirectorySize(dropboxPath) {
                print("📦 Dropbox: \(Utils.formatBytes(size))")
            }
        }

        print()
    }

    static func optimizeFileProvider() {
        print("\n🔧 Optimizing File Provider...\n")

        if Utils.askForConfirmation("This will restart the File Provider daemon.Continue?") {
            ProcessManager.restartProcess("fileproviderd")

            // Also restart cloudd (iCloud daemon)
            if ProcessManager.isProcessRunning("cloudd") {
                print("Restarting iCloud daemon...")
                ProcessManager.restartProcess("cloudd")
            }

            print("✅ File Provider optimization complete\n")
            Logger.log("File Provider optimized", level: .success)
        }
    }

    // MARK: - Private Helpers

    private static func getDirectorySize(_ path: String) -> Int64? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else { return nil }

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            var size: Int64 = 0

            for item in contents {
                let fullPath = (path as NSString).appendingPathComponent(item)
                let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                size += attributes[.size] as? Int64 ?? 0
            }

            return size
        } catch {
            return nil
        }
    }
}

import Foundation

enum CleanupManager {
    static func clearXcodeCache() {
        print("\n🧹 Clearing Xcode cache...\n")

        let derivedDataPath = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"
        let buildPath = "\(NSHomeDirectory())/Library/Developer/Xcode/Archives"

        // Get size before
        if let sizeBefore = getDirectorySize(derivedDataPath) {
            print("📊 Current DerivedData size: \(Utils.formatBytes(sizeBefore))")
        }

        // Confirm
        print("⚠️  This will delete Xcode DerivedData. Continue? (y/n): ", terminator: "")
        fflush(stdout)

        guard let input = readLine()?.lowercased(), input == "y" else {
            print("❌ Operation cancelled.\n")
            return
        }

        // Delete
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: derivedDataPath)
            print("✅ Successfully cleared \(derivedDataPath)\n")
        } catch {
            print("❌ Error clearing cache: \(error)\n")
        }
    }

    static func cleanupCaches() {
        print("\n🧹 Cleaning application caches...\n")

        let cachePaths = [
            "\(NSHomeDirectory())/.cache",
            "\(NSHomeDirectory())/Library/Caches",
        ]

        let fileManager = FileManager.default
        var totalSize: Int64 = 0

        for cachePath in cachePaths {
            guard fileManager.fileExists(atPath: cachePath) else { continue }

            if let size = getDirectorySize(cachePath) {
                print("📂 Cache: \(cachePath)")
                print("   Size: \(Utils.formatBytes(size))")
                totalSize += size
            }
        }

        print("\n💾 Total cache size: \(Utils.formatBytes(totalSize))")

        // Confirm
        print("\n⚠️  This will delete old cache files.Continue? (y/n): ", terminator: "")
        fflush(stdout)

        guard let input = readLine()?.lowercased(), input == "y" else {
            print("❌ Operation cancelled.\n")
            Logger.log("Cache cleanup cancelled by user", level: .info)
            return
        }

        // Clean caches (remove files older than 30 days)
        for cachePath in cachePaths {
            cleanOldCaches(in: cachePath, olderThan: 30)
        }

        print("✅ Cache cleanup complete\n")
        Logger.log(
            "Cache cleanup completed, freed approximately \(Utils.formatBytes(totalSize))",
            level: .success)
    }

    static func cleanBrowserCaches() {
        print("\n🧹 Cleaning browser caches...\n")

        let browserCaches = [
            ("Chrome", "\(NSHomeDirectory())/Library/Caches/Google/Chrome"),
            ("Safari", "\(NSHomeDirectory())/Library/Caches/com.apple.Safari"),
            ("Firefox", "\(NSHomeDirectory())/Library/Caches/Firefox"),
            ("Brave", "\(NSHomeDirectory())/Library/Caches/BraveSoftware/Brave-Browser"),
        ]

        var totalSize: Int64 = 0
        var foundCaches: [(String, String, Int64)] = []

        for (browser, path) in browserCaches {
            if let size = getDirectorySize(path) {
                print("🌐 \(browser): \(Utils.formatBytes(size))")
                foundCaches.append((browser, path, size))
                totalSize += size
            }
        }

        guard !foundCaches.isEmpty else {
            print("No browser caches found.\n")
            return
        }

        print("\n💾 Total: \(Utils.formatBytes(totalSize))")

        if Utils.askForConfirmation("⚠️  Delete browser caches?") {
            for (browser, path, _) in foundCaches {
                cleanOldCaches(in: path, olderThan: 7)
                print("✅ Cleaned \(browser) cache")
            }
            Logger.log(
                "Browser caches cleaned, freed approximately \(Utils.formatBytes(totalSize))",
                level: .success)
        } else {
            print("❌ Operation cancelled.\n")
        }
    }

    static func cleanDevelopmentCaches() {
        print("\n🧹 Cleaning development caches...\n")

        let devCaches = [
            ("Node modules", "\(NSHomeDirectory())/.npm"),
            ("Yarn cache", "\(NSHomeDirectory())/Library/Caches/Yarn"),
            ("Homebrew cache", "\(NSHomeDirectory())/Library/Caches/Homebrew"),
            ("pip cache", "\(NSHomeDirectory())/Library/Caches/pip"),
            ("CocoaPods", "\(NSHomeDirectory())/Library/Caches/CocoaPods"),
        ]

        var totalSize: Int64 = 0

        for (name, path) in devCaches {
            if let size = getDirectorySize(path) {
                print("📦 \(name): \(Utils.formatBytes(size))")
                totalSize += size
            }
        }

        print("\n💾 Total: \(Utils.formatBytes(totalSize))")

        if Utils.askForConfirmation("⚠️  Clean development caches?") {
            // Clean npm cache
            let _ = Utils.executeCommand(
                "/usr/local/bin/npm", arguments: ["cache", "clean", "--force"])

            // Clean yarn cache
            let _ = Utils.executeCommand("/usr/local/bin/yarn", arguments: ["cache", "clean"])

            // Clean homebrew cache
            let _ = Utils.executeCommand("/usr/local/bin/brew", arguments: ["cleanup", "-s"])

            print("✅ Development caches cleaned\n")
            Logger.log(
                "Development caches cleaned, freed approximately \(Utils.formatBytes(totalSize))",
                level: .success)
        } else {
            print("❌ Operation cancelled.\n")
        }
    }

    static func cleanLogs() {
        print("\n🧹 Cleaning system logs...\n")

        let logPaths = [
            "\(NSHomeDirectory())/Library/Logs",
            "/private/var/log",
        ]

        var totalSize: Int64 = 0

        for logPath in logPaths {
            if let size = getDirectorySize(logPath) {
                print("📝 \(logPath): \(Utils.formatBytes(size))")
                totalSize += size
            }
        }

        print("\n💾 Total log size: \(Utils.formatBytes(totalSize))")

        if Utils.askForConfirmation("⚠️  Delete logs older than 30 days?") {
            for logPath in logPaths {
                cleanOldCaches(in: logPath, olderThan: 30)
            }
            print("✅ Logs cleaned\n")
            Logger.log(
                "Logs cleaned, freed approximately \(Utils.formatBytes(totalSize))", level: .success
            )
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

    private static func cleanOldCaches(in path: String, olderThan days: Int) {
        let fileManager = FileManager.default
        let cutoffDate = Date().addingTimeInterval(TimeInterval(-days * 24 * 3600))

        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else { return }

        for item in contents {
            let fullPath = (path as NSString).appendingPathComponent(item)

            do {
                let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                if let modDate = attributes[.modificationDate] as? Date, modDate < cutoffDate {
                    try fileManager.removeItem(atPath: fullPath)
                    print("  ✅ Removed: \(item)")
                }
            } catch {
                // Skip files we can't access
            }
        }
    }

}

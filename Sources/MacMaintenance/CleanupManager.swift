import Foundation

enum CleanupManager {
    static func clearXcodeCache() {
        print("\n🧹 Clearing Xcode cache.. .\n")
        
        let derivedDataPath = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"
        let buildPath = "\(NSHomeDirectory())/Library/Developer/Xcode/Archives"
        
        // Get size before
        if let sizeBefore = getDirectorySize(derivedDataPath) {
            print("📊 Current DerivedData size: \(formatBytes(sizeBefore))")
        }
        
        // Confirm
        print("⚠️  This will delete Xcode DerivedData.  Continue? (y/n): ", terminator: "")
        fflush(stdout)
        
        guard let input = readLine()?.lowercased(), input == "y" else {
            print("❌ Operation cancelled.\n")
            return
        }
        
        // Delete
        let fileManager = FileManager.default
        do {
            try fileManager. removeItem(atPath: derivedDataPath)
            print("✅ Successfully cleared \(derivedDataPath)\n")
        } catch {
            print("❌ Error clearing cache: \(error)\n")
        }
    }
    
    static func cleanupCaches() {
        print("\n🧹 Cleaning application caches...\n")
        
        let cachePaths = [
            "\(NSHomeDirectory())/.cache",
            "\(NSHomeDirectory())/Library/Caches"
        ]
        
        let fileManager = FileManager.default
        
        for cachePath in cachePaths {
            guard fileManager.fileExists(atPath: cachePath) else { continue }
            
            if let size = getDirectorySize(cachePath) {
                print("📂 Cache: \(cachePath)")
                print("   Size: \(formatBytes(size))")
            }
        }
        
        // Confirm
        print("\n⚠️  This will delete old cache files. Continue? (y/n): ", terminator: "")
        fflush(stdout)
        
        guard let input = readLine()?.lowercased(), input == "y" else {
            print("❌ Operation cancelled.\n")
            return
        }
        
        // Clean caches (remove files older than 30 days)
        for cachePath in cachePaths {
            cleanOldCaches(in: cachePath, olderThan: 30)
        }
        
        print("✅ Cache cleanup complete\n")
    }
    
    // MARK: - Private Helpers
    
    private static func getDirectorySize(_ path: String) -> Int64?  {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else { return nil }
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            var size: Int64 = 0
            
            for item in contents {
                let fullPath = (path as NSString).appendingPathComponent(item)
                let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                size += attributes[. size] as? Int64 ?? 0
            }
            
            return size
        } catch {
            return nil
        }
    }
    
    private static func cleanOldCaches(in path: String, olderThan days: Int) {
        let fileManager = FileManager.default
        let cutoffDate = Date(). addingTimeInterval(TimeInterval(-days * 24 * 3600))
        
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
    
    private static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter. allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
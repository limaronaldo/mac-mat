import Foundation

enum ICloudRecovery {

    static func listRecentlyDeleted(sortBy: SortOption = .dateDeleted, filterBy: String? = nil) {
        print("\n🗑️  iCloud Drive - Recently Deleted Files\n")

        // Try multiple possible trash locations
        let possiblePaths = [
            "\(NSHomeDirectory())/Library/Mobile Documents/com~apple~CloudDocs/.Trash",
            "\(NSHomeDirectory())/Library/Mobile Documents/.Trash",
        ]

        var trashPath: String?
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                trashPath = path
                break
            }
        }

        guard let validTrashPath = trashPath else {
            print("❌ iCloud Drive Recently Deleted folder not found locally.")
            print("\n💡 This could mean:")
            print("   1. iCloud Drive isn't enabled on this Mac")
            print("   2. Your deleted files are on iCloud servers but not synced locally")
            print("   3. The Recently Deleted folder is empty\n")
            print("🌐 To recover files from iCloud.com:")
            print("   1. Go to https://icloud.com")
            print("   2. Sign in with your Apple ID")
            print("   3. Click on iCloud Drive")
            print("   4. Look for 'Recently Deleted' in the sidebar")
            print("   5. Select files and click 'Recover'\n")
            print("📱 Or from your iPhone/iPad:")
            print("   Files app → Browse → iCloud Drive → Recently Deleted\n")
            return
        }

        var deletedFiles: [(path: String, name: String, size: Int64, modified: Date)] = []

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: validTrashPath)

            for item in contents {
                let fullPath = (validTrashPath as NSString).appendingPathComponent(item)
                let attributes = try FileManager.default.attributesOfItem(atPath: fullPath)

                let size = attributes[.size] as? Int64 ?? 0
                let modifiedDate = attributes[.modificationDate] as? Date ?? Date()

                // Apply filter if specified
                if let filter = filterBy {
                    if !item.lowercased().contains(filter.lowercased()) {
                        continue
                    }
                }

                deletedFiles.append(
                    (path: fullPath, name: item, size: size, modified: modifiedDate))
            }

            // Sort files
            switch sortBy {
            case .dateDeleted:
                deletedFiles.sort { $0.modified > $1.modified }
            case .name:
                deletedFiles.sort { $0.name.lowercased() < $1.name.lowercased() }
            case .size:
                deletedFiles.sort { $0.size > $1.size }
            }

            // Display results
            if deletedFiles.isEmpty {
                if let filter = filterBy {
                    print("No files found matching '\(filter)'\n")
                } else {
                    print("✅ No deleted files found (Recently Deleted is empty)\n")
                }
                return
            }

            print("Found \(deletedFiles.count) deleted file(s)\n")
            print(String(format: "%-50s %12s %20s", "File Name", "Size", "Deleted"))
            print(String(repeating: "-", count: 85))

            for file in deletedFiles {
                let sizeStr = Utils.formatBytes(file.size)
                let dateStr = formatDate(file.modified)
                let displayName =
                    file.name.count > 48 ? String(file.name.prefix(45)) + "..." : file.name
                print(String(format: "%-50s %12s %20s", displayName, sizeStr, dateStr))
            }

            print("\n💡 Tips:")
            print("   • Use --filter to search for specific files")
            print("   • Use --sort to change sorting (name, size, date)")
            print("   • Use 'restore-icloud-files' to restore selected files\n")

            Logger.log("Listed \(deletedFiles.count) recently deleted iCloud files", level: .info)

        } catch {
            print("❌ Error reading Recently Deleted folder: \(error)\n")
            Logger.log("Error listing iCloud deleted files: \(error)", level: .error)
        }
    }

    static func restoreFile(fileName: String) {
        print("\n♻️  Restoring iCloud file: \(fileName)\n")

        let trashPath = "\(NSHomeDirectory())/Library/Mobile Documents/com~apple~CloudDocs/.Trash"
        let sourceFile = (trashPath as NSString).appendingPathComponent(fileName)
        let iCloudPath = "\(NSHomeDirectory())/Library/Mobile Documents/com~apple~CloudDocs"
        let destinationFile = (iCloudPath as NSString).appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: sourceFile) else {
            print("❌ File not found in Recently Deleted: \(fileName)\n")
            return
        }

        do {
            // Check if destination already exists
            if FileManager.default.fileExists(atPath: destinationFile) {
                print("⚠️  A file with this name already exists in iCloud Drive.")
                if !Utils.askForConfirmation("Overwrite existing file?") {
                    print("❌ Restore cancelled.\n")
                    return
                }
                try FileManager.default.removeItem(atPath: destinationFile)
            }

            try FileManager.default.moveItem(atPath: sourceFile, toPath: destinationFile)
            print("✅ File restored to iCloud Drive: \(fileName)\n")
            Logger.log("Restored iCloud file: \(fileName)", level: .success)

        } catch {
            print("❌ Error restoring file: \(error)\n")
            Logger.log("Error restoring iCloud file \(fileName): \(error)", level: .error)
        }
    }

    static func restoreAll(filterBy: String? = nil) {
        print("\n♻️  Restoring iCloud files...\n")

        let trashPath = "\(NSHomeDirectory())/Library/Mobile Documents/com~apple~CloudDocs/.Trash"

        guard FileManager.default.fileExists(atPath: trashPath) else {
            print("❌ iCloud Drive Recently Deleted folder not found.\n")
            return
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: trashPath)
            var filesToRestore: [String] = []

            for item in contents {
                if let filter = filterBy {
                    if item.lowercased().contains(filter.lowercased()) {
                        filesToRestore.append(item)
                    }
                } else {
                    filesToRestore.append(item)
                }
            }

            if filesToRestore.isEmpty {
                if let filter = filterBy {
                    print("No files found matching '\(filter)'\n")
                } else {
                    print("No files to restore.\n")
                }
                return
            }

            print("Found \(filesToRestore.count) file(s) to restore")
            if let filter = filterBy {
                print("Filter: '\(filter)'")
            }
            print()

            if !Utils.askForConfirmation("Restore all \(filesToRestore.count) file(s)?") {
                print("❌ Restore cancelled.\n")
                return
            }

            var successCount = 0
            var failCount = 0

            for fileName in filesToRestore {
                let sourceFile = (trashPath as NSString).appendingPathComponent(fileName)
                let iCloudPath = "\(NSHomeDirectory())/Library/Mobile Documents/com~apple~CloudDocs"
                let destinationFile = (iCloudPath as NSString).appendingPathComponent(fileName)

                do {
                    // Skip if destination exists
                    if FileManager.default.fileExists(atPath: destinationFile) {
                        print("⚠️  Skipped (already exists): \(fileName)")
                        failCount += 1
                        continue
                    }

                    try FileManager.default.moveItem(atPath: sourceFile, toPath: destinationFile)
                    print("✅ Restored: \(fileName)")
                    successCount += 1

                } catch {
                    print("❌ Failed: \(fileName) - \(error.localizedDescription)")
                    failCount += 1
                }
            }

            print("\n📊 Summary:")
            print("   ✅ Successfully restored: \(successCount)")
            print("   ❌ Failed/Skipped: \(failCount)")
            print()

            Logger.log(
                "Restored \(successCount) iCloud files (failed: \(failCount))", level: .success)

        } catch {
            print("❌ Error: \(error)\n")
            Logger.log("Error during bulk restore: \(error)", level: .error)
        }
    }

    static func openInFinder() {
        let trashPath = "\(NSHomeDirectory())/Library/Mobile Documents/com~apple~CloudDocs/.Trash"

        if FileManager.default.fileExists(atPath: trashPath) {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            task.arguments = [trashPath]

            do {
                try task.run()
                print("✅ Opened iCloud Recently Deleted folder in Finder\n")
            } catch {
                print("❌ Error opening folder: \(error)\n")
            }
        } else {
            print("❌ iCloud Drive Recently Deleted folder not found.\n")
        }
    }

    // MARK: - Helper Methods

    enum SortOption {
        case dateDeleted
        case name
        case size
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

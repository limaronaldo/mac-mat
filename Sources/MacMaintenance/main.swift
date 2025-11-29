import Foundation


enum MacMaintenance {
    static func run() {
        // Initialize logger
        Logger.setup()

        let arguments = CommandLine.arguments

        // Remove the program name from arguments
        let command = arguments.count > 1 ? arguments[1] : "help"
        let args = arguments.count > 2 ? Array(arguments.dropFirst(2)) : []

        switch command {
        case "status":
            SystemMonitor.showStatus()

        case "top-processes":
            SystemMonitor.showTopProcesses()

        case "menu":
            showMainMenu()

        case "restart-process":
            if args.isEmpty {
                print("❌ Usage: mac-maint restart-process <process-name>")
                exit(1)
            }
            ProcessManager.restartProcess(args[0])

        case "clear-xcode-cache":
            CleanupManager.clearXcodeCache()

        case "cleanup-caches":
            CleanupManager.cleanupCaches()

        case "pause-icloud":
            SyncManager.pauseICloud()

        case "resume-icloud":
            SyncManager.resumeICloud()

        case "sync-status":
            SyncManager.showSyncStatus()

        case "optimize-fileprovider":
            SyncManager.optimizeFileProvider()

        case "clean-browser-cache":
            CleanupManager.cleanBrowserCaches()

        case "clean-dev-cache":
            CleanupManager.cleanDevelopmentCaches()

        case "clean-logs":
            CleanupManager.cleanLogs()

        case "config":
            Config.printConfig()

        case "help", "-h", "--help":
            showHelp()

        default:
            print("❌ Unknown command: \(command)")
            showHelp()
            exit(1)
        }
    }

    static func showHelp() {
        print("""
        🔧 MacBook Maintenance Tool

        USAGE:
            mac-maint <command> [options]

        SYSTEM MONITORING:
            status              Show system status (CPU, RAM, disk, battery, uptime)
            top-processes       List top CPU-consuming processes
            sync-status         Show file sync status (iCloud, Google Drive, Dropbox)

        PROCESS MANAGEMENT:
            restart-process     Restart a specific process
            optimize-fileprovider   Restart fileproviderd and cloudd

        CLEANUP:
            clear-xcode-cache   Clear Xcode derived data
            cleanup-caches      Clean application caches
            clean-browser-cache Clean browser caches (Chrome, Safari, Firefox, Brave)
            clean-dev-cache     Clean development caches (npm, yarn, brew, pip)
            clean-logs          Clean system logs

        SYNC MANAGEMENT:
            pause-icloud        Pause iCloud synchronization
            resume-icloud       Resume iCloud synchronization

        OTHER:
            menu                Interactive maintenance menu
            config              Show current configuration
            help                Show this help message

        EXAMPLES:
            mac-maint status
            mac-maint top-processes
            mac-maint restart-process Dock
            mac-maint clear-xcode-cache
            mac-maint clean-browser-cache
            mac-maint optimize-fileprovider

        LOGS:
            Logs are stored in: ~/.mac-maintenance/logs/maintenance.log

        CONFIG:
            Config file: ~/.mac-maintenance/config.json

        For more information, visit: https://github.com/limaronaldo/mac-mat
        """)
    }

    static func showMainMenu() {
        print("\n╔════════════════════════════════════════╗")
        print("║   MacBook Maintenance Menu             ║")
        print("╚════════════════════════════════════════╝\n")

        let menuItems = [
            ("1", "Show System Status"),
            ("2", "View Top Processes"),
            ("3", "Restart Problematic Process"),
            ("4", "Clear Xcode Cache"),
            ("5", "Cleanup Caches"),
            ("6", "Pause iCloud"),
            ("7", "Resume iCloud"),
            ("0", "Exit")
        ]

        for (key, description) in menuItems {
            print("  [\(key)] \(description)")
        }

        print("\nEnter your choice: ", terminator: "")
        fflush(stdout)

        guard let input = readLine() else { return }

        switch input.trimmingCharacters(in: .whitespaces) {
        case "1":
            SystemMonitor.showStatus()
            showMainMenu()
        case "2":
            SystemMonitor.showTopProcesses()
            showMainMenu()
        case "3":
            print("Enter process name: ", terminator: "")
            fflush(stdout)
            if let processName = readLine() {
                ProcessManager.restartProcess(processName)
            }
            showMainMenu()
        case "4":
            CleanupManager.clearXcodeCache()
            showMainMenu()
        case "5":
            CleanupManager.cleanupCaches()
            showMainMenu()
        case "6":
            SyncManager.pauseICloud()
            showMainMenu()
        case "7":
            SyncManager.resumeICloud()
            showMainMenu()
        case "0":
            print("✅ Goodbye!\n")
            exit(0)
        default:
            print("❌ Invalid choice.Try again.\n")
            showMainMenu()
        }
    }
}
// Entry point
MacMaintenance.run()

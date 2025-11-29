import Foundation

@main
enum MacMaintenance {
    static func main() {
        let arguments = CommandLine.arguments
        
        // Remove the program name from arguments
        let command = arguments.count > 1 ? arguments[1] : "help"
        let args = arguments.count > 2 ? Array(arguments. dropFirst(2)) : []
        
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
        
        COMMANDS:
            status              Show system status (CPU, RAM, disk usage)
            top-processes       List top CPU-consuming processes
            menu                Interactive maintenance menu
            restart-process     Restart a specific process
            clear-xcode-cache   Clear Xcode derived data
            cleanup-caches      Clean application caches
            pause-icloud        Pause iCloud synchronization
            resume-icloud       Resume iCloud synchronization
            help                Show this help message
        
        EXAMPLES:
            mac-maint status
            mac-maint top-processes
            mac-maint restart-process Dock
            mac-maint clear-xcode-cache
        
        For more information, visit: https://github.com/limaronaldo/macbook-maintenance
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
        
        switch input.trimmingCharacters(in: . whitespaces) {
        case "1":
            SystemMonitor. showStatus()
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
            SyncManager. resumeICloud()
            showMainMenu()
        case "0":
            print("✅ Goodbye!\n")
            exit(0)
        default:
            print("❌ Invalid choice. Try again.\n")
            showMainMenu()
        }
    }
}
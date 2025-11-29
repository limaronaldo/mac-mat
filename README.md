# 🔧 MacBook Maintenance Tool

A comprehensive macOS maintenance toolkit written in Swift and shell scripts to help keep your MacBook optimized, organized, and healthy.

## Features

- **System Monitoring**: Monitor CPU, RAM, disk usage, and process health
- **One-Click Maintenance**: Quick actions for common maintenance tasks
- **Safe Automation**: Built with safeguards—no dangerous auto-deletion outside your home folder
- **Hybrid Approach**: Swift for the main tool, shell scripts for quick utilities
- **Process Management**: Monitor and restart problematic processes (Dock, Finder, coredns, etc.)
- **Cleanup Tools**: Clear caches, derived data, and unnecessary files safely
- **File Synchronization Management**: Handle iCloud Drive and Google Drive optimization

## What's Inside

```
macbook-maintenance/
├── README.md
├── Package.swift                    # Swift Package manifest
├── Sources/
│   └── MacMaintenance/
│       ├── main.swift               # Entry point
│       ├── SystemMonitor.swift      # CPU, RAM, disk monitoring
│       ├── ProcessManager.swift     # Process control and restart
│       ├── CleanupManager.swift     # Safe cleanup operations
│       ├── SyncManager.swift        # File sync optimization
│       └── Utils.swift              # Helper functions
├── Scripts/
│   ├── quick-cleanup.sh             # Quick shell-based cleanup
│   ├── reset-spotlight.sh           # Spotlight index reset
│   ├── restart-fileprovider.sh      # Safe fileprovider restart
│   ├── show-top-processes.sh        # Display CPU hogs
│   └── brew-maintenance.sh          # Homebrew cleanup and updates
├── . gitignore
└── LICENSE
```

## Installation

### Prerequisites
- macOS 12.0 or later
- Swift 5.5+
- Xcode Command Line Tools (for Swift compilation)

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/limaronaldo/macbook-maintenance.git
cd macbook-maintenance

# Build the project
swift build -c release

# Make shell scripts executable
chmod +x Scripts/*. sh

# Optional: Link to /usr/local/bin for easy access
ln -s $(pwd)/. build/release/MacMaintenance /usr/local/bin/mac-maint
```

## Usage

### Main Swift Tool

```bash
# Show system status
mac-maint status

# List top CPU-consuming processes
mac-maint top-processes

# Show menu of maintenance options
mac-maint menu

# Perform specific actions
mac-maint restart-process Dock
mac-maint clear-xcode-cache
mac-maint cleanup-caches
```

### Shell Scripts (Quick Actions)

```bash
# Quick cleanup
./Scripts/quick-cleanup.sh

# Reset Spotlight index
./Scripts/reset-spotlight.sh

# Restart fileprovider safely
./Scripts/restart-fileprovider.sh

# Show top processes
./Scripts/show-top-processes.sh

# Homebrew maintenance
./Scripts/brew-maintenance.sh
```

## Features Breakdown

### 🎯 System Monitoring
- Real-time CPU and RAM usage
- Disk space overview
- Process activity tracking
- System temperature monitoring (if available)

### 🔄 Process Management
- Monitor problematic processes (fileproviderd, coredns, etc.)
- Safe restart of system processes (Dock, Finder, etc.)
- Kill unresponsive applications
- Automatic alerts for CPU spike detection

### 🧹 Cleanup Operations
- Clear application caches (~Library/Caches)
- Remove Xcode DerivedData
- Clean temporary files
- Safe browser cache cleanup
- Log file management

### 📁 File Sync Optimization
- Monitor iCloud Drive and Google Drive activity
- Pause/resume sync services safely
- Check sync queue status
- Optimize big dev folders

## Safety Features

✅ **What This Tool Does Safely:**
- Only operates within your home directory (`/Users/username`)
- Asks for confirmation before destructive operations
- Creates backups of important config files before cleanup
- Never modifies system files outside the home folder
- All operations are logged to `~/.mac-maintenance/logs/`

❌ **What This Tool Will NOT Do:**
- Delete system files outside `/Users/` or `/Applications`
- Modify `/System` or `/Library` (Apple's system directories)
- Auto-delete without confirmation
- Run with sudo by default (manual elevation for risky operations)

## Examples

### Example 1: Quick System Check
```bash
mac-maint status
```

Output:
```
╔════════════════════════════════════════╗
║      MacBook Maintenance Status        ║
╚════════════════════════════════════════╝

💻 CPU Usage: 34. 2%
🧠 RAM Usage: 12.4 GB / 16 GB (77. 5%)
💾 Disk Usage: 245.6 GB / 500 GB (49.1%)

⚠️  Top 3 CPU Hogs:
  1. fileproviderd - 18.5%
  2. coredns - 8.2%
  3. Google Chrome - 7.1%
```

### Example 2: Restart Problematic Process
```bash
mac-maint restart-process fileproviderd
```

### Example 3: Cleanup Xcode
```bash
mac-maint clear-xcode-cache
# Frees: 12.4 GB
# Ask for confirmation before deletion
```

## Troubleshooting

### "Permission denied" errors
Some operations may require elevated privileges. The tool will prompt you for your password when needed.

### fileproviderd using too much CPU? 
1. Pause iCloud Drive temporarily: `mac-maint pause-icloud`
2. Run Spotlight reset: `./Scripts/reset-spotlight.sh`
3. Restart fileprovider: `./Scripts/restart-fileprovider.sh`

### Still having issues?
Check the logs:
```bash
tail -f ~/. mac-maintenance/logs/maintenance.log
```

## Configuration

Create `~/.mac-maintenance/config. yaml` for custom settings:

```yaml
# Cleanup settings
cleanup:
  auto_backup: true
  confirm_before_delete: true
  max_cache_age_days: 30

# Monitoring thresholds
monitoring:
  cpu_alert_threshold: 80
  ram_alert_threshold: 85
  disk_alert_threshold: 90

# Process management
processes_to_monitor:
  - fileproviderd
  - coredns
  - mdworker
```

## Development

### Building from Source

```bash
# Development build
swift build

# Release build (optimized)
swift build -c release

# Run tests
swift test

# Generate documentation
swift package generate-documentation
```

### Project Structure Notes

- **Sources/MacMaintenance/**: Main Swift implementation
- **Scripts/**: Shell scripts for quick CLI actions
- **Tests/**: Unit tests for Swift code (to be added)
- **.gitignore**: Excludes build artifacts and sensitive files

## Contributing

This is a personal maintenance tool, but you're welcome to:
- Report issues you find
- Suggest new features
- Improve existing scripts
- Optimize performance

## License

MIT License - Feel free to use, modify, and distribute

## Disclaimer

⚠️ **Important**: While this tool is designed with safety in mind, always:
1. Back up important data before running cleanup operations
2. Read confirmation prompts carefully
3. Test on non-critical files first
4. Keep this tool updated

This tool calls existing Apple utilities (mdutil, fileproviderctl, launchctl) but does not modify system-level code. Always review what operations will do before confirming.

## Resources

- [Apple System Management](https://developer.apple.com/documentation/)
- [launchctl documentation](https://ss64.com/osx/launchctl. html)
- [macOS process management](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/)
- [Swift on macOS](https://swift.org)

---

**Last Updated**: November 2025  
**Maintainer**: limaronaldo
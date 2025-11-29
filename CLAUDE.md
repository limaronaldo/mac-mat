# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

**mac-mat** (MacBook Maintenance Tool) is a comprehensive macOS maintenance toolkit written in Swift. It helps keep your MacBook optimized, organized, and healthy through system monitoring, process management, cleanup operations, and iCloud file recovery.

## Project Structure

```
mac-mat/
├── Package.swift                    # Swift Package manifest
├── Sources/MacMaintenance/
│   ├── main.swift                   # Entry point and command routing
│   ├── SystemMonitor.swift          # CPU, RAM, disk, battery monitoring
│   ├── ProcessManager.swift         # Process control and restart
│   ├── CleanupManager.swift         # Cache and file cleanup operations
│   ├── SyncManager.swift            # iCloud/sync optimization
│   ├── ICloudRecovery.swift         # iCloud Recently Deleted file recovery
│   ├── Config.swift                 # JSON configuration management
│   └── Utils.swift                  # Shared utilities and logging
├── Scripts/
│   ├── quick-cleanup.sh             # Quick shell-based cleanup
│   ├── reset-spotlight.sh           # Spotlight index reset
│   ├── restart-fileprovider.sh      # FileProvider daemon restart
│   ├── show-top-processes.sh        # Display CPU hogs
│   └── brew-maintenance.sh          # Homebrew cleanup
└── README.md                        # Full documentation
```

## Technology Stack

- **Language**: Swift 5.5+
- **Platform**: macOS 12.0+
- **Build System**: Swift Package Manager
- **Dependencies**: None (pure Swift/Foundation)

## Key Features

### System Monitoring
- Real-time CPU, RAM, disk usage
- Battery status and charging state
- System uptime tracking
- Top process identification

### Process Management
- Safe restart of system processes (Dock, Finder, etc.)
- Process monitoring and health checks
- PID lookup by process name
- Automatic daemon management

### Cleanup Operations
- Xcode DerivedData clearing
- Application cache cleanup
- Browser cache removal (Chrome, Safari, Firefox, Brave)
- Development cache cleanup (npm, yarn, Homebrew, pip, CocoaPods)
- System log management
- Age-based file filtering (default 30 days)

### iCloud Recovery
- List files in iCloud Recently Deleted
- Restore individual files by name
- Bulk restore all deleted files
- Open trash folder in Finder
- Works with locally synced iCloud files

### Sync Management
- Monitor iCloud Drive, Google Drive, Dropbox status
- Optimize FileProvider daemon
- Pause/resume iCloud synchronization
- Show sync queue status

### Configuration System
- JSON-based config file: `~/.mac-maintenance/config.json`
- Configurable alert thresholds (CPU, RAM, disk)
- Customizable cleanup settings
- Process monitoring lists

### Logging System
- File-based logging: `~/.mac-maintenance/logs/maintenance.log`
- Log levels: INFO, WARN, ERROR, SUCCESS
- All operations logged with timestamps

## Building & Running

```bash
# Development build
swift build

# Release build (optimized)
swift build -c release

# Run directly
.build/debug/mac-maint <command>

# Install for easy access
ln -s $(pwd)/.build/release/mac-maint /usr/local/bin/mac-maint
```

## Common Commands

```bash
# System monitoring
mac-maint status                    # Show system status
mac-maint top-processes             # List CPU hogs
mac-maint sync-status               # Show file sync status

# Process management
mac-maint restart-process Dock      # Restart a process
mac-maint optimize-fileprovider     # Fix FileProvider issues

# Cleanup
mac-maint clear-xcode-cache         # Clear Xcode cache
mac-maint cleanup-caches            # Clean app caches
mac-maint clean-browser-cache       # Clean browser caches
mac-maint clean-dev-cache           # Clean dev tool caches
mac-maint clean-logs                # Clean system logs

# iCloud Recovery
mac-maint list-icloud-deleted       # List deleted files
mac-maint restore-icloud-file name  # Restore specific file
mac-maint restore-all-icloud        # Restore all files
mac-maint open-icloud-trash         # Open trash in Finder

# Configuration
mac-maint config                    # Show current config
mac-maint menu                      # Interactive menu
```

## Important Implementation Details

### API Usage
- Uses modern Swift Process API (`executableURL` instead of deprecated `launchPath`)
- All utilities organized in `Utils` enum for namespace management
- FileManager operations confined to home directory for safety

### Safety Features
- Only operates within user's home directory (`~/`)
- Asks for confirmation before destructive operations
- Never modifies system files outside `/Users/`
- All operations logged for audit trail
- Automatic backup prompts for critical operations

### iCloud Recovery Limitations
The `list-icloud-deleted` command works with **locally synced** iCloud files only. Files stored on iCloud servers but not downloaded to the Mac won't appear. In such cases:
1. Files must be recovered via iCloud.com web interface
2. Or enable Desktop & Documents sync to download files locally first
3. The tool provides helpful guidance when files aren't found locally

### Code Organization
- Each module is self-contained (enum-based namespacing)
- Shared utilities in `Utils.swift`
- Logger is globally available via `Logger.log()`
- Configuration loaded lazily via `Config.shared`

## Development Guidelines

When adding new features:
1. Add command case in `main.swift` switch statement
2. Update `showHelp()` with new command documentation
3. Use `Logger.log()` for operation tracking
4. Use `Utils.askForConfirmation()` for destructive operations
5. Handle errors gracefully with user-friendly messages
6. Test with `swift build` before committing

## Git Repository

- **GitHub**: https://github.com/limaronaldo/mac-mat
- **License**: MIT
- **Maintainer**: limaronaldo

## Related Documentation

- [Swift Process Documentation](https://developer.apple.com/documentation/foundation/process)
- [FileManager Documentation](https://developer.apple.com/documentation/foundation/filemanager)
- [macOS System Management](https://developer.apple.com/documentation/)

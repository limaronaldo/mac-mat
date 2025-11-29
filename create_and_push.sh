#!/usr/bin/env bash
#
# create_and_push.sh
#
# Creates a local macOS-maintenance project, populates it with files (Swift + shell scripts),
# initializes a git repository, and uses the GitHub CLI (gh) to create the remote repo and push.
#
# Requirements:
#  - Git installed
#  - GitHub CLI (gh) installed and authenticated (run: gh auth login)
#  - Optional: sudo for some scripts that call sudo when executed later
#
# Usage:
#  ./create_and_push.sh
#
# The script will ask for the target repository name (owner/repo) and visibility (public/private).
# It will create a directory named after the repository (repo part) in the current working directory.
#

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ The GitHub CLI (gh) is required but not found in PATH."
  echo "   Install it and authenticate (gh auth login) and re-run this script."
  exit 1
fi

read -r -p "Target repository (owner/repo) [default: limaronaldo/mac-mat]: " REPO_INPUT
REPO_INPUT=${REPO_INPUT:-limaronaldo/mac-mat}
REPO="$REPO_INPUT"

read -r -p "Visibility (public/private) [default: public]: " VIS
VIS=${VIS:-public}
if [[ "$VIS" != "public" && "$VIS" != "private" ]]; then
  echo "Invalid visibility. Use 'public' or 'private'."
  exit 1
fi

# Extract repo name for local folder
REPO_NAME="${REPO##*/}"
TARGET_DIR="./${REPO_NAME}"

if [[ -d "$TARGET_DIR" ]]; then
  echo "Directory $TARGET_DIR already exists. Please remove it or run this script from another directory."
  exit 1
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo "Creating project files in $(pwd)..."

# README.md
cat > README.md <<'EOF'
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
├── .gitignore
└── LICENSE

## Installation

### Prerequisites
- macOS 12.0 or later
- Swift 5.5+
- Xcode Command Line Tools (for Swift compilation)

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/<owner>/<repo>.git
cd <repo>

# Build the project
swift build -c release

# Make shell scripts executable
chmod +x Scripts/*.sh

# Optional: Link to /usr/local/bin for easy access
sudo ln -s "$(pwd)/.build/release/mac-maint" /usr/local/bin/mac-maint
#!/bin/bash

# Homebrew Maintenance Script
# Updates packages and cleans up

echo "🍺 Homebrew Maintenance"
echo ""

# Check if Homebrew is installed
if !  command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed"
    exit 1
fi

echo "📦 Updating Homebrew..."
brew update
echo "✅ Homebrew updated"

echo ""
echo "📦 Upgrading packages..."
brew upgrade
echo "✅ Packages upgraded"

echo ""
echo "🧹 Cleaning up..."
brew cleanup
echo "✅ Cleanup complete"

echo ""
echo "📊 Disk space freed:"
du -sh ~/Library/Caches/Homebrew
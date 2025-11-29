#!/bin/bash

# Safely Restart File Provider
# Use this when iCloud/Google Drive is using too much CPU

echo "🔄 Restarting file provider daemon..."
echo ""

# Kill fileprovider processes
killall -9 fileproviderd 2>/dev/null
echo "✅ Stopped fileproviderd"

# Kill sync services
killall -9 bird 2>/dev/null
echo "✅ Stopped iCloud daemon"

# Wait for restart
echo "⏳ Waiting for services to restart (5 seconds)..."
sleep 5

echo "✅ File provider restarted"
echo ""
echo "💡 If the problem persists:"
echo "   1.  Pause iCloud Drive in System Preferences"
echo "   2. Run: ./reset-spotlight.sh"
echo "   3. Resume iCloud Drive"
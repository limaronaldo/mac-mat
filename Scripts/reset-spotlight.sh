#!/bin/bash

# Reset Spotlight Index
# This can help with performance and search issues

echo "🔍 Resetting Spotlight index..."
echo ""
echo "⚠️  This will take a few minutes and restart Spotlight."
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# Disable and re-enable Spotlight
sudo mdutil -a -i off
echo "⏳ Waiting for Spotlight to stop..."
sleep 3

sudo mdutil -a -i on
echo "✅ Spotlight index reset"
echo "⏳ Spotlight is now re-indexing your Mac..."
echo ""
echo "💡 Tip: You can monitor progress with: log stream --predicate 'process == \"mdworker\"' --level debug"
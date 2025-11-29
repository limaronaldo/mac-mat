#!/bin/bash

# Quick macOS Cleanup Script
# This script performs safe, common cleanup tasks

echo "🧹 Starting quick cleanup..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Empty Trash
echo -e "${YELLOW}Emptying trash...${NC}"
rm -rf ~/. Trash/*
echo -e "${GREEN}✅ Trash emptied${NC}"

# Clear DNS cache
echo -e "${YELLOW}Clearing DNS cache...${NC}"
sudo dscacheutil -flushcache
echo -e "${GREEN}✅ DNS cache cleared${NC}"

# Clear browser cache (Chrome)
if [ -d "$HOME/Library/Application Support/Google/Chrome/Default/Cache" ]; then
    echo -e "${YELLOW}Clearing Chrome cache...${NC}"
    rm -rf "$HOME/Library/Application Support/Google/Chrome/Default/Cache"
    echo -e "${GREEN}✅ Chrome cache cleared${NC}"
fi

# Remove old log files
echo -e "${YELLOW}Removing old log files...${NC}"
find $HOME/Library/Logs -type f -mtime +30 -delete 2>/dev/null
echo -e "${GREEN}✅ Old logs cleaned${NC}"

# Clear temporary files
echo -e "${YELLOW}Clearing temp files...${NC}"
rm -rf /var/tmp/*
rm -rf /tmp/*
echo -e "${GREEN}✅ Temp files cleared${NC}"

echo ""
echo -e "${GREEN}✅ Cleanup complete!${NC}"
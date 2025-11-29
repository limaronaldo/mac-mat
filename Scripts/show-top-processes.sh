#!/bin/bash

# Show Top CPU-Consuming Processes

echo "📊 Top CPU-consuming processes:"
echo ""
ps aux | head -1
ps aux | sort -nrk 3,3 | head -15 | awk '{printf "%-15s %6s%% %8s MB\n", $1, $3, int($6/1024)}'
echo ""
echo "To monitor in real-time: top"
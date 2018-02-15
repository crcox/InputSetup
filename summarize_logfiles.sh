#!/bin/bash
TIMEAWK=$(which summarize_time.awk)
MEMAWK=$(which summarize_memory.awk)
DISKAWK=$(which summarize_disk.awk)
LOGFILES=$(find ./ -maxdepth 2 -type f -name "process.log")

grep "Total Remote Usage" $LOGFILES|\
  sed 's/[\t ]\+/,/g'|\
  awk -f $TIMEAWK
echo ""
grep "Memory (MB)" $LOGFILES|\
  tr -d ':' |\
  sed 's/[\t ]\+/,/g'|\
  awk -f $MEMAWK
echo ""
grep "Disk (KB)" $LOGFILES|\
  tr -d ':' |\
  sed 's/[\t ]\+/,/g'|\
  awk -f $DISKAWK

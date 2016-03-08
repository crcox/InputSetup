#!/bin/bash

function usage() {
  echo "usage: $0 [-h|--help] [status]"
  echo "  status can be idle, running, failed, done, held, loading, or unloading."
}

STATUS=$1
case $STATUS in
"-h"|"--help")
  usage
  exit 0
  ;;
"idle")
  STATUS_ID=1
  ;;
"running")
  STATUS_ID=2
  ;;
"failed")
  STATUS_ID=3
  ;;
"done")
  STATUS_ID=4
  ;;
"held")
  STATUS_ID=5
  ;;
"loading")
  STATUS_ID=6
  ;;
"unloading")
  STATUS_ID=7
  ;;
"")
  STATUS_ID=0
  ;;
*)
  echo "Error: Invalid status code."
  echo ""
  usage
  exit 1
  ;;
esac

if [ $STATUS_ID -gt 0 ]; then
  condor_q -submitter $USER \
    -format "%d." ClusterId \
    -format "%d\n" ProcId  \
    -constraint "( JobStatus == $STATUS_ID )"
else
  condor_q -submitter $USER \
    -format "%d." ClusterId \
    -format "%d\n" ProcId
fi

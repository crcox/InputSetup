#!/bin/bash

function usage() {
  echo "usage: sudo $0 [-h|--help] [node] [nickname]"
  echo "  node can be either submit-3 or submit-5"
  echo "  submit-5 is the default if none are specified."
  echo "  nickname is a short-hand that can be given to ssh to reference the full address."
  echo "  If nickname is not specified, it will default to the node name."
}

NODE=$1
case $NODE in
  "-h"|"--help")
    usage
    exit 0
    ;;
  "submit-3")
    ip=128.104.100.44
    url="submit-3.chtc.wisc.edu"
    ;;
  "submit-5"|"")
    ip=128.104.101.92
    url="submit-5.chtc.wisc.edu"
    ;;
  *)
    echo "Error: Unknown submit node: $NODE"
    echo ""
    usage
    exit 1
    ;;
esac

if [ -n "$2" ]; then
  NICK=$2
else
  NICK=$NODE
fi

if [ ! $EUID -eq 0 ]
then
  echo ""
  echo "ERROR: This program needs to be run as a super user with sudo."
  usage
  exit;
fi

if grep -n --color=always ${ip} /etc/hosts
then
  echo "Warning:"
  echo "${ip} already exists in /etc/hosts"
  echo ""
  echo "file not modified"
else
  printf "%s %s %s\n" ${ip} ${url} ${NICK} >> /etc/hosts
  echo "Added ${ip} ${url} ${NICK} to /etc/hosts"
  echo "You can now connect to $NODE with:"
  echo "  ssh <user>@$NICK"
fi

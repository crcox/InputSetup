#!/bin/bash
ip=128.104.100.44
url=submit-3.chtc.wisc.edu
key=chtc

if [ ! $EUID -eq 0 ]
then
  echo ""
  echo "ERROR: This program needs to be run as a super user with sudo."
  echo "usage: sudo ./addCHTCtoHostsList.sh"
  exit;
fi

if grep -n --color=always ${ip} /etc/hosts
then
  echo "Warning:"
  echo "${ip} already exists in /etc/hosts"
  echo ""
  echo "file not modified"
else
  printf "\n# CHTC\n%s %s %s\n" ${ip} ${url} ${key} >> /etc/hosts
  echo "Added ${ip} ${url} ${key} to /etc/hosts"
fi

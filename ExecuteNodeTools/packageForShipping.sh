#!/bin/bash

dirs=`find ./ -type d -maxdepth 1 ! \( -name "*.git" -o -name "." \)`
for dir in ${dirs}
do
  name=${dir#./}.tgz
  tar czvf $name $dir
done

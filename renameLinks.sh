#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "usage: $0 <initial pattern> <final pattern> <files>"
	exit -1
fi

from="$1"
to="$2"
shift 2
for i
do
  a=$(readlink "$i") && ln -sf "$(echo $a | sed "s@$from@$to@")" "$i"
done

#use like:
# renameLinks V4 V5 Summer16_25nsV4_MC_*

#based on:
# http://stackoverflow.com/questions/11456588/is-there-a-simple-way-to-batch-rename-symlink-targets
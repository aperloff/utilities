#!/bin/bash

export DEPTH=1
while getopts d option
do
    case "${option}"
    in
    d) DEPTH=${OPTARG};;
    esac
done

for t in files links directories; do echo `find . -maxdepth ${DEPTH} -type ${t:0:1} | wc -l` $t; done 2> /dev/null
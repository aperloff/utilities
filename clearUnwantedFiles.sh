#!/bin/bash

export DEPTH=1
while getopts d option
do
    case "${option}"
    in
    d) DEPTH=${OPTARG};;
    esac
done

if [ -z "$1" ]; then
    LOCATION=$PWD
else
    LOCATION=${1}
fi

declare -a types=( "txt" "C" "hh" "cc" "py" "sh" "csh" "cfg" "xml" "jdl" "pbs" )
for type in "${types[@]}" ; do
    find "${LOCATION}" -type f -name "*.${type}~" -exec rm -f '{}' ';'
done

declare -a patterns=( ".pbs.o" ".pbs.e" )
for pattern in "${patterns[@]}" ; do
    find "${LOCATION}" -type f -name "*${pattern}*" -exec rm -f '{}' ';'
done

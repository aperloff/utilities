#!/bin/bash

usage()
{
cat <<EOF
usage: $0 options

This script will remove a select set of backup files (*.<extension>~) and PBS output files.

OPTIONS:
   -h      Show this message
   -d      Depth for the find command (default=1)
   -l      Location to remove the files (default=$PWD)
EOF
}

DEPTH=1
LOCATION=$PWD
while getopts "hd:l:" OPTION; do
    case "$OPTION" in
	h)  usage
	    exit 1
	    ;;
	d)  DEPTH=$OPTARG
	    ;;
	l)  LOCATION=${OPTARG}
	    ;;
	\?)
            echo "Invalid option: -$OPTARG" >&2
	    usage
            exit 2
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 3
            ;;
    esac
done

declare -a types=( "txt" "C" "hh" "cc" "py" "sh" "csh" "cfg" "xml" "jdl" "pbs" )
for type in "${types[@]}" ; do
    find "${LOCATION}" -type f -name "*.${type}~" -exec rm -f '{}' ';'
done

declare -a patterns=( ".pbs.o" ".pbs.e" )
for pattern in "${patterns[@]}" ; do
    find "${LOCATION}" -type f -name "*${pattern}*" -exec rm -f '{}' ';'
done

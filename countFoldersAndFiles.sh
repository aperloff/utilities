#!/bin/bash

usage()
{
cat <<EOF
usage: $0 options

This script will count the number of files, links, and directories starting from the durrent directory

OPTIONS:
   -h      Show this message
   -d      Depth for the find command (default=1)
EOF
}

export DEPTH=1
while getopts hd: option; do
    case "${option}" in
    	h)  usage
		    exit 1
		    ;;
	    d)  DEPTH=${OPTARG}
			echo ${DEPTH}
			;;
		\?) echo "Invalid option: -$OPTARG" >&2
	    	usage
            exit 2
            ;;
        :)  echo "Option -$OPTARG requires an argument." >&2
            exit 3
            ;;
    esac
done

for t in files links directories; do echo `find . -maxdepth ${DEPTH} -type ${t:0:1} | wc -l` $t; done 2> /dev/null
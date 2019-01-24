#!/bin/bash

function join_by { local IFS="$1"; shift; echo "$*"; }

usage()
{
cat <<EOF
usage: $0 [options] <file(s)/folder(s)>

This script will tar up a set of files/folders and include a progress bar.

OPTIONS:
   -f      A space separated list of files and folders (not implemented yet)
   -h      Show this message
   -n      The name of the output file
   -z      Use the gzip command to compress the result (default=false)
EOF
}

#while getopts "f:hn:z" OPTION; do
while getopts "hn:z" OPTION; do
    case "$OPTION" in
#    f)  files_folders=$OPTARG
#        ;;
    h)  usage
        exit 1
        ;;
    n)  NAME=$OPTARG
        NAMESET=true
        ;;
    z)  GZIP=true
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

shift $(($OPTIND - 1))
files_folders=( "$@" )
files_folders_string=$( join_by " " "${files_folders[@]}" )

if [ "$NAMESET" != "true" ]; then
    NAME="tarp_output.tar"
fi

if [ -n "$GZIP" ]; then
    if [ "${NAME##*.}" != "gz" ]; then
        NAME=${NAME}.gz
    fi
    tar cfP - ${files_folders_string} | pv -s $(($(du -sk ${files_folders_string} | awk 'BEGIN{sum=0}{sum=sum+$1}END{print sum}') * 1024)) | gzip > ${NAME}
else
    tar cfP - ${files_folders_string} | pv -s $(($(du -sk ${files_folders_string} | awk 'BEGIN{sum=0}{sum=sum+$1}END{print sum}') * 1024)) > ${NAME}
fi

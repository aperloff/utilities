#!/bin/bash

usage()
{
cat <<EOF
usage: $0 options

This script will delete all files older than a certain number of days and matching a given pattern.

OPTIONS:
	-h      Show this message
	-d      The number of days to go back before deleting files. Use +DAYS to delete older files and -DAYS to delete files from today.
	-n      Name of the files (can include wildcards)
	-p      Path to the files
	-t      Test the file selection before removing
	-v      Verbose
EOF
}

while getopts :hd:n:p:tv OPTION
do
	case $OPTION in
		h)
			 usage
			 exit 1
			 ;;
		d)
			DAYS=$OPTARG
			;;
		n)
			PATTERN=$OPTARG
			;;
		p)
			FINDPATH=$OPTARG
			;;
		v)
			VERBOSE=true
			;;
		t)
			TEST=true
			echo -e "The selected files will be printed without being deleted\n"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	 esac
done

if [ -z "$DAYS" ] ; then
	echo "Missing required argument -d"
	exit 1
fi

if [ -z "$FINDPATH" ] ; then
	if [ "$VERBOSE" = true ] ; then
		echo "Missing option -p"
		echo "    Setting the find path to \"./\""
	fi
	FINDPATH="./"
fi

if [ -z "$PATTERN" ] ; then
	if [ "$VERBOSE" = true ] ; then 
		echo "Missing option -n"
		echo "    Setting the filenames to find to \"*\""
	fi
	PATTERN="*"
fi

echo ""

#example
#find ./*.pdf -mtime +3 -exec rm {} \;
if [ -n "$TEST" ] ; then
	find $FINDPATH -type f -name "$PATTERN" -mtime $DAYS
else
	find $FINDPATH -type f -name "$PATTERN" -mtime $DAYS -exec rm {} \;
fi

#for positional arguments
#ARG1=${@:$OPTIND:1}
#ARG2=${@:$OPTIND+1:1}

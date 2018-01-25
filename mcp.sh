#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script will copy a set of files with wildcards and replace a specified set of characters with a new set of characters.

Example: mcp -f batchInputJetCorrectionAnalyzer\?_0.txt -n 1.txt -o 0.txt -d

This will copy the set of files with "_0.txt" at the end of the filename to an identical set of files with "_1.txt" at the end of the filename.

OPTIONS:
   -d      Debug
   -h      Show this message
   -f      The original file names with the wildcard included (be sure to escape the wildcards)
   -n      The new set of characters (i.e. the new set)
   -o      The set of characters to be replaced (i.e. the old set)
EOF
}

DEBUG=false

while getopts dh?f:n:o: OPTION
do
     case $OPTION in
         d)
             DEBUG=true
             ;;
         h|\?)
             usage
             exit 1
             ;;
         f)
			 IFILES=$OPTARG
             ;;
         n)
			 NEWCHAR=$OPTARG
             ;;
         o)
			 OLDCHAR=$OPTARG
             ;;
     esac
done

if [ "$DEBUG" = true ]
then
	echo "The input file string is \"$IFILES\""
	echo "The old set of characters is \"$OLDCHAR\""
	echo "The new set of characters is \"$NEWCHAR\""
	for file in $IFILES; do echo cp "$file" "${file/$OLDCHAR/$NEWCHAR}";done
else
	for file in $IFILES; do cp "$file" "${file/$OLDCHAR/$NEWCHAR}";done
fi

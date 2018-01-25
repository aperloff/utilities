#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script will copy the directory structure of one folder to another folder.

OPTIONS:
   -h      Show this message
   -s      The absolute path to the source folder
   -d      The absolute path to the destination folder
   -f      Copy the sh and jdl files as well
   -v      Verbose
EOF
}

while getopts “hs:d:fv” OPTION
do
     case $OPTION in
         h|\?)
             usage
             exit 1
             ;;
         s)
			 if [[ "$1" = /* ]]
			 then
				 source=$OPTARG
			 else
				 source=$PWD/$OPTARG
			 fi
             ;;
         d)
			 if [[ "$1" = /* ]]
             then
                 destination=$OPTARG
             else
                 destination=$PWD/$OPTARG
             fi
             ;;
		 f)
			 files=true
			 ;;
         v)
             VERBOSE=" -print "
             ;;
		 :)
			 echo "Option -$OPTARG requires an argument." >&2
			 exit 1
			 ;;
     esac
done

if [ -z "$source" ]
then
	echo -e "\nsource is empty"
	exit 1
else
	echo -e "\nsource = $source"
fi
if [ -z "$destination" ]
then
	echo -e "\ndestination is empy"
	exit 1
else
	echo -e "\ndestination = $destination"
fi

cd $source &&
find . -type d $VERBOSE -exec mkdir -p -- $destination/{} \;

if [ $files ]
then
	find . -type f -name "*.jdl" $VERBOSE -exec cp {} $destination/{} \;
	find . -type f -name "*.sh" $VERBOSE -exec cp {} $destination/{} \;
fi 

echo -e "\nDONE\n"


#You could do something like:
#find . -type d >dirs.txt
#to create the list of directories, then
#xargs mkdir -p <dirs.txt
#to create the directories on the destination.

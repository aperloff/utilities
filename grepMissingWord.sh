#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script will show all of the files which are missing a specific word. The user can specify a specific directory to search in or use their current directory.

OPTIONS:
   -d      The directory the user would like to search
   -f      The shared part of the file names you want to search (include the wildcards)
   -h      Show this message
   -r      Search the given directory recursively
   -v      Verbose
   -w      The word or phrase to look for
EOF
}

search_dir=$PWD
recursive=false
search_word=()
file_subset=""
VERBOSE=0

while getopts ?d:f:hrvw:? OPTION
do
     case $OPTION in
     	 d)
			 unset search_dir
			 search_dir=$OPTARG
			 ;;
		 f)
			 unset file_subset
			 file_subset=$OPTARG
			 ;;
         h|\?)
             usage
             exit 1
             ;;
         r)
			 unset recursive
			 recursive=true
             ;;
         v)
			 unset VERBOSE
             VERBOSE=1
             ;;
         w)
			 unset search_word
			 count=0
			 for i in $OPTARG; do
				 search_word[$((count++))]=$i
			 done
			 ;;
		 :)
      		 echo "Option -$OPTARG requires an argument." >&2
      		 exit 1
      		 ;;
     esac
done

if [ VERBOSE ]
then
	echo "***************************"
	echo "*      INPUT OPTIONS      *"
	echo "***************************"
	echo "search_dir  = $search_dir"
	echo "file_subset = $file_subset"
	echo -n "search_word = "
	for i in ${search_word[@]}; do
		echo -n "$i "
	done
	echo
	echo -e "recursive   = $recursive\n\n"
fi

if [ -z "$search_word" ]
then
	echo "ERROR::Variable \"search_word\" is empty." >&2
	echo -e "       Enter a word using the \"-w\" option." >&2
	exit 1
fi

command="grep -nL "
if ( "$recursive" )
then
	command="$command -r \""
fi

for i in ${search_word[@]}; do
	if [ "$i" == "${search_word[0]}" ]; then
		command="$command$i"
	else
		command="$command $i"
	fi
done

command="$command\" $search_dir/$file_subset"

echo "***************************"
echo "*         COMMAND         *"
echo "***************************"
echo -e "$command\n\n"

echo "***************************"
echo "*         RESULTS         *"
echo "***************************"
eval $command

#Example
#grep -rnL "Finished" ../log/SingleEl_Full_Subset/CondorME_SingleEl_Full_Subset_3332797-*.brazos.tamu.edu.stdout




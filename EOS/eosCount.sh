#!/bin/bash

usage()
{
cat <<EOF
usage: $0 [options] <path>

This script will find and count all of the files starting from a given EOS path.
The path must be provided as the first positional argument after the names options.
By default files with the words "failed" and "log" in the path name are skipped. 

OPTIONS:
	-e      The extension of the files to search for (defaul=".root")
	-h      Show this message
	-l      List the files rather than counting them
EOF
}

extension=".root"
while getopts e:hl OPTION
do
	case $OPTION in
		e)
			if [[ ${OPTARG:0:1} == "." ]]; then
				extension=${OPTARG}
			else
				echo "The extension must start with a \".\""
				exit 1
			fi
			;;
		h)
			usage
			exit 2
			;;
		l)
			list="true"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 3
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 4
			;;
	 esac
done
PARG1=${@:$OPTIND:1}
#PARG2=${@:$OPTIND+1:1}

if [[ ${PARG1:0:7} != "/store/" ]]; then
	echo "The <path> must start with \"/store/\""
	exit 5
fi

cmd="eos root://cmseos.fnal.gov/ find ${PARG1}"

words_to_skip=( "failed" "log")
for word in ${words_to_skip[@]}; do
	cmd+=" | grep -v ${word}"
done

cmd+=" | grep -F ${extension}"

if [[ "$list" != true ]]; then
	cmd+=" | wc -l"
fi

eval $cmd

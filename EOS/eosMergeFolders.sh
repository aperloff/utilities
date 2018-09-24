#!/bin/bash


#for file in `eosls /store/user/aperloff/tmp/tmp2/`; do eos root://cmseos.fnal.gov/ mv /store/user/aperloff/tmp/tmp2/${file} /store/user/aperloff/tmp/tmp1/${file}; done
#success: renamed '/store/user/aperloff/tmp/tmp2/fastjet-3.3.0.tar.gz' to '/store/user/aperloff/tmp/tmp1/fastjet-3.3.0.tar.gz'

usage()
{
cat <<EOF
usage: $0 [options] <folder1> <folder2>

This script will merge the files from <folder1> into <folder2>.
By defult <folder1> will then be removed

OPTIONS:
	-c      Clean-up/remove <folder1> after the move (default=false)
	-d      Do a dry-run and don't actually move files (default=false)
	-h      Show this message
	-r      Rename <folder2> after the merge (use the full path from \`/store/\`)
	-v      Prints the command line options for debugging purposes (verbose)
EOF
}

clean="false"
dryrun="false"
rename=""
verbose="false"
while getopts cdhr:v OPTION
do
	case $OPTION in
		c)
			clean="true"
			;;
		d)
			dryrun="true"
			;;
		h)
			usage
			exit -1
			;;
		r)
			rename=$OPTARG
			;;
		v)
			verbose="true"
			;;	
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit -2
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit -3
			;;
	 esac
done
PARG1=${@:$OPTIND:1}
PARG2=${@:$OPTIND+1:1}

if [[ "$verbose" != false ]]; then
	echo "clean=${clean}"
	echo "dryrun=${dryrun}"
	echo "rename=${rename}"
	echo "PARG1=${PARG1}"
	echo "PARG2=${PARG2}"
fi

if [[ ${PARG1:0:7} != "/store/" ]]; then
	echo "The <folder1> must start with \"/store/\""
	exit -4
fi
if [[ ${PARG2:0:7} != "/store/" ]]; then
	echo "The <folder2> must start with \"/store/\""
	exit -5
fi
if [[ "$rename" != "" ]]; then
	if [[ ${rename:0:7} != "/store/" ]]; then
		echo "The new name for <folder2> must start with \"/store/\""
		exit -6
	fi
fi

list=`eos root://cmseos.fnal.gov/ ls ${PARG1}`
if [[ "$dryrun" != false ]]; then
	if [[ "$rename" != "" ]]; then
		echo "Will rename ${PARG1} as ${rename} after the merge"
	fi
	for file in $list; do
		echo "Moving ${PARG1}/${file} to ${PARG2}/${file}"
	done
	exit 1
fi

for file in $list; do
	eos root://cmseos.fnal.gov/ mv ${PARG1}/${file} ${PARG2}/${file}
done

if [[ "$clean" != false ]]; then
	eos root://cmseos.fnal.gov rm -r ${PARG1}
	if [[ $? -eq 0 ]]; then
		echo "Success: removed '${PARG1}'"
	else
		echo "Failure: unable to remove '${PARG1}'"
	fi
fi

if [[ "$rename" != "" ]]; then
	eos root://cmseos.fnal.gov mv ${PARG2} ${rename}
fi

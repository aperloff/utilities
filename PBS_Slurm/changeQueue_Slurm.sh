#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script will show the current queue status for a selection of users.

OPTIONS:
   -d      Destination partition where the jobs will end up
   -h      Show this message
   -s      Source partition where the pending jobs now reside
   -t      The new walltime to set
   -u      Username with the jobs you want to modify
   -v      Verbose
EOF
}

while getopts d:hs:t:u:v OPTION
do
     case $OPTION in
		 d)
			 DESTINATION=$OPTARG
			 ;;
         h|\?)
             usage
             exit 1
             ;;
         s)
			 SOURCE=$OPTARG
             ;;
		 t)
			 TIME=$OPTARG
			 ;;
         u)
			 USERNAME=$OPTARG
             ;;
         v)
             VERBOSE=1
             ;;
     esac
done

if [ -z "$SOURCE" ]; then
	echo "You must specify a source partition using the -s option."
	exit 1
elif [ -z "$DESTINATION" ]; then
	echo "You must specify a destination partition using the -d option."
	exit 1
fi

if [ -z "$USERNAME" ]; then
	USERNAME=$USER
fi

echo "Settings:"
echo "---------"
echo | awk -v I=${USERNAME} -v S=$SOURCE -v D=$DESTINATION -v T=$TIME 'BEGIN { format = "\t%-21s = %-25s\n" } { printf format, "username",I} { printf format, "source partition",S} { printf format, "destination partition",D } { printf format, "new walltime",T}'

for jobid in `squeue -u $USERNAME -t PENDING -p $SOURCE -o '%A' --noheader`; do
	if [ -z "$TIME" ]; then
		scontrol update job=$jobid partition=$DESTINATION qos=grid time=$TIME;
	else
		scontrol update job=$jobid partition=$DESTINATION;
	fi
done
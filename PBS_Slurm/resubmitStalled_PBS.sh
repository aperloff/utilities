#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script will show the current queue status for a selection of users.

OPTIONS:
   -h      Show this message
   -p      Specify the PBS script for the qsub action
   -q      Queues to check, can be any queue on the Brazos Cluster
   -t      Show what the program will do without actually killing or resubmitting any jobs
   -u      Usernames that you would like to check on
   -v      Verbose
EOF
}

names=(aperloff)
queues=(bgsc bgscrt short)
test=false

while getopts œôòühtq:u:p:vœôòı OPTION
do
     case $OPTION in
         h|\?)
             usage
             exit 1
             ;;
		 t)
			 unset test
			 test=true
			 ;;
         q)
			 unset queues
			 count=0
			 for i in $OPTARG; do
				 queues[$((count++))]=$i
			 done
             ;;
         u)
			 unset names
			 count=0
			 for i in $OPTARG; do
				 names[$((count++))]=$i
			 done
             ;;
		 p)
			 #PBSscript="CondorLauncher_ZJets.pbs"
			 PBSscript=$OPTARG
			 ;;
         v)
             VERBOSE=1
             ;;
     esac
done

jobs=`qstat -u aperloff | grep " grid " | grep " S " | awk '{print $1}' | awk 'BEGIN{FS="."}{ print $1 }'`
index=0
njobs=`echo $jobs | wc -w`

for j in ${jobs[@]}; do
	index=$(($index + 1))
	echo "Job $j ($index of $njobs) is stalled and is being deleted"

	if [ "$test" = false ] ; then
		`qdel $j`
	fi

	resubList="$resubList$j,"
#	all=`qstat | grep -w $j | wc -l`
#	q=`qstat | grep -w $j | grep ' Q ' | wc -l`
#	s=`qstat | grep -w $j | grep ' S ' | wc -l`
#	r=`qstat | grep -w $j | grep ' R ' | wc -l`
#	echo | awk -v ALL=$all -v Q=$q -v S=$s -v R=$r -v N="All users" 'BEGIN { format = "\t%-12s: %-7s %-7s %-7s %s\n"
#                                                                             printf "\t%-12s  %-7s %-7s %-7s %s\n", "User", "All", "Queued", "Stalled", "Running" 
#                                                                             printf "\t%-12s  %-7s %-7s %-7s %s\n", "----", "---", "------", "-------", "-------" }
#                                                                     { printf format, N, ALL, Q, S, R }'
done

if [ "$test" = false ] && [ -n "$PBSscript" ] ; then
    `qsub -t resubList PBSscript`
fi
resubList=${resubList%","}
echo $resubList
#	echo -e "\n"

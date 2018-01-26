#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script will show the current queue status for a selection of users.

OPTIONS:
   -h      Show this message
   -q      Queues to check, can be any queue on the Brazos Cluster
   -u      Usernames that you would like to check on
   -v      Verbose
EOF
}

names=(aperloff goodell rjmhrj tatarinov willhf isuarez jkroe daniel.cruz vaikunth pakhotin zqhong anthony.rose georgemm01 hogenshp whiteran16 spock136)
queues=(hepx hepxrt hepxshort grid gridrt bgsc bgscrt short)

while getopts œôòühq:u:vœôòı OPTION
do
     case $OPTION in
         h|\?)
             usage
             exit 1
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
         v)
             VERBOSE=1
             ;;
     esac
done

for j in ${queues[@]}; do
	echo "Queue: $j"

	all=`qstat | grep -w $j | wc -l`
	q=`qstat | grep -w $j | grep ' Q ' | wc -l`
	s=`qstat | grep -w $j | grep ' S ' | wc -l`
	r=`qstat | grep -w $j | grep ' R ' | wc -l`
	#echo -e "\t[All users] jobs in $j: $all $q $s $r" #V1 style
	echo | awk -v ALL=$all -v Q=$q -v S=$s -v R=$r -v N="All users" 'BEGIN { format = "\t%-12s: %-7s %-7s %-7s %s\n"
                                                                             printf "\t%-12s  %-7s %-7s %-7s %s\n", "User", "All", "Queued", "Stalled", "Running" 
                                                                             printf "\t%-12s  %-7s %-7s %-7s %s\n", "----", "---", "------", "-------", "-------" }
                                                                     { printf format, N, ALL, Q, S, R }'

	for i in ${names[@]}; do		
		all=`qstat | grep -w $j | grep $i | wc -l`
		q=`qstat -u $i $j | grep ' Q ' | wc -l`
		s=`qstat -u $i $j | grep ' S ' | grep -v ' S Time' | wc -l`
		r=`qstat -u $i $j | grep ' R ' | wc -l`
		#echo -e "\t[${i}]  jobs in $j: $all $q $s $r" #V1 style
		echo | awk -v I=${i} -v ALL=$all -v Q=$q -v S=$s -v R=$r 'BEGIN { format = "\t%-12s: %-7s %-7s %-7s %s\n"}
                                                                  { printf format, I, ALL, Q, S, R }'
	done

	echo -e "\n"
done
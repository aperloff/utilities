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

names=(aperloff goodell rjmhrj tatarinov isuarez jkroe daniel.cruz vaikunth pakhotin zqhong anthony.rose georgemm01 whiteran16 spock136 pwinslow armarotta taohuang hra288)
queues=(stakeholder stakeholder-4g background background-4g serial serial-long)

while getopts ‘¡°hq:u:v‘¡± OPTION
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

	all=`squeue | grep -w $j | wc -l`
	q=`squeue -p $j | grep ' PD ' | wc -l`
	s=`squeue -p $j | grep ' S ' | wc -l`
	r=`squeue -p $j | grep ' R ' | wc -l`
	echo | awk -v ALL=$all -v Q=$q -v S=$s -v R=$r -v N="All users" 'BEGIN { format = "\t%-12s: %-7s %-7s %-7s %s\n"
                                                                             printf "\t%-12s  %-7s %-7s %-7s %s\n", "User", "All", "Queued", "Stalled", "Running" 
                                                                             printf "\t%-12s  %-7s %-7s %-7s %s\n", "----", "---", "------", "-------", "-------" }
                                                                     { printf format, N, ALL, Q, S, R }'

	format="%.7i %.15P %.8j %.8u %.2t %.10M %.6D %R"

	for i in ${names[@]}; do		
		all=`squeue | grep -w $j | grep $i | wc -l`
		q=`squeue --format "$format" -u $i | grep -E "\<$j\>([^-]|\s)" | grep ' PD ' | wc -l`
		s=`squeue --format "$format" -u $i | grep -E "\<$j\>([^-]|\s)" | grep ' S ' | grep -v ' S Time' | wc -l`
		r=`squeue --format "$format" -u $i | grep -E "\<$j\>([^-]|\s)" | grep ' R ' | wc -l`
		echo | awk -v I=${i} -v ALL=$all -v Q=$q -v S=$s -v R=$r 'BEGIN { format = "\t%-12s: %-7s %-7s %-7s %s\n"}
                                                                  { printf format, I, ALL, Q, S, R }'
	done

	echo -e "\n"
done
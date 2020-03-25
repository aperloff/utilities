#!/bin/bash

case $1 in
1)
	ssh -Y -t correlator1.fnal.gov "cd /home/aperloff/; source setup_2016.4.csh; tcsh"
	;;
2)
	ssh -Y -t correlator2.fnal.gov "cd /data/aperloff/; bash" 
	;;
*)
	echo "Specify \"1\" for correlator1.fnal.gov or \"2\" for correlator2.fnal.gov"
	;;
esac

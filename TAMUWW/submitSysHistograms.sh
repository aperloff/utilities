#!/bin/sh

subLimHist=/uscms/home/aperloff/Scripts/submitLimitHistograms.sh

## declare an array variable
declare -a arr=( "CSVWeightSysDown" "CSVWeightSysUp" "PUWeightSysDown" "PUWeightSysUp" "QCDEtaWeightDown" "QCDEtaWeightUp" "TopPtWeightSysDown" "TopPtWeightSysUp" )

## now loop through the above array
for d in "${arr[@]}" ; do
	cd "$d/"
    "$subLimHist"
	cd ../
done

echo "All 48 jobs submitted (attempted)"

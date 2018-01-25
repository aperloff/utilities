#!/bin/bash

declare -A cmssw_rel=(["424"]="CMSSW_4_2_4" \
                      ["442"]="CMSSW_4_4_2_patch8" \
                      ["523"]="CMSSW_5_2_3_patch4" \
                      ["525"]="CMSSW_5_2_5" \
                      ["532CVS"]="CMSSW_5_3_2_patch4_CVS" \
                      ["532"]="CMSSW_5_3_2_patch4" \
                      ["5322"]="CMSSW_5_3_22_patch1" \
                      ["62016"]="CMSSW_6_2_0_SLHC16_patch1" \
                      ["62016dev"]="CMSSW_6_2_0_SLHC16_patch1_dev" \
                      ["620"]="CMSSW_6_2_0_SLHC23_patch1" \
                      ["720"]="CMSSW_7_2_0_pre5" \
                      ["722"]="CMSSW_7_2_2_patch1" \
                      ["733"]="CMSSW_7_3_3" \
                      ["733puppi"]="CMSSW_7_3_3_testPUPPI" \
                      ["740"]="CMSSW_7_4_0_pre9" \
                      ["741"]="CMSSW_7_4_1" \
                      ["746"]="CMSSW_7_4_6_patch2" \
                      ["760"]="CMSSW_7_6_0_pre2" \
                      ["763"]="CMSSW_7_6_3" \
                      ["801"]="CMSSW_8_0_1" \
                      ["8020"]="CMSSW_8_0_20" \
                      ["810p9"]="CMSSW_8_1_0_pre9" \
                      ["900p4"]="CMSSW_9_0_0_pre4" \
                      ["91XIB"]="CMSSW_9_1_X_2017-04-12-1100")

# CMSSW VERSION
if [ $1 ]
then
    chupK=$1
else
    export format="\t%-29s\t%-6s\n"
    printf "Which CMSSW release do you want to setup? (Default = CMSSW_8_1_0_pre9)\n"
    printf "\t%-29s\t%-4s\n" "CMSSW Releases" "Code"
    printf "\t%-29s\t%-4s\n" "--------------" "----"
    for code in "${!cmssw_rel[@]}"; do 
        printf "$format" "${cmssw_rel[$code]}" "$code"; 
    done | 
    sort -n -k3
    read chupK
fi

export search_paths=(/home/aperloff/JEC/ /home/aperloff/fdata/OldCMSSWReleases/JEC/)

if [ -n "${cmssw_rel[$chupK] + 1}" ]; then
    echo "$chupK --> ${cmssw_rel[$chupK]}"
    export found_dir=false
    for dir in "${search_paths[@]}"; do
        export cmssw_dir="$dir/${cmssw_rel[$chupK]}/src/"
        if [ -d "$cmssw_dir" ]; then
            cd $cmssw_dir
            cmsenv
            found_dir=true
            break
        fi
    done
    if [[ "$found_dir" = false ]] ; then
        echo 'Could not find the directory corresponding to the release ${cmssw_rel[$chupK]}!'
    fi
else
    echo "Couldn't find the CMSSW release corresponding to code $chupK"
fi

# CRAB SOURCE
export CRAB_SOURCE=/cvmfs/cms.cern.ch/crab3/crab.sh
source $CRAB_SOURCE

echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH

proxy=`voms-proxy-info -exists -valid 8:00`
if [[ $? -ne 0 ]]
then
    voms-proxy-init -voms cms -valid 192:00
fi

echo "Go to /fdata/hepx/store/user/aperloff/JEC/? (y/n)"
read FDATA
if [ $FDATA == y ]
then
    cd /fdata/hepx/store/user/aperloff/JEC/
fi

#sometimes CVSROOT needs to be set to:
#:ext:username@cmssw.cvs.cern.ch:/local/reps/CMSSW
#:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
#:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW

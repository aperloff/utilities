#!/bin/bash
#
if [ $1 ]
then
    chupK=$1
else
    echo | awk 'BEGIN { format = "\t%-29s\t%-6s\n"}
                        { printf "Which CMSSW release do you want to setup? (Default = CMSSW_5_3_22_patch1)\n"}
                        { printf "\t%-29s\t%-4s\n", "CMSSW Releases", "Code" }
                        { printf "\t%-29s\t%-4s\n", "--------------", "----" }
                        { printf format, "CMSSW_3_8_7", "387" }
                        { printf format, "CMSSW_4_2_8", "428" }
                        { printf format, "CMSSW_5_2_5", "525" }
                        { printf format, "CMSSW_5_3_2", "532" }
                        { printf format, "CMSSW_5_3_2_patch4", "532pat" }
                        { printf format, "CMSSW_5_3_2_patch4", "532p4" }
                        { printf format, "CMSSW_5_3_22_patch1", "5322" }'
	read chupK
fi

if [ $chupK == 387 ]
then
   export SCRAM_ARCH=slc5_ia32_gcc434
   cd /home/aperloff/MatrixElement/CMSSW_3_8_7/src/
   source /home/hepxadmin/gLite/gLite-UI/etc/profile.d/grid_env.sh
elif [ $chupK == 428 ]
then
    export SCRAM_ARCH=slc5_amd64_gcc434
    cd /home/aperloff/MatrixElement/CMSSW_4_2_8/src/
    source /home/hepxadmin/gLite/gLite-UI/etc/profile.d/grid_env.sh
elif [ $chupK == 525 ]
then
	export SCRAM_ARCH=slc5_amd64_gcc462
    source /home/hepxadmin/gLite/gLite-UI/etc/profile.d/grid_env.sh
	cd /home/aperloff/MatrixElement/CMSSW_5_2_5/src/
elif [ $chupK == 532pat ]
then
    cd /home/aperloff/MatrixElement/PATTupleCreation/CMSSW_5_3_2_patch4/src/
    source /home/hepxadmin/gLite/gLite-UI/etc/profile.d/grid_env.sh
elif [ $chupK == 532 ]
then
	export SCRAM_ARCH=slc5_amd64_gcc462
 	cd /home/aperloff/MatrixElement/gitty/CMSSW_5_3_2/src/
    source /home/hepxadmin/gLite/gLite-UI/etc/profile.d/grid_env.sh
elif [ $chupK == 532p4 ]
then
	export SCRAM_ARCH=slc5_amd64_gcc462
 	cd /home/aperloff/MatrixElement/gitty/CMSSW_5_3_2_patch4/src/
    source /home/hepxadmin/gLite/gLite-UI/etc/profile.d/grid_env.sh	
else
	export SCRAM_ARCH=slc6_amd64_gcc472
	cd /home/aperloff/MatrixElement/CMSSW_5_3_22_patch1/src/
fi

cmsenv

echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH

#CRAB
#source /home/hepxadmin/crab/current/crab.sh #Used for locally installed versions
#source /home/hepxadmin/crab/CRAB_2_8_7_patch2_dev/crab.sh #Developer version for submitting ME jobs via CRAB
#source /home/hepxadmin/crab/CRAB_2_10_5_patch1/crab.sh #For testing publishing using PBSv2
#source /home/aperloff/crab/CRAB_2_10_5_patch1/crab.sh #local version for testing publishing using PBSv2
source /cvmfs/cms.cern.ch/crab/CRAB_2_10_7_patch1/crab.sh
#source /cvmfs/cms.cern.ch/crab/crab.sh #Official reslease
test=`voms-proxy-info`
if [[ -z "$test" ]]
then
    voms-proxy-init -voms cms -valid 192:00
fi
#voms-proxy-init -voms cms -valid 192:00

#CVS
#export CVSROOT=:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW

#cvs login

#sometimes CVSROOT needs to be set to:
#:ext:username@cmssw.cvs.cern.ch:/local/reps/CMSSW
#:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
#:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW
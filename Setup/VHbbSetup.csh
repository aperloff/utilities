#!/bin/csh 
#
if ( $#argv > 0 ) then
	set chupK = $argv[1]
else
	echo " Type 710 for CMSSW_7_1_0_pre9, or anything for for CMSSW_7_1_0_pre9 "
	set chupK = $<
endif

if ( $chupK == 710 ) then
   setenv SCRAM_ARCH slc6_amd64_gcc481
   cd /uscms_data/d2/aperloff/YOURWORKINGAREA/VHbb/CMSSW_7_1_0_pre9/
   cmscvsroot CMSSW
   cmsenv
   cd src/VHbb/
#else if ( $chupK == 532 ) then
#	    setenv SCRAM_ARCH slc5_amd64_gcc462
#		cd /uscms/home/aperloff/MatrixElement/CMSSW_5_3_2_patch4
#	    cmscvsroot CMSSW
#		cmsenv
#		cd src/
else
		setenv SCRAM_ARCH slc6_amd64_gcc481
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/VHbb/CMSSW_7_1_0_pre9/
   		cmscvsroot CMSSW
   		cmsenv	
   		cd src/VHbb/
endif

source /cvmfs/cms.cern.ch/crab3/crab.csh
cmsenv
set test = `voms-proxy-info`
if ( $test == "" ) then
    voms-proxy-init -voms cms -valid 192:00
endif
echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH

#sometimes CVSROOT needs to be set to:
#:ext:username@cmssw.cvs.cern.ch:/local/reps/CMSSW
set CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
#:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW


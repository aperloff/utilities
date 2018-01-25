#!/bin/csh 

if ( $#argv > 0 ) then
	set chupK = $argv[1]
else
	echo " Type 428 for CMSSW_4_2_8, 5324 for CMSSW_5_3_2_patch4, 5325 for CMSSW_5_3_2_patch5, 5322 for CMSSW_5_3_22_patch1, 5327 for CMSSW_5_3_27, 715 for CMSSW_7_1_5, or anything for for gitty/CMSSW_5_3_27 "
	set chupK = $<
endif

if ( $chupK == 428 ) then
   setenv SCRAM_ARCH slc5_amd64_gcc434
   cd /uscms/home/aperloff/MatrixElement/CMSSW_4_2_8
   cmscvsroot CMSSW
   cmsenv
   cd src
else if ( $chupK == 5324 ) then
	    setenv SCRAM_ARCH slc5_amd64_gcc462
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MatrixElement/gitty/CMSSW_5_3_2_patch4
	    cmscvsroot CMSSW
		cmsenv
		cd src/
else if ( $chupK == 5327 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc472
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MatrixElement/gitty/CMSSW_5_3_27/src/
		cmsenv
else if ( $chupK == 715 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc481
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MatrixElement/gitty/CMSSW_7_1_5/src/
		cmsenv
else if ( $chupK == 5325 ) then
		setenv SCRAM_ARCH slc5_amd64_gcc462
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MatrixElement/gitty/CMSSW_5_3_2_patch5/src/
   		cmsenv
else if ( $chupK == 5322 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc472
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MatrixElement/gitty/CMSSW_5_3_22_patch1/src/
		cmsenv
else
		setenv SCRAM_ARCH slc6_amd64_gcc472
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MatrixElement/gitty/CMSSW_5_3_22_patch1/src/
		cmsenv
endif

echo " Type 2 for CRAB2 and 3 for CRAB3 "
set crab_version = $<

if ( $crab_version == 2 ) then
	source /cvmfs/cms.cern.ch/crab/crab.csh
else if ( $crab_version == 3 ) then
	source /cvmfs/cms.cern.ch/crab3/crab.csh
	cmsenv
endif

echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH

#sometimes CVSROOT needs to be set to:
#:ext:username@cmssw.cvs.cern.ch:/local/reps/CMSSW
#set CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
#:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW


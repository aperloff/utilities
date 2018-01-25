#!/bin/csh 
#
if ( $#argv > 0 ) then
	set chupK = $argv[1]
else
    echo | awk 'BEGIN { format = "\t%-29s\t%-6s\n" }\
                      { printf "Which CMSSW release do you want to setup? (Default = CMSSW_8_1_0_pre15)\n"}\
                      { printf format, "CMSSW Releases", 	         "Code"    }\
					  { printf format, "--------------", 		     "----"    }\
					  { printf format, "CMSSW_5_3_3",                "533"     }\
					  { printf format, "CMSSW_5_3_32",               "5332"    }\
					  { printf format, "CMSSW_6_2_0_SLHC16_patch1",  "62016"   }\
					  { printf format, "CMSSW_6_2_0_SLHC23_patch1",  "62023"   }\
					  { printf format, "CMSSW_6_2_0_SLHC25_patch4",  "62025"   }\
					  { printf format, "CMSSW_6_2_0_SLHC26",         "62026"   }\
					  { printf format, "CMSSW_7_0_5_patch1",         "705"     }\
					  { printf format, "CMSSW_7_2_2_patch1",         "722"     }\
					  { printf format, "CMSSW_8_1_0_pre8",           "810p8"   }\
					  { printf format, "CMSSW_8_1_0_pre11",          "810p11"  }\
					  { printf format, "CMSSW_8_1_0_pre15",          "810p15"  }\
					  { printf format, "CMSSW_9_0_0_pre1",           "900p1"   }\
					  { printf format, "CMSSW_9_0_0_pre2",           "900p2"   }\
                      { printf format, "CMSSW_8_2_0",                "820"     }\
                      { printf format, "CMSSW_8_2_0_patch1",         "820p1"   }\
					  { printf format, "CMSSW_9_1_X_2017-05-05-1100","91XIB"   }\
					  { printf format, "CMSSW_9_1_1_patch3",         "911p3"   }\
					  { printf format, "CMSSW_9_2_X_2017-06-26-1100","92XIB"   }\
					  { printf format, "CMSSW_9_3_X_2017-07-20-1100","93XIB"   }\
					  { printf format, "CMSSW_9_3_0_pre1",           "930p1"   }\
					  { printf format, "CMSSW_9_4_X_2017-10-15-1100","94XIB"   }\
					  { printf format, "CMSSW_10_0_0_pre3",          "1000pre3"}'

	set chupK = $<
endif

if ( $chupK == 705 ) then
   setenv SCRAM_ARCH slc5_amd64_gcc481
   cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_7_0_5_patch1/
   cmsenv
   cd src
   source /cvmfs/cms.cern.ch/crab/crab.csh
else if ( $chupK == 533 ) then
	    setenv SCRAM_ARCH slc5_amd64_gcc462
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_5_3_3/
		cmsenv
		cd src/
		source /cvmfs/cms.cern.ch/crab/crab.csh
else if ( $chupK == 5332 ) then
	    setenv SCRAM_ARCH slc6_amd64_gcc472
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/MLJEC/CMSSW_5_3_32/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 62016 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc472
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_6_2_0_SLHC16_patch1/
   		cmsenv	
   		cd src/
		source /cvmfs/cms.cern.ch/crab/crab.csh
else if ( $chupK == 62023 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc472
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_6_2_0_SLHC23_patch1/
   		cmsenv	
   		cd src/
		source /cvmfs/cms.cern.ch/crab/crab.csh
else if ( $chupK == 62025 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc472
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_6_2_0_SLHC25_patch4/
   		cmsenv	
   		cd src/
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 62026 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc472
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_6_2_0_SLHC26/
   		cmsenv	
   		cd src/
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 722 ) then 
		setenv SCRAM_ARCH slc6_amd64_gcc481
   		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_7_2_2_patch1/
		cmsenv
		cd src/
		source /cvmfs/cms.cern.ch/crab3/crab.csh
		cmsenv
else if ( $chupK == 810p8 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_8_1_0_pre8/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
		cmsenv
else if ( $chupK == 810p11 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_8_1_0_pre11/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
		cmsenv
else if ( $chupK == 810p15 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_8_1_0_pre15/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 900p1 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_0_0_pre1/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 900p2 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_0_0_pre2/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 91XIB ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_1_X_2017-05-05-1100/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 92XIB ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_2_X_2017-06-26-1100/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 93XIB ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_3_X_2017-07-20-1100/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 820 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_8_2_0/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 911p3 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_1_1_patch3/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 930p1 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_9_3_0_pre1/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 820p1 ) then
		setenv SCRAM_ARCH slc6_amd64_gcc530
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/gitty/CMSSW_8_2_0_patch1/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else if ( $chupK == 94XIB ) then
		setenv SCRAM_ARCH slc6_amd64_gcc630
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/CMSSW_9_4_X_2017-10-15-1100/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
else
		setenv SCRAM_ARCH slc6_amd64_gcc630
		cd /uscms_data/d2/aperloff/YOURWORKINGAREA/JEC/CMSSW_10_0_0_pre3/src/
		cmsenv
		source /cvmfs/cms.cern.ch/crab3/crab.csh
endif

#source /uscmst1/prod/grid/CRAB/crab.csh
echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH
set test = `voms-proxy-info`
if ( ${%test} == 0 ) then
    voms-proxy-init -voms cms -valid 192:00
endif

#sometimes CVSROOT needs to be set to:
#:ext:username@cmssw.cvs.cern.ch:/local/reps/CMSSW
#set CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
#:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW


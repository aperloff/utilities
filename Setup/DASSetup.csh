#!/bin/csh 
#
if ( $#argv > 0 ) then
	set chupK = $argv[1]
else
    echo | awk 'BEGIN { format = "\t%-20s\t%-6s\t%-10s\n" }\
                      { printf "Which CMSSW release do you want to setup? (Default = CMSSW_9_3_3)\n"}\
                      { printf format, "CMSSW Releases",      "Code",   "DAS Year" }\
                      { printf format, "--------------",      "----",   "--------" }\
                      { printf format, "CMSSW_7_2_2_patch2",  "722p2",  "2015"     }\
                      { printf format, "CMSSW_7_4_15_pre1",   "7415p1", "2016"     }\
                      { printf format, "CMSSW_7_4_14",        "7414",   "2017"     }\
                      { printf format, "CMSSW_8_0_24_patch1", "8024p1", "2017"     }\
                      { printf format, "CMSSW_7_4_15",        "7415",   "2018"     }\
					  { printf format, "CMSSW_8_0_25",        "8025",   "2018"     }\
					  { printf format, "CMSSW_9_3_2",         "932",    "2018"     }\
					  { printf format, "CMSSW_9_3_3",         "933",    "2018"     }'
	set chupK = $<
endif

if ( $chupK == 722 ) then
   setenv SCRAM_ARCH slc6_amd64_gcc481
   cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2015/CMSSW_7_2_2_patch2/src/
else if ( $chupK == 7415p1 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc491
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2016/CMSSW_7_4_15_patch1/src/
else if ( $chupK == 7414 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc491
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2017/CMSSW_7_4_14/src/
else if ( $chupK == 7415 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc491
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2018/CMSSW_7_4_15/src/
else if ( $chupK == 8024p1 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc530
	cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2017/CMSSW_8_0_24_patch1/src/
else if ( $chupK == 8025 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc530
	cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2018/CMSSW_8_0_25/src/
else if ($chupK == 932 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc630
	cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2018/CMSSW_9_3_2/src/
else
	setenv SCRAM_ARCH slc6_amd64_gcc630
	cd /uscms_data/d2/aperloff/YOURWORKINGAREA/CMSDAS2018/CMSSW_9_3_3/src/
endif

cmsenv
source /cvmfs/cms.cern.ch/crab3/crab.csh
cmsenv

echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH
set test = `voms-proxy-info`
if ( ${%test} == 0 ) then
    voms-proxy-init -voms cms -valid 192:00
endif

#sometimes CVSROOT needs to be set to:
#:ext:username@cmssw.cvs.cern.ch:/local/reps/CMSSW
#set CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
#:pserver:anonymous@cmssw.cvs.cern.ch:/local/reps/CMSSW


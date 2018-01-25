#!/bin/csh 
#
if ( $#argv > 0 ) then
	set chupK = $argv[1]
else
	echo " Type 742 for CMSSW_7_4_2_patch1, or anything for for CMSSW_8_0_12 "
    echo | awk 'BEGIN { format = "\t%-20s\t%-8s\t%-15s\t%-4s\n" }\
                      { printf "Which CMSSW release do you want to setup? (Default = CMSSW_8_0_21)\n"}\
                      { printf format, "CMSSW Releases",      "Code",   "Subject",       "Year"  }\
                      { printf format, "--------------",      "----",   "-------",       "----"  }\
                      { printf format, "CMSSW_5_3_15",        "5315",   "MET",           "2014"  }\
                      { printf format, "CMSSW_5_3_15",        "5314",   "Statistics",    "2014"  }\
					  { printf format, "CMSSW_7_4_2_patch1",  "742p1",  "JEC",           "2015"  }\
                      { printf format, "CMSSW_8_0_12",        "8012",   "JEC",           "2016"  }\
                      { printf format, "CMSSW_8_0_28_patch1", "8028p1", "JEC",           "2017"  }\
                      { printf format, "CMSSW_8_0_21",        "8021",   "CRAB3",         "2016"  }\
                      { printf format, "CMSSW_9_0_1",         "901",    "PyROOT-rootpy", "2017"  }'
					  
	set chupK = $<
endif


if ( $chupK == 5315 ) then
   cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/MET/CMSSW_5_3_15/src/
else if ( $chupK == 5314 ) then
   cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/Statistics/CMSSW_5_3_14/src/
else if ( $chupK == 742 ) then
   setenv SCRAM_ARCH slc6_amd64_gcc491
   cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/JEC/CMSSW_7_4_2_patch1/src/
else if ( $chupK == 8012 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc530
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/JEC/CMSSW_8_0_12/src/
else if ( $chupK == 8028p1 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc530
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/JEC/CMSSW_8_0_28_patch1/src/
else if ( $chupK == 8021 ) then
	setenv SCRAM_ARCH slc6_amd64_gcc530
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/CRAB3/CMSSW_8_0_21/src/
else
	setenv SCRAM_ARCH slc6_amd64_gcc530
    cd /uscms_data/d2/aperloff/YOURWORKINGAREA/HATS@LPC/PyROOT-rootpy/CMSSW_9_0_1/src/
endif

cmsenv
source /cvmfs/cms.cern.ch/crab3/crab.csh

echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH
set test = `voms-proxy-info`
if ( ${%test} == 0 ) then
    voms-proxy-init -voms cms -valid 192:00
endif



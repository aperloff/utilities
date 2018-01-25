#!/bin/bash

cd /Users/aperloff/Documents/CMS/Notes_and_Papers/

echo "Do you want to update the utilities? (y/n)"
read ynu
if [ $ynu = y ]
then
    echo "Updating utils"
    svn update utils
fi

echo "Do you want to access notes (n) or papers (p)?"
read np

if [ $np == n ]
then
#	echo "Updating notes"
#	svn update -N notes
	eval `notes/tdr runtime -sh`
elif [ $np == p ]
then
#	echo "Updating papers"
#	svn update -N papers
	eval `papers/tdr runtime -sh`
else
	echo "Unknown document type $np."
fi

#cd [papers|notes]/XXX-YY-NNN/trunk
echo | awk 'BEGIN { format = "\t%-9s\n"}
			{ printf "Which document do you want to access? (Default = AN-13-131)\n"}
			{ printf "\t%-9s\n", "Documents" }
			{ printf "\t%-9s\n", "---------" }
			{ printf format, "AN-13-125 (JEC MC Truth L1FastJet)" }
			{ printf format, "AN-13-131 (JetResponseAnalyzer)" }
			{ printf format, "AN-13-132 (H->WW->lnujj)" }
                        { printf format, "JME-13-004 (Jet Energy Calibration in the 8 TeV pp data)" }
                        { printf format, "PRF-14-001 (PF/GED Paper)" }
                        { printf format, "JME-16-001 (JetMET Summer PAS)" }
                        { printf format, "AN-16-116 (Jet Energy and Angular Resolution at 13 TeV)" }
                        { printf format, "AN-17-023  (L2/L3 MC Truth JEC in 2016)"}'

read doc
if [[ ! -d "notes/$doc/" && ! -L "notes/$doc/" && ! -d "papers/$doc/" && ! -L "/papers/$doc/" ]]
then
    echo "Document $doc is unknown. Do you want to check it out? (y/n)"
    read ync
    if [ $ync == y ]
    then
	svn update utils
	if [ $np = n ]
	then
	    svn update -N notes 
	    svn update notes/$doc
	elif [ $np = p ]
	then
	    svn update -N papers
	    svn update papers/$doc
	fi
    else
	echo "Unknown document requested. There is nothing I can do. Exiting..."
	exit 1
    fi
fi

if [ $np == n ]
then
    cd notes/$doc/trunk
elif [ $np == p ]
then
    cd papers/$doc/trunk
fi

echo "Do you want to compile this document? (y/n)"
read yn

if [ $yn == y ]
then
	source /Applications/Scripts/TDRCompile.sh
else
	echo "All set up!"
fi
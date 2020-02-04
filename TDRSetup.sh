#!/bin/bash

#The extglob option is needed for the *(pattern-list) and ?(pattern-list) forms.
#This allows you to use regular expressions (although in a different form to most regular expressions) instead of just pathname expansion (*?[).
shopt -s extglob

#Initial setup
working_area="/Users/aperloff/Documents/CMS/Notes_and_Papers/"
cd ${working_area}
unset doc

#Check if svn or gitlab. Will only need this for a limited amount of time as the svn servers will be shut off shortly.
echo "Is this an svn or gitlab area? (svn/gitlab)"
read svn_gitlab
if [ "$svn_gitlab" == "svn" ]; then
	echo "Do you want to update the utilities? (y/n)"
	read ynu
	if [ "$ynu" == y ]; then
	echo "You will need your CERN (svn.cern.ch) password:"
	svn update utils
	fi
fi

echo "Do you want to access notes (n) or papers (p)?"
read np

if [ $np == n ]; then
#	echo "Updating notes"
#	svn update -N notes
	if [ "$svn_gitlab" == "svn" ]; then
			eval `notes/tdr runtime -sh`
	fi
	np_selection="notes"
elif [ $np == p ]; then
#	echo "Updating papers"
#	svn update -N papers
		if [ "$svn_gitlab" == "svn" ]; then
		eval `papers/tdr runtime -sh`
	fi
	np_selection="papers"
else
	echo "Unknown document type $np."
fi

#Get a list of [notes|papers]
notes_papers=(${working_area}/${np_selection}/*/)
#Filter the paths for just the last folder name
for ((i=0; i<${#notes_papers[@]}; i++)); do
  notes_papers[$i]="$(basename ${notes_papers[$i]})"
done
#Filter specific folder names
# Note: '-eq' does not work for checking string equality. Use '==' instead.
for index in "${!notes_papers[@]}" ; do [[ ( "${notes_papers[$index]}" == "tmp" ) || ( "${notes_papers[$index]}" == "MVA_Directions" ) || ( "${notes_papers[$index]}" == "general" )]] && unset -v 'notes_papers[$index]' ; done
notes_papers=("${notes_papers[@]}")
#Setup the [note|paper descriptions]
declare notes_papers_description=()
for ((i=0; i<${#notes_papers[@]}; i++)); do
	if [ -e ${working_area}/${np_selection}/${notes_papers[$i]}/description.md ]; then
		printf -v VAR "%-10s %s %-80s" "${notes_papers[$i]}" "|" "$(head -n 1 ${working_area}/${np_selection}/${notes_papers[$i]}/description.md)"
		notes_papers_description+=("${VAR}")
	else
		printf -v VAR "%-10s" ${notes_papers[$i]} 
		notes_papers_description+=("${VAR}")
	fi
done
#Select a [note|paper]
prompt="Pick a ${np_selection%?} (1-${#notes_papers[@]}, anything else to exit):"
PS3="$prompt "
echo "Which ${np_selection%?} do you want to setup?"; \
select npd in "${notes_papers_description[@]}"; do
	if ! [[ "${REPLY}" =~ ^-?[0-9]+$ ]]; then
		doc=${REPLY}
		break
	elif [ "$REPLY" -gt "${#notes_papers[@]}" ] || [ "$REPLY" -lt "1" ]; then
		unset doc
		break
	else
		echo "You selected ${notes_papers[$REPLY-1]}"'!'
		doc=${notes_papers[$REPLY-1]}
		break
	fi
done

doc_path="${working_area}/${np_selection}/${doc}/"

if [[ ! -d "${doc_path}" && ! -L "${doc_path}" ]]; then
	echo "Document \"$doc\" is unknown. Do you want to check it out? (y/n)"
	read ync
	if [ "$ync" == y ]; then
	if [ "$svn_gitlab" == "svn" ]; then
		if [ "$ynu" == y ]; then
			svn update utils
		fi
		if [ "$np" == n ]; then
			svn update -N notes 
			svn update notes/$doc
		elif [ "$np" == p ]; then
			svn update -N papers
			svn update papers/$doc
		fi
	else 
		cd ${working_area}/${np_selection}/
		git clone --recursive https://:@gitlab.cern.ch:8443/tdr/${np_selection}/${doc}.git
		if [ $? == 0 ]; then
			cd ${doc}
			eval `utils/tdr runtime -sh`
			if [[ ! -d "tmp/" ]]; then
				mkdir tmp/
			fi
			export TDR_TMP_DIR="${working_area}/${np_selection}/$doc/tmp/"
			# Replace the "bibtex" commands in utils/tdr with "openout_any=r bibtex"
			# Only needed for TexLive2018 and higher
			sed -i '' -e 's/"bibtex/"openout_any=r bibtex/g' utils/tdr
		else 
			echo "Something has failed in checking out the new area. Check that you have a CENR kerberos ticket:"
			echo "  Run: 'kinit `whoami`@CERN.CH'"
		fi
	fi
	else
	echo "Unknown document requested. There is nothing I can do. Exiting..."
	fi
elif [[ -z "${doc}" ]]; then
	echo "No ${np_selection%?} selected"
else
	if [ "$svn_gitlab" == "svn" ]; then
		cd ${working_area}/${np_selection}/$doc/trunk
	else
		cd ${working_area}/${np_selection}/$doc/
		eval `utils/tdr runtime -sh`
		if [[ ! -d "tmp/" ]]; then
			mkdir tmp/
		fi
		export TDR_TMP_DIR="${working_area}/${np_selection}/$doc/tmp/"
	fi

	echo "Do you want to compile this document? (y/n)"
	read yn

	if [ $yn == y ]; then
		TDRCompile
	else
		echo "All set up!"
	fi
fi
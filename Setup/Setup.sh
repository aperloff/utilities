#!/bin/bash

shopt -s extglob dotglob nullglob 

#Function to check if an array contains a specific value (fuzzy search)
array_contains () { 
	local array="$1[@]"
	local seeking=$2
	local in=1
	for element in "${!array}"; do
		if [[ $element = *"$seeking"* ]]; then
			in=0
			break
		fi
	done
	echo $in
}

#Set the exit conditions
exit_conditions() {
	#Reset the column sizes so that the PROMPT_COMMAND function will work again
	COLUMNS=$COLUMNS_ORIGINAL
	#Reset the shopt options so that tab completion will work
	shopt -u nullglob dotglob
}

#Set the correct column size for multi column options
COLUMNS_ORIGINAL=$COLUMNS
COLUMNS=80

#Check that the script is being sourced and not run
if [[ "$(basename -- "$0")" == "Setup.sh" ]]; then
	echo "Don't run $0, source it" >&2
	exit 1
fi

#Select the correct SLC version (you might need it later)
if [[ `uname -r` == *"el6"* ]]; then 
	SLC_VERSION="slc6"
elif [[ `uname -r` == *"el7"* ]]; then 
	SLC_VERSION="slc7"
else
	echo "WARNING::Unknown SLC version. Defaulting to SLC7."
	SLC_VERSION="slc7"
fi

#Select the correct project
if [[ ${HOSTNAME} = *"cmslpc"* ]]; then
	WORKING_AREA="/uscms_data/d2/aperloff/YOURWORKINGAREA/"
elif [[ ${HOSTNAME} = *"brazos"* ]]; then
	WORKING_AREA="${HOME}"
elif [[ ${HOSTNAME} = *"alexx"* ]]; then
	WORKING_AREA="/Applications/"
elif [[ ${HOSTNAME} = "login"*".uscms.org" ]]; then
	WORKING_AREA="/local-scratch/aperloff/"
else
	echo "Unknown working area. No known projects."
	exit_conditions
fi
PROJECTS=(${WORKING_AREA}/*/)
for ((i=0; i<${#PROJECTS[@]}; i++)); do
	PROJECTS[$i]="$(basename ${PROJECTS[$i]})"
done
prompt="Pick an option (1-${#PROJECTS[@]}):"
PS3="$prompt "
echo "Which project do you want to work on? (Default = JEC)"; \
select proj in "${PROJECTS[@]}"; do
	case "$proj,${REPLY}" in
		"4BBFF",*|*,"4BBFF")
			PROJECT_PATHS=("4BBFF/")
			break
			;;
		"CMSDAS",*|*,"CMSDAS")
			PROJECT_PATHS=("CMSDAS/2017/" "CMSDAS/2018/" "CMSDAS/2019/" "CMSDAS/2020/")
			break
			;;
		"EXO",*|*,"EXO")
			PROJECT_PATHS=("EXO/${SLC_VERSION}")
			break
			;;
		"HATS@LPC",*|*,"HATS@LPC")
			PROJECT_PATHS=("HATS@LPC/" "HATS@LPC/CMSConnect" "HATS@LPC/JEC" "HATS@LPC/Jets" "HATS@LPC/PyROOT-rootpy" "HATS@LPC/Statistics" "HATS@LPC/egamma" "HATS@LPC/hatslpc2014")
			break
			;;
		"JEC",*|*,"JEC")
			PROJECT_PATHS=("JEC/gitty/" "JEC/")
			break
			;;
		"MLJEC",*|*,"MLJEC")
			PROJECT_PATHS=("MLJEC/")
			break
			;;
		"MatrixElement",*|*,"MatrixElement")
			PROJECT_PATHS=("MatrixElement/CVS/" "MatrixElement/Git/")
			break
			;;
		"SUSY",*|*,"SUSY")
			PROJECT_PATHS=("SUSY/${SLC_VERSION}/")
			break
			;;
		"TSABoard",*|*,"TSABoard")
			PROJECT_PATHS=("TSABoard/${SLC_VERSION}/")
			break
			;;
		"VHbb",*|*,"VHbb")
			PROJECT_PATHS=("VHbb/")
			break
			;;
		*)
			echo "invalid option!!!"
			echo "Look, it's a simple question..."
			;;
	esac
done
if [[ "${proj}" -eq "" ]]; then
	echo -e "You selected ${REPLY}"'!\n'
else
	echo -e "You selected ${proj}"'!\n'
fi

#Set the correct column size for a single column list
COLUMNS=12

#Find all of the releases in the project paths
declare RELEASE_PATHS=()
declare scram_arch=()
for p in ${PROJECT_PATHS[@]}; do
	RELEASE_PATHS+=(${WORKING_AREA}/${p}/*/)
done

#Sort the releases
IFS=$'\n' RELEASE_PATHS=($(sort -t _ -k3.1,3.2 -k4.1,4.1 -g <<<"${RELEASE_PATHS[*]}"))

#Find the scram architectures
for p in ${RELEASE_PATHS[@]}; do
	scram_arch+=(${p}/lib/*/)
done

#find arrays for deleting
for ((i=0; i<${#RELEASE_PATHS[@]}; i++)); do
	if [[ "${RELEASE_PATHS[$1]}" == *"CMSSW"* ]] && [[ "$(array_contains scram_arch ${RELEASE_PATHS[$i]})" -eq "1" ]]; then
		echo "WARNING::${RELEASE_PATHS[$i]} is missing the lib/<SCRAM_ARCH> folder"
		unset 'RELEASE_PATHS[$i]'
	fi
done

#Reset the indices after deleting some values
for i in "${!RELEASE_PATHS[@]}"; do
		new_array+=( "${RELEASE_PATHS[i]}" )
done
RELEASE_PATHS=("${new_array[@]}")
unset new_array

#Check that the release paths and scram_archs have the same size
if [[ "${proj}" != "EXO" ]] && [ "${#RELEASE_PATHS[@]}" -ne "${#scram_arch[@]}" ]; then
	echo "Not the same number of releases and scram_archs"
fi

#Setup the aliases (not needed anymore), descriptions, and scram_arch based on the valid release paths
declare releases=()
declare alias=()
declare release_and_description=()
for ((i=0; i<${#RELEASE_PATHS[@]}; i++)); do
	releases+=("$(basename ${RELEASE_PATHS[$i]})")
	alias+=("${releases[$i]//_}")
	alias[$i]="${alias[$i]//CMSSW}"
	alias[$i]="${alias[$i]/patch/p}"
	if [[ "${RELEASE_PATHS[$i]}" == *"CMSSW"* ]]; then
		scram_arch[$i]="$(basename ${scram_arch[$i]})"
	else
		scram_arch[$i]="slc7_amd64_gcc700"
	fi
	if [ -e ${RELEASE_PATHS[$i]}/src/description.md ]; then
		CURCOL=`tput cols`
		DESCCOLWIDTH=`expr $CURCOL - 29 - 3 - 3 - 2`
		DESCRIPTION="$(head -n 3 ${RELEASE_PATHS[$i]}/src/description.md)"
		DESCWIDTH=${#DESCRIPTION}
		let NDESCLINES=($DESCWIDTH+$DESCCOLWIDTH-1)/$DESCCOLWIDTH
		insert="\                                    " #36
		for j in $(seq 0 `expr ${NDESCLINES} - 2`); do
			START=$((j * DESCCOLWIDTH))
			END=$((((j + 1) * DESCCOLWIDTH) + (j*${#insert})))
			if [ "${DESCWIDTH}" -gt "${DESCCOLWIDTH}" ]; then
				DESCRIPTION="${DESCRIPTION:0:${END}}${insert}${DESCRIPTION:${END}}"
			fi
		done
		printf -v VAR "%-29s %s %-${DESCCOLWIDTH}s" "${releases[$i]}" "|" "${DESCRIPTION}"
		release_and_description+=("${VAR}")
	else
		printf -v VAR "%-29s" ${releases[$i]} 
		release_and_description+=("${VAR}")
	fi
done

#Select a release if there is more than one
if [ "${#releases[@]}" -eq "1" ]; then
	SELECTED_RELEASE_PATH=${RELEASE_PATHS[0]}
	SELECTED_ALIAS=${alias[0]}
	SELECTED_SCRAM_ARCH=${scram_arch[0]}
	echo "Only one release available. Selecting ${releases[0]}"
else
	prompt="Pick an option (1-${#releases[@]}, anything else to exit):"
	PS3="$prompt "
	echo "Which CMSSW release do you want to setup?"; \
		select dir in "${release_and_description[@]}"; do
			if ! [[ "${REPLY}" =~ ^-?[0-9]+$ ]]; then
				break
			elif [ "$REPLY" -gt "${#releases[@]}" ] || [ "$REPLY" -lt "1" ]; then
				break
			else
				echo "You selected ${releases[$REPLY-1]}"'!'
				SELECTED_RELEASE_PATH=${RELEASE_PATHS[$REPLY-1]}
				SELECTED_ALIAS=${alias[$REPLY-1]}
				SELECTED_SCRAM_ARCH=${scram_arch[$REPLY-1]}
				break
			fi
	done
fi

if [[ -z "${SELECTED_RELEASE_PATH}" ]]; then
	echo "No release selected"
elif [[ "${proj}" == "EXO" ]] && [[ "${SELECTED_RELEASE_PATH}" != *"CMSSW"* ]]; then
	cd ${SELECTED_RELEASE_PATH}/
	source coffeaenv/bin/activate

	#Check for a voms-proxy
	test=`voms-proxy-info`
	if [[ -z "$test" ]]; then
		voms-proxy-init -voms cms -valid 192:00
	fi
else
	#Setup the chosen release
	export SCRAM_ARCH=${SELECTED_SCRAM_ARCH}
	cd ${SELECTED_RELEASE_PATH}/src/
	cmsenv
	source /cvmfs/cms.cern.ch/common/crab-setup.sh

	#Check for a voms-proxy
	test=`voms-proxy-info`
	if [[ -z "$test" ]]; then
		voms-proxy-init -voms cms -valid 192:00
	fi
fi

#Reset the column sizes so that the PROMPT_COMMAND function will work again
#COLUMNS=$COLUMNS_ORIGINAL

#Reset the shopt options so that tab completion will work
#shopt -u nullglob dotglob
exit_conditions

#select: https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script

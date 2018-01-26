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

#Select the correct project
COLUMNS=80
NOBACKUP_AREA="/uscms_data/d2/aperloff/YOURWORKINGAREA/"
PROJECTS=(${NOBACKUP_AREA}/*/)
for ((i=0; i<${#PROJECTS[@]}; i++)); do
  PROJECTS[$i]="$(basename ${PROJECTS[$i]})"
done
prompt="Pick an option (1-${#PROJECTS[@]}):"
PS3="$prompt "
echo "Which project do you want to work on? (Default = JEC)"; \
select proj in "${PROJECTS[@]}"; do
  case $proj in
        "$QUIT")
          echo "Abort."
          break
          ;;
        "4BBFF")
          PROJECT_PATHS=("4BBFF/")
          break
          ;;
        "CMSDAS")
          PROJECT_PATHS=("CMSDAS/2017/" "CMSDAS/2018/")
          break
          ;;
        "HATS@LPC")
          PROJECT_PATHS=("HATS@LPC/" "HATS@LPC/CMSConnect" "HATS@LPC/JEC" "HATS@LPC/Jets" "HATS@LPC/PyROOT-rootpy" "HATS@LPC/Statistics" "HATS@LPC/egamma" "HATS@LPC/hatslpc2014")
          break
          ;;
        "JEC")
          PROJECT_PATHS=("JEC/gitty/" "JEC/")
          break
          ;;
        "MLJEC")
          PROJECT_PATHS=("MLJEC/")
          break
          ;;
        "MatrixElement")
          PROJECT_PATHS=("MatrixElement/CVS/" "MatrixElement/Git/")
          break
          ;;
        "VHbb")
          PROJECT_PATHS=("VHbb/")
          break
          ;;
        *)
          echo "invalid option"
          ;;
  esac
done
echo -e "You selected ${proj}"'!\n'

#Find all of the releases in the project paths
COLUMNS=12
declare RELEASE_PATHS=()
declare scram_arch=()
for p in ${PROJECT_PATHS[@]}; do
	RELEASE_PATHS+=(${NOBACKUP_AREA}/${p}/*/)
done

#Sort the releases
IFS=$'\n' RELEASE_PATHS=($(sort -t _ -k3.1,3.2 -k4.1,4.1 -g <<<"${RELEASE_PATHS[*]}"))

#Find the scram architectures
for p in ${RELEASE_PATHS[@]}; do
  scram_arch+=(${p}/lib/*/)
done

#find arrays for deleting
for ((i=0; i<${#RELEASE_PATHS[@]}; i++)); do
  if [[ "$(array_contains scram_arch ${RELEASE_PATHS[$i]})" -eq "1" ]]; then
    echo "WARRNING::${RELEASE_PATHS[$i]} is missing the lib/<SCRAM_ARCH> folder"
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
if [ "${#RELEASE_PATHS[@]}" -ne "${#scram_arch[@]}" ]; then
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
   	scram_arch[$i]="$(basename ${scram_arch[$i]})"
   	if [ -e ${RELEASE_PATHS[$i]}/src/description.md ]; then
   		printf -v VAR "%-29s %s %-80s" "${releases[$i]}" "|" "$(head -n 1 ${RELEASE_PATHS[$i]}/src/description.md)"
	   	release_and_description+=("${VAR}")
	else
		printf -v VAR "%-29s" ${releases[$i]} 
		release_and_description+=("${VAR}")
	fi
done

#Select a release
prompt="Pick an option (1-${#releases[@]}):"
PS3="$prompt "
echo "Which CMSSW release do you want to setup? (Default = CMSSW_5_3_22_patch1)"; \
select dir in "${release_and_description[@]}"; do
	echo "You selected ${releases[$REPLY-1]}"'!'
	 SELECTED_RELEASE_PATH=${RELEASE_PATHS[$REPLY-1]}
	 SELECTED_ALIAS=${alias[$REPLY-1]}
	 SELECTED_SCRAM_ARCH=${scram_arch[$REPLY-1]}
	 break
done

#Setup the chosen release
export SCRAM_ARCH=${SELECTED_SCRAM_ARCH}
cd ${SELECTED_RELEASE_PATH}/src/
cmsenv
source /cvmfs/cms.cern.ch/crab3/crab.sh
cmsenv

#Check for a voms-proxy
test=`voms-proxy-info`
if [[ -z "$test" ]]
then
    voms-proxy-init -voms cms -valid 192:00
fi

#select: https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
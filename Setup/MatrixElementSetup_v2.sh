#!/bin/bash

COLUMNS=12
shopt -s dotglob
shopt -s nullglob

NOBACKUP_AREA="/uscms_data/d2/aperloff/"
PROJECT_PATHS=("YOURWORKINGAREA/MatrixElement/CVS/" "YOURWORKINGAREA/MatrixElement/Git/")
declare RELEASE_PATHS=()
declare scram_arch=()
for p in ${PROJECT_PATHS[@]}; do
	RELEASE_PATHS+=(${NOBACKUP_AREA}/${p}/*/)
	scram_arch+=(${NOBACKUP_AREA}/${p}/*/lib/*/)
done

declare releases=()
declare alias=()
declare release_and_description=()
for ((i=0; i<${#RELEASE_PATHS[@]}; i++)); do
   	#RELEASES[$i]="$(basename ${RELEASES[$i]})"
   	releases+=("$(basename ${RELEASE_PATHS[$i]})")
   	alias+=("${releases[$i]//_}")
   	alias[$i]="${alias[$i]//CMSSW}"
   	alias[$i]="${alias[$i]/patch/p}"
   	scram_arch[$i]="$(basename ${scram_arch[$i]})"
   	if [ -e ${PROJECT_PATH}/${releases[$i]}/src/description.md ]; then
   		printf -v VAR "%-29s %s %-80s" "${releases[$i]}" "|" "$(head -n 1 ${PROJECT_PATH}/${releases[$i]}/src/description.md)"
	   	release_and_description+=("${VAR}")
	else
		printf -v VAR "%-29s" ${releases[$i]} 
		release_and_description+=("${VAR}")
	fi
done

prompt="Pick an option (1-${#releases[@]}):"
PS3="$prompt "
echo "Which CMSSW release do you want to setup? (Default = CMSSW_5_3_22_patch1)"; \
select dir in "${release_and_description[@]}"; do
	echo "You selected ${releases[$REPLY-1]}"'!'
	 SELECTED_RELEASE=${releases[$REPLY-1]}
	 SELECTED_ALIAS=${alias[$REPLY-1]}
	 SELECTED_SCRAM_ARCH=${scram_arch[$REPLY-1]}
	 break
done

export SCRAM_ARCH=${SELECTED_SCRAM_ARCH}
cd $PROJECT_PATH/${SELECTED_RELEASE}/src/
cmsenv
source /cvmfs/cms.cern.ch/crab3/crab.csh
cmsenv

test=`voms-proxy-info`
if [[ -z "$test" ]]
then
    voms-proxy-init -voms cms -valid 192:00
fi

#select: https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
'''
#For a different way to format your own select
for ((i=0;i<${#releases[@]};i++)); do 
  string="$(($i+1))) ${RELEASES[$i]}"
  printf "%s" "$string"
  printf "%$(($width-${#string}))s" " "
  [[ $(((i+1)%$cols)) -eq 0 ]] && echo
done

read -p '#? ' opt
'''
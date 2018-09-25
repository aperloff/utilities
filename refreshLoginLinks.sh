#!/bin/bash

# This utility sets up the home area softlinks to the login scripts.

function get_script_path() {
	local SCRIPT_PATH="`dirname \"$0\"`"            # relative
	SCRIPT_PATH="`( cd \"$SCRIPT_PATH\" && pwd )`"  # absolutized and normalized
	if [ -z "$SCRIPT_PATH" ] ; then
	  # error; for some reason, the path is not accessible
	  # to the script (e.g. permissions re-evaled after suid)
	  exit 1  # fail
	fi
	echo "$SCRIPT_PATH"
}

declare -A files_unified=( ["rootlogon.C"]="ROOT" [".rootrc"]="ROOT" \
                   		   [".gitconfig"]="Git" [".gitignore_global"]="Git" \
                   		   [".k5login"]="Login" [".emacs"]="Login" [".forward"]="Login" )
declare -A files_tcsh=(    [".login"]="Login" [".cshrc"]="Login" [".tcshrc.complete"]="Login" [".tcshrc.logout"]="Login" )
declare -A files_bash=(    [".bashrc"]="Login" [".bash_profile"]="Login" [".profile"]="Login" [".bash_logout"]="Login" ["liquidpromptrc-dist"]="../liquidprompt")

if [ `basename "$SHELL"` == "bash" ]; then
	for key in ${!files_bash[@]}; do
    	files_unified+=( [${key}]=${files_bash[${key}]} )
	done
elif [ `basename "$SHELL"` == "tcsh" ]; then
	for key in ${!files_tcsh[@]}; do
    	files_unified+=( [${key}]=${files_tcsh[${key}]} )
	done
else
	echo "Unknown shell ($SHELL)"
	exit
fi

for file in "${!files_unified[@]}"; do
	if [ -L ${HOME}/${file} ]; then
		echo "Refreshing the \"${file}\" symlink."
		unlink ${HOME}/${file}
	elif [ -f ${HOME}/${file} ]; then
		echo "Abort, a regular file called \"${file}\" already exists at ${HOME}"
		exit 1
	else
		echo "Making the \"${file}\" symlink"
	fi
	ln -s $(get_script_path)/${files_unified[$file]}/${file} ${HOME}/${file}

	# Special Cases
	if [ "${file}" == "liquidpromptrc-dist" ]; then
		mv "${HOME}/${file}" "${HOME}/.liquidpromptrc"
	fi
done

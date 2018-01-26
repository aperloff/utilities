#!/bin/bash

function get_script_path() {
	local SCRIPT_PATH="`dirname \"$0\"`"              # relative
	SCRIPT_PATH="`( cd \"$SCRIPT_PATH\" && pwd )`"  # absolutized and normalized
	if [ -z "$SCRIPT_PATH" ] ; then
	  # error; for some reason, the path is not accessible
	  # to the script (e.g. permissions re-evaled after suid)
	  exit 1  # fail
	fi
	echo "$SCRIPT_PATH"
}

declare -A files=( ["rootlogon.C"]="ROOT" [".rootrc"]="ROOT" \
                   [".gitconfig"]="Git" [".gitignore_global"]="Git" \
                   [".k5login"]="Login" [".login"]="Login" [".emacs"]="Login" [".forward"]="Login" [".profile"]="Login" \
                   [".cshrc"]="Login" [".tcshrc.complete"]="Login" [".tcshrc.logout"]="Login" \
                   [".bashrc"]="Login" [".bash_profile"]="Login" [".bash_ps1"]="Login" )

for file in "${!files[@]}"; do
	if [ -L ${HOME}/${file} ]; then
		echo "Refreshing the \"${file}\" symlink."
		unlink ${HOME}/${file}
	elif [ -f ${HOME}/${file} ]; then
		echo "Abort, a regular file called \"${file}\" already exists at ${HOME}"
		exit 1
	else
		echo "Making the \"${file}\" symlink"
	fi
	ln -s $(get_script_path)/${files[$file]}/${file} ${HOME}/${file}
done
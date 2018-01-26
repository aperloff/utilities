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

if [ -L ${HOME}/rootlogon.C ]; then
	unlink ${HOME}/rootlogon.C
fi
if [ -z ${HOME}/rootlogon.C ]; then
	echo "Abort, a regular file called \"rootlogon.C\" already exists at ${HOME}"
	exit 1
fi
ln -s $(get_script_path)/ROOT/rootlogon.C ${HOME}/rootlogon.C
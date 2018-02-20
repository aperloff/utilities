#!/bin/bash

'''
This utility sets up the home area softlinks to special directories for cmslpc.
'''

declare -A links=(
                  ["lpccvmfs"]="/uscms_data/d1/lpccvmfs" \
                  ["nobackup"]="/uscms_data/d2/aperloff" \
                  ["publicweb"]="/publicweb/a/aperloff/" \
                  )

for link in "${!links[@]}"; do
	if [ -L ${HOME}/${link} ]; then
		echo "Refreshing the \"${link}\" symlink."
		unlink ${HOME}/${link}
	elif [ -f ${HOME}/${link} ]; then
		echo "Abort, a regular file called \"${link}\" already exists at ${HOME}"
		exit 1
	else
		echo "Making the \"${link}\" symlink"
	fi
	ln -s ${links[$link]} ${HOME}/${link}
done
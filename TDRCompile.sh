#!/bin/bash

echo "Is this a draft? (y/n)"
read IsDraft

if [[ -f "utils/tdr" ]]; then
	cmd="utils/tdr --"
else
	cms="tdr --"
fi

if [ $IsDraft == y ]; then
	cmd=$cmd"draft"
else
	cmd=$cmd"nodraft"
fi

echo | awk 'BEGIN { format = "\t%-5s\n"}
		{ printf "What style document is this? (Default = an)\n"}
		{ printf "\t%-5s\n", "Style" }
		{ printf "\t%-5s\n", "-----" }
		{ printf format, "paper" }
		{ printf format, "pas" }
		{ printf format, "an" }
                { printf format, "note" }'
read style

echo "Verbose? (y/n)"
read verbose

if [ $verbose == y ]; then
    cmd=$cmd" --verbose"
fi

#tdr  --draft --style=[paper|pas|an] b XXX-YY-NNN
cmd=$cmd" --style="$style" b "$doc

echo
echo "Running the command: "$cmd
$cmd
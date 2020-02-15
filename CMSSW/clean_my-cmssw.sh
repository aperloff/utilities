#!/bin/bash

# Taken from: https://gist.github.com/nsmith-/6d9d29ed66cf71e0e92e
# Slower than Kevin's code, but also deletes branches and has a way to delete on a selected number of branches.

# Delete all tags
git ls-remote -t my-cmssw | sed 's:^.*refs/tags/::' | while read t; do git push my-cmssw :$t; done
# Delete all branches
git ls-remote -h my-cmssw |sed 's:^.*refs/heads/::' | while read b; do git push my-cmssw :$b; done
# Or, save list of branches, and remove ones you want to keep
git ls-remote -h my-cmssw |sed 's:^.*refs/heads/::' > branches_to_del
vim branches_to_del
while read b; do git push my-cmssw :$b; done < branches_to_del

#!/bin/bash

# Taken from: https://twiki.cern.ch/twiki/bin/view/CMS/CMSGitTutorial#Delete all tags from CMSSW fork

git ls-remote --tags my-cmssw | cut -f2 | sed 's~refs/tags/~~' | xargs -n 1000 -P 1 git push my-cmssw --delete

#!/bin/csh

eos root://cmseos.fnal.gov/ find $argv[1] | grep -v failed | grep -v log | grep -F .root | wc -l

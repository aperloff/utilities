#!/bin/bash

# Taken from: https://github.com/kpedro88/utilities/blob/master/cmsrel_all.sh

ls -dt /cvmfs/cms.cern.ch/slc*/cms/cmssw/CMSSW_* /cvmfs/cms.cern.ch/slc*/cms/cmssw-patch/CMSSW_* | grep $1

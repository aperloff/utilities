#!/bin/csh

cd jets2/electron/
condor_submit PlotterBatchJob.jdl
cd ../muon/
condor_submit PlotterBatchJob.jdl
cd ../../jets3/electron/
condor_submit PlotterBatchJob.jdl
cd ../muon/
condor_submit PlotterBatchJob.jdl
cd ../../jets4/electron/
condor_submit PlotterBatchJob.jdl
cd ../muon/
condor_submit PlotterBatchJob.jdl
cd ../../

echo "All 6 jobs submitted (attempted)"

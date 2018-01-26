#!/bin/csh

cd Jets2/electron/
rename electron electron_jets2 histos_*.root
cd ../muon/
rename muon muon_jets2 histos_*.root
cd ../../Jets3/electron/
rename electron electron_jets3 histos_*.root
cd ../muon/
rename muon muon_jets3 histos_*.root
cd ../../Jets4/electron/
rename electron electron_jets4 histos_*.root
cd ../muon/
rename muon muon_jets4 histos_*.root
cd ../../

#find . -name '*histos_*.root' -exec bash -c 'echo mv $0 ${0/_jets/_Jets}' {} \;
#find . -name '*histos_*.root' -exec bash -c 'mv "$0" "${0/_Jets/_jets}"' {} \;

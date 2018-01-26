#!/bin/sh
#Environment
umask 0022
ulimit -s 11000
PS1="\n\[\033[35m\]\$(/bin/date)\n\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
# To add separators to a terminal
if [ -f "$HOME/.bash_ps1" ]; then
. "$HOME/.bash_ps1"
fi

export PROMPT_DIRTRIM=3

LD_LIBRARY_PATH=/lib64:/usr/lib64:$LD_LIBRARY_PATH
PATH=/bin:/usr/bin:$PATH

#Kerberos
export KRB5_CONFIG=/home/hepxadmin/krb5.conf
#export VO_CMS_SW_DIR=/home/hepxadmin/cmssw
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
#export VO_CMS_SW_DIR=/fdata/hepx/store/cvmfs/cms.cern.ch/
case `hostname -s` in
hurr|brazos)
  export SCRAM_ARCH=slc5_amd64_gcc462
  ;;
login*)
  export SCRAM_ARCH=slc6_amd64_gcc472
  ;;
esac
source $VO_CMS_SW_DIR/cmsset_default.sh

# to avoid urllib2 SSL: CERTIFICATE_VERIFY_FAILED
export SSL_CERT_DIR='/etc/pki/tls/certs:/etc/grid-security/certificates'

#GIT
export CMSSW_GIT_REFERENCE=/cvmfs/cms.cern.ch/cmssw.git.daily/

#Tab Completion
export autoexpand
export autolist=ambiguous

export PATH=$HOME/.local/bin:$PATH
#if (! $?PYTHONPATH) then
#  setenv PYTHONPATH $HOME/.local/lib/python2.7/site-packages:/usr/lib64/python2.6/site-packages
#else
#  setenv PYTHONPATH $HOME/.local/lib/python2.7/site-packages:/usr/lib64/python2.6/site-packages:$P\
#YTHONPATH
#endif
if [ "${LD_LIBRARY_PATH:?}" ]; then
  export LD_LIBRARY_PATH=$HOME/.local/lib
else 
  export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
fi

#Alias
alias ll='ls -lFh --color=auto'
alias la='ls -Ah --color=auto'
alias l='ls -CF --color=auto'
alias lla='ls -alh --color=auto'
alias llt='ls -lFht --color=auto'
alias lltr='ls -lFhtr --color=auto'
alias lld='ll -d */' #or could alias ll | grep ^d
alias llf='ll | grep -v ^d'

alias valgrindcms='valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --num-callers=20 --suppressions=$ROOTSYS/etc/valgrind-root.supp --track-origins=yes'

alias root='root -l'

alias scram8='scram b -j 8 USER_CXXFLAGS="-g"'
alias scram16='scram b -j 16 USER_CXXFLAGS="-g"'
alias scram32='scram b -j 32 USER_CXXFLAGS="-g"'
alias scram64='scram b -j 64 USER_CXXFLAGS="-g"'
alias scram128='scram b -j 128 USER_CXXFLAGS="-g"'
myscram() {
	mv ~/.rootlogon.C ~/dnc.rootlogon.C.dnc ;
	scram b -j ${1} USER_CXXFLAGS="-g" ;
	mv ~/dnc.rootlogon.C.dnc ~/.rootlogon.C ;
	return ; 
}

alias countr='source ~/Scripts/countFoldersAndFilesRecursively.sh'
alias count='source ~/Scripts/countFoldersAndFiles.sh'
alias clearf='source ~/Scripts/clearUnwantedFiles.sh'
alias clearfr='source ~/Scripts/clearUnwantedFilesRecursive.sh'
alias renameLinks='source ~/Scripts/renameLinks.sh'

alias fnal='ssh -Y aperloff@cmslpc-sl5.fnal.gov'

alias brazos='ssh -Y -o GSSAPIAuthentication=no aperloff@brazos.tamu.edu'
alias hurr='ssh -Y -o GSSAPIAuthentication=no aperloff@hurr.tamu.edu'
alias qint='qsub -I -X -V -d $PWD -q hepxrt'
alias qint8='qsub -I -X -V -d $PWD -q hepxrt -l nodes=1:ppn8'
alias sint='srun -p background-4g --pty --x11=first --mem 7600 --time 240 "bash"'
alias wsqueue='watch squeue -u aperloff'
alias checkq='~/Scripts/checkQueues_v3.sh -u aperloff -q "stakeholder stakeholder-4g background background-4g serial"'
alias checkq_long='~/Scripts/checkQueues_v3.sh -q "stakeholder stakeholder-4g serial"'
alias changeq='~/Scripts/changeQueue.sh'
alias mcp='~/Scripts/mcp.sh'
alias sacct_short='sacct  -X --format=jobid,ncpus,cputime,elapsed,state'
alias jec='source ~/Scripts/JECSetup.sh'
alias ME='source ~/Scripts/MatrixElementSetup.sh'
alias kserver_init='/usr/kerberos/bin/kinit -5 aperloff@CERN.CH'
export STORE=/fdata/hepx/store/
export FDATA=/fdata/hepx/store/user/aperloff/

alias lxplus='ssh -Y -o GSSAPIAuthentication=no aperloff@lxplus5.cern.ch'

alias io='ssh -Y -o GSSAPIAuthentication=no aperloff@io.physics.tamu.edu'

alias voms-proxy-init='voms-proxy-init -out ${HOME}/.x509up_u${UID}'
export X509_USER_PROXY=${HOME}/.x509up_u${UID}

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

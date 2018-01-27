#!/bin/csh
#
# Add any personal extra databases here:
#
#setenv UPS_EXTRA_DIR $HOME/p/upsdb
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get ups environment, and then setup the shrc product
# 
#if ( -f "/afs/fnal.gov/ups/etc/setups.csh" ) then
#    source "/afs/fnal.gov/ups/etc/setups.csh"
#endif
#
#if ( { ups exist shrc } ) then
#    setup shrc
#endif
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# start ssh-agent
if ( ! $?SSH_AGENT_PID ) then
  eval `ssh-agent -c` > /dev/null
endif
alias addkey 'ssh-add ~/.ssh/id_rsa'

# Place any items that you want executed even for non-interactive use here

#skip if not interactive shell
if ( $?prompt ) then

    set noclobber            #prevent overwrite when redirecting output
    set ignoreeof            #prevent accidental logouts

	set history=19000
	set savehist = (19000 merge)
	alias precmd 'history -M'
    #Define various aliases; user selects desired alias by removng the # sign 
    #alias a            alias
    #alias killit       kill -9         #guarantees that a process is killed
    #alias h            'history | tail'
    alias ll           ls -lh
    alias la           ls -ah          #see hidden files
	alias lla          ls -alh         #combines the previous two aliases
    alias lf           ls -CF          #check file TYPE (exe, dir ..)
	alias ld           ls -lhd
	alias lfile           "ls -l | egrep -v '^d'"
	alias ldir         "ls -l | egrep '^d'"
    #alias rmi          rm -i           #confirm before deletion
    #alias home         cd              #HOME
    #alias side         'cd ../\!*'     #side
    #alias down         'cd \!*'        #down
    #alias up           cd ..           #up
    #alias cpi          cp -i           #no overwrite of output file
    #alias cd          'cd \!*;echo $cwd'
    #alias mvi          mv -i           #confirm before moving
    #Next alias replaces standard info command on SGI platforms
    #alias info         Info            #get list of info articles
    #
    #VMS type commands
    #
    #alias dir          ls -l
    #alias copy         cp
    #alias rename       mv
    alias kinit '/usr/krb5/bin/kinit'

	set autocorrect
	set autoexpand
	set autolist = ambiguous
    set complete = enhance

	source /cvmfs/cms.cern.ch/cmsset_default.csh
	echo "   ##########################################################################"
	echo "    Setting HOME to /uscms/home/aperloff"
	echo "   ##########################################################################"
	setenv HOME /uscms/homes/a/aperloff

	set watch=(0 any any)

	#echo "You are now using SCRAM_ARCH = "$SCRAM_ARCH

	setenv CUDA_HOME /usr/local/cuda
    setenv ROOTSYS ${CMS_PATH}/lcg/external/root/3.10.02/${SCRAM_ARCH}/root
	#setenv ROOFITSYS ${CMS_PATH}/slc5_amd64_gcc462/lcg/roofit/5.32.03-cms4/
	setenv ROOFITSYS /cvmfs/cms.cern.ch/slc6_amd64_gcc491/lcg/roofit/5.34.18-cms3//
    setenv PATH ${PATH}:${ROOTSYS}/bin
	setenv PATH ${PATH}:${ROOFITSYS}/bin
	setenv PATH "${HOME}/Scripts":${PATH}
	setenv PATH ${CUDA_HOME}/bin:${PATH}
    #setenv TEXINPUTS .:~/latex/inputs:/usr/share/texmf/tex/latex/
    if (${?LD_LIBRARY_PATH}) then
      setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ROOTSYS}/lib:.
	  setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ROOFITSYS}/lib:.
	  setenv LD_LIBRARY_PATH ${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

    else

      setenv LD_LIBRARY_PATH ${ROOTSYS}/lib:.
      setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ROOFITSYS}/lib:.
	  setenv LD_LIBRARY_PATH ${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

    endif

	#source /uscmst1/prod/grid/gLite_SL5.csh
else
    #source /uscmst1/prod/sw/cms/cshrc prod
	#source /uscmst1/prod/grid/gLite_SL5.csh
	#source /uscmst1/prod/grid/CRAB/crab.csh

endif
#setenv XLIB_SKIP_ARGB_VISUALS 1

#when using slc6_amd64_gcc700 use this as well --suppressions=$PYTHON_VALGRIND_SUPP
alias valgrindcms 'valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --num-callers=20 --suppressions=$ROOTSYS/etc/valgrind-root.supp --track-origins=yes'

alias root 'root -l'

alias dasgoclient '/cvmfs/cms.cern.ch/common/dasgoclient'

alias scram8 'scram b -j 8'
alias scram8debug 'scram b -j 8 USER_CXXFLAGS="-g"'
alias scram16 'scram b -j 16'
alias scram16debug 'scram b -j 16 USER_CXXFLAGS="-g"'
#alias scram32 'scram b -j 32 USER_CXXFLAGS="-O0\ -g"'
alias scram32 'scram b -j 32'
alias scram32debug 'scram b -j 32 USER_CXXFLAGS="-g"'

alias count '~/Scripts/utilities/countFoldersAndFiles.sh'
alias countCrab '~/Scripts/utilities/eosCount.csh'
alias clearf '~/Scripts/utilities/clearUnwantedFiles.sh'
alias clearlim '~/Scripts/utilities/TAMUWW/clearLimitTestingFiles.py'
alias wcq 'watch -n 60 condor_q -global aperloff'
alias wct 'watch -n 60 condor_tail -maxbytes 300'
alias ct 'condor_tail -maxbytes 1024000'
alias cpDir '~/Scripts/utilities/copyDirectories.sh'
alias subLimHist '~/Scripts/utilities/TAMUWW/submitLimitHistograms.sh'
alias subSysHist '~/Scripts/utilities/TAMUWW/submitSysHistograms.sh'

alias ME 'source ~/Scripts/utilities/Setup/MatrixElementSetup.csh'
alias jec 'source ~/Scripts/utilities/Setup/JECSetup.csh'
alias vhbb 'source ~/Scripts/utilities/Setup/VHbbSetup.csh'
alias das 'source ~/Scripts/utilities/Setup/DASSetup.csh'
alias hats 'source ~/Scripts/utilities/Setup/HATSSetup.csh'
alias fpga 'source ~/Scripts/utilities/Setup/FPGASetup.csh'

alias brazos 'ssh -Y -o GSSAPIAuthentication=no aperloff@brazos.tamu.edu'
alias hurr 'ssh -Y -o GSSAPIAuthentication=no aperloff@hurr.tamu.edu'
alias lxplus 'ssh -Y -o GSSAPIAuthentication=no aperloff@lxplus5.cern.ch'
alias io 'ssh -Y -o GSSAPIAuthentication=no aperloff@io.physics.tamu.edu'

setenv STORE /store/user/aperloff/
setenv ESTORE /store/user/eusebi/
setenv EOSSTORE /eos/uscms$STORE
setenv EOS root://cmseos.fnal.gov/$STORE
setenv EEOS root://cmseos.fnal.gov/$ESTORE
setenv MEInput MatrixElement/Summer12ME8TeV/MEInput/
setenv MEResults MatrixElement/Summer12ME8TeV/MEResults/
setenv EMEResults Winter12to13ME8TeV/rootOutput/
setenv SMEInput $EOS/MatrixElement/Summer12ME8TeV/MEInput/
setenv SMEResults $EOS/MatrixElement/Summer12ME8TeV/MEResults/
setenv ESMEResults $EEOS/Winter12to13ME8TeV/rootOutput/
#xrdfs can use ls, mkdir, rm, rmdir, cat, tail, some 'query' (checksum for example), stat, ...
#Example: xrdfs root://cmseos.fnal.gov/ ls /store/user/aperloff
#Example: eosfind /store/user/aperloff
alias eosfind 'eos root://cmseos.fnal.gov/ find'
setenv EE /eos/uscms/store/user/eusebi/
setenv JME /eos/uscms/store/user/lpcjme/
setenv MBJA /eos/uscms/store/user/lpcmbja/
setenv LNUJJ /eos/uscms/store/user/lnujj/
alias rxrdcp 'python ~/Scripts/movefiles.py'
alias eosinfo 'eos root://cmseos.fnal.gov/ fileinfo'
alias xrdfsloc 'xrdfs cms-xrd-global.cern.ch locate -h -d'

#setenv CMSSW_GIT_REFERENCE /uscms_data/d2/aperloff/.cmsgit-cache/
setenv CMSSW_GIT_REFERENCE /cvmfs/cms.cern.ch/cmssw.git.daily/
#Sets the editor for crontab -e
setenv VISUAL 'emacs -nw'

# start ssh-agent
if ( ! $?SSH_AGENT_PID ) then
  eval `ssh-agent -c` > /dev/null
endif
alias addkey 'ssh-add ~/.ssh/id_rsa'

# for iTerm2
source ~/.iterm2_shell_integration.`basename $SHELL`

# to avoid urllib2 SSL: CERTIFICATE_VERIFY_FAILED
setenv SSL_CERT_DIR '/etc/pki/tls/certs:/etc/grid-security/certificates'

# makes sure the history file is not corrupted due to overloading because of the merging
alias exit 'source ~/.tcshrc.logout; ""exit'

# completions for interactive shells
#source $HOME/.tcshrc.complete

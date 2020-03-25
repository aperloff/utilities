#!/bin/bash

# For debugging a slowdown
# Remember to (un)comment the block at the bottom
#PS4='+ $(date "+%s.%N")\011 '
#exec 3>&2 2>/tmp/bashstart.$$.log
#set -x

###############
# Environment #
###############
set -o noclobber
set -o ignoreeof
set +o history
set -P
# History
# Avoid duplicates
export HISTCONTROL=ignoreboth:erasedups
# Don't save ls, ps and history commands
export HISTIGNORE="ls:ll:ps:history:exit"
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend
# Add Date and Time to Bash History
export HISTTIMEFORMAT="%h %d %H:%M:%S "
# Increase the number of commands to remember in the command history (default = 500)
export HISTSIZE=10000
# Increase the maximum number of lines contained in the history file (default = 500)
export HISTFILESIZE=10000
# Expand variables on tab. This is a workaround for the bug in tab completion which adds a slash before the $
# https://askubuntu.com/questions/70750/how-to-get-bash-to-stop-escaping-during-tab-completion
if [[ `uname -r` == *"el7"* ]]; then
	shopt -s direxpand
fi
# After each command, append to the history file and reread it
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

umask 0022
ulimit -s 11000

# GIT
export CMSSW_GIT_REFERENCE=/cvmfs/cms.cern.ch/cmssw.git.daily/

# Emacs
# Taken from: https://superuser.com/questions/204236/how-can-i-open-a-file-read-only-from-command-line-with-emacs-vi-vim
ev() {
  emacs "$1" "$2" --eval '(setq buffer-read-only t)'
}

# Sets the editor for crontab -e
export VISUAL='emacs -nw'

#Select the correct SLC version (you might need it later)
if [[ `uname -r` == *"el6"* ]]; then
    SLC_VERSION="slc6"
elif [[ `uname -r` == *"el7"* ]]; then
    SLC_VERSION="slc7"
else
    echo "WARNING::Unknown SLC version. Defaulting to SLC7."
    SLC_VERSION="slc7"
fi

# Set initial SCRAM_ARCH and CMS software
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
if [[ `hostname -s` != *cmslpc-cvmfs-install* ]]; then
  source $VO_CMS_SW_DIR/cmsset_default.sh
fi
export SCRAM_ARCH=${SLC_VERSION}_amd64_gcc630

# Kerberos
export KRB5_CONFIG=/home/hepxadmin/krb5.conf

# Grid Proxy
export X509_USER_PROXY=${HOME}/.x509up_u${UID}
# to avoid urllib2 SSL: CERTIFICATE_VERIFY_FAILED
export SSL_CERT_DIR='/etc/pki/tls/certs:/etc/grid-security/certificates'

# CUDA/Anaconda
#export CUDA_HOME=/usr/local/cuda
#export PATH=${CUDA_HOME}/bin:${PATH}
case `hostname -s` in
cmslpcgpu*|cmslpc-cvmfs-install*)
    source /cvmfs/cms-lpc.opensciencegrid.org/sl7/gpu/Setup.sh
	export CPATH=/cvmfs/cms-lpc.opensciencegrid.org/sl7/usr/local/cuda/bin/include:$CPATH
	export DYLD_LIBRARY_PATH=/cvmfs/cms-lpc.opensciencegrid.org/sl7/usr/local/cuda/lib:$DYLD_LIBRARY_PATH
	;;
esac

# ROOT
export ROOTSYS=${CMS_PATH}/${SCRAM_ARCH}/lcg/root/6.10.09-mmelna2/
export ROOFITSYS=${CMS_PATH}/${SCRAM_ARCH}/lcg/root/6.10.09-mmelna2/

# LD_LIBRARY_PATH
if [ ${LD_LIBRARY_PATH} ]; then
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib:.
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOFITSYS}/lib:.
    export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
else
    export LD_LIBRARY_PATH=${ROOTSYS}/lib:.
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOFITSYS}/lib:. 
    export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
fi

# cms-lpc.opencisncegrid.org
case `hostname -s` in
cmslpc1[0-9][0-9]*|cmslpcgpu*|cmslpc-cvmfs-install*)
	export PATH="/cvmfs/cms-lpc.opensciencegrid.org/sl7/bin/":${PATH}
	export SINGULARITY_CACHEDIR="/uscms_data/d2/aperloff/.singularity/cache"
	export SINGULARITY_LOCALCACHEDIR="/uscms_data/d2/aperloff/.singularity/cache"
    ;;
cmslpc*)
	export PATH="/cvmfs/cms-lpc.opensciencegrid.org/sl6/bin/":${PATH}
	;;
esac

# Needed to access FNAL EOS from remote server
if [[ `hostname -s` != *cmslpc* ]]; then
    export XrdSecGSISRVNAMES="cmseos.fnal.gov"
fi

# User Scripts
if [ -d "${HOME}/Scripts" ]; then
    export PATH="${HOME}/Scripts/":${PATH}
	export PATH="${HOME}/Scripts/lpc-scripts/":${PATH}
	export PATH="${HOME}/Scripts/utilities/":${PATH}
fi

# User Executables
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin":${PATH}
fi

# LaTeX
#export TEXINPUTS .:~/latex/inputs:/usr/share/texmf/tex/latex/

#####################
# Interactive Shell #
#####################

# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ $- = *i* ]] && source ~/Scripts/liquidprompt/liquidprompt

#Tab Completion
#set autocorrect
#export autoexpand
#export autolist=ambiguous
#set complete = enhance
if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

##########
# iTerm2 #
##########
source ~/.iterm2_shell_integration.`basename $SHELL`
#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
iterm2_commands() {
cat << EOF
    imgcat filename
      Displays the image inline.
    imgls
      Shows a directory listing with image thumbnails
    it2attention start|stop|fireworks
      Gets your attention
    it2check
      Checks if the terminal is iTerm2
    it2copy [filename]
      Copies to the pasteboard
    it2dl filename
      Downloads the specified file, saving it in your Downloads folder.
    it2setcolor ...
      Changes individual color settings or loads a color preset
    it2setkeylabel ...
      Changes Touch Bar function key labels
    it2ul
      Uploads a file
    it2universion
      Sets the current unicode version
EOF
}

###########
# Aliases #
###########
# Define various aliases; user selects desired alias by removng the # sign 
alias is_interactive="[[ $- == *i* ]] && echo 'True' || echo 'False'"
alias is_login="shopt -q login_shell && echo 'True' || echo 'False'"

# skip if not interactive shell
case "$-" in
  *i*)
      alias a=alias
      alias killit='kill -9'                #guarantees that a process is killed
      alias h='history | tail'

      alias ll='ls -lFh --color=auto'
      alias la='ls -Ah --color=auto'        #see hidden files
      alias lla='ls -alh --color=auto'      #combines the previous two aliases
      alias l='ls -CF --color=auto'         #check file TYPE (exe, dir ..)
      alias ld='ls -lhd --color=auto'
      alias llt='ls -lFht --color=auto'
      alias lltr='ls -lFhtr --color=auto'
      alias lld='ll -d */' #or could alias ll | grep ^d
      alias llf='ll | grep -v ^d'
      alias lfile="ls -l | egrep -v '^d'"
      alias ldir="ls -l | egrep '^d'"
      #alias rmi          rm -i             #confirm before deletion
      #alias home         cd                #HOME
      #alias side         'cd ../\!*'       #side
      #alias down         'cd \!*'          #down
      #alias up           cd ..             #up
      #alias cpi          cp -i             #no overwrite of output file
      #alias cd          'cd \!*;echo $cwd'
      #alias mvi          mv -i             #confirm before moving
      #Next alias replaces standard info command on SGI platforms
      #alias info         Info              #get list of info articles
      #
      #VMS type commands
      #
      #alias dir          ls -l
      #alias copy         cp
      #alias rename       mv
      ;;
  *)  echo "This shell is not interactive. Some aliases not set."
      ;;
esac

# Computer Information
alias ncpu='grep -c ^processor /proc/cpuinfo'
alias gpuinfo='lspci | grep -i nvidia'
alias linuxinfo='uname -m && cat /etc/*release'

# User Information
alias myinfo='finger aperloff'

# Encrypt/Decrypt Files
# Use as 'encrypt <file>' or 'decrypt <file>.gpg'
alias encrypt='gpg -c'
alias dycrypt='gpg'

# Kerberos
alias kinit='/usr/krb5/bin/kinit'
alias kinit_cern='/usr/bin/kinit -5 -A'
alias kinitfnal='/usr/bin/kinit aperloff@FNAL.GOV'

# Valgrind
#when using slc6_amd64_gcc700 use this as well --suppressions=$PYTHON_VALGRIND_SUPP
alias valgrindcms='valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --num-callers=20 --suppressions=$ROOTSYS/etc/valgrind-root.supp --track-origins=yes'

# ROOT
alias root='root -l'

# SCRAM
alias cmsunsetenv='eval scramv1 unsetenv -sh'
alias scram4='scram b -j 4'
alias scram4debug='scram b -j 4 USER_CXXFLAGS="-g"'
alias scram8='scram b -j 8'
alias scram8debug='scram b -j 8 USER_CXXFLAGS="-g"'
alias scram16='scram b -j 16'
alias scram16debug='scram b -j 16 USER_CXXFLAGS="-g"'
alias scram32='scram b -j 32'
alias scram32debug='scram b -j 32 USER_CXXFLAGS="-g"'
#alias scram32='scram b -j 32 USER_CXXFLAGS="-O0\ -g"'
myscram() {
	mv ~/.rootlogon.C ~/dnc.rootlogon.C.dnc ;
	scram b -j ${1} USER_CXXFLAGS="-g" ;
	mv ~/dnc.rootlogon.C.dnc ~/.rootlogon.C ;
	return ; 
}

# CMSSW
alias cmslist='source /cvmfs/cms.cern.ch/cmsset_default.sh'
alias cmsib1='source /cvmfs/cms-ib.cern.ch/week1/cmsset_default.sh'
alias cmsib0='source /cvmfs/cms-ib.cern.ch/week0/cmsset_default.sh'
#alias cmsenv='eval `scram runtime -sh`; PATH=${CMSSW_BASE}/test/${SCRAM_ARCH}/:${PATH}'

# cache dir tag creator
alias cachedir='echo "Signature: 8a477f597d28d172789f06886806bc55\n# This file is a cache directory tag.\n# For information about cache directory tags, see:\n#       http://www.brynosaurus.com/cachedir/" > CACHEDIR.TAG'

# HERMIT
alias manageJobs='python $CMSSW_BASE/src/Condor/Production/python/manageJobs.py'

# Scripts
alias duSort='${HOME}/Scripts/utilities/duSort.sh'
alias count='${HOME}/Scripts/utilities/countFoldersAndFiles.sh'
alias countCrab='${HOME}/Scripts/utilities/eosCount.csh'
alias clearf='${HOME}/Scripts/utilities/clearUnwantedFiles.sh'
alias clearlim='${HOME}/Scripts/utilities/TAMUWW/clearLimitTestingFiles.py'
alias renameLinks='${HOME}/Scripts/renameLinks.sh'
alias cpDir='${HOME}/Scripts/utilities/copyDirectories.sh'
alias subLimHist='${HOME}/Scripts/utilities/TAMUWW/submitLimitHistograms.sh'
alias subSysHist='${HOME}/Scripts/utilities/TAMUWW/submitSysHistograms.sh'
alias mcp='${HOME}/Scripts/utilities/mcp.sh'
alias git-delete-branch='${HOME}/Scripts/utilities/Git/git-delete-branch'
alias git-move-commits='${HOME}/Scripts/utilities/Git/git-move-commits'
alias git-pull-pr='${HOME}/Scripts/utilities/Git/git-pull-pr'
alias git-copy-untracked='${HOME}/Scripts/utilities/Git/git-copy-untracked'

#Globus Connect Personal
alias globus_start='${HOME}/globusconnectpersonal-2.3.3/globusconnectpersonal -start -restrict-paths rw/uscms_data/d2/aperloff/ &'
alias globus_status='${HOME}/globusconnectpersonal-2.3.3/globusconnectpersonal -status'
alias group_members='getent group | grep lpccvmfs'

# SSH
alias fnal5='ssh -Y aperloff@cmslpc-sl5.fnal.gov'
alias fnal6='ssh -Y aperloff@cmslpc-sl6.fnal.gov'
alias fnal7='ssh -Y aperloff@cmslpc-sl7.fnal.gov'
alias fnal=fnal7
alias brazos='ssh -Y -o GSSAPIAuthentication=no aperloff@login.brazos.tamu.edu'
alias lxplus='ssh -Y -o GSSAPIAuthentication=no aperloff@lxplus.cern.ch'
alias io='ssh -Y -o GSSAPIAuthentication=no aperloff@io.physics.tamu.edu'

# Setup Scripts
alias ME_legacy='source ${HOME}/Scripts/utilities/Setup/MatrixElementSetup.csh'
alias jec_legacy='source ${HOME}/Scripts/utilities/Setup/JECSetup.csh'
alias vhbb_legacy='source ${HOME}/Scripts/utilities/Setup/VHbbSetup.csh'
alias das_legacy='source ${HOME}/Scripts/utilities/Setup/DASSetup.csh'
alias hats_legacy='source ${HOME}/Scripts/utilities/Setup/HATSSetup.csh'
case `hostname` in
cmslpc* | login.uscms.org)
	alias setup='source ${HOME}/Scripts/utilities/Setup/Setup.sh'
	alias fpga='source ${HOME}/Scripts/utilities/Setup/FPGASetup.csh'
	alias awssetup='exec tcsh -c "source ~burt/awscli/bin/activate.csh ; exec tcsh"'
	;;
*)
	alias setup='source ${HOME}/utilities/Setup/Setup.sh'
esac

if [ -f /usr/bin/condor_submit ]; then
  alias wcq='watch -n 60 condor_q -global aperloff'
  alias wct='watch -n 60 condor_tail -maxbytes 300'
  alias ct='condor_tail -maxbytes 1024000'
fi
if [ -f /usr/bin/squeue ]; then
  alias sint='srun -p background-4g --pty --x11=first --mem 7600 --time 240 "bash"'
  alias wsqueue='watch squeue -u aperloff'
  alias checkq='${HOME}/Scripts/utilities/PBS_Slurm/checkQueues_slurm.sh -u aperloff -q "stakeholder stakeholder-4g background background-4g serial"'
  alias checkq_long='${HOME}/Scripts/utilities/PBS_Slurm/checkQueues_slurm.sh -q "stakeholder stakeholder-4g serial"'
  alias changeq='${HOME}/Scripts/utilities/PBS_Slurm/changeQueue.sh'
  alias sacct_short='sacct  -X --format=jobid,ncpus,cputime,elapsed,state'
fi
if [ -f /usr/bin/qsub ]; then
  alias qint='qsub -I -X -V -d $PWD -q hepxrt'
  alias qint8='qsub -I -X -V -d $PWD -q hepxrt -l nodes=1:ppn8'
fi

case `hostname -s` in
hurr|brazos|login*)
  export STORE=/fdata/hepx/store/
  export FDATA=/fdata/hepx/store/user/aperloff/
  ;;
cmslpc*)
  export STORE=/store/user/aperloff/
  export ESTORE=/store/user/eusebi/
  export EOSSTORE=/eos/uscms$STORE
  export EOS=root://cmseos.fnal.gov/$STORE
  export EEOS=root://cmseos.fnal.gov/$ESTORE
  export MEInput=MatrixElement/Summer12ME8TeV/MEInput/
  export MEResults=MatrixElement/Summer12ME8TeV/MEResults/
  export EMEResults=Winter12to13ME8TeV/rootOutput/
  export SMEInput=$EOS/MatrixElement/Summer12ME8TeV/MEInput/
  export SMEResults=$EOS/MatrixElement/Summer12ME8TeV/MEResults/
  export ESMEResults=$EEOS/Winter12to13ME8TeV/rootOutput/
  export EE=/eos/uscms/store/user/eusebi/
  export JME=/eos/uscms/store/user/lpcjme/
  export MBJA=/eos/uscms/store/user/lpcmbja/
  export LNUJJ=/eos/uscms/store/user/lnujj/
  export EOSL1PFInputs=/eos/cms/store/cmst3/user/jngadiub/L1PFInputs/
  ;;
esac

# XRootD
#xrdfs can use ls, mkdir, rm, rmdir, cat, tail, some 'query' (checksum for example), stat, ...
#Example: xrdfs root://cmseos.fnal.gov/ ls /store/user/aperloff
#Example: eosfind /store/user/aperloff
alias eosfind='eos root://cmseos.fnal.gov/ find'
alias rxrdcp='python ${HOME}/Scripts/lpc_scripts/movefiles.py'
alias eosinfo='eos root://cmseos.fnal.gov/ fileinfo'
alias xrdfsloc='xrdfs cms-xrd-global.cern.ch locate -h -d'
alias xrddebugon='export XRD_LOGLEVEL=Debug'
alias xrddebugoff='unset XRD_LOGLEVEL'

function list_redirectors {
	declare -A redirectors
	redirectors['CERN (EOS)']="eoscms.cern.ch"
	redirectors['Europe/Asia']="xrootd-cms.infn.it"
	redirectors['FNAL']="cmsxrootd.fnal.gov"
	redirectors['FNAL (site)']="cmsxrootd-site.fnal.gov"
	redirectors['FNAL (EOS)']="cmseos.fnal.gov"
	redirectors['Global']="cms-xrd-global.cern.ch"
	redirectors['Open Data']="eospublic.cern.ch"
	redirectors['CERNBOX (T2_CH_CERNBOX)']="eosuser.cern.ch"
	declare -A user_areas
	user_areas['CERN (EOS)']="/store/user/<username>"
	user_areas['Europe/Asia']="/store/user/<username>"
	user_areas['FNAL']="/store/user/<username>"
	user_areas['FNAL (site)']="/store/user/<username>"
	user_areas['FNAL (EOS)']="/eos/uscms/store/user/<username>"
	user_areas['Global']="/store/user/<username>"
	user_areas['Open Data']="/eos/opendata/cms/"
	user_areas['CERNBOX (T2_CH_CERNBOX)']="/eos/user/<first letter in username>/<username>/"
	printf "%-30s %-30s %-30s\n" "Location/Region" "Redirector" "User Storage Path"
	printf "%-30s %-30s %-30s\n" "---------------" "----------" "-----------------"
	for K in "${!redirectors[@]}"; do printf "%-30s %-30s %-30s\n" "$K:" "${redirectors[$K]}" "${user_areas[$K]}"; done | sort -n -k1
}

# cern-get-sso-cookie
#alias cern-get-sso-cookie='/cvmfs/cms-lpc.opensciencegrid.org/sl7/bin/cern-get-sso-cookie --capath /etc/grid-security/certificates'
#alias sso-curl='curl --capath /etc/grid-security/certificates -L --cookie ~/private/ssocookie.txt --cookie-jar ~/private/ssocookie.txt'
alias sso-curl='curl -L --cookie ~/private/ssocookie.txt --cookie-jar ~/private/ssocookie.txt'

# FTS
fts-status () {
	#example: fts-status <job-id> <server>
	fts-transfer-status -v -s ${2:-https://cmsfts3.fnal.gov:8446} ${1} -F
}
fts-priority-helper() {
	args=()
	args+=( '-s' "${1}" "${2}" "${3}" )
	echo -e "# Command : fts-set-priority ${args[@]}"
	IFS=$'\n' __priority_status=($(fts-set-priority "${args[@]}"));
}
fts-submit-helper() {
  args=()
  args+=( '-v' '-s' "${4}" '-f' "${1}" '-K' '--job-metadata' '{"issuer": "Alexx"}' "${5}")
  (( "${3}" == "true" )) && args+=( '-o' )

  if [[ "${2}" == "true" ]]; then
	  echo -e "# Dry-run : true\n# Command : fts-transfer-submit ${args[@]}"
  else
	  echo -e "# Command : fts-transfer-submit ${args[@]}"
	  IFS=$'\n' __job_id=($(fts-transfer-submit "${args[@]}"));
	  printf "%s\n" "${__job_id[@]}";
  fi
}
fts-submit () {
	local dryrun="false"
	local overwrite="false"
	local other=""
	local server="https://cmsfts3.fnal.gov:8446"
	local priority=3
	local usage="$FUNCNAME [-h] [-d] [-o] [-O <other options>] [-p <priority>] [-s <server name>] <file list to submit>
    -- submits a list of file transfers to FTS.

    where:
        -d  echo the command rather than submitting to FTS (default: ${dryrun})
        -h  show this help message
        -o  overwrite any previously existing files at the destination (default: ${overwrite})
        -O  passthrough for other fts-transfer-submit options
        -p  set the job priority after submission (default: ${priority})
        -s  change the FTS server (default: ${server})
              commonly used servers:
                FNAL: https://cmsfts3.fnal.gov:8446
                FNAL (backup): https://cmsftssrv2.fnal.gov:8446
                CERN: https://fts3.cern.ch:8449

    example: fts-submit fts_transfer_file_list.txt"

	local OPTIND OPTARG
	while getopts 'hdoO:p:s:' option; do
		case "$option" in
			d) dryrun="true"
			   ;;
			h) echo "$usage"
			   return 0
			   ;;
			o) overwrite="true"
			   ;;
			O) other=$OPTARG
			   ;;
			p) priority=$OPTARG
			   ;;
			s) server=$OPTARG
			   ;;
            :) printf "missing argument for -%s\n" "$OPTARG" >&2
               echo "$usage" >&2
               return -1
               ;;
            \?) printf "illegal option: -%s\n" "$OPTARG" >&2
                echo "$usage" >&2
                return -2
                ;;
        esac
	done
	shift $((OPTIND - 1))

	fts-submit-helper ${1} ${dryrun} ${overwrite} ${server} ${other}

	if [[ "${dryrun}" == "false" ]]; then
		local server_url=${server%:*}
		echo
		echo "Job status: ${server_url}:8449/fts3/ftsmon/#/job/${__job_id[-1]}"

		if [[ "${priority}" != "3" ]]; then
			echo "Job priority: ${priority}"
			fts-priority-helper ${server} ${__job_id[-1]} ${priority}
		fi
	fi
}

# For debugging a slowdown
#set +x
#exec 2>&3 3>&-

#Reinitiate history
set -o history


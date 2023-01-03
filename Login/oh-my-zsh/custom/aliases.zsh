########################
# User defined aliases #
########################

#
# Command wrappers
#

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#
# Kerberos aliases
#
# Need this alias because the kereros5 package from MacPorts is overriding the system kerberos
alias kinit='/usr/bin/kinit'
# After chainging the Kerberos password, you will need to use this alias the first time to save the new password to the keychain
alias kinit_keychain='/usr/bin/kinit --keychain'

#
# ls aliases
#
# Some of these will override the default aliases from oh-my-zsh
alias ll='ls -lFh'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -alFh'

#
# ROOT
#
#alias root='root6 -l'
#pushd /usr/local >/dev/null; . bin/thisroot.sh; popd >/dev/null

#
# Script aliases
#
alias count='/opt/utilities/countFoldersAndFiles.sh'
alias clearf='/opt/utilities/clearUnwantedFiles.sh'
alias TDRSetup='source /opt/utilities/TDRSetup.sh'
alias TDRCompile='source /opt/utilities/TDRCompile.sh'
alias TDROpen='source /opt/utilities/TDROpen.sh'

#
# SSH
#
alias ssh='ssh -o TCPKeepAlive=no -o ServerAliveInterval=15'
alias fnal6='ssh -Y aperloff@cmslpc-sl6.fnal.gov'
alias fnal7='ssh -Y aperloff@cmslpc-sl7.fnal.gov'
alias fnal8='ssh -Y aperloff@cmslpc-c8-heavy01.fnal.gov'
alias fnal='fnal7'
alias fnaljupyter7='ssh -Y -L localhost:8888:localhost:8888 -L localhost:8787:localhost:8787 aperloff@cmslpc-sl7.fnal.gov'
alias fnaljupyter8='ssh -Y -L localhost:8888:localhost:8888 -L localhost:8787:localhost:8787 aperloff@cmslpc-c8-heavy01.fnal.gov'
alias fnaljupyter='fnaljupyter7'
alias fnalgpu='ssh -Y aperloff@cmslpcgpu1.fnal.gov'
alias fnalcvmfs='ssh -Y aperloff@cmslpc-cvmfs-install.fnal.gov'
alias fnalbuild7='ssh -Y aperloff@cmslpc-sl7-heavy.fnal.gov'
alias fnalbuild8='ssh -Y aperloff@cmslpc-c8-heavy01.fnal.gov'
alias fnalbuild='fnalbuild8'
alias lxplusgpu='ssh -Y aperloff@lxplus-gpu.cern.ch'
alias lxplustunnel='ssh -Y aperloff@lxtunnel.cern.ch'
alias lxplusfuture='ssh -Y aperloff@lxplus-future.cern.ch'
alias lxplus6='ssh -Y -o GSSAPIAuthentication=no aperloff@lxplus6.cern.ch'
alias lxplus7='ssh -Y -o GSSAPIAuthentication=no aperloff@lxplus7.cern.ch'
alias lxplus8='ssh -Y -o GSSAPIAuthentication=no aperloff@lxplus8.cern.ch'
alias lxplus='lxplus7'
alias culogin='ssh -Y -C aperloff@culogin01.colorado.edu'
alias cmsconnect6='ssh -Y aperloff@login.uscms.org'
alias cmsconnect7='ssh -Y aperloff@login-el7.uscms.org'
alias cmsconnect='cmsconnect7'

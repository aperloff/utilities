[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc
[ -f /etc/bashrc ] && . /etc/bashrc
#[ -f /etc/profile ] && source /etc/profile
[ -f ~/.bash_profile ] && [[ $- = *i* ]] && . ~/.bash_profile
#umask 077
umask 0022

case `hostname -s` in
cmslpcgpu*|cmslpc-cvmfs-install*)
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/cvmfs/cms-lpc.opensciencegrid.org/sl7/gpu/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/cvmfs/cms-lpc.opensciencegrid.org/sl7/gpu/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/cvmfs/cms-lpc.opensciencegrid.org/sl7/gpu/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/cvmfs/cms-lpc.opensciencegrid.org/sl7/gpu/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
;;
esac

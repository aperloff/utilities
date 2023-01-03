######################################
# User defined environment variables #
######################################

#
# Anaconda2 stuff
#
# Currently obsolete
#export PATH="/anaconda2/bin:$PATH"

#
# Editor Settings
#
export VISUAL="emacs -nw"

#
# Home
#
export PATH=${HOME}/bin/:$PATH

#
# Latex
#
# Currently obsolete
#export PATH=/usr/local/texlive/2015/bin/x86_64-darwin/:$PATH

#
# Nvidia CUDA
#
# Currently obsolete
#export PATH=/Developer/NVIDIA/CUDA-7.5/bin:$PATH
#export DYLD_LIBRARY_PATH=/Developer/NVIDIA/CUDA-7.5/lib:$DYLD_LIBRARY_PATH

#
# ROOT
#
# Currently obsolete
#export ROOTTUTORIALS=/opt/local/share/root6/doc/root/tutorials/


#
# XrootD
#
export XrdSecGSISRVNAMES="cmseos.fnal.gov"

#
# Kubernetes
#
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config-servicex:$HOME/.kube/config-servicex-cms:$HOME/.kube/config-cms-servicex


#
# Homebrew
#
# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

#
# Pyenv (Homebrew Installed)
#
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#
# Ruby (Homebrew)
#

#By default, binaries installed by gem will be placed into:
#  /opt/homebrew/lib/ruby/gems/3.0.0/bin

#You may want to add this to your PATH.

#ruby is keg-only, which means it was not symlinked into /usr/local,
#because macOS already provides this software and installing another version in
#parallel can cause all kinds of trouble.

#If you need to have ruby first in your PATH, run:
#  echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

#For compilers to find ruby you may need to set:
#  export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
#  export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

#For pkg-config to find ruby you may need to set:
#  export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"

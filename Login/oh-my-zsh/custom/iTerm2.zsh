#########################
# iTerm2 Customizations #
#########################

#
# Shell Integrations
#
test -e "${HOME}/.iterm2_shell_integration.zsh" && source ${HOME}/.iterm2_shell_integration.`basename $SHELL`

#
# Renames tab, terminal, or both
#
# $1 = type; 0 - both, 1 - tab, 2 - title
# rest = text
setTerminalText () {
    # echo works in bash & zsh
    local mode=$1 ; shift
    echo -ne "\033]$mode;$@\007"
}
rboth  () { setTerminalText 0 $@; }
rtab   () { setTerminalText 1 $@; }
rtitle () { setTerminalText 2 $@; }
# uncomment below for shorter version
#rtab() { echo -ne "\033]0;"$@"\007";}
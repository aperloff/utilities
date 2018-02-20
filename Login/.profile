#echo "HOME variable is originally set to '$HOME'"
export HOME=`pwd`
echo "   ##########################################################################"
echo "    Setting HOME to ${HOME}"
echo "   ##########################################################################"

test -e "${HOME}/.iterm2_shell_integration.sh" && source "${HOME}/.iterm2_shell_integration.sh"

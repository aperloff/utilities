##############################
# Daemons that need to start #
##############################

#
# Start ssh-agent
#
if [ ! $SSH_AGENT_PID ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi
alias addkey='ssh-add ~/.ssh/id_rsa'

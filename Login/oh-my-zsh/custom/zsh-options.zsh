#######################
# Set the zsh options #
#######################
# See `man zshoptions` for more information

#
# Prevent duplicates when hitting the up arrow in the shell
# Options: HIST_FIND_NO_DUPS, HIST_IGNORE_ALL_DUPS, HIST_IGNORE_DUPS, HIST_SAVE_NO_DUPS
# Note: HIST_FIND_NO_DUPS may not work on OSX Mojave. Alternative is to use HIST_IGNORE_DUPS
#
setopt HIST_FIND_NO_DUPS

#
# If  the  internal  history  needs  to be trimmed to add the current command line, setting this option will
#  cause the oldest history event that has a duplicate to be lost before losing a unique event from the list.
# More information in man pages
#
setopt HIST_EXPIRE_DUPS_FIRST

#
# Remove command lines from the history list when the first character on the line is a space, or when one of
#  the  expanded  aliases  contains a leading space.
# More information in man pages
#
setopt HIST_IGNORE_SPACE

#
# If  this  is set, zsh sessions will append their history list to the history file, rather than replace it.
# In other words, they will write to the history file immediately, not when the shell exits.
# Options: APPEND_HISTORY, EXTENDED_HISTORY, INC_APPEND_HISTORY, INC_APPEND_HISTORY_TIME, SHARE_HISTORY
# More information in man pages
#
setopt INC_APPEND_HISTORY_TIME

#
# Share history between all sessions.
# Off because it's mutually exclusive with INC_APPEND_HISTORY_TIME 
#    
#setopt SHARE_HISTORY

#
# Remove superfluous blanks before recording entry.
#
setopt HIST_REDUCE_BLANKS

#
# Don't execute immediately upon history expansion.
#
setopt HIST_VERIFY

#
# Beep when accessing nonexistent history.
#
setopt HIST_BEEP

#
# How many lines of history to keep in memory
#
HISTSIZE=100000

#
# How many lines to keep in the history file
#
SAVEHIST=50000
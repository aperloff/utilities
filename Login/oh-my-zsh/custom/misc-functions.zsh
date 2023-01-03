###########################
# Miscellaneous functions #
###########################

#
# If your starting a command that will run for a while and want to be notified when it’s completed, you can do:
#   long_cmd ; growl "command completed"
#
growl() { echo -e $'\e]9;'${1}'\007' ; return  ; }

#
# Convert an SVG file to a PDF
#
svgpdf() {
    # Old
    #"/Applications/Inkscape.app/Contents/Resources/bin/Inkscape" "$PWD"/$1 -A="$PWD"/$1.pdf --without-gui
    # From: https://superuser.com/a/723031
    rsvg-convert -h ${2:-1200} ${1} > "${1%.*}.png"
}

#
# Change the screenshot format
#  may need to use "killall SystemUIServer" to have the change take effect
#
screenshot_format() { defaults write com.apple.screencapture type ${1}; }

#
# make less more friendly for non-text input files, see lesspipe(1)
#
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
# If this is an xterm set the title to user@host:dir
#
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#
# List the files inside a tarball, filters them by size, and then sorts them by size in descending order.
# This will print out the size and path of each file.
# Based on: https://stackoverflow.com/a/39615827
#
tarsort() {
  local file=$1
  local size=${2:=10485760} #default: 1KB in B
  echo "Filtering out files with size less than ${2} bytes."
  tar tvf ${file} \
    | awk -v size="${size}" '$5 >= size {print $5" "$9}' \
    | sort -t' ' -k1,1nr
}

#
# Quickly delete directories w/ many files using rsync
# Based on: https://github.com/kpedro88/utilities/blob/master/del_fast.sh
#
del_fast() {
  DIRTODEL=$1

  if [[ -z $1 ]]; then
    echo "No directory specified"
    exit 0
  fi

  EMPTYDIR="empty"`date +%s%N`
  mkdir $EMPTYDIR
  echo "deleting ${DIRTODEL} with rsync..."
  rsync -a --delete ${EMPTYDIR}/ ${DIRTODEL}/
  rm -rf ${EMPTYDIR}
  rm -rf ${DIRTODEL}
}

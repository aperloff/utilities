#ps aux | grep $USER | grep ssh-agent | grep -v grep | awk '{print $2}' | xargs -Ireplace kill replace
#pkill -f ssh-agent -u aperloff

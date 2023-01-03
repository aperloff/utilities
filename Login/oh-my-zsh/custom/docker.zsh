##############################################
# Customizations/functions related to docker #
##############################################

source /opt/vivado-docker/.xilinx_docker
source /opt/cms-cvmfs-docker/.cms-cvmfs-docker
source /opt/TreeMaker/.treemaker_docker
alias dxrd='cvmfs_docker -m "cms.cern.ch oasis.opensciencegrid.org" -l `pwd` -r /root/local_mount/'
alias docker_cleanup='docker rmi $(docker images -f "dangling=true" -q)'
alias docker_list_dangling='docker images -f "dangling=true" -q'
alias emjdockercreate='cvmfs_docker -d -v -s -m "cms.cern.ch oasis.opensciencegrid.org sft.cern.ch" -l /Users/aperloff/Documents/CMS/EXO/EMJAnalysis/ -r /home/cmsuser/EMJAnalysis/ -n EMJAnalysis'

function docker_get_image_size {
    local res=""
    res=`curl -s -H "Authorization: JWT " "https://hub.docker.com/v2/repositories/${1}/tags/?page_size=100&page=1" | jq -r ".results[] | select(.\"name\"==\"${2}\") | .images[0].size" | numfmt --to=iec-i`
    echo "${1}:${2} = ${res}"
}

# From: https://docs.docker.com/docker-hub/download-rate-limit/
# From: https://github.com/mike-engel/jwt-cli
function docker_get_rate_limit {
    local ACCOUNT=""
    local AUTHENTICATED="false"
    local REPO=""
    local VERBOSE="-s"

    local usage="$FUNCNAME [options]
    -- Determines the rate limit for a given repo in DockerHub

    where:
        -a [account]          the DockerHub account (default: ${ACCOUNT})
        -A                    check the rate limit for an authenticated account (default: ${AUTHENTICATED})
        -h                    show this help text
        -r [repository]       the repository in DockerHub (default: ${REPO})
        -v                    print extra information (default: ${})

    example: docker_get_rate_limit -a <account> -r <repo>"

    local OPTIND OPTARG
    while getopts 'a:Ahr:v' option; do
        case "$option" in
            a) ACCOUNT=$OPTARG
               ;;
	    A) AUTHENTICATED="true"
	       ;;
            h) echo "$usage"
               return 0
               ;;
            r) REPO=$OPTARG
               ;;
            v) VERBOSE=""
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

    local TOKEN=""
    if [[ "${AUTHENTICATED}" == "true" ]]; then
	local USERNAME='aperloff'
	local PASSWORD=$(security find-internet-password -w -l 'Docker Credentials' -a 'aperloff' -j 'https://hub.docker.com/')
	if [ -z ${PASSWORD} ]; then
	    echo "Could not get the DockerHub password from the keychain."
	    return 1
	fi
	TOKEN=$(curl ${VERBOSE} --user "${USERNAME}:${PASSWORD}" "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${ACCOUNT}/${REPO}:pull" | jq -r .token)
    else
	TOKEN=$(curl ${VERBOSE} "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${ACCOUNT}/${REPO}:pull" | jq -r .token)
    fi

    if [[ -z "$VERBOSE" ]]; then
	jwt decode $TOKEN
    fi

    curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/${ACCOUNT}/${REPO}/manifests/latest 2>&1 | grep ratelimit
}

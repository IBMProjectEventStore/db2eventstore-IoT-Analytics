#!/bin/bash

# path within container
SETUP_PATH="/root/db2eventstore-IoT-Analytics/container/setup"
USER_VOLUME=${HOME}/eventstore_demo_volume

if [ -f ${HOME}/.user_info ]; then
    echo "File: '.user-info' found in the current directory."
    echo "Extracting user information from the file."
    EVENT_USER=$(grep  "username" ${HOME}/.user_info |awk {'print $2'})
    EVENT_PASSWORD=$(grep  "password" ${HOME}/.user_info |awk {'print $2'})
fi

function usage()
{
cat <<-USAGE #| fmt
Description:
This script is the entrypoint of the eventstore_demo container. The script takes
target Event Store server's public IP, Watson Studio Local's username, and password.
The script will start docker container in interactive mode using the 
image: eventstore_demo:latest.

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--IP        Public IP address of the target Event Store server.
--user      User name of the Watson Studio Local user
--password  Password of the Watson Studio Local user
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --IP)
        IP="$2"
        shift 2
        ;;
    --user)
        EVENT_USER="$2"
        shift 2
        ;;
    --password)
        EVENT_PASSWORD="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

if [ -z ${EVENT_USER} ]; then
    echo "Error: Please provide the Watson Studio Local user name with --user flag"
    usage >&2
    exit 1
fi

if [ -z ${EVENT_PASSWORD} ]; then
    echo "Error: Please provide the Watson Studio Local password with --password flag"
    usage >&2
    exit 1
fi

if [ -z ${IP} ]; then
    echo "Error: Please provide the Event Store server's public IP with --IP flag"
    usage >&2
    exit 1
fi

mkdir -p ${USER_VOLUME}
# start container in interactive mode

docker run -it --name eventstore_demo_${EVENT_USER} -v ${USER_VOLUME}:/root/user_volume \
    -e EVENT_USER=${EVENT_USER} -e EVENT_PASSWORD=${EVENT_PASSWORD} -e IP=${IP} \
    eventstore_demo:latest \
    bash -c "${SETUP_PATH}/setup-ssl.sh && ${SETUP_PATH}/entrypoint_msg.sh && bash --login"

echo "Cleaning up dangling images and/or exited containers"
docker rmi $(docker images -q -f dangling=true) > /dev/null 2>&1
docker rm -v $(docker ps -a -q -f status=exited) > /dev/null 2>&1
echo "Exited container successfully!"
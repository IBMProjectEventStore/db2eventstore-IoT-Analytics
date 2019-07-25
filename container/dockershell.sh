#!/bin/bash

SETUP_PATH="/root/db2eventstore-IoT-Analytics/container/setup"

function usage()
{
cat <<-USAGE #| fmt
Description:
This script is the entrypoint of the event_store_demo container. The script takes
target Event Store server's public IP, Watson Studio Local's username, and password.
The script will create the docker container using the image: event_store_demo:latest,
and start a bash session in the container.

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
        USER="$2"
        shift 2
        ;;
    --password)
        PASSWORD="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

if [ -z ${USER} ]; then
    echo "Error: Please provide the Watson Studio Local user name with --user flag"
    usage >&2
    exit 1
fi

if [ -z ${PASSWORD} ]; then
    echo "Error: Please provide the Watson Studio Local password with --password flag"
    usage >&2
    exit 1
fi

if [ -z ${IP} ]; then
    echo "Error: Please provide the Event Store server's public IP with --IP flag"
    usage >&2
    exit 1
fi

#TODO: handle background docker ps created by docker run.
CONTAINER_ID=$(docker run -d \
                -e USER=${USER} -e PASSWORD=${PASSWORD} -e IP=${IP} \
                event_store_demo:latest \
                bash -c "${SETUP_PATH}/setup-ssl.sh \
                --IP ${IP} --user ${USER} -passoword ${PASSWORD} \
                && sleep infinity")
docker exec -it ${CONTAINER_ID} bash
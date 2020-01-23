#!/bin/bash

# path within container
SETUP_PATH="/root/db2eventstore-IoT-Analytics/container/setup"
USER_VOLUME=${HOME}/eventstore_demo_volume

# Deployment type constants, default to cp4d
declare -r deployTypeCp4d="cp4d"
declare -r deployTypeDsx="dsx"
declare -r deployTypeStandalone="standalone"
declare -r defaultDeployType=$deployTypeCp4d

if [ -f ${HOME}/.user_info ]; then
    printf "File: '.user-info' found in the current directory."
    printf "Extracting user information from the file."
    EVENT_USER=$(grep  "username" ${HOME}/.user_info |awk {'print $2'})
    EVENT_PASSWORD=$(grep  "password" ${HOME}/.user_info |awk {'print $2'})
fi

function usage()
{
cat <<-USAGE #| fmt

Description:
This script is the entrypoint of the eventstore_demo container. The script takes
target Event Store server's public IP, optionally the target Event Store server's REST
endpoint (required if it differs from the public IP), optionally the target Event Store
server's deployment type, and the deployment's user and password.

The script will start docker container in interactive mode using the:
image: eventstore_demo:latest.
-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--IP        Public IP address or DNS name of the target Event Store server
--IPR       The REST endpoint IP or DNS name of the Event Store server.
            This is to be used when the REST endpoint differs from the Public IP
            (i.e. --IP) ... typically the case for cp4d deployments
--deploymentType
            The deployment type of the Event Store server, valid options include (default is cp4d):
               cp4d (Cloud Pak for Data deployments)
               dsx (DSX/WSL deployments)
               standalone (standalone/desktop container deployments)
--serviceName
            cp4d deployments utilize a per database service name that must be specified.
            This can be found in the database details page on the IBM Cloud Pak for Data UI console.
            This field is only required for cp4d deployment types.
               e.g. "db2eventstore-1578174815082"
--user      User name of the Event Store server
--password  Password of the Event Store server
-----------
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
    --IPR)
        IPREST="$2"
        shift 2
        ;;
    --deploymentType)
        DTYPE="$2"
        shift 2
        ;;
    --serviceName)
        SERVICE_NAME="$2"
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
        printf "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

if [ -z ${EVENT_USER} ]; then
    printf "Error: Please provide the cluster user name with --user flag\n"
    usage >&2
    exit 1
fi

if [ -z ${EVENT_PASSWORD} ]; then
    printf "Error: Please provide the cluster password with --password flag\n"
    usage >&2
    exit 1
fi

if [ -z ${IP} ]; then
    printf "Error: Please provide the Event Store server's public IP with --IP flag\n"
    usage >&2
    exit 1
fi

if [ -z ${DTYPE} ]; then
    printf "DeploymentType (--deploymentType) not specified, defaulting too: $defaultDeployType\n"
    DTYPE=$defaultDeployType
fi

case "$DTYPE" in
   $deployTypeCp4d)
      if [ -z ${SERVICE_NAME} ]; then
         printf "Error: cp4d deployment types require a service name (i.e. --service_name) as input\n"
         usage >&2
         exit 1
      fi
      ;;
   $deployTypeDsx)
      ;;
   $deployTypeStandalone)
      ;;
   *)
      printf "Deployment type \"$DTYPE\" not supported!\n"
      usage >&2
      exit 1
esac

if [ -z ${IPREST} ]; then
   printf "Rest Deployment IP (--IPR) not specified, using the (--IP) endpoint: $IP\n"
   IPREST=$IP
fi

mkdir -p ${USER_VOLUME}
# start container in interactive mode

entryPoint="env && ${SETUP_PATH}/setup-ssl.sh && ${SETUP_PATH}/entrypoint_msg.sh && bash --login"

# For standalone deployment types there SSL is not enabled so do not execute the
# corresponding setup.
if [ $DTYPE = $deployTypeStandalone ]; then
   entryPoint="${SETUP_PATH}/entrypoint_msg.sh && bash --login"
fi

docker run -it --name eventstore_demo_${EVENT_USER} -v ${USER_VOLUME}:/root/user_volume \
    -e EVENT_USER=${EVENT_USER} -e EVENT_PASSWORD=${EVENT_PASSWORD} -e IP=${IP} -e IPREST=${IPREST} -e DTYPE=${DTYPE} -e SERVICE_NAME=${SERVICE_NAME}\
    eventstore_demo:latest bash -c "$entryPoint"

printf "Cleaning up dangling images and/or exited containers"
docker rmi $(docker images -q -f dangling=true) > /dev/null 2>&1
docker rm -v $(docker ps -a -q -f status=exited) > /dev/null 2>&1
printf "Exited container successfully!"

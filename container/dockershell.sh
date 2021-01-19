#!/bin/bash

# path within container
SETUP_PATH="/root/db2eventstore-IoT-Analytics/container/setup"
USER_VOLUME=${HOME}/eventstore_demo_volume

# Deployment type constants, default to cp4d
declare -r deployTypeCp4d="cp4d"
declare -r deployTypeWsl="wsl"
declare -r deployTypeDeveloper="developer"
declare -r defaultDeployType=$deployTypeCp4d
declare -r defaultNamespace="zen"

if [ -f ${HOME}/.user_info ]; then
    printf "File: '.user-info' found in the current directory."
    printf "Extracting user information from the file."
    EVENT_USER=$(grep  "username" ${HOME}/.user_info |awk {'print $2'})
    EVENT_PASSWORD=$(grep  "password" ${HOME}/.user_info |awk {'print $2'})
fi

NAMESPACE=${defaultNamespace}

function usage()
{
cat <<-USAGE #| fmt

Description:
This script is the entrypoint of the eventstore_demo container. The script takes
target Event Store server's public IP or dns name, optionally the target Event Store server's REST
endpoint (required if it differs from the public IP), optionally the target Event Store
server's deployment type, and the deployment's user and password.

The script will start docker container in interactive mode using the:
image: eventstore_demo:latest.
-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--endpoint     Public endpoint address or DNS name of the target Event Store server used by the SDKs to connect to the database
--endpointRest The REST endpoint IP or DNS name of the Event Store server.
               This is to be used when the REST endpoint differs from the Public IP
               (i.e. --endpoint) ... typically the case for cp4d deployments
--db2-port     The db2 port for the Event Store jdbc client
--es-port      The Event Store port for ingest client
--deploymentType
               The deployment type of the Event Store server, valid options include (default is cp4d):
                  cp4d (Cloud Pak for Data deployments)
                  wsl (WSL deployments)
                  developer (developer container deployments)
--namespace
               cp4d deployments could be installed on a user defined namespace. Use this
               to override the default "zen" namespace.
--deploymentID
               cp4d deployments utilize a per database deployment ID that must be specified.
               This can be found in the database details page on the IBM Cloud Pak for Data UI console.
               This field is only required for cp4d deployment types.
                  e.g. "db2eventstore-1578174815082"
--user         User name of the Event Store server
--password     Password of the Event Store server
--es-version   The Event Store version you want to install 
-----------
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --endpoint)
        ENDPOINT="$2"
        shift 2
        ;;
    --endpointRest)
        ENDPOINT_REST="$2"
        shift 2
        ;;
    --db2-port)
        DB2_PORT="$2"
        shift 2
        ;;
    --es-port)
        ES_PORT="$2"
        shift 2
        ;;                 
    --deploymentType)
        DEPLOYMENT_TYPE="$2"
        shift 2
        ;;
    --namespace)
        NAMESPACE="$2"
        shift 2
        ;;
    --deploymentID)
        DEPLOYMENT_ID="$2"
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
    --es-version)
        ES_VERSION="$2"
        shift 2
        ;;
    *)
        printf "Unknown option: '$1'"
        usage >&2
        exit 1
    esac
done

if [ -z ${EVENT_USER} ]; then
    printf "Error: Please provide Db2 Event Store instance user name with --user flag\n" >&2
    usage >&2
    exit 1
fi

if [ -z ${EVENT_PASSWORD} ]; then
    printf "Error: Please provide Db2 Event Store instance password with --password flag\n" >&2
    usage >&2
    exit 1
fi

if [ -z ${ENDPOINT} ]; then
    printf "Error: Please provide the Event Store server's public endpoint with --endpoint flag\n" >&2
    usage >&2
    exit 1
fi

if [ -z ${DB2_PORT} ]; then
    printf "Error: Please provide the DB2 Event Store port for jdbc client with --db2-port flag\n" >&2
    usage >&2
    exit 1
fi

if [ -z ${ES_PORT} ]; then
    printf "Error: Please provide the Event Store port for ingest client with --es-port flag\n" >&2
    usage >&2
    exit 1
fi

if [ -z ${DEPLOYMENT_TYPE} ]; then
    printf "DeploymentType (--deploymentType) not specified, defaulting too: $defaultDeployType\n"
    DEPLOYMENT_TYPE=$defaultDeployType
fi

if [ -z ${ES_VERSION} ]; then
    printf "Event Store version (--es-version) not specified, please provide"
    DEPLOYMENT_TYPE=$defaultDeployType
fi

case "$DEPLOYMENT_TYPE" in
   $deployTypeCp4d)
      if [ -z ${DEPLOYMENT_ID} ]; then
         printf "Error: cp4d deployment types require a deployment ID (i.e. --deploymentID) as input\n" >&2
         usage >&2
         exit 1
      fi
      ;;
   $deployTypeWsl)
      ;;
   $deployTypeDeveloper)
      ;;
   *)
      printf "Deployment type \"$DEPLOYMENT_TYPE\" not supported!\n" >&2
      usage >&2
      exit 1
esac

if [ -z ${ENDPOINT_REST} ]; then
   printf "Rest Deployment (--endpointRest) not specified, using the (--endpoint) endpoint: $ENDPOINT\n"
   ENDPOINT_REST=$ENDPOINT
fi

mkdir -p ${USER_VOLUME}
# start container in interactive mode

echo "setting the entrypoint variable"
echo $SETUP_PATH
entryPoint="env && ${SETUP_PATH}/setup-ssl.sh && ${SETUP_PATH}/setup-container.sh ${ES_VERSION} && ${SETUP_PATH}/entrypoint_msg.sh && bash --login"
echo $entryPoint

# For developer deployment types there SSL is not enabled so do not execute the
# corresponding setup.
if [ $DEPLOYMENT_TYPE = $deployTypeDeveloper ]; then
   entryPoint="${SETUP_PATH}/entrypoint_msg.sh && bash --login"
fi

# copy json file to mount in container
cp es-releases.json ${HOME}/eventstore_demo_volume

docker run -it --name eventstore_demo_${EVENT_USER} -v ${USER_VOLUME}:/root/user_volume \
    -e EVENT_USER=${EVENT_USER} -e EVENT_PASSWORD=${EVENT_PASSWORD} -e IP=${ENDPOINT} -e IPREST=${ENDPOINT_REST} -e DB2_PORT=${DB2_PORT} -e ES_PORT=${ES_PORT} -e DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE} -e NAMESPACE=${NAMESPACE} -e DEPLOYMENT_ID=${DEPLOYMENT_ID}\
    -e ES-VERSION=${ES_VERSION} eventstore_demo:latest bash -c "$entryPoint"

printf "Cleaning up dangling images and/or exited containers"
docker rmi $(docker images -q -f dangling=true) > /dev/null 2>&1
docker rm -v $(docker ps -a -q -f status=exited) > /dev/null 2>&1
printf "Exited container successfully!"

#!/bin/bash
set -x

function usage()
{
cat <<-USAGE #| fmt
Pre-requisite:
- This script requires the SSL certificate to be the default self-signed certificate
- You have the REST endpoint of the target Event Store 2.0 (or greater) server
- You have the username and password of the target cluster
- You have the service name of the target cluster
-- Note this is only required for cp4d (IBM Cloud Pak for Data) Event Store deployments
========
Description:
This script will use the REST endpoint, user, password, and optionally the service name
of the target Event Store server to retrieve the clientkeystore file and password. Environment variables
(and the bashrc) will be setup so applications can use the required parameters for SSL connections.

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--IP  Rest endpoint of the target cluster
--user User name of the target cluster
--password Password of the target cluster
--serviceName the service name of the target cluster
   This is only applicable for cp4d (IBM Cloud Pak for Data) Event Store deployments
USAGE
}
while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --IP)
        IPREST="$2"
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
    --serviceName)
        SERVICE_NAME="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$2"
        usage >&2
        exit 1
    esac
done

# IP, Evnet_User, Event_Password can be read from the environment variable set by `docker run -e`

if [ -z ${IPREST} ]; then
   echo "Error: Please pass in the REST endpoint of your cluster using flag --IP" >&2
   usage >&2
   exit 1
fi

if [ -z ${EVENT_USER} ]; then
    echo "Error: Please pass in the user name using flag --user" >&2
    usage >&2
    exit 1
fi

if [ -z ${EVENT_PASSWORD} ]; then
    echo "Error: Please pass in the password name using flag --password" >&2
    usage >&2
    exit 1
fi

# Construct the URL path, this will vary if this is a Cp4d or DSX cluster.
# The presence of the service name indicates this is a Cp4d cluster.
URLPATH="com/ibm/event/api/v1"

if [ ! -z ${SERVICE_NAME} ]; then
   URLPATH="icp4data-databases/${SERVICE_NAME}/zen/com/ibm/event/api/v1"
fi

# target path to store client ssl key
KEYDB_PATH="/var/lib/eventstore"
mkdir -p ${KEYDB_PATH}
# get bearerToken
bearerToken=`curl --silent -k -X GET https://${IPREST}/v1/preauth/validateAuth -u ${EVENT_USER}:${EVENT_PASSWORD} | python -c "import sys, json; print(json.load(sys.stdin)['accessToken'])"`
[ $? -ne 0 ] && echo "Not able to get bearerToken" && exit 2

# get clientkeystore file
curl --silent -k -X GET -H "authorization: Bearer $bearerToken" "https://${IPREST}:443/${URLPATH}/oltp/keystore" -o ${KEYDB_PATH}/clientkeystore
[ $? -ne 0 ] && echo "Not able to get clientkeystore file" && exit 3

# get clientkeystore password
KEYDB_PASSWORD=$(curl --silent -k -i -X GET -H "authorization: Bearer $bearerToken" "https://${IPREST}:443/${URLPATH}/oltp/keystore_password" | tail -1)
[ $? -ne 0 ] && echo "Not able to get clientkeystore password" && exit 4

# get server certificate
curl -k -X GET -H "authorization: Bearer $bearerToken" "https://${IPREST}:443/${URLPATH}/oltp/certificate" -o ${KEYDB_PATH}/eventstore.pem
[ $? -ne 0 ] && echo "Not able to get server certificate" && exit 5

# export the KEYDB_PATH and KEYDB_PASSWORD only if it's in a container.
if [ -f "/.dockerenv" ]; then
    sed -i "/export KEYDB_PASSWORD=/d" ~/.bashrc
    sed -i "/export KEYDB_PATH=/d" ~/.bashrc
    sed -i "/export SERVER_CERT_PATH=/d" ~/.bashrc
    echo "export KEYDB_PASSWORD=${KEYDB_PASSWORD}" >> ~/.bashrc
    echo "export KEYDB_PATH=${KEYDB_PATH}/clientkeystore" >> ~/.bashrc
    echo "export SERVER_CERT_PATH=${KEYDB_PATH}/eventstore.pem" >> ~/.bashrc
    source ~/.bashrc
fi


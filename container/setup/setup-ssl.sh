#!/bin/bash

# target cluster's public IP 
PUBLIC_IP=$1

# check if USER name is provided through environment var, if not set to default.
if [ -z ${USER} ]; then
    USER="admin"
    PASSWORD="password"
fi

function usage()
{
cat <<-USAGE #| fmt
Pre-requisite:
- You have created the table IOT_TEMP by runnign the Notebook examples
- You have ingested data into the IOT_TEMP table by running /data/load.sh
- You have run install.sh in this directory to install required packages
========
Description:
This script will execute multiple REST APIs to:
- Connect to database
- Get table IOT_TEMP
- Query the count of record in IOT_TEMP
- Fetch the first 5 record in IOT_TEMP with certain ID.

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--IP  Public IP of target cluster.
--user [Default: admin] User name of Watson Studio Local user
--password [Default: password] Password of Watson Studio Local user
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --IP)
        PUBLIC_IP="$2"
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
        echo "Unknown option:$2"
        usage >&2
        exit 1
    esac
done

if [ -z ${PUBLIC_IP} ]; then
   echo "Error: please pass in the public IP of your cluster as part of the script argument" >&2
   exit 1
fi

# target path to store client ssl key
KEY_PATH="/var/lib/eventstore"

# get bearerToken
bearerToken=`curl --silent -k -X GET https://${PUBLIC_IP}/v1/preauth/validateAuth -u ${USER}:${PASSWORD} | jq -r '.accessToken'`

# get clientkeystore file
curl --silent -k -X GET -H "authorization: Bearer $bearerToken" "https://${PUBLIC_IP}:443/com/ibm/event/api/v1/oltp/certificate" -o ${KEY_PATH}/clientkeystore

PASSWORD=$(curl --silent -k -i -X GET -H "authorization: Bearer $bearerToken" "https://${PUBLIC_IP}:443/com/ibm/event/api/v1/oltp/certificate_password" | tail -1)

export KEYDB_PATH="${KEYDB_PATH}/clientkeystore"
export KEYDB_PASSWORD="${PASSWORD}"

cat > /bluspark/external_conf/bluspark.conf <<EOL 
internal.client.security.sslTrustStoreLocation ${KEY_PATH}/clientkeystore 
internal.client.security.sslTrustStorePassword ${PASSWORD}
internal.client.security.sslKeyStoreLocation ${KEY_PATH}/clientkeystore 
internal.client.security.sslKeyStorePassword ${PASSWORD}
internal.client.security.plugin true
internal.client.security.pluginName IBMIAMauth
security.SSLEnabled true
EOL

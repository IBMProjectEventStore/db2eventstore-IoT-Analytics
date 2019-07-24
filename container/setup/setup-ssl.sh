#!/bin/bash

# target cluster's public IP 
PUBLIC_IP=$1

if [ -z ${PUBLIC_IP} ]; then
   echo "Error: please pass in the public IP of your cluster as part of the script argument" >&2
   exit 1
fi

# target path to store client ssl key
KEY_PATH="/var/lib/eventstore"

# get bearerToken
bearerToken=`curl --silent -k -X GET https://${PUBLIC_IP}/v1/preauth/validateAuth -u admin:password | jq -r '.accessToken'`

# get clientkeystore file
curl --silent -k -X GET -H "authorization: Bearer $bearerToken" "https://${PUBLIC_IP}:443/com/ibm/event/api/v1/oltp/certificate" -o ${KEY_PATH}/clientkeystore

PASSWORD=$(curl --silent -k -i -X GET -H "authorization: Bearer $bearerToken" "https://${PUBILC_IP}:443/com/ibm/event/api/v1/oltp/certificate_password" | tail -1)

cat > /bluspark/external_conf/bluspark.conf <<EOL 
internal.client.security.sslTrustStoreLocation ${KEY_PATH}/clientkeystore 
internal.client.security.sslTrustStorePassword ${PASSWORD}
internal.client.security.sslKeyStoreLocation ${KEY_PATH}/clientkeystore 
internal.client.security.sslKeyStorePassword ${PASSWORD}
internal.client.security.plugin true
internal.client.security.pluginName IBMIAMauth
security.SSLEnabled true
EOL

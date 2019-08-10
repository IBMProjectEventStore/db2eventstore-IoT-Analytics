#!/bin/bash

CLUSTER_IP_FOR_SSH=$1
CLUSTER_PASSWORD=$2
if [ -z $CLUSTER_IP_FOR_SSH ]; then
   echo "Please provide cluster ip" >&2 
   exit 1
fi
if [ -z $CLUSTER_PASSWORD ]; then
   echo "Please provide cluster password" >&2 
   exit 1
fi

EVENTSTORE_NAMESPACE=dsx
DB2INST_PATH="/database/config/db2inst1"
SSH_OPTIONS="-o StrictHostKeyChecking=no"
RUN_IN_CLUSTER="sshpass -p ${CLUSTER_PASSWORD} ssh ${SSH_OPTIONS} root@${CLUSTER_IP_FOR_SSH}"
CERT_LABEL="SSLCert"

echo "Attempting to find engine container within the cluster with the provided IP ${CLUSTER_IP_FOR_SSH}"
ENGINE_POD=`${RUN_IN_CLUSTER} kubectl get pods -n ${EVENTSTORE_NAMESPACE} --field-selector=status.phase=Running | grep eventstore-tenant-engine | cut -f1 -d" " | head -1`
if [ -z "${ENGINE_POD}" ]
then
   echo "Unable to find Event Store engine POD within the cluster with the provided IP ${CLUSTER_IP_FOR_SSH}" >&2
   exit 1
fi

echo "Attempting to retrieve eventstore SSL keystore"
${RUN_IN_CLUSTER} kubectl exec -n ${EVENTSTORE_NAMESPACE} ${ENGINE_POD} -- cat /eventstorefs/eventstore/db2inst1/sqllib_shared/gskit/certs/eventstore.kdb > ${DB2INST_PATH}/eventstore.kdb
if [ $? -ne 0 ]; then
   echo "Failed to retreive eventstore SSL keystore" >&2
   exit 1
fi

echo "Attempting to retrieve eventstore SSL stash"
${RUN_IN_CLUSTER} kubectl exec -n ${EVENTSTORE_NAMESPACE} ${ENGINE_POD} -- cat /eventstorefs/eventstore/db2inst1/sqllib_shared/gskit/certs/eventstore.sth > ${DB2INST_PATH}/eventstore.sth
if [ $? -ne 0 ]; then
   echo "Failed to retreive eventstore SSL stash" >&2
   exit 1
fi

echo "Validating certificate label in eventstore SSL keystore"
echo "Expected label: ${CERT_LABEL}"
$HOME/sqllib/gskit/bin/gsk8capicmd_64 -cert -list -db ${DB2INST_PATH}/eventstore.kdb  -stashed -label ${CERT_LABEL}
if [ $? -ne 0 ]; then
   echo "Error: Failed to validate certificate label of ${CERT_LABEL}." >&2
   exit 1
fi

# Set db to cde
$HOME/sqllib/adm/db2set DB2_WORKLOAD=ANALYTICS

# setup db2 server ssl keystore
$HOME/sqllib/bin/db2 update dbm cfg using SSL_SVR_KEYDB ${DB2INST_PATH}/eventstore.kdb

# setup db2 server ssl stash
$HOME/sqllib/bin/db2 update dbm cfg using SSL_SVR_STASH ${DB2INST_PATH}/eventstore.sth

# setup db2 server ssl label to be same withe eventstore keystore
$HOME/sqllib/bin/db2 update dbm cfg using SSL_SVR_LABEL ${CERT_LABEL}

# setup db2 server ssl listening port
$HOME/sqllib/bin/db2 update dbm cfg using SSL_SVCENAME 18730

# setup db2 comm method to SSL
$HOME/sqllib/adm/db2set -i db2inst1 DB2COMM=SSL

# restart instance
db2stop
db2start



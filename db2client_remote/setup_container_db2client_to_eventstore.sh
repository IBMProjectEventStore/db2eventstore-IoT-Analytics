#!/bin/bash

DB_DIRECTORY=${HOME}/db_directory
DB2INST1_PASSWORD=GD1OJfLGG64HV2dtwK
DB2_PORT=$((50000+${UID}))
LICENCE_ACCEPT=
SSL_KEY_DATABASE_PASSWORD=myClientPassw0rdpw0
DOCKER_CLIENT_CONTAINER_NAME=db2-${USER}
CLUSTER_IP_FOR_SSH=
CLUSTER_IP_FOR_DB2=

# default values
DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER=18730
EVENTSTORE_USER=${USER}
EVENTSTORE_PASSWORD=password
EVENTSTORE_NAMESPACE=dsx
EVENTSTORE_DATABASE=eventdb
NODE_NAME=nova

function usage()
{
cat <<-USAGE #| fmt
Usage: $0 [OPTIONS] [arg]
OPTIONS:
=======
  --shared-path                 Local path to share with the docker container (default ${HOME}/db_directory)
  --docker-db2-port             Port to use in docker container for db2 (default: ${DB2_PORT})
  --docker-container-name       Docker container name (default db2-${USER})
  --licence                     Licence acceptance: accept/reject
  --docker-ssl-keydb-password   Password to SSL key database in container (optional)
  --eventstore-cluster-ip       Event store cluster IP to use for ssh
  --eventstore-cluster-db2-ip   Event store cluster IP to use for remote db2 client
  --eventstore-cluster-db2-port Event store cluster port to use for remote db2 client (default 18730)
  --eventstore-user             Event store user (default: ${USER})
  --eventstore-password         Event store password (default: password)
  --eventstore-namespace        Kubernetes namespace in event store cluster (default: dsx)
  --help                        Usage
USAGE

}

while [ -n "$1" ]
do
   case $1 in
      --shared-path)
         DB_DIRECTORY=$2
         shift 2
         ;;
      --docker-db2-port)
         DB2_PORT=$2
         shift 2
         ;;
      --docker-ssl-keydb-password)
         SSL_KEY_DATABASE_PASSWORD=$2
         shift 2
         ;;
      --docker-container-name)
         DOCKER_CLIENT_CONTAINER_NAME=$2
         shift 2
         ;;
      --licence)
         LICENCE_ACCEPT=$2
         shift 2
         ;;
      --eventstore-cluster-ip)
         CLUSTER_IP_FOR_SSH=$2
         shift 2
         ;;
      --eventstore-cluster-db2-ip)
         CLUSTER_IP_FOR_DB2=$2
         ping -c 1 -q ${CLUSTER_IP_FOR_DB2}  >/dev/null
         if [ $? -ne 0 ]
         then
            echo "Unable to ping ${ CLUSTER_IP_FOR_DB2}" >&2
            exit 1
         fi
         shift 2
         ;;
      --eventstore-cluster-db2-port)
         DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER=$2
         shift 2
         ;;
      --eventstore-user)
         EVENTSTORE_USER=$2
         shift 2
         ;;
      --eventstore-password)
         EVENTSTORE_PASSWORD=$2
         shift 2
         ;;
      --eventstore-namespace)
         EVENTSTORE_NAMESPACE=$2
         shift 2
         ;;
      --help)
         usage
         exit 0
         ;;
      --*)
         echo "Unknown option: $1" >&2
         usage >&2
         exit 1
         ;;
      *)
         break;
         ;;
   esac
done

if [ "${LICENCE_ACCEPT}" != "accept" ]
then
   echo "Unable to proceed. Licence not accepted" >&2
   usage >&2
   exit 1
fi

if [ -z "${CLUSTER_IP_FOR_SSH}" ]
then
   echo "Unable to proceed without a cluster IP for SSH into the cluster" >&2
   usage >&2
   exit 1
fi

if [ -z "${CLUSTER_IP_FOR_DB2}" ]
then
   echo "Unable to proceed without a cluster IP for DB2" >&2
   usage >&2
   exit 1
fi

function check_errors() {
   local RES=$1
   local MSG=$2
   if [ $RES -ne 0 ]
   then
      echo "Error $RES: running $MSG" >&2
      docker stop ${DOCKER_CLIENT_CONTAINER_NAME}
      docker rm ${DOCKER_CLIENT_CONTAINER_NAME}
      exit 1
   fi
}

SSH_OPTIONS="-o StrictHostKeyChecking=no"
RUN_IN_CLUSTER="ssh ${SSH_OPTIONS} root@${CLUSTER_IP_FOR_SSH}"

echo -e "\n\n*Starting db2 client container\n"
DOCKER_IMAGE=ibmcom/db2
# DOCKER_IMAGE=registry.ng.bluemix.net/db2team/db2client:new
# DOCKER_IMAGE=registry.ng.bluemix.net/db2team/db2client:latest
# PORT_OPTION=-p ${DB2_PORT}:50000
docker run -itd --name ${DOCKER_CLIENT_CONTAINER_NAME} -v ${DB_DIRECTORY}:/database -e DB2INST1_PASSWORD=${DB2INST1_PASSWORD} -e LICENSE=${LICENCE_ACCEPT} ${PORT_OPTION} --privileged=true ${DOCKER_IMAGE}
check_errors $? "running the docker container"

echo -e "\n\n* Client container started"
docker ps | grep ${DOCKER_CLIENT_CONTAINER_NAME}

echo -e "\n\n* Waiting for client container setup to be complete...\n"
SETUP_COMPLETED_STRING="Setup has completed"
docker logs ${DOCKER_CLIENT_CONTAINER_NAME} | grep -q "${SETUP_COMPLETED_STRING}"
RES=$?
ITER=0
MAX_ITER=300
while [ $RES -ne 0 ]
do
   if [ $ITER -eq $MAX_ITER ]
   then
      echo "Timeout waiting for docker container setup to be completed" >&2
      exit 1
   fi 
   sleep 1
   docker logs ${DOCKER_CLIENT_CONTAINER_NAME} | grep -q "${SETUP_COMPLETED_STRING}"
   RES=$?
   ITER=$(( $ITER + 1 ))
done

function docker_run() 
{
   DB2_DEFAULT_USERNAME=db2inst1
   COMMAND="$@"
   docker exec ${DOCKER_CLIENT_CONTAINER_NAME} bash -c "su - ${DB2_DEFAULT_USERNAME} -c \"$COMMAND\" "
}

function docker_cp_tgt_container() 
{
   FILE_SRC=$1
   FILE_TGT=$2
   docker cp ${FILE_SRC} ${DOCKER_CLIENT_CONTAINER_NAME}:${FILE_TGT}
}

echo -e "\n\n* Configuring connection to Event Store database...\n"
docker_run rm -f /database/config/db2inst1/mydbclient.kdb /database/config/db2inst1/mydbclient.sth /database/config/db2inst1/mydbclient.rdb /database/config/db2inst1/mydbclient.crl 
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ gsk8capicmd_64 -keydb -create -db mydbclient.kdb -pw ************ -stash"
docker_run gsk8capicmd_64 -keydb -create -db mydbclient.kdb -pw ${SSL_KEY_DATABASE_PASSWORD} -stash
check_errors $? "gsk8capicmd_64 -keydb -create -db "mydbclient.kdb" -pw ************* -stash"

ENGINE_POD=`${RUN_IN_CLUSTER} kubectl get pods -n ${EVENTSTORE_NAMESPACE} --field-selector=status.phase=Running | grep eventstore-tenant-engine | cut -f1 -d" " | head -1`
check_errors $? "Attempting to find engine container within the cluster with the provided IP ${CLUSTER_IP_FOR_SSH}"
if [ -z "${ENGINE_POD}" ]
then
   echo "Unable to find Event Store engine POD within the cluster with the provided IP ${CLUSTER_IP_FOR_SSH}" >&2
   exit 1
fi

echo -e "\n\n   - Retrieving SSL certificate from Event Store cluster and copying into the db2 client container\n"
${RUN_IN_CLUSTER} kubectl exec -n ${EVENTSTORE_NAMESPACE} ${ENGINE_POD} -- cat /eventstorefs/eventstore/db2inst1/sqllib_shared/gskit/certs/eventstore_ascii.cert >server-certificate.cert
check_errors $? "Attempting to retrieve SSL certificate"

docker_cp_tgt_container server-certificate.cert /database/config/db2inst1/server-certificate.cert
check_errors $? "storing SSL certifiate within the docker container"
rm server-certificate.cert

echo -e "\n\n   - Configuring SSL connection to Event Store cluster\n"
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ gsk8capicmd_64 -cert -add -db mydbclient.kdb -pw ************  -label server -file /database/config/db2inst1/server-certificate.cert -format ascii -fips"
docker_run gsk8capicmd_64 -cert -add -db mydbclient.kdb -pw ${SSL_KEY_DATABASE_PASSWORD}  -label server -file /database/config/db2inst1/server-certificate.cert -format ascii -fips
check_errors $? "gsk8capicmd_64 -cert -add -db "mydbclient.kdb" -pw ************* -label "server" -file "server-certificate.cert" -format ascii -fips"

echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ db2 update dbm cfg using SSL_CLNT_KEYDB /database/config/db2inst1/mydbclient.kdb SSL_CLNT_STASH /database/config/db2inst1/mydbclient.sth"
docker_run db2 update dbm cfg using SSL_CLNT_KEYDB /database/config/db2inst1/mydbclient.kdb SSL_CLNT_STASH /database/config/db2inst1/mydbclient.sth
check_errors $? "db2 update dbm cfg using SSL_CLNT_KEYDB /database/config/db2inst1/mydbclient.kdb SSL_CLNT_STASH /database/config/db2inst1/mydbclient.sth"

echo -e "\n\n   - Configuring connection to Event Store cluster node\n"
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ db2 UNCATALOG NODE ${NODE_NAME}"
docker_run db2 UNCATALOG NODE ${NODE_NAME}
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ db2 CATALOG TCPIP NODE ${NODE_NAME} REMOTE ${CLUSTER_IP_FOR_DB2} SERVER ${DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER} SECURITY SSL"
docker_run db2 CATALOG TCPIP NODE ${NODE_NAME} REMOTE ${CLUSTER_IP_FOR_DB2} SERVER ${DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER} SECURITY SSL
check_errors $? "db2 CATALOG TCPIP NODE ${NODE_NAME} REMOTE ${CLUSTER_IP_FOR_DB2} SERVER ${DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER} SECURITY SSL"

echo -e "\n\n   - Adding Event Store database to catalog\n"
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ db2 UNCATALOG DATABASE ${EVENTSTORE_DATABASE}"
docker_run db2 UNCATALOG DATABASE ${EVENTSTORE_DATABASE}
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ db2 CATALOG DATABASE ${EVENTSTORE_DATABASE} AT NODE ${NODE_NAME} AUTHENTICATION GSSPLUGIN"
docker_run db2 CATALOG DATABASE ${EVENTSTORE_DATABASE} AT NODE ${NODE_NAME} AUTHENTICATION GSSPLUGIN
check_errors $? "db2 CATALOG DATABASE ${EVENTSTORE_DATABASE} AT NODE ${NODE_NAME} AUTHENTICATION GSSPLUGIN"

echo -e "\n\n   - Testing connection to Event Store database\n"
echo -e "\n\n[${DOCKER_CLIENT_CONTAINER_NAME}] $ db2 CONNECT TO ${EVENTSTORE_DATABASE} USER ${EVENTSTORE_USER} USING ************"
docker_run db2 CONNECT TO ${EVENTSTORE_DATABASE} USER ${EVENTSTORE_USER} USING ${EVENTSTORE_PASSWORD}
check_errors $? "db2 CONNECT TO ${EVENTSTORE_DATABASE} USER ${EVENTSTORE_USER} USING ************"

echo -e "\n\n* Connection to event store database is configured\n"

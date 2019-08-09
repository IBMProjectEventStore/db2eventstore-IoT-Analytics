#!/bin/bash -x

DB_DIRECTORY=${HOME}/db2Client_volume/
DB2INST1_PASSWORD=GD1OJfLGG64HV2dtwK
DB2_PORT=$((50000+${UID}))
LICENCE_ACCEPT=
SSL_KEY_DATABASE_PASSWORD=myClientPassw0rdpw0
DOCKER_CLIENT_CONTAINER_NAME=db2-${USER}
IP=
AUTO_SETUP="false"

# default values
DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER=18730
EVENT_USER=${USER}
EVENTSTORE_NAMESPACE=dsx
EVENTSTORE_DATABASE=eventdb
NODE_NAME=nova
DOCKER_IMAGE=ibmcom/db2
CSV_FILE="sample_IOT_table.csv"
# PORT_OPTION=-p ${DB2_PORT}:50000

if [ -f ${HOME}/.user_info ]; then
    echo "File: '.user-info' found in the current directory."
    echo "Extracting user information from the file."
    EVENT_USER=$(grep  "username" ${HOME}/.user_info |awk {'print $2'})
    EVENT_PASSWORD=$(grep  "password" ${HOME}/.user_info |awk {'print $2'})
fi

function usage()
{
cat <<-USAGE #| fmt
Usage: $0 [OPTIONS] [arg]
OPTIONS:
=======
[Mandatory]
  --licence                     Licence acceptance: accept/reject
  --IP                          Event store cluster IP

[Optional]
  --auto-config      Automatically conigure the remote Event Store connection (default: false)
  --user             Event store user (default: ${USER})
  --password         Event store password (default: password)
  --shared-path                 Local path to share with the docker container (default ${HOME}/db2Client_volume)
  --docker-db2-port             Port to use in docker container for db2 (default: ${DB2_PORT})
  --docker-container-name       Docker container name (default db2-${USER})
  --docker-ssl-keydb-password   Password to SSL key database in container (optional)
  --eventstore-cluster-db2-port Event store cluster port to use for remote db2 client (default 18730)
  --eventstore-namespace        Kubernetes namespace in event store cluster (default: dsx)
  --help                        Usage
USAGE

}


while [ -n "$1" ]
do
   case $1 in
      --auto-config)
         AUTO_SETUP=$2
         shift 2
         ;;
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
      --IP)
         IP=$2
         ping -c 1 -q ${IP}  >/dev/null
         if [ $? -ne 0 ]
         then
            echo "Unable to ping ${IP}" >&2
            exit 1
         fi
         shift 2
         ;;
      --eventstore-cluster-db2-port)
         DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER=$2
         shift 2
         ;;
      --user)
         EVENT_USER=$2
         shift 2
         ;;
      --password)
         EVENT_PASSWORD=$2
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

if [ "${LICENCE_ACCEPT}" != "accept" ]
then
   echo "Unable to proceed. Licence not accepted" >&2
   usage >&2
   exit 1
fi
mkdir -p ${DB_DIRECTORY}
docker run -itd --name ${DOCKER_CLIENT_CONTAINER_NAME} -v ${DB_DIRECTORY}:/database \
    -e EVENT_USER=${EVENT_USER} -e EVENT_PASSWORD=${EVENT_PASSWORD} -e IP=${IP} \
    -e DB2INST1_PASSWORD=${DB2INST1_PASSWORD} -e LICENSE=${LICENCE_ACCEPT} \
    -e SSL_KEY_DATABASE_PASSWORD=${SSL_KEY_DATABASE_PASSWORD} -e EVENTSTORE_DATABASE=${EVENTSTORE_DATABASE}\
    -e NODE_NAME=${NODE_NAME} -e DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER=${DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER}\
    --privileged=true ${DOCKER_IMAGE}

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
   docker exec ${DOCKER_CLIENT_CONTAINER_NAME} bash -c "su ${DB2_DEFAULT_USERNAME} -c \"$COMMAND\" "
}

function docker_run_as_root() 
{
   COMMAND="$@"
   echo $COMMAND
   docker exec --user root ${DOCKER_CLIENT_CONTAINER_NAME} bash -c "$COMMAND"
}

function check_errors() {
  local RES=$1
  local MSG=$2
  if [ $RES -ne 0 ]; then
    echo "Error $RES: running $MSG" >&2
    docker rm -f ${DOCKER_CLIENT_CONTAINER_NAME}
    docker rmi $(docker images -q -f dangling=true) > /dev/null 2>&1
    docker rm -v $(docker ps -a -q -f status=exited) > /dev/null 2>&1
    exit 1
    fi
}


JAVA_VERSION=1.8.0
# install java
docker_run_as_root yum install -y java-${JAVA_VERSION}-openjdk-devel wget
#docker_run_as_root yum clean all
#docker_run_as_root rm -rf /var/cache/yum
#docker_run_as_root "cat > /etc/profile.d/local_java.sh <<EOL
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/jvm/java-${JAVA_VERSION}-openjdk/jre/lib/amd64/server
#export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk
#export JVM_LIBRARY_PATH=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk/jre/lib/amd64/server/libjvm.so
#EOL"
check_errors $? "install java and wget"

# install screen
wget -P /tmp/ http://mirror.centos.org/centos/7/os/x86_64/Packages/screen-4.1.0-0.25.20120314git3c2946.el7.x86_64.rpm
yum localinstall -y /tmp/screen-4.1.0-0.25.20120314git3c2946.el7.x86_64.rpm && yum clean all && rm -rf /var/cache/yum && rm -rf /tmp/screen-4.1.0-0.25.20120314git3c2946.el7.x86_64.rpm

# setup screen
docker_run_as_root echo -e 'startup_message off \nhardstatus on \nhardstatus alwayslastline \nvbell off \nhardstatus string "%{.bW}%-w%{..G}%n %t%{-}%+w %=%{..G} %H %{..Y} %m/%d %C%a"' > ${HOME}/.screenrc

# create or update setup-remoteES connection script to the shared path on host
touch ${DB_DIRECTORY}/setup-remote-eventstore.sh ${DB_DIRECTORY}/load_csv.sql
check_errors $? "create setup-remote-eventstore.sh & load_csv.sql"

chmod +x ${DB_DIRECTORY}/setup-remote-eventstore.sh ${DB_DIRECTORY}/load_csv.sql
check_errors $? "chmod on setup-remote-eventstore.sh & /database/load_csv.sql"

cat > ${DB_DIRECTORY}/setup-remote-eventstore.sh <<'EOF' 
#!/bin/bash -x
. /database/config/db2inst1/sqllib/db2profile
rm -rf $HOME/mydbclient.kdb  $HOME/mydbclient.sth $HOME/mydbclient.crl $HOME/mydbclient.rdb
$HOME/sqllib/gskit/bin/gsk8capicmd_64 -keydb -create -db $HOME/mydbclient.kdb -pw ${SSL_KEY_DATABASE_PASSWORD} -stash

KEYDB_PATH=/var/lib/eventstore/clientkeystore

bearerToken=`curl --silent -k -X GET "https://$IP/v1/preauth/validateAuth" -u $EVENT_USER:$EVENT_PASSWORD | python -c "import sys, json; print (json.load(sys.stdin)['accessToken']) "`

export KEYDB_PASSWORD=`curl --silent -k -i -X GET -H "authorization: Bearer $bearerToken" "https://${IP}:443/com/ibm/event/api/v1/oltp/certificate_password" | tail -1`

curl --silent -k -X GET -H "authorization: Bearer $bearerToken"  "https://${IP}:443/com/ibm/event/api/v1/oltp/certificate" -o  $HOME/clientkeystore

keytool -list -keystore  $HOME/clientkeystore -storepass $KEYDB_PASSWORD

keytool -export -keystore $HOME/clientkeystore -storepass  $KEYDB_PASSWORD  -file $HOME/server-certificate.cert -alias SSLCert

$HOME/sqllib/gskit/bin/gsk8capicmd_64 -cert -add -db $HOME/mydbclient.kdb  -pw ${SSL_KEY_DATABASE_PASSWORD}  -label server -file $HOME/server-certificate.cert -format ascii -fips

$HOME/sqllib/bin/db2 update dbm cfg using SSL_CLNT_KEYDB $HOME/mydbclient.kdb SSL_CLNT_STASH $HOME/mydbclient.sth

$HOME/sqllib/bin/db2 UNCATALOG NODE ${NODE_NAME}
$HOME/sqllib/bin/db2 CATALOG TCPIP NODE ${NODE_NAME} REMOTE ${IP} SERVER ${DB2_CLIENT_PORT_ON_EVENTSTORE_SERVER} SECURITY SSL
$HOME/sqllib/bin/db2 UNCATALOG DATABASE ${EVENTSTORE_DATABASE}
$HOME/sqllib/bin/db2 CATALOG DATABASE ${EVENTSTORE_DATABASE} AT NODE ${NODE_NAME} AUTHENTICATION GSSPLUGIN
$HOME/sqllib/bin/db2 CONNECT TO ${EVENTSTORE_DATABASE} USER ${EVENT_USER} USING ${EVENT_PASSWORD}
EOF

check_errors $? "cat to setup-remote-eventstore.sh"

# create or update load_csv.sql to the shared path on host
cat > ${DB_DIRECTORY}/load_csv.sql <<EOF
CONNECT TO ${EVENTSTORE_DATABASE} USER ${EVENT_USER} USING ${EVENT_PASSWORD}
SET CURRENT ISOLATION UR
CREATE TABLE db2cli_csvload (DEVICEID INTEGER NOT NULL, SENSORID INTEGER NOT NULL, TS BIGINT NOT NULL, AMBIENT_TEMP DOUBLE NOT NULL, POWER DOUBLE NOT NULL, TEMPERATURE DOUBLE NOT NULL, CONSTRAINT "TEST1INDEX" PRIMARY KEY(DEVICEID, SENSORID, TS) INCLUDE (TEMPERATURE)) DISTRIBUTE BY HASH (DEVICEID, SENSORID) ORGANIZE BY COLUMN STORED AS PARQUET
INSERT INTO db2cli_csvload SELECT * FROM EXTERNAL '/database/${CSV_FILE}' LIKE db2cli_csvload USING (delimiter ',' MAXERRORS 10 SOCKETBUFSIZE 30000 REMOTESOURCE 'YES' LOGDIR '/database/logs' )
SELECT * FROM db2cli_csvload LIMIT 10
SELECT COUNT(*) FROM db2cli_csvload 
SELECT AMBIENT_TEMP FROM db2cli_csvload WHERE TS > 1541019365252 AND TS < 1541019500380 
DROP TABLE db2cli_csvload
CONNECT RESET
TERMINATE
EOF
check_errors $? "cat to load_csv.sql"

# wget the data csv file to the shared path on host
wget https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/raw/master/data/sample_IOT_table.csv -O  ${DB_DIRECTORY}/sample_IOT_table.csv
check_errors $? "wget csv file from github"

docker_run_as_root mkdir -p /database/logs
check_errors $? "mkdir -p database/logs"

docker_run_as_root chmod 777 /database/logs
check_errors $? "chmod 777 /database/logs"

if [ ${AUTO_SETUP} == "true" ]; then
  docker_run /database/setup-remote-eventstore.sh
  check_errors $? "running setup-remote-eventstore.sh"
fi

rm -f ${DB_DIRECTORY}/setup-ssl.sh && wget https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/raw/master/container/setup/setup-ssl.sh -O ${DB_DIRECTORY}/setup-ssl.sh
check_errors $? "downloading setup-ssl.sh script to the shared path"
docker_run_as_root chmod +x /database/setup-ssl.sh 
check_errors $? "make setup-ssl.sh executable"

docker_run_as_root /database/setup-ssl.sh
check_errors $? "running setup-ssl.sh as root in the container"

rm -f  ${DB_DIRECTORY}/setup-db2instance.sh
cp setup-db2instance.sh ${DB_DIRECTORY}/
docker_run /database/setup-db2instance.sh 172.30.0.11

rm -f ${DB_DIRECTORY}/runExampleJDBCApp
wget https://raw.githubusercontent.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/master/AdvancedApplications/JDBCApplication/runExampleJDBCApp -P ${DB_DIRECTORY}/

rm -f ${DB_DIRECTORY}/ExampleJDBCApp.java
wget https://raw.githubusercontent.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/master/AdvancedApplications/JDBCApplication/ExampleJDBCApp.java -P ${DB_DIRECTORY}/

docker exec -it --user db2inst1 ${DOCKER_CLIENT_CONTAINER_NAME} bash

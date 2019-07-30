#!/bin/bash

DOCKER_CLIENT_CONTAINER_NAME=db2-${USER}

# default values
EVENTSTORE_USER=$USER
EVENTSTORE_PASSWORD=password
EVENTSTORE_DATABASE=eventdb
CSV_FILE=sample_IOT_table.csv

function usage()
{
cat <<-USAGE #| fmt
Usage: $0 [OPTIONS] [arg]
OPTIONS:
=======
  --docker-container-name       Docker container name (default db2-${USER})
  --eventstore-user             Event store user (default: ${USER})
  --eventstore-password         Event store password (default: password)
  --csv-file                    Sample CSV file to use during load
  --help                        Usage
USAGE

}

while [ -n "$1" ]
do
   case $1 in
      --docker-container-name)
         DOCKER_CLIENT_CONTAINER_NAME=$2
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
      --csv-file)
         CSV_FILE=$2
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

function check_errors() {
   local RES=$1
   local MSG=$2
   if [ $RES -ne 0 ]
   then
      echo "Error $RES: running $MSG" >&2
      exit 1
   fi
}

function docker_run_as_instance_owner() 
{
   DB2_DEFAULT_USERNAME=db2inst1
   COMMAND="$@"
   docker exec ${DOCKER_CLIENT_CONTAINER_NAME} bash -c "su - ${DB2_DEFAULT_USERNAME} -c \"$COMMAND\" "
}

function docker_run_as_root() 
{
   COMMAND="$@"
   docker exec ${DOCKER_CLIENT_CONTAINER_NAME} bash -c "$COMMAND"
}

function docker_cp_tgt_container() 
{
   FILE_SRC=$1
   FILE_TGT=$2
   docker cp ${FILE_SRC} ${DOCKER_CLIENT_CONTAINER_NAME}:${FILE_TGT}
}

if [ -z "${CSV_FILE}" ]
then
   echo "Error: CSV file must be provided" >&2
   exit 1
fi
if [ ! -r "${CSV_FILE}" ]
then
   echo "Error: readable CSV file must be provided - ${CSV_FILE}" >&2
   exit 1
fi

echo -e "\n\n* Generating a sample SQL file load_csv.sql with db2 commands to create the table, load it and do some simple queries\n"
cat >load_csv.sql <<EOF
CONNECT TO ${EVENTSTORE_DATABASE} USER ${EVENTSTORE_USER} USING ${EVENTSTORE_PASSWORD}
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
cat load_csv.sql

echo -e "\n\n* Copying load_csv.clp into db2 client container"
docker_cp_tgt_container load_csv.sql /database/load_csv.sql
check_errors $? "docker cp load_csv.sql"

echo -e "\n\n* Copying CSV file into db2 client container"
docker_cp_tgt_container ${CSV_FILE} /database/${CSV_FILE}
check_errors $? "docker cp ${CSV_FILE}"

echo -e "\n\n* Running sample CLP with create table and remote load\n"
# Create the logs directory to be world writable as load runs 
# as the instance owner
docker_run_as_root mkdir -p /database/logs
check_errors $? "creating directory /database/logs"
docker_run_as_root chmod 777 /database/logs
check_errors $? "changing /database/logs directory permissions"
docker_run_as_instance_owner db2 -vf /database/load_csv.sql
check_errors $? "db2 -vf load_csv.sql"

echo -e "\n\n* Load test completed\n"

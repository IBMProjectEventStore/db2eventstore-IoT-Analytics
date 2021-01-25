#!/bin/bash

# test if ES version supplied
if [ -z $1 ]; then
   ES_VERSION='"2.0.1.0"'
else
   ES_VERSION=\"${1}\"
fi

# set user volume
USER_VOLUME=/root/user_volume

# set the version variables
SPARK_VERSION=$(jq -r .release.${ES_VERSION}.sparkversion $USER_VOLUME/es-releases.json)
SPARK_CLIENT=$(jq -r .release.${ES_VERSION}.sparkclient $USER_VOLUME/es-releases.json)


IOT_REPO_PATH="/root/db2eventstore-IoT-Analytics"
SETUP_AREA=${IOT_REPO_PATH}/container/setup

# set up environments

${SETUP_AREA}/setup-java.sh
${SETUP_AREA}/setup-spark.sh
${SETUP_AREA}/setup-scala.sh
${SETUP_AREA}/setup-python.sh
${SETUP_AREA}/setup-kafka.sh
${IOT_REPO_PATH}/rest/install.sh

echo "Downloading Event Store Spark client for selected version, this may take some time"
wget -P ${SPARK_HOME}/jars https://${SPARK_CLIENT}

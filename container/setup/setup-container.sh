#!/bin/bash

echo "setup container entry breakpoints"
echo $ES_VERSION
echo "end entry breakpoints"


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

echo "jq variables breakpoints"
echo $ES_VERSION
echo $SPARK_VERSION
echo $SPARK_CLIENT
echo "end variables breakpoints"

# run setup spark script
${SETUP_AREA}/setup-spark.sh $SPARK_VERSION

IOT_REPO_PATH="/root/db2eventstore-IoT-Analytics"
SETUP_AREA=${IOT_REPO_PATH}/container/setup

echo "Downloading Event Store Spark client for selected version, this may take some time"
wget -P ${SPARK_HOME}/jars https://${SPARK_CLIENT}

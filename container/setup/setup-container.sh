#!/bin/bash

# test if ES version supplied
if [ -z $1 ]; then
   ES_VERSION='"2.0.1.4"'
else
   ES_VERSION=\"${1}\"
fi

# set user volume
USER_VOLUME=/root/user_volume

# set the version variables, in dec 2021 the original variables defined by jq command stopped working, 2 variables below are now hard coded
# SPARK_VERSION=$(jq -r .release.${ES_VERSION}.sparkversion $USER_VOLUME/es-releases.json)
SPARK_VERSION="2.4.8"
# SPARK_CLIENT=$(jq -r .release.${ES_VERSION}.sparkclient $USER_VOLUME/es-releases.json)
SPARK_CLIENT="ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar"

# Setup java/scala/python/kafka/rest/spark
${SETUP_AREA}/setup-java.sh
${SETUP_AREA}/setup-scala.sh
${SETUP_AREA}/setup-python.sh
${SETUP_AREA}/setup-kafka.sh
${IOT_REPO_PATH}/rest/install.sh
${SETUP_AREA}/setup-spark.sh $SPARK_VERSION


IOT_REPO_PATH="/root/db2eventstore-IoT-Analytics"
SETUP_AREA=${IOT_REPO_PATH}/container/setup

echo "Downloading Event Store Spark client for selected version, this may take some time, using hardcoded url and showing variables for Spark home, version & client"
# command below stopped workeing because https:// was not getting populated, somehow the original variable definitions stopped working
# wget -P ${SPARK_HOME}/jars https://${SPARK_CLIENT}
echo "Spark home directory is ${SPARK_HOME}"
echo "Spark version is ${SPARK_VERSION}"
echo "Spark client is ${SPARK_CLIENT}"
# hardcode download of ibm spark client
wget -P ${SPARK_HOME}/jars  https://repo1.maven.org/maven2/com/ibm/event/ibm-db2-eventstore-client-spark-2.4.6/2.0.1.0/ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar

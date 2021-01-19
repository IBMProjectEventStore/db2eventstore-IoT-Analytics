#!/bin/bash

# test if ES version supplied
if [ -z $1 ]; then
   ES_VERSION='"2.0.1.0"'
else
   ES_VERSION=\"${1}\"
fi

# set user volume and proxy values
USER_VOLUME=/root/user_volume
export http_proxy=http://proxy1.fyre.ibm.com:3128
export ftp_proxy=http://proxy1.fyre.ibm.com:3128
export HTTP_PROXY=http://proxy1.fyre.ibm.com:3128
export FTP_PROXY=http://proxy1.fyre.ibm.com:3128
export no_proxy=localhost,127.0.0.1,.fyre.ibm.com
export NO_PROXY=localhost,127.0.0.1,.fyre.ibm.com

# set the version variables
SPARK_VERSION=$(jq -r .release.${ES_VERSION}.sparkversion $USER_VOLUME/es-releases.json)
SPARK_CLIENT=$(jq -r .release.${ES_VERSION}.sparkclient $USER_VOLUME/es-releases.json)


IOT_REPO_PATH="/root/db2eventstore-IoT-Analytics"
SETUP_AREA=${IOT_REPO_PATH}/container/setup

# if comment out setup spark uncomment spark home variable
# SPARK_HOME=/spark_home

${SETUP_AREA}/setup-java.sh
${SETUP_AREA}/setup-spark.sh
${SETUP_AREA}/setup-scala.sh
${SETUP_AREA}/setup-python.sh

echo "Downloading Event Store Spark client for selected version, this may take some time"
wget -P ${SPARK_HOME}/jars https://$SPARK_CLIENT

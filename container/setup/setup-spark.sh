#!/bin/bash
. $(dirname $0)/setup-header.sh

##
## spark
##

echo $1
SPARK_VERSION=$1

if [ -z "$SPARK_VERSION" ]
then
   SPARK_VERSION="2.4.8"
   echo "SPARK_VERSION not defined. Using local version SPARK_VERSION=${SPARK_VERSION}"
fi
if [ -z "$HADOOP_VERSION" ]
then
   HADOOP_VERSION="2.6"
   echo "HADOOP_VERSION not defined. Using local version HADOOP_VERSION=${HADOOP_VERSION}"
fi
if [ -z "$SCOPT_211_VERSION" ]
then
   SCOPT_211_VERSION="3.5.0"
   echo "SCOPT_211_VERSION not defined. Using local version SCOPT_211_VERSION=${SCOPT_211_VERSION}"
fi
if [ -z "$SPARK_MEDIA_LOC" ]
then
   SPARK_MEDIA_LOC=/tmp
fi

if [ -z "${SPARK_MEDIA}" ]
then
   SPARK_MEDIA=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
fi

if [ -z "${SPARK_HOME}" ]
then
   SPARK_HOME=/spark_home
   echo "SPARK_HOME not defined. Using SPARK_HOME=${SPARK_HOME}"
fi

cd $SPARK_MEDIA_LOC

mkdir -p $SPARK_HOME
# Will use local copy of spark media Jim Stroud copied to github.com as the download took too long and was unreliable.
# Jan 29 2022 had to undo this b/c could not clone this repo as out of git lfs bandwdith
# hardcode spark-2.4.8-bin-hadoop2.6.tgz file in wget
wget -q -O ${SPARK_MEDIA}.tar.gz \
   http://ec2-3-19-229-245.us-east-2.compute.amazonaws.com/spark-2.4.8-bin-hadoop2.6.tgz
tar -xzvf ${SPARK_MEDIA}.tar.gz
mv ${SPARK_MEDIA}/* $SPARK_HOME
#  Below was original media source from apache.org that is unreliable
#   http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_MEDIA}.tgz
# Jim Stroud created a free linux aws linux ec2 server and installed nginx and placed spark media there jan 29, 2022

# below are commands use files for spark media from github, git clone performed earlier puts files under /root/ in docker container
# comment out because does not work anymore as we are out bandwidth for gihub.com for git lfs downloads
# echo "extract spark tar gzipped file and move it to /spark_home and then delete original media file"
# tar -xzvf /root/db2eventstore-IoT-Analytics/spark_media_package/spark-2.4.8-bin-hadoop2.6.tgz -C /
# cp -r /spark-2.4.8-bin-hadoop2.6/* /spark_home
# rm -rf /root/db2eventstore-IoT-Analytics/spark_media_package /spark-2.4.8-bin-hadoop2.6
wget -q -O scopt_2.11-${SCOPT_211_VERSION}.jar \
   https://repo1.maven.org/maven2/com/github/scopt/scopt_2.11/${SCOPT_211_VERSION}/scopt_2.11-${SCOPT_211_VERSION}.jar
mv scopt_2.11-${SCOPT_211_VERSION}.jar $SPARK_HOME/jars
chown -R 500:500 $SPARK_HOME/jars/scopt_2.11-${SCOPT_211_VERSION}.jar

$(dirname $0)/setup-cleanup.sh

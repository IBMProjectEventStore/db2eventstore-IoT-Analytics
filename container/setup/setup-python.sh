#!/bin/bash
##
## python
##

## Set up python 3.5

cd /usr/src
wget https://www.python.org/ftp/python/3.5.6/Python-3.5.6.tgz
tar xzf Python-3.5.6.tgz
cd Python-3.5.6
./configure --enable-optimizations
make altinstall
rm /usr/src/Python-3.5.6.tgz
ln -s /usr/local/bin/python3.5 /usr/local/bin/python

## set up EventStore python library
if [ -z "${SPARK_HOME}" ]
then
   SPARK_HOME=/spark_home
   echo "SPARK_HOME not defined. Using SPARK_HOME=${SPARK_HOME}"
fi

git clone https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages.git /
unzip /db2eventstore-pythonpackages/python.zip -d /var/lib
rm -rf /db2eventstore-pythonpackages

PY4J_VERSION=$(ls ${SPARK_HOME}/python/lib | grep py4j)
echo "export PYTHONPATH=$PYTHONPATH:/var/lib:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/${PY4J_VERSION}" >> /etc/profile.d/local_python.sh

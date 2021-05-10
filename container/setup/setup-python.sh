#!/bin/bash
##
## python
##

## Set up python 3.6

cd /usr/src
wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tgz
tar xzf Python-3.6.8.tgz
cd Python-3.6.8
./configure --enable-optimizations
make altinstall
rm /usr/src/Python-3.6.8.tgz
ln -fs /usr/local/bin/python3.6 /usr/local/bin/python

## set up EventStore python library
if [ -z "${SPARK_HOME}" ]
then
   SPARK_HOME=/spark_home
   echo "SPARK_HOME not defined. Using SPARK_HOME=${SPARK_HOME}"
fi

git clone https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages.git /db2eventstore-pythonpackages
tar -C /var/lib -xvf /db2eventstore-pythonpackages/python.zip
rm -rf /db2eventstore-pythonpackages

PY4J_VERSION=$(ls ${SPARK_HOME}/python/lib | grep py4j)
echo "export PYTHONPATH=$PYTHONPATH:/var/lib:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/${PY4J_VERSION}:${SPARK_HOME}/python/jars/:${HOME}/db2eventstore-IoT-Analytics/AdvancedApplications/PythonApplication/" >> /etc/profile.d/local_python.sh

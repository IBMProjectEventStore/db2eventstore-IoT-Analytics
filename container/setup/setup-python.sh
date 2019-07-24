#!/bin/bash
##
## python
##

if [ -z "${SPARK_HOME}" ]
then
   SPARK_HOME=/spark_home
   echo "SPARK_HOME not defined. Using SPARK_HOME=${SPARK_HOME}"
fi

unzip /root/python.zip -d /var/lib
rm -f /root/python.zip

PY4J_VERSION=$(ls ${SPARK_HOME}/python/lib | grep py4j)

echo "export PYTHONPATH=$PYTHONPATH:/var/lib:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/${PY4J_VERSION}" >> /etc/profile.d/local_python.sh

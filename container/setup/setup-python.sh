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

echo "export PYTHONPATH=$PYTHONPATH:/var/lib:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.3-src.zip" >> /etc/profile.d/local_python.sh

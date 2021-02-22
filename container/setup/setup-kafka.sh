#!/bin/bash
##
## kafka git repository has been tagged with release to ensure correct ibm-event.jar file is used
##


# set passed kafka tag value
KAFKA_TAG=${1}

cd ~
git clone -b $KAFKA_TAG --single-branch https://github.com/IBMProjectEventStore/db2eventstore-kafka.git
cd ~/db2eventstore-kafka
sbt clean
sbt compile
sbt package assembly
echo "Kafka setup finished."

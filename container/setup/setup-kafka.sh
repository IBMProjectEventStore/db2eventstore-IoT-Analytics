#!/bin/bash
##
## kafka
##

cd ~
git clone https://github.com/IBMProjectEventStore/db2eventstore-kafka.git
cd ~/db2eventstore-kafka
sbt clean
sbt compile
sbt package assembly
echo "Kafka setup finished."
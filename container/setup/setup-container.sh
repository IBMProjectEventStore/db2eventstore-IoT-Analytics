#!/bin/bash
IOT_REPO_PATH="/root/db2eventstore-IoT-Analytics"
SETUP_AREA=${IOT_REPO_PATH}/container/setup
echo ${SETUP_AREA}
${SETUP_AREA}/setup-java.sh
${SETUP_AREA}/setup-spark.sh
${SETUP_AREA}/setup-scala.sh
${SETUP_AREA}/setup-python.sh

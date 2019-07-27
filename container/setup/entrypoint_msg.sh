#!/bin/bash

# message that printed out when container starts.

cat <<-EOL

==================================================================
IP of target Event Store server:    $IP
Username:    $EVENT_USER
==================================================================

You are now in the Event Store Demo container.

You can find the pre-compiled Kafka example app at:
    $KAFKA_REPO_PATH 

You can find IoT Analytics example apps at:
    $IOT_REPO_PATH 

Happy exploring!

EOL
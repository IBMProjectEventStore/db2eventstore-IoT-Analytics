#!/bin/bash

if [[ $(java -version 2>&1) != *'version'* ]]; then
    echo "Java not found. Please install Java before continuing."
	exit 1
fi

if [ ! -f ./es-csvloader.jar ]; then
	echo "\"es-csvloader.jar\" missing. Downloading \"es-csvloader.jar\""
	curl -o ./es-csvloader.jar 'https://oss.sonatype.org/content/groups/public/com/ibm/event/es-csvloader/1.0.0/es-csvloader-1.0.0.jar'
fi

java -jar es-csvloader.jar "$@"


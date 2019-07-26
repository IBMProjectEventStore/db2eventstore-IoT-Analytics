#!/bin/bash

TAG="latest"

function usage()
{
cat <<-USAGE #| fmt
Description:
This script build a docker image containing the db2eventstore-IoT-Analytics repo
and db2eventstore-kafka repo. The container has runtime for Python, Java, sbt and 
Spark. The image will be built without using cache, and the image is always named
event_store_demo:latest.

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
-t|--tag    [Default: latest] Tag of the docker image to be built.
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    -t|--tag)
        TAG="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

docker build --no-cache -t event_store_demo:"${TAG}" .
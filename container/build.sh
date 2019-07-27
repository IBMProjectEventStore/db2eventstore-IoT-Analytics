#!/bin/bash

TAG="latest"
BRANCH="master"
TIMESTAMP=`date "+%Y-%m-%d-%H:%M:%S"`

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
    -b|--branch)
        BRANCH="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir -p ${DIR}/image_build_log/
docker build --no-cache --build-arg BRANCH="${BRANCH}" -t event_store_demo:"${TAG}" . | tee "${DIR}/image_build_${TIMESTAMP}.log"
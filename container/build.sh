#!/bin/bash
ES_VERSION="latest"
BRANCH="master"
TIMESTAMP=`date "+%Y-%m-%d-%H:%M:%S"`

function usage()
{
cat <<-USAGE #| fmt
Description:
This script builds a docker image containing the db2eventstore-IoT-Analytics repo
and db2eventstore-kafka repo. The container has runtime for Python, Java, sbt and 
Spark. The image will be built without using cache, and the image is always named
eventstore_demo:${ES_VERSION}

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
-es|--es-version    [Default: latest] Event Store version the docker image will be compatible with
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    -es|--es-version)
        ES_VERSION="$2"
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

echo ${ES_VERSION}  ${BRANCH
mkdir -p ${DIR}/image_build_log/
docker build --no-cache --build-arg BRANCH="${BRANCH}" -t eventstore_demo:"${ES_VERSION}" . | tee "${DIR}/image_build_log/image_build_${TIMESTAMP}.log"

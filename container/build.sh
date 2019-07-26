#!/bin/bash

TAG="latest"

#!/bin/bash

function usage()
{
cat <<-USAGE #| fmt
Description:
This script is the entrypoint of the 

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
        TAG="$1"
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

docker build  --no-cache -t event_store_demo:"${TAG}" .
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
-n|--namespace    [Default: dsx] Kubernetes namespace that Event Store is deployed under.
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    -n|--namespace)
        NAMESPACE="$1"
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

#TODO:
echo "Not implemented yet"
#!/bin/bash

NAMESPACE="dsx"
RELEASE_NAME="eventstore"
DATA_PATH="/ibm"

function usage()
{
cat <<-USAGE #| fmt
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

if [ NAMESPACE != "dsx" ]; then
    RELEASE_NAME=`helm ls --tls | grep db2eventstore | grep -v catalog | awk {'print $1'} | uniq`
    DATA_PATH="/data"
fi

# check nfs mount on each node for each instance
for node in ${nodes}; do
    for release in ${RELEASE_NAME}; do
        if [ $(findmnt -T ${DATA_PATH}/${release}/engine/utils/external_db | grep nfs) ]; then
            echo "Error: NFS server not mounted on ${DATA_PATH}/${release}/engine/utils/external_db/"
            echo "Please ensure Event Store is properly installed and"
            echo "NFS partition is mount on the above path on node $node"
            exit 1
        fi
    done
done

# define eventstoreUtils macro
TOOLS_CONTAINER=$(kubectl get pods -n "$NAMESPACE" | grep eventstore-tenant-tools | \
    awk {'print $1'}) && ORIGIN_IP=`hostname -i | awk '{print $1}'`
eventstoreUtils() { kubectl -n "$NAMESPACE" exec "${TOOLS_CONTAINER}" \
    -- bash -c 'export ORIGIN_IP="${1}" && eventstore-utils "${@:2}"' bash "${ORIGIN_IP}" "${@}"; }

# execute external table loading
eventstoreUtils --tool db2_engine --command "db2 -f /eventstore/db/external_db/ingest.clp" | tee
#!/bin/bash -x

NAMESPACE="dsx"
RELEASE_NAME="eventstore"
DATA_PATH="/ibm"

function usage()
{
cat <<-USAGE #| fmt
Description:
This script provision an NFS server on an DSX cluster where EventStore 2.0 
is already deployed. The script will mount the NFS server to the designated
external table mount point on each cluster nodes.
1/ Create NFS server on the current node
2/ Put the sample data csv file and ingest.clp file under NFS server dir
3/ Mount NFS server to the external_tb mnt point for active releases on all nodes

-------------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
=======
-n | --namespace    [Default: dsx] Kubernetes namespace that Event Store is deployed under.
USAGE
}

while [ -n "$1" ]; do
    case "$1" in 
    -n|--namespace)
        NAMESPACE=$1
        ;;
    -h|--help)
        usage >&2
        exit 0
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
        ;;
    esac
done

NFS_DIR="/mnt/external_tb"
NFS_SERVER=`hostname -i | awk {'print $1'}`
# check if the nfs server dir exist
if [ ! -d "${NFS_DIR}" ]; then
    # create nfs server dir
    echo "Creating NFS server directory"
    sudo mkdir -p "${NFS_DIR}"
    sudo chmod 777 "${NFS_DIR}"

fi

if [ ! -f "${NFS_DIR}/sample_IOT_table.csv" ]; then
    echo "Downloading sample csv data file."
    wget https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/raw/master/data/sample_IOT_table.csv \
        -O ${NFS_DIR}/sample_IOT_table.csv
fi

if [ ! -f "${NFS_DIR}/ingest.clp" ]; then
    touch ${NFS_DIR}/ingest.clp
    echo "insert into ADMIN.IOT_TEMP SELECT * FROM EXTERNAL '/eventstore/db/external_db/sample_IOT_table.csv' USING (DELIMITER ',')" \
        >> ${NFS_DIR}/ingest.clp
fi

echo "Exporting NFS server directory"
nodes=`kubectl get node -n ${NAMESPACE} | awk {'print $1'} | sed '1d'`
for node in ${nodes}; do 
    grep -qxF "${NFS_DIR} ${node}(rw,sync,no_root_squash,no_all_squash)" /etc/exports || \
        sudo echo "${NFS_DIR} ${node}(rw,sync,no_root_squash,no_all_squash)" \
            >> /etc/exports
done

sudo exportfs -a

echo "NFS Directory are exported as:"
sudo exportfs

if [ ${NAMESPACE} != "dsx" ]; then
    RELEASE_NAME=`helm ls --tls | grep db2eventstore | grep -v catalog | awk {'print $1'} | uniq`
    DATA_PATH="/data"
fi

echo "Mounting NFS directory to the external table mount point for active "
echo "Event Store releases on all nodes..."
for node in ${nodes}; do
    for release in ${RELEASE_NAME}; do
        ssh root@"${node}" "mount -t nfs ${NFS_SERVER}:${NFS_DIR} ${DATA_PATH}/${release}/engine/utils/external_db/" | tee
    done
done

#!/bin/bash -x

CLUSTER_IP=$(ifconfig | sed -n -e 's/ *inet \(9.30[0-9.]\+\) \+netmask.*/\1/p')
EVENTSTORE_USERID="admin"
EVENTSTORE_PASSWORD="password"

function usage()
{
cat <<-USAGE #| fmt
Pre-requisite:
- You have created the table IOT_TEMP by runnign the Notebook examples
- You have ingested data into the IOT_TEMP table by running /data/load.sh
- You have run install.sh in this directory to install required packages
========
Description:
This script will execute multiple REST APIs to:
- Connect to database
- Get table IOT_TEMP
- Query the count of record in IOT_TEMP
- Fetch the first 5 record in IOT_TEMP with certain ID.

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--publicIP    [Default: Public IP] Public IP of any cluster node.
--user [Default: admin] User name of Watson Studio Local user who created the IOT_TEMP table
--password [Default: password] Password of Watson Studio Local user who created the IOT_TEMP table
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --publicIP)
        CLUSTER_IP="$1"
        ;;
    --user)
        EVENTSTORE_USERID="$1"
        ;;
    --password)
        EVENTSTORE_PASSWORD="$1"
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

node test.js --engine=$CLUSTER_IP:1101 --server=https://$CLUSTER_IP:443 --user=$EVENTSTORE_USERID --password=$EVENTSTORE_PASSWORD

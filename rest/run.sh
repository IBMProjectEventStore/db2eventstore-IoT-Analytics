#!/bin/bash -x

function usage()
{
cat <<-USAGE #| fmt
Pre-requisite:
- You have created the table IOT_TEMP by runnign the Notebook examples
- You have ingested data into the IOT_TEMP table 
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
--IP       IP of Eventstore Rest Endpoint.
--PORT     Listening port of Eventstore Rest Endpoint
--user     User name of Watson Studio Local user who created the IOT_TEMP table
           [Default: ${EVENT_USER} shell environment variable]
--password Password of Watson Studio Local user who created the IOT_TEMP table
           [Default: ${EVENT_PASSWORD} shell environment variable]

USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --IP)
        IP="$2"
        shift 2
        ;;
    --port)
        PORT="$2"
        shift 2
        ;;        
    --user)
        EVENT_USER="$2"
        shift 2
        ;;
    --password)
        EVENT_PASSWORD="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$2"
        usage >&2
        exit 1
    esac
done

if [ -z ${EVENT_USER} ]; then
    echo "Error: Please provide the Watson Studio Local user name with --user flag"
    usage >&2
    exit 1
fi

if [ -z ${EVENT_PASSWORD} ]; then
    echo "Error: Please provide the Watson Studio Local password with --password flag"
    usage >&2
    exit 1
fi

if [ -z ${IP} ]; then
    echo "Error: Please provide the Event Store server's public IP with --IP flag"
    usage >&2
    exit 1
fi

if [ -z ${PORT} ]; then
    echo "Error: Please provide the Event Store Rest Endpoint port with --port flag"
    usage >&2
    exit 1
fi

node test.js --engine=$IP:$PORT --server=https://$IP:443 --user=$EVENT_USER --password=$EVENT_PASSWORD

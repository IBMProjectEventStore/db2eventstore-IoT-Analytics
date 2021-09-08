
#!/bin/bash -x

function usage()
{
cat <<-USAGE #| fmt
Pre-requisite:
- You have created the table IOT_TEMP by running the Notebook examples
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
--endpoint     Public endpoint address or DNS name of the target Event Store server used by the SDKs to connect to the database
--db2_port     Listening port of Eventstore Rest Endpoint, this is the Db2 port that is exposed outside of the OpenShift (Kuberenetes cluster)
--user         User name of Watson Studio Local user who created the IOT_TEMP table
               [Default: ${EVENT_USER} shell environment variable]
--password     Password of Watson Studio Local user who created the IOT_TEMP table
               [Default: ${EVENT_PASSWORD} shell environment variable]
--endpointRest The REST endpoint IP or DNS name of the Event Store server.
               This is to be used when the REST endpoint differs from the Public IP
               (i.e. --endpoint) ... typically the case for cp4d deployments.  Also can be obtain by oc get routes from OpenShift terminal.
--namespace    cp4d deployments could be installed on a user defined namespace. Use this
               to override the default "zen" namespace.
--deployment-id cp4d deployments utilize a per database deployment ID that must be specified.
               This can be found in the database details page on the IBM Cloud Pak for Data UI console.
               This field is only required for cp4d deployment types.
                e.g. "db2eventstore-1578174815082"
USAGE
}

NAMESPACE="zen"

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --endpoint)
        IP="$2"
        shift 2
        ;;
    --db2_port)
        DB2_PORT="$2"
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
    --endpointRest)
        IPREST="$2"
        shift 2
        ;;
    --namespace)
        NAMESPACE="$2"
        shift 2
        ;;
    --deployment-id)
        DEPLOYMENT_ID="$2"
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
    echo "Error: Please provide the Event Store server's public IP with --endpoint flag"
    usage >&2
    exit 1
fi

if [ -z ${DB2_PORT} ]; then
    echo "Error: Please provide the Event Store Rest Endpoint port with --db2_port flag"
    usage >&2
    exit 1
fi

if [ -z ${IPREST} ]; then
    echo "Error: Please provide the route url of the CP4D with --endpointRest flag"
    usage >&2
    exit 1
fi

if [ -z ${DEPLOYMENT_ID} ]; then
    echo "Error: Please provide the deployment id with --deployment-id flag"
    usage >&2
    exit 1
fi

node test.js --engine=$IP:$DB2_PORT --server=https://$IPREST:443 --user=$EVENT_USER --password=$EVENT_PASSWORD --namespace=$NAMESPACE --deployment-id=$DEPLOYMENT_ID

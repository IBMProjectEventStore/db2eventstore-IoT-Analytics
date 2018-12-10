# REST API DEMO

This section demostrates using the IBM Db2 Event Store REST endpoint in order to perform queries and return results.

For more information, please find on [**IBM Db2 Event Store REST API (1.0.0)**](https://www.ibm.com/support/knowledgecenter/en/SSGNPV_1.1.3/develop/rest-api.html#restapi)

Task performed through the REST API example: 

- Obtain the count of records that matches a filter condition from a existing Event Store database table

- Display all records that match a filter condition from a existing Event Store database table

### Pre-Requisites

- Created the Event Store database and table using the notebook. 
- Ingested sample data into the database table using [`load.sh`](../data/load.sh).
- Define `CLUSTER_IP`, `EVENTSTORE_USERID`, and `EVENTSTORE_PASSWORD` as shell environment variables.

- Run [`install.sh`](install.sh) to  installed the pre-requisited packages.

### Sample Execution

To Run this example simple execute [`./run.sh`](run.sh)

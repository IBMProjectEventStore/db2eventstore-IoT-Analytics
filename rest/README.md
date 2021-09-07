# REST API DEMO

This section demonstrates using the IBM Db2 Event Store REST endpoint in order to perform queries and return results.

For more information, please find on [**IBM Db2 Event Store REST API (2.0.0)**](https://www.ibm.com/docs/en/db2-event-store/2.0.0?topic=store-rest-api)

Task performed through the REST API example:

- Obtain the count of records that matches a filter condition from a existing Event Store database table

- Display all records that match a filter condition from a existing Event Store database table

### Prerequisites

- Created the Event Store database and table using the notebook.
- Ingested sample data into the database table using [`load.sh`](../data/load.sh).
- Define `CLUSTER_IP`, `EVENTSTORE_USERID`, and `EVENTSTORE_PASSWORD` as shell environment variables.

- Run [`install.sh`](install.sh) to install the prerequisite packages.

### Sample Execution

To Run this example, simply execute [`./run.sh`](run.sh)

### Successful Execution Output
```
[root@e9480f587c9f rest]# node test.js --engine=9.46.196.49:9177 --server=https:                                                                                                     //zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443 --user=admin --pas                                                                                                     sword=password --namespace=zen --deployment-id=db2eventstore-1630513601941818
Using Engine: 9.46.196.49:9177
Using Server: https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:44                                                                                                     3
Using Username: admin
Using Password: password
Namespace: zen
Deployment id: db2eventstore-1630513601941818

Authorization in header
Basic YWRtaW46cGFzc3dvcmQ=
Getting the IDP Bearer Token
==========================
https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/v1/preauth/v                                                                                                     alidateAuth
(node:259) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security                                                                                                      and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Bu                                                                                                     ffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
Token from IDP Cluster successfully retrieved:
==========================
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwicm9sZSI6IkFkbWl                                                                                                     uIiwicGVybWlzc2lvbnMiOlsiYWRtaW5pc3RyYXRvciIsImNhbl9wcm92aXNpb24iXSwiZ3JvdXBzIjp                                                                                                     bMTAwMDBdLCJzdWIiOiJhZG1pbiIsImlzcyI6IktOT1hTU08iLCJhdWQiOiJEU1giLCJ1aWQiOiIxMDA                                                                                                     wMzMwOTk5IiwiYXV0aGVudGljYXRvciI6ImRlZmF1bHQiLCJpYXQiOjE2MzEwNDU5NTgsImV4cCI6MTY                                                                                                     zMTA4OTEyMn0.Sr3kJ7qNmA0Hms3jC-4s411DBnN95v3qzG0ABfhxmXkNjZIZyHFSXwqd0kvxs4W7oo8                                                                                                     CoJANdFeY2Q3Ri62YD-KVuEeHHdbvmKztMidI9FQa3whAxce3y1R3lULsMbDMpmGZVM4MpJHfLT7yw87                                                                                                     Yvz_hU6riuaTd56pBTe8eOBwxlDprpsnEPlwtsu5S1sMbeBYygZUPSc2lg22Njgtr00uKf5ei5pH1Ndc                                                                                                     rlDjo4lzhhfHY5_rDQpX2JCJiRVayp5qC5wRKuoMOnV6Q6OW42hG6wxtWRgLjsM0iuTvd22hjnALnOa2                                                                                                     lTg-ZyTETitGXA5Jh-X2qgcE_Nh_ZmYPxmA
==========================


==========================
IDP Cluster located at: https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.                                                                                                     ibm.com:443

Running test: Connect to Engine
https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/icp4data-dat                                                                                                     abases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/init/engine?engin                                                                                                     e=9.46.196.49:9177
==========================
==========================
URL Called -> https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:44                                                                                                     3/icp4data-databases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/ini                                                                                                     t/engine?engine=9.46.196.49:9177
** Received response **
Response Returned -> [object Object]
Body Returned -> {"code":"ES100","message":"Engine initialization succeeded"}
RESPONSE -> ES100
MESSAGE -> Engine initialization succeeded

Running test: Get Database
https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/icp4data-dat                                                                                                     abases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/oltp/databases
==========================
URL Called -> https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:44                                                                                                     3/icp4data-databases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/olt                                                                                                     p/databases
** Received response **
Response Returned -> [object Object]
Body Returned -> {"code":"ES350","message":"List of all databases successfully r                                                                                                     etrieved","data":[{"name":"EVENTDB"}]}
RESPONSE -> ES350
MESSAGE -> List of all databases successfully retrieved

Running test: Get the table Info
https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/icp4data-dat                                                                                                     abases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/oltp/table?tableN                                                                                                     ame=IOT_TEMP&databaseName=EVENTDB
==========================
URL Called -> https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:44                                                                                                     3/icp4data-databases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/olt                                                                                                     p/table?tableName=IOT_TEMP&databaseName=EVENTDB
** Received response **
Response Returned -> [object Object]
Body Returned -> {"code":"ES370","message":"Table information successfully retri                                                                                                     eved","data":{"groupID":24,"tableGroupName":"sys_ADMINIOT_TEMP","id":48,"numberS                                                                                                     hards":36}}
RESPONSE -> ES370
MESSAGE -> Table information successfully retrieved

Submitting a SparkSql query
==========================
Submitting -> "select count(*) as count from IOT_TEMP where deviceID=1 and senso                                                                                                     rID=31"
Result of SparkSql query:
https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/icp4data-dat                                                                                                     abases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/spark/sql?tableNa                                                                                                     me=IOT_TEMP&databaseName=EVENTDB
==========================
URL Called -> https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:44                                                                                                     3/icp4data-databases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/spa                                                                                                     rk/sql?tableName=IOT_TEMP&databaseName=EVENTDB
** Received response **
Response Returned -> [object Object]
Body Returned -> {"code":"ES400","message":"SparkSQL query was correctly execute                                                                                                     d","data":"[{\"count\":1155}]"}

**Query Result:**
[{"count":1155}]

Submitting a SparkSql query
==========================
Submitting -> "select * from IOT_TEMP where deviceID=1 and sensorID=31 limit 5"
Result of SparkSql query:
https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/icp4data-dat                                                                                                     abases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/spark/sql?tableNa                                                                                                     me=IOT_TEMP&databaseName=EVENTDB
==========================
URL Called -> https://zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com:443/icp4data-databases/db2eventstore-1630513601941818/zen/com/ibm/event/api/v1/spark/sql?tableName=IOT_TEMP&databaseName=EVENTDB
** Received response **
Response Returned -> [object Object]
Body Returned -> {"code":"ES400","message":"SparkSQL query was correctly executed","data":"[{\"DEVICEID\":1,\"SENSORID\":31,\"TS\":1541627199220,\"AMBIENT_TEMP\":27.593995991939863,\"POWER\":6.921405275716975,\"TEMPERATURE\":44.1656966644114},{\"DEVICEID\":1,\"SENSORID\":31,\"TS\":1541310567376,\"AMBIENT_TEMP\":27.08558496190764,\"POWER\":13.62873063735008,\"TEMPERATURE\":50.3360236897283},{\"DEVICEID\":1,\"SENSORID\":31,\"TS\":1541543326122,\"AMBIENT_TEMP\":26.047510749164648,\"POWER\":12.6674332022278,\"TEMPERATURE\":47.016434953018525},{\"DEVICEID\":1,\"SENSORID\":31,\"TS\":1541054234074,\"AMBIENT_TEMP\":25.60663139977397,\"POWER\":14.718642454235619,\"TEMPERATURE\":47.998245262863314},{\"DEVICEID\":1,\"SENSORID\":31,\"TS\":1541699793364,\"AMBIENT_TEMP\":24.66876440073116,\"POWER\":12.570519460858517,\"TEMPERATURE\":43.262131448398314}]"}

**Query Result:**
[{"DEVICEID":1,"SENSORID":31,"TS":1541627199220,"AMBIENT_TEMP":27.593995991939863,"POWER":6.921405275716975,"TEMPERATURE":44.1656966644114},{"DEVICEID":1,"SENSORID":31,"TS":1541310567376,"AMBIENT_TEMP":27.08558496190764,"POWER":13.62873063735008,"TEMPERATURE":50.3360236897283},{"DEVICEID":1,"SENSORID":31,"TS":1541543326122,"AMBIENT_TEMP":26.047510749164648,"POWER":12.6674332022278,"TEMPERATURE":47.016434953018525},{"DEVICEID":1,"SENSORID":31,"TS":1541054234074,"AMBIENT_TEMP":25.60663139977397,"POWER":14.718642454235619,"TEMPERATURE":47.998245262863314},{"DEVICEID":1,"SENSORID":31,"TS":1541699793364,"AMBIENT_TEMP":24.66876440073116,"POWER":12.570519460858517,"TEMPERATURE":43.262131448398314}]

```

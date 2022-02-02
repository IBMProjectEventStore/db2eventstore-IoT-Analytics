# ODBC Remote Application / DB2CLI Execution Steps:

Prior to running the ODBC sample application you must set up the ODBC/DB2CLI environment. If you are using the Docker container, the ODBC/DB2CLI is already set-up for you and you do not use the instructions for the ODBC/DB2CLI Setup are found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup).  

If you are not running in the Docker container, run the script found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh) to download the SSL server certificate. This is necessary as Db2 Event Store is configured with SSL using a dynamically generated self signed certificate out of the box. 

Regardless if you are running inside the Docker container or creating your own environment, the following environment variables must be set up prior to running the ODBC sample application. 

* IP with the cluster's IP address
* EVENT_USER with the Event Store user name
* EVENT_PASSWORD with the Event Store user password
* DB2_PORT with the port used by Db2
* SERVER_CERT_PATH with the server cetificate path which is set when SSL is configured in the Docker container. If not running in the Docker container you must set the variable

## Running the example app ExampleODBCApp

1. Compile the app by executing the following. The <odbc_client_path> is where the ODBC client was unpacked during the environment setup. The script finds the ODBC headers under `<odbc_client_path>/include`, compiles the main app ExampleODBCApp.c, a helper utilcli.c which checks for errors and returns diagnostic message and links the db2 library under <odbc_client_path>/lib.  If you are using the Docker container the `<odbc_client_path>` is `/clidriver` inside the Docker container
```
./bldExampleODBCApp <odbc_client_path>
```
If you running the docker demo container run these commands:
```
cd /root/db2eventstore-IoT-Analytics/AdvancedApplications/ODBCApplication
./bldExampleODBCApp /clidriver
./ExampleODBCApp
```
### Db2 Data Server Driver Versions
For some reason db2 ds driver 11.5.7 does not work, I got this error when running `./bldExampleODBCApp /clidriver`  (there should be no output from that command)
```
[root@c0ae9eaffd40 ODBCApplication]# ./bldExampleODBCApp /clidriver
/clidriver/lib/libdb2.so: undefined reference to `SqloCosClient::SqloCosClient_toString(unsigned long, char*)'
collect2: error: ld returned 1 exit status
```
So I reverted back to db2 ds driver 11.5.6. The issue is this file `clidriver/lib/libdb2.so.1` in db2 ds driver ver. 11.5.7 causes the `./bldExampleODBCApp /clidriver` command to fail with error mentioned above but this same file from version 11.5.6 works fine. The `libdb2.so.1` file is zipped in this file `ibm_data_server_driver_for_odbc_cli.tar.gz` which is zipped in this file `v11.5.6_linuxx64_dsdriver.tar.gz`


 
With vesrsions 11.5.6 and earlier some of output after running the 3 commands, at the end will look like
```
-----------------------------------------------------------
USE THE CLI FUNCTIONS
  SQLExecDirect
  SQLBindCol
  SQLFetch
TO PROCESS SQL QUERY RESULT SET:

  Directly execute SELECT * FROM IOT_TEMP FETCH FIRST 10 ROWS ONLY.

  1 6 1541608808893 23.100081670190129 13.039762334338846 40.725704939741505
  1 6 1541692063994 23.231144125868092 10.905764685605330 42.552486820314854
  1 6 1541072557045 24.754846044565248 7.842973434366321 40.098125855881406
  1 6 1541739758037 23.586596370324894 12.707494438552153 42.825719719249321
  1 6 1541741409175 27.713916953170603 4.500360172227634 44.530580976342783
  1 6 1541489785094 21.944065021121851 10.051196444228976 38.013755171543934
  1 6 1541332982350 25.230894616915396 4.941043098535454 41.147460423219975
  1 6 1541316155282 26.172570331182822 10.780627950616898 45.498515325155118
  1 6 1541049754681 24.400766844283801 12.977732546098055 40.581683401949135
  1 6 1541657205418 20.881357065156827 7.475510945569964 36.927511174461820

-----------------------------------------------------------
USE THE CLI FUNCTIONS
  SQLDisconnect
  SQLFreeHandle
TO DISCONNECT FROM EVENTSTORE:

  Disconnecting from the database EVENTDB...
  Disconnected from the database EVENTDB.
```

2. To clean up compiler generated files

`./bldExampleODBCApp --clean`

## Running the Db2 interactive CLI

To open an interactive user interface that can be used to run queries, complete the following steps. 

1. Go to ODBC client bin directory

`cd <odbc_client_path>/bin`

2. Before running the following command a number of parameters must be provided.

  * server_certificate_path is the path that you obtained using the rest API/setup script, you could use the environment variable $SERVER_CERT_PATH
  * IP is the IP address of your Event Store cluster, you could use the environment variable $IP
  * Db2_port is the port used for Db2 (can be found in the Clould Pak for Data UI), you could use the environment variable $DB2_PORT
  * username and password are your Event Store user credentials, you could use the environment variables $EVENT_USER and $EVENT_PASSWORD

`./db2cli execsql -connstring "DATABASE=eventdb; Protocol=tcpip; Authentication=GSSPLUGIN; Security=ssl; SSLServerCertificate=<server_certificate_path>; HOSTNAME=<IP>; PORT=<Db2_port>; UID=<username>; PWD=<password>"`

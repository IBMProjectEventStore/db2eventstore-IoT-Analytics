# ODBC Remote Application / DB2CLI Execution Steps:

Prior to running the ODBC sample application you must set up the ODBC/DB2CLI environment. If you are using the Docker container, the ODBC/DB2CLI Setup instructions that follow must be executed inside the container. The instructions for the ODBC/DB2CLI Setup are found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup).  

If you are not running in the Docker container, run the script found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh) to download the SSL server certificate. This is necessary as Db2 Event Store is configured with SSL using a dynamically generated self signed certificate out of the box. 

Regardless if you are running inside the Docker container or creating your own environment, the following environment variables must be set up prior to running the ODBC sample application. 

* IP with the cluster's IP address
* EVENT_USER with the Event Store user name
* EVENT_PASSWORD with the Event Store user password
* SERVER_CERT_PATH with the server cetificate path which is set when SSL is configured in the Docker container. If not running in the Docker container you must set the variable

## Running the example app ExampleODBCApp.c

1. Compile the app by executing the following. The <odbc_client_path> is where the ODBC client was unpacked during the environment setup. The script finds the ODBC headers under `<odbc_client_path>/include`, compiles the main app ExampleODBCApp.c, a helper utilcli.c which checks for errors and returns diagnostic message and links the db2 library under <odbc_client_path>/lib

`./bldExampleODBCApp <odbc_client_path>`
 
2. Run the executable created by the build

`./ExampleODBCApp`

3. To clean up compiler generated files

`./bldExampleODBCApp --clean`

## Running the Db2 interactive CLI

To open an interactive user interface that can be used to run queries, complete the following steps. 

1. Go to ODBC client bin directory

`cd <odbc_client_path>/bin`

2. Before running the following command a number of parameters must be substituted.

  * server_certificate_path is the path that you obtained using the rest API/setup script, you could use the environment variable $SERVER_CERT_PATH
  * IP is the IP address of your Event Store cluster, you could use the environment variable $IP
  * Db2_port is the port used for Db2 (can be found in the Clould Pak for Data UI)
  * username and password are your Event Store user credentials, you could use the environment variables $EVENT_USER and $EVENT_PASSWORD

`./db2cli execsql -connstring "DATABASE=eventdb; Protocol=tcpip; Authentication=GSSPLUGIN; Security=ssl; SSLServerCertificate=<server_certificate_path>; HOSTNAME=<IP>; PORT=<Db2_port>; UID=<username>; PWD=<password>"`

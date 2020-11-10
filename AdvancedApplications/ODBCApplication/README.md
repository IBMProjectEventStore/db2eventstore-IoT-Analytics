# ODBC Remote Application / DB2CLI Execution Steps:

Prior to running the ODBC sample application you must first set up the ODBC/DB2CLI environment. If you are using the Docker container, the following instructions are executed inside the container. You must completed the following steps found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup).  

If you are not running in the Docker container, run the script used in the container setup which configures SSL, it can be found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). The script downloads the SSL server certificate through the REST API. This is necessary as Db2 Event Store is configured with SSL using a dynamically generated self signed certificate out of the box. 

Regardless if you are running inside the Docker container or creating your own environment, the following environment variables must be set up prior to running the ODBC sample application. 

* IP with the cluster IP address
* EVENT_USER with the user name
* EVENT_PASSWORD with the user password

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

2. Run this command after providing the information like the IP address of the cluster. You can find the port being used by Db2 in the Cloud Pak 4 Data user interface. 

`./db2cli execsql -connstring "DATABASE=eventdb; Protocol=tcpip; Authentication=GSSPLUGIN; Security=ssl; SSLServerCertificate=<server_certificate_path>; HOSTNAME=<IP>; PORT=<Db2_port>; UID=<username>; PWD=<password>"`

   * `<server_certificate_path>` is the path that you obtained above using the rest API/setup script, or the environment variable `$SERVER_CERT_PATH` if SSL was configured through the setup script mentioned above
   * `<IP>`  is the IP address of your eventstore cluster, or the environment variable `$IP`
   * `<Db2_port>` is the port used for Db2 (can be found in the Clould Pak for Data UI)
   * `<username>`and `<password>` is your eventstore user credentials, or the environment variables `$EVENT_USER` `$EVENT_PASSWORD`

# ODBC Remote Application / DB2CLI Execution Steps:

Prior to running the sample application you must first set up the environment to run a ODBC/DB2CLI application. You must have completed the following steps found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup). If you are using the Docker container, the instructions are executed inside the container. 

If you are not running in the Docker container, run the script to configure SSL which is used when setting up the container which can be found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). The script downloads the SSL server certificate through the REST API. This is necessary as Db2 Event Store is configured with SSL with a default keystore out of the box (this may change if you configure your own keystore after installation). Also the following environment variables must be set up

* IP with the cluster IP address
* EVENT_USER with the user name
* EVENT_PASSWORD with the user password

## Running the example app ExampleODBCApp.c

1. Compile the app by running

`./bldExampleODBCApp <odbc_client_path>` 
The `<odbc_client_path>` is where you unpacked the ODBC client during the environment setup. The script does the following:
     * Finds the ODBC headers under `<odbc_client_path>/include` and compiles the main app ExampleODBCApp.c and a helper utilcli.c which checks for errors and returns diagnostic messages
     * Links the db2 library under <odbc_client_path>/lib
     
2. Run the executable creaed by the build

`./ExampleODBCApp`

To clean up the compiler generated files

`./bldExampleODBCApp.c --clean'

### To run the DB2 interactive CLI, follow these steps:
1. Go to ODBC client bin directory
`cd <odbc_client_path>/bin`
2. Run the following command
`./db2cli execsql -connstring "DATABASE=eventdb; Protocol=tcpip; Authentication=GSSPLUGIN; Security=ssl; SSLServerCertificate=<server_certificate_path>; HOSTNAME=<IP>; PORT=18730; UID=<username>; PWD=<password>"`
   * `<server_certificate_path>` is the path that you obtained above using the rest API/setup script, or the environment variable `$SERVER_CERT_PATH` if configured SSL through the setup script mentioned above.
   * `<IP>`  is the IP address of your eventstore cluster, or the environment variable `$IP`.
   * `<username>`and `<password>` is your eventstore user credentials, or the environment variables `$EVENT_USER` `EVENT_PASSWORD`.
3. The command will open an interactive user interface. Run queries on it!

# Instructions on How to Run ODBC Applications For IBM Db2 Event Store

## Python Remote Application Execution Steps:

This assumes that you have set up the environment to run a ODBC/DB2CLI application. If you haven't yet done this step, [please follow the instructions here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup) to set up your environment. 

If not running within the docker container, run the script to configure SSL that is provided in the container [set up folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh), which will download the SSL server certificate through the rest API. This is necessary because Db2 Event Store is configured with SSL with a default keystore out of the box (this may change if you configure your own keystore after installation). Also set up the environment variables IP with the cluster IP address, EVENT_USER with the user name, and EVENT_PASSWORD with the user password.

To run the example app [`ExampleODBCApp.c`](ExampleODBCApp.c), follow these steps:
1. Compile the app by running [`./runExampleODBCApp.c <path to ODBC client directory>`](runExampleODBCApp.c)
    * The script will then do the following for you:
         * Find the ODBC headers under `<odbc_client_path>/include` and compile the main app [`ExampleODBCApp.c`](ExampleODBCApp.c) and a helper ['utilcli.c'](utilcli.c) which will check for errors and return the diagnostic messages
		* Link the db2 library under <odbc_client_path>/lib.
2. Run the executable `./ExampleODBCApp`

# Setting up a remote connection from a standard Db2 client to a Db2 Event Store database 

This document provides an example for setting up a remote Db2 client to connect to a Db2 Event Store database, and from this client be able to create and drop tables, load CSV files, and query the database.

This example is built using a container that already contains the latest Db2 10.5, and that can be downloaded directly from docker hub [ibmcom/db2](https://hub.docker.com/r/ibmcom/db2). This same example can be modified to run it on any local installation of a Db2 server or Db2 client.

The example has two parts:

1. A setup script to configure the Db2 client to connect to a Db2 Event Store instance and database.

In the following example, we invoke the script providing an external directory to store any persistent data outside the client container, the acceptance of the licence for the Db2 client container, and the IP address to the cluster and credentials for the test connection:

```
./setup_container_db2client_to_eventstore.sh  --shared-path /home/cmgarcia/db2client_external/shared_path/  --licence accept --eventstore-cluster-ip 172.16.173.163 --eventstore-cluster-db2-ip 172.16.173.163 --eventstore-user admin --eventstore-password password
```

2. A script with a sample SQL code to load data from a CSV file and then query this data using the configured Db2 client from step 1.

In the following example we invoke the test script with the credentials to establish the connection to the database and the sample CSV file generated that will be loaded into the Db2 Event Store database:

```
$ ./remote_load_csv_using_db2client_container.sh --eventstore-user admin --eventstore-password password --csv-file sample_IOT_table.csv
```

Once the two parts are completed you can access the container using the instance owner name, establish a new connection to the database and from there execute other Db2 client commands against the remote DB2 Event Store database.

```
$ docker ps 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                           NAMES
4facc111479a        ibmcom/db2          "/var/db2_setup/lib/…"   2 hours ago         Up 2 hours          22/tcp, 50000/tcp, 55000/tcp, 60006-60007/tcp   db2-user1
$ docker exec -it  db2 bash -c "su - db2inst1"
```

## Setting up the Db2 client Connection to a Db2 Event Store instance and database

In this section we will describe the steps followed within the setup script to configure the remote connection from the Db2 client to the remote Db2 Event Store database.

First, start the container with the Db2 client like the following:

```
$ docker run -itd --name db2 -e DBNAME=testdb -v ~/:/database -e DB2INST1_PASSWORD=GD1OJfLGG64HV2dtwK -e LICENSE=accept -p 50000:50000 --privileged=true ibmcom/db2
```

Then enter the container:

```
$ docker exec -it  db2 bash -c "su - db2inst1"
```

For the next steps follow the documentation for [Configuring Secure Sockets Layer (SSL) support in non-Java Db2 clients](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.5.0/com.ibm.db2.luw.admin.sec.doc/doc/t0053518.html)

First, use the GSKCapiCmd tool to create a key database on the client by using GSKit ```gsk8capicmd_64```. For example, within the client container do the following:

```
[db2inst1@a33d5b29ffa2 ~]$ gsk8capicmd_64 -keydb -create -db "mydbclient.kdb" -pw "myClientPassw0rdpw0" -stash
```
Second, copy the default self-signed certificate from the Db2 Event Store cluster. 

For example, access the Db2 Event Store cluster, and then within the cluster run the following to determine one of the engine PODS followed by a copy of the certificatre file from the POD:

```
# kubectl get pods -n dsx | grep eventstore-tenant-engine | head -1
eventstore-tenant-engine-565d74cfd8-64jv4         1/1       Running     0          21h

# kubectl exec -n dsx eventstore-tenant-engine-565d74cfd8-64jv4 -- cat /eventstorefs/eventstore/db2inst1/sqllib_shared/gskit/certs/eventstore_ascii.cert
```

With this, create a server-certificate.cert file on the client (that is, in this example, within the client container), and then add the certificate to the client key database. 

Following the example, run the following command within the client container to add the certificate to the previously created key database:

```
[db2inst1@a33d5b29ffa2 ~]$ gsk8capicmd_64 -cert -add -db "mydbclient.kdb" -pw "myClientPassw0rdpw0"  -label "server" -file "server-certificate.cert" -format ascii -fips
```

And finally update the configuration on the client to use the key database you just set up:

```
[db2inst1@a33d5b29ffa2 ~]$ db2 update dbm cfg using
      SSL_CLNT_KEYDB /home/test1/sqllib/security/keystore/clientkey.kdb
      SSL_CLNT_STASH /home/test1/sqllib/security/keystore/clientstore.sth
```
Then, follow the documentation to [catalog a remote TCPIP node using SECURITY SSL](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.5.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0001944.html):

```
[db2inst1@a33d5b29ffa2 ~]$ db2 catalog tcpip node nova remote 172.16.197.11 server 18730 SECURITY SSL
DB20000I  The CATALOG TCPIP NODE command completed successfully.
DB21056W  Directory changes may not be effective until the directory cache is
refreshed.
```

And lastly, follow the documentation to [catalog the database using AUTHENTICATION GSSPLUGIN](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.5.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0001936.html):

```
[db2inst1@a33d5b29ffa2 ~]$ db2 CATALOG DATABASE eventdb AT NODE  nova AUTHENTICATION GSSPLUGIN
DB20000I  The CATALOG DATABASE command completed successfully.
DB21056W  Directory changes may not be effective until the directory cache is
refreshed.
```

All the set up is done at this point. Now [establish a connection](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.5.0/com.ibm.db2.luw.sql.ref.doc/doc/r0000908.html?pos=2) to the remote Db2 Event Store database using the user and the password to validate this configuration:

```
[db2inst1@a33d5b29ffa2 ~]$ db2 CONNECT TO eventdb USER admin USING password

   Database Connection Information

 Database server        = DB2/LINUXX8664 11.1.9.0
 SQL authorization ID   = ADMIN
 Local database alias   = EVENTDB
```


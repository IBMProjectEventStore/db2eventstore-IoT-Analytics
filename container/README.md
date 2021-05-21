### Docker Image for Event Store 2.0 Demo

The Dockerfile in this directory will build a docker image named `eventstore_demo`. The image contains remote applications and runtime environment for Event Store demo. Users can build the docker image, run the docker container from the image built, and run the pre-loaded examples in the docker container.

**Procedure:**
**Step 1: Build the docker image**
On a linux desktop or server (CentOS 7.9 works fine) that has docker already installed and running.  See https://docs.docker.com/engine/install/ for instructions on installing docker.  <br>
Run the shell script `build.sh` to build the docker image.
The image size is around 3.5 GB, build takes around 30 mins, depending on network conditions.
The Event Store release the IoT applications will use must be specified. The release is used to tag the image. Supported releases are: `2.0.1.2`, `2.0.1.0` and `2.0.0.5`. To run this for release 2.0.1.2, the command would be:
```
./build.sh --es-version 2.0.1.2
```
The format to run this for other (versions) releases of Event Store is:
```
./build.sh --es-version <eventstore-release>
```
where `<eventstore-release>` is replaced with the actual eventstore-release number.

**Step 2: Start the docker container**
After the image is built, run the shell script `dockershell.sh` to start the container and run the examples. The Event Store release identifies which tagged image to start.
The script takes 4 mandatory arguments and 3 optional ones.

`./dockershell.sh --endpoint <EventStore_Server_Endpoint> --db2-port <db2_port_number> --es-port <es_port_number> --endpointRest <EventStore_Rest_Endpoint> --user <EventStore_Username> --password <EventStore_Password> --deploymentType <deployment type> --deploymentID <deployment ID> --es-version <release>`

How to run with different deployment types:

IBM Cloud Pak For Data (cp4d) // Default deployment type
- Generally this requires you to specify --endpointRest as the REST endpoint differs from the eventstore server endpoint` (i.e., --endpoint)
- endpoint on ibm fyre with OpenShift installed via OCP+, the endpoint is the ip address of your infrastructure node
- endpointRest is typically the dns name of the url you use to log into cloud pak for data, this often can be found while logged into the cluster and run these 2 commands
   ```
   oc project zen
   oc get route  | grep -v 'HOST/PORT' | awk '{print $2}'
   ```
- This requires the --deploymentID which is specific to the database and can be retrieved from the eventstore cloudpak for data User Interface (UI) at: `Data ... Databases ... Details`.  It will be a value that appears similar to: `db2eventstore-16043310702252545`
- This requires the user and password options (normally what is used to log into Cloud Pak for data url)
- This optionally requires the Kubernetes namespace which is the OpenShift project that is used for the specific deployment. The default namespace/project is `zen`.
- For example

`./dockershell.sh --endpoint 9.30.68.83 --db2-port 9177 --es-port 9178 --endpointRest zen-cpd-zen.apps.es-cp4d-r9.os.fyre.ibm.com --user user --password passw0rd --deploymentType cp4d --deploymentID db2eventstore-1604331070225254 --es-version 2.0.1.2`

After the script is successfully run you are placed inside the conatiner. <br>

Watson Studio Local (wsl)
- Generally the eventstore server endpoint and the rest endpoint are the same, implying you only need to specify --endpoint
- This requires the user and password options

Developer container (developer)
- This requires the --endpoint of the container where the eventstore server is running, there is no REST server here so --endpointRest is not applicable
- This requires the user and password options

See the scripts help option for more details (i.e. `./dockershell.sh --help`)

After the above commnand:
- A docker container instance named `eventstore_demo_${user}` will be started. The container instance contains necessary run-time environments for running applications in Python, Java, JDBC, Scala, Kafka, REST (Node.js), and Spark.
- The environment will be setup with the necessary configurations to establish SSL connection with the SDKs where applicable (i.e. when not using a developer deployment, which does not use SSL).
- Mount hostpath `${HOME}/eventstore_demo_volume` to `/root/user_volume` inside the container.

**Using the container** <br>

If you exit the container, here is how to re-enter it, from the host that is running the `evenstore_demo` container enter the following command
```
docker ps
```
this should give an output similar to what is shown below
```
CONTAINER ID   IMAGE                     COMMAND                  CREATED        STATUS        PORTS     NAMES
2ed7b72a008a   eventstore_demo:2.0.1.2   "bash -c 'env && /ro…"   11 hours ago   Up 11 hours             eventstore_demo_admin
```
To enter the container run the following command (for your case replace `2ed7b72a008a` with your actual CONTAINER ID for your `evenstore_demo:<version>` docker image
```
docker exec -it 0 2ed7b72a008a bash
```

This will place you back into the container.   Once in the container, the various sample applications (e.g. jdbc, scala, ...) can be accessed here:
```
/root/db2eventstore-IoT-Analytics/AdvancedApplications:
IngestUsingIBMStreams
JDBCApplication
JavaApplication
ODBCApplication
PythonApplication
ScalaApplication
```
The instructions for each of these applications can be found here:
[Advanced Applications Documentation](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications)


The kafka sample application is contained in its own repository, which for convenience is cloned into the container in the following location:
```
/root/db2eventstore-kafka
```
The instruction for using the kafka application can be found in the README of the corresponding repository: [Kafka Repository](https://github.com/IBMProjectEventStore/db2eventstore-kafka)

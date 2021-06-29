## Docker Image for Event Store 2.0 Demo

The Dockerfile in this directory will build a docker image named `eventstore_demo`. The image contains remote applications and runtime environment for Event Store demo. Users can build the docker image, run the docker container from the image built, and run the pre-loaded examples in the docker container.

### Procedure
#### Step 1: Clone this repo
On a linux desktop git clone this repo
```
cd ~
yum install -y git
git clone git@github.com:IBMProjectEventStore/db2eventstore-IoT-Analytics.git
```

#### Step 2: Build the docker image
On either 
- Mac OS 11.4 with [docker desktop](https://www.docker.com/products/docker-desktop) (tested with Docker version `20.10.7, build f0df350` MacBook Pro 16 inch 2019 model) installed and running or: 
- linux desktop or server (CentOS 7.9 & CentOS 8.4 work fine, Red Hat 8.4 only works with Docker and not Podman) that has docker already installed and running.  See https://docs.docker.com/engine/install/ for instructions on installing docker.  The machine also needs access to the internet. <br>

Run the shell script `build.sh` to build the docker image.
The image size is around 4.5 GB, build takes around 12 to 30 mins, depending on network conditions and processing power of the host (MacBook Pro 16 in 2019 model took 12.6 minutes).
The Event Store release the IoT applications will use must be specified. The release is used to tag the image. Supported releases are: `2.0.1.3`,`2.0.1.2`, `2.0.1.0` and `2.0.0.5`. To run this for release `2.0.1.3`, the command would be:
```
cd ~ db2eventstore-IoT-Analytics/container
./build.sh --es-version 2.0.1.3
```
The format to run this for other (versions) releases of Event Store is:
```
./build.sh --es-version <eventstore-release>
```
where `<eventstore-release>` is replaced with the actual eventstore-release number.

#### Step 3: Start the docker container
After the image is built, run the shell script `dockershell.sh` to start the container and run the examples. The Event Store release identifies which tagged image to start.
The script takes 4 mandatory arguments and 3 optional ones.

```
cd ~ db2eventstore-IoT-Analytics/container
./dockershell.sh --endpoint <EventStore_Server_Endpoint> --db2-port <db2_port_number> --es-port <es_port_number> --endpointRest <EventStore_Rest_Endpoint> --user <EventStore_Username> --password <EventStore_Password> --deploymentType <deployment type> --deploymentID <deployment ID> --es-version <release>
```

How to run with different deployment types:

IBM Cloud Pak For Data (cp4d) // Default deployment type
- Generally this requires you to specify --endpointRest as the REST endpoint differs from the eventstore server endpoint` (i.e., --endpoint)
- db2-port - db2 port accessible outside of OpenShift
- es-port - this is the eventstore port accessible outside of OpenShift <br>
Here is how to obtain the internal `db-port` and internal `es-port` while connected to OpenShift cluster via `oc login` from a terminal session.  These ports must then get exposed outside of the OpenShift cluster (typically on a different port number).  These external ports must be used and not the internal port numbers.
```
DB2_EXTERNAL_ENGINE_SVC=`oc get svc | grep db2eventstore-.*engine-db2-external-svc | awk '{ print $1 }'`
ES_EXTERNAL_ENGINE_SVC=`oc get svc | grep db2eventstore-.*engine-es-external-svc | awk '{ print $1 }'`
DB2_INTERNAL_PORT=`oc get svc ${DB2_EXTERNAL_ENGINE_SVC} -o jsonpath='{.spec.ports[?(@.name=="server")].nodePort}'`
EVENTSTORE_INTERNAL_PORT=`oc get svc ${ES_EXTERNAL_ENGINE_SVC} -o jsonpath='{.spec.ports[?(@.name=="legacy-server")].nodePort}'`
echo $DB2_INTERNAL_PORT
echo $EVENTSTORE_INTERNAL_PORT
```
- endpoint is the IP addresses that exposed the `db-port` and `es-port`.  On ibm fyre with OpenShift installed via OCP+, the endpoint is external the ip address of your infrastructure node (starts with 9.x and not 10.x)
- endpointRest is typically the dns name of the url you use to log into cloud pak for data, this often can be found while logged into the cluster and run these 2 commands
   ```
   oc project zen
   oc get route zen-cpd -o jsonpath={.spec.host}
   ```
   command below now gives two hostnames
   ```
   oc get route  | grep -v 'HOST/PORT' | awk '{print $2}'
   ```
- This requires the --deploymentID which is specific to the database and can be retrieved from the eventstore cloudpak for data User Interface (UI) at: `Data ... Databases ... Details`.  It will be a value that appears similar to: `db2eventstore-16043310702252545`
- This requires the user and password options (normally what is used to log into Cloud Pak for data url)
- This optionally requires the Kubernetes namespace which is the OpenShift project that is used for the specific deployment. The default namespace/project is `zen`.
- For example
```
cd ~ db2eventstore-IoT-Analytics/container
./dockershell.sh --endpoint 9.30.68.83 --db2-port 9177 --es-port 9178 --endpointRest zen-cpd-zen.apps.es-cp4d-r9.os.fyre.ibm.com --user admin --password password --deploymentType cp4d --deploymentID db2eventstore-1604331070225254 --es-version 2.0.1.2
```
If this successfully connects to your Event Store the end of output of this script will look like:
```
==================================================================
IP of target Event Store server:    9.46.100.48
Username:    admin
==================================================================

You are now in the Event Store Demo container.

You can find the pre-compiled Kafka example app at:
    /root/db2eventstore-kafka

You can find IoT Analytics example apps at:
    /root/db2eventstore-IoT-Analytics

Happy exploring!
``` 
After the script is successfully run you are placed inside the conatiner. <br>
### Troubleshooting & Instructions
1.  If you see this at the very end
```
Happy exploring!

bash: /html: No such file or directory
```
the `bash: /html: No such file or directory` indicates something is not correct, most likey the ports are not configured correctly in `/etc/haproxy/haproxy.cfg` or you have the wrong `--deploymentID` specified. <br>

2. If you see this at the very end
```
KeyError: 'accessToken'
+ bearerToken=
+ '[' 1 -ne 0 ']'
+ echo 'Not able to get bearerToken'
Not able to get bearerToken
````
This usually means you have either the wrong user name or password in `deploydocker.sh` command, specfically double check this section
```
--user admin --password password
```

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

### Using the container

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

### Connect to a different Event Store environment
If you want to connect to a different Event Store environment you re-installed Event Store on an existing OpenShift environment you need to ensure the docker image is not running.  If you see the `eventstore_demo` image running when you run `docker ps`, do a `docker stop <CONTAINER ID>,` such as
```
docker stop 2ed7b72a008a
```
This will take a minute.  Then run the `./dockershell.sh` command again, don't forget to provide the new `--deploymentID ` value as that will change for each new deployment.  Also if using IBM fyre the db2 and eventstore ports will change (they are randomly created for each Event Store deployment) and the `/etc/haproxy/haproxy.cfg` on fyre infrastructure node will need to get updated and the haproxy will neeed to get restarted.

### Recreate the Docker Container
If you want to rebuild the docker container after you have built it (for example there have been updates to the Docker Container), do the following
1) Stop the Docker Containeer if it is running as described above via `docker stop`
2) Delete the container by running 
   ```
   docker rmi -f <IMAGE ID>
   ```
  you obtain the `<IMAGE ID>` by running 
   ```
   docker images
   ```
3) Do a `git pull` under `db2eventstore-IoT-Analytics` diretory to ensure you have the latest files from github.com
4) Follow the steps at the top of this page to build the container 
```
./build.sh --es-version 2.0.1.2
```

### Red Hat 8.x
To get this demo container to work on Red Hat 8.x do the following, which will uninstall `podman` and `buildah` and install `docker-ce`, start docker and have it run on boot
```
dnf remove -y buildah podman
yum install -y yum-utils
yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io
systemctl start docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```
When using `podman`  the demo applications do not complete their run, it complains about keydb not found or something like that.

## Docker Image for Event Store 2.0 Demo

The Dockerfile in this directory will build a docker image named `eventstore_demo`. The image contains remote applications and runtime environment for Event Store demo. Users can build the docker image, run the docker container from the image built, and run the pre-loaded examples in the docker container.

### Procedure
#### Step 1: Clone this git repo
On a Mac or Linux desktop git clone this repo (it is possible to do this on Windows 10 but not recommended).  Add your public ssh key (normally the contents of this file `~/.ssh/id_rsa.pub` on your Windows, Linux or Mac machine) to https://github.com/settings/keys if you have not done so already.  To add your public ssh key click `New SSH Key` button on upper right ...Title ... In `Key` Box paste in your public ssh key ... Click `Add SSH Key` button <br>

As of January 2022 `git-lfs` is no longer needed but I kept the command to install it in below (in Dec 2021 we used `git-lfs` but backed this change out in Jan 2022)

**Linux**
```
cd ~
yum install -y git
yum update -y
wget https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh
chmod +x script.rpm.sh
./script.rpm.sh 
yum install git-lfs -y
git clone git@github.com:IBMProjectEventStore/db2eventstore-IoT-Analytics.git
```
**Mac**
```
brew install git
brew install git-lfs
git clone git@github.com:IBMProjectEventStore/db2eventstore-IoT-Analytics.git
```


#### Step 2: Build the docker image
In all scenarios below, the machine that will build and run the docker image needs docker installed and running, git & git-lfs installed, access to the internet, and about 6 GB of free disk space.  
#### Install Docker
On either:
- Mac OS 11.4, 11.5.2, 11.6, 12.0.1, 12.1, 12.2 and [docker desktop](https://www.docker.com/products/docker-desktop) (tested with Docker version `20.10.7, build f0df350` & `Docker version 20.10.8, build 3967b7d` with Docker Desktop `4.1.1 (69879)` & Docker Desktop `4.4.2 (73305)` and `Docker version 20.10.11, build dea9396`  and `Docker version 20.10.12, build e91ed57`  MacBook Pro 16 inch 2019 model) installed and running or;
- Linux desktop or server (CentOS & Red Hat  7.9 & CentOS & Red Hat 8.x, & CentOS 8 Stream work fine.  CentOS 8 Stream, Red Hat 7.x & 8.x only work with Docker and not Podman.  Docker must be installed and running.  See https://docs.docker.com/engine/install/ for instructions on installing docker. Linux is the most common OS used. Tested with multiple versions of Docker CE two last used were `Docker version 20.10.8, build 3967b7d` & `Docker version 20.10.12, build e91ed57 (on Red Hat 8.5)` 
- CentOS 8 Stream & Rocky Linux 8 - work fine also

    Docker Community Edition (CE) works fine for CentOS & Red Hat 7.9 & 8.5 and CentOS 8 Stream. For Red Hat 8.x & CentOS 8 Stream you first need to uninstall `podmad` & `buildah` by running these commands as root (before installing docker-ce).  
    ```
    dnf remove -y buildah podman
    ```

    run commands below as root to install the latest version of docker-ce on both Red Hat & CentOS 7.x & 8.x and CentOS 8 Stream, the last 2 commands configure docker to automatically start on operating system start-up.
    ```
    yum install -y yum-utils
    yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    ```
    then run to show which version of docker is installed.
    ``` 
    docker -v
    ```
    will show something like
    ```
    Docker version 20.10.12, build e91ed57
    ```
    More details are here https://docs.docker.com/engine/install/centos/
- Windows 10 21H1 or greater with [docker desktop](https://www.docker.com/products/docker-desktop) installed and running with [Windows Subsystem for Linux 2 (WSL 2)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) integration enabled with a Linux distro from Windows installed (this was tested with Kali Linux from the Microsoft Store in Windows 10). In July 2021 Microsoft greatly simplified the instalation of WSL2 and linux distributions.  You just need to run from either DOS prompt or Powersheel with Administrator privlidges `wsl --install` to install WSL2 with Ubuntu. You need to be running Windows 10 version 2004 or higher, and have the [KB5004296](https://betanews.com/2021/07/30/microsoft-releases-kb5004296-update-for-windows-10-to-fix-game-performance-problems-and-more/) update installed to take advantage of this new single command WSL installation procedure. [see here for more details](https://betanews.com/2021/07/31/microsoft-just-made-it-even-easier-to-install-windows-subsystem-for-linux-in-windows-11-and-10/) and Microsoft's blog about it [here](https://devblogs.microsoft.com/commandline/install-wsl-with-a-single-command-now-available-in-windows-10-version-2004-and-higher/). 
- Here is a good [youtube video that shows you how to install WSL2 and Kali Linux on Windows 10 using the older more complicated method](https://www.youtube.com/watch?v=AfVH54edAHU).  Kali Linux is an offshoot of Ubuntu. Below is a screenshot of configuring docker on Windows with WSL 
   ![](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/images/docker-windows10-wsl.png)
   
   #### Windows 10 Only
   **Getting this to work on Windows 10 is more challenging of a setup and is not recommended.**  In the Kali linux command prompt run the following commands
   ```
   sudo su -
   ```
   Enter your Windows 10 Administrator password when prompted, then 
   ```
   cd /mnt/c/Users
   ```
   this will make you the `root` user and get you to the `C:\Users` directory.  Now navigate to where you have cloned the repo, such as 
   ```
   cd /mnt/c/Users/strou/Documents/sirius-repos/db2eventstore-IoT-Analytics/container
   ```
   Run these commands to update Kali linux and install and run `dos2unix`.  For some reason Windows 10 shows ^M characters in `build.sh` and `dockershell.sh` even though I ran `dos2unix` on the .sh files on linux and checked them into github that way, last time I did this on Windows 10 I did not need to run the last 2 commands below to install and run `dos2unix` .
   ```
   sudo apt update && apt full-upgrade -y
   sudo apt-get install dos2unix
   dos2unix *.sh
   ```
  #### All Operating Systems
- For all Operating Systems: CentOS 7.x and 8.x, Red Hat 7.x and 8.x, CentOS 8 Stream, MacOS, and Windows 10 with Kali Linux, run the shell script `build.sh` to build the docker image.
- The image size is around 5 GB, build takes around 12 to 20 mins, depending on network conditions and processing power of the host (MacBook Pro 16 in 2019 model took 12.6 minutes and on Windows 10 Pro with Kali Linux with AMD Ryzen 5 56000X with 64 GB of RAM and 2 TB Western Digital Black PCIe 4.0  it took 13.6 minutes, both with 100 Mbps FIOS internet download speed).
- The Event Store release the IoT applications will use must be specified. The release is used to tag the image. Supported releases are: `2.0.1.4`, `2.0.1.3`,`2.0.1.2`, `2.0.1.0` and `2.0.0.5`. To run this for release `2.0.1.4`, the command would be (if running as root you do not need put `sudo` in front of `./build.sh`:
#### Build IoT Demo container
  Run these commmands after you have docker installed and running and have cloned the repo
```
cd ~/db2eventstore-IoT-Analytics/container
sudo ./build.sh --es-version 2.0.1.4
```
The format to run this for other (versions) releases of Event Store is:
```
./build.sh --es-version <eventstore-release>
```
where `<eventstore-release>` is replaced with the actual eventstore-release number.

Note the log file for the installation is under 
```
~/db2eventstore-IoT-Analytics/container/
```

#### Step 3: Start the docker container
After the image is built, run the shell script `dockershell.sh` to start the container and run the examples. The Event Store release identifies which tagged image to start.
The script takes 4 mandatory arguments and 3 optional ones.

```
cd ~/db2eventstore-IoT-Analytics/container
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
   echo `oc get route zen-cpd -o jsonpath={.spec.host}`
   ```
   command below now gives two hostnames
   ```
   oc get route  | grep -v 'HOST/PORT' | awk '{print $2}'
   ```
- This requires the --deploymentID which is specific to the database and can be retrieved from the eventstore cloudpak for data User Interface (UI) at: `Data ... Databases ... Details`.  It will be a value that appears similar to: `db2eventstore-16043310702252545`
- This requires the user and password options (normally what is used to log into Cloud Pak for data url)
- This optionally requires the Kubernetes namespace which is the OpenShift project that is used for the specific deployment. The default namespace/project is `zen`.
- For example (if not run run sudo ./dockershell.sh ...)
```
cd ~/db2eventstore-IoT-Analytics/container
./dockershell.sh --endpoint 9.46.196.49 --db2-port 9177 --es-port 9178 --endpointRest zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com --user admin --password password --deploymentType cp4d --deploymentID db2eventstore-1631578935585341 --es-version 2.0.1.4
```
If this successfully connects to your Event Store the end of output of this script will look like:
```
==================================================================
IP of target Event Store server:    9.46.196.49
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

After `dockershell.sh`command is successfully run as described above:
- A docker container instance named `eventstore_demo_${user}` will be started. The container instance contains necessary run-time environments for running applications in Python, Java, JDBC, Scala, Kafka, REST (Node.js), and Spark.
- The environment will be setup with the necessary configurations to establish SSL connection with the SDKs where applicable (i.e., when not using a developer deployment, which does not use SSL).
- Mount hostpath `${HOME}/eventstore_demo_volume` to `/root/user_volume` inside the container.
### Troubleshooting
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
This usually means you have either the wrong user name or password in `deploydocker.sh` command, specfically double check this section, or check you have the correct hostname for the `--endpointRest`.  It could also mean that your docker container cannot reach the OpenShift system running EventStore, this could be the case if you are using a PC or MAC and it is not on the IBM network (did not start the VPN to connect to IBM) and your EventStore system is on the IBM network.
```
--user admin --password password
```
3. If you get this error: container name "/eventstore_demo_admin" is already in use
After running this
```
./dockershell.sh --endpoint 9.30.138.71 --db2-port 9177 --es-port 9178 --endpointRest zen-cpd-zen.apps.stroud-eventstore-2.cp.fyre.ibm.com --user admin --password password --deploymentType cp4d --deploymentID db2eventstore-1624989035389301 --es-version 2.0.1.2
```
this is the error 
```
docker: Error response from daemon: Conflict. The container name "/eventstore_demo_admin" is already in use by container "1244343e4a17655720f6b36e495b1b7b3a3508dcf69cdaffcae1cb22daa59c19". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.
Cleaning up dangling images and/or exited containersExited container successfully![root@fcitest53 container]#
```
do the following to see any running containers
```
docker ps -a
```
The output will look something like:
```
[root@fcitest53 container]# docker ps -a
CONTAINER ID   IMAGE                     COMMAND                  CREATED       STATUS       PORTS     NAMES
1244343e4a17   eventstore_demo:2.0.1.2   "bash -c 'env && /ro…"   2 weeks ago   Up 2 weeks             eventstore_demo_admin
```
the do a `docker stop <container-id-that-is-running>`, for example
```
[root@fcitest53 container]# docker stop 1244343e4a17
1244343e4a17
[root@fcitest53 container]#
```
then you should be able to run `./dockershell.sh` command

4. If you get this error while running `./dockershell.sh` (note the last line in the output)
```
[root@fcistroud1-3-centos8 container]# ./dockershell.sh --endpoint 9.46.196.49 --db2-port 9177 --es-port 9178 --endpointRest zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com --user admin --password password --deploymentType cp4d --deploymentID db2eventstore-1631578935585341 --es-version 2.0.1.4
docker: Error response from daemon: Conflict. The container name "/eventstore_demo_admin" is already in use by container "74992f7e0af3307867dcc87c2a31c133af64337d8c7488557506df3863aaa56d". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.
Cleaning up dangling images and/or exited containersExited container successfully!
```
Simply just re-run the `./dockershell` command, for example

```
./dockershell.sh --endpoint 9.46.196.49 --db2-port 9177 --es-port 9178 --endpointRest zen-cpd-zen.apps.stroud-es-2010-os-4631.cp.fyre.ibm.com --user admin --password password --deploymentType cp4d --deploymentID db2eventstore-1631578935585341 --es-version 2.0.1.4
```
I believe this is because at 1st when you run `docker ps` and then `docker ps -a` you will see something like
```
[root@fcistroud1-3-centos8 ~]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[root@fcistroud1-3-centos8 ~]# docker ps -a
CONTAINER ID   IMAGE                     COMMAND                  CREATED      STATUS                    PORTS     NAMES
74992f7e0af3   eventstore_demo:2.0.1.4   "bash -c 'env && /ro…"   2 days ago   Exited (0) 26 hours ago             eventstore_demo_admin
```
Which shows you exited the container 26 hours ago but somehow docker thinks the container is still in use, but the last line of the error
```
Cleaning up dangling images and/or exited containersExited container successfully!
```
shows that docker has "cleaned up", so now when your run `docker ps -a` you see
```
[root@fcistroud1-3-centos8 container]# docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
the output of the command above shows that the container is not in use, this is why I believe re-running the `./dockershell` command works

5. If you get this error while running the scala application https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications/ScalaApplication#running-scala-example (also similar error will occur with all other tests).  This may be because Event Store was running for more than 30 days and the cluster is too small to have it run that long. 
   ```
   Error msg: DB2 SQL Error: SQLCODE=-10003, SQLSTATE=57011, SQLERRMC=null, DRIVER=4.25.4
   SQLSTATE: 57011
   Error code: -10003
   com.ibm.db2.jcc.am.SqlException: DB2 SQL Error: SQLCODE=-10003, SQLSTATE=57011, SQLERRMC=null, DRIVER=4.25.4
        at com.ibm.db2.jcc.am.b6.a(b6.java:815)
        at com.ibm.db2.jcc.am.b6.a(b6.java:66)
        at com.ibm.db2.jcc.am.b6.a(b6.java:140)
        at com.ibm.db2.jcc.am.Connection.completeSqlca(Connection.java:5269)
        at com.ibm.db2.jcc.t4.z.q(z.java:861)
        at com.ibm.db2.jcc.t4.z.p(z.java:717)
        at com.ibm.db2.jcc.t4.z.l(z.java:538)
        at com.ibm.db2.jcc.t4.z.d(z.java:153)
        at com.ibm.db2.jcc.t4.b.i(b.java:1343)
        at com.ibm.db2.jcc.t4.b.a(b.java:6821)
        at com.ibm.db2.jcc.t4.b.b(b.java:888)
        at com.ibm.db2.jcc.t4.b.a(b.java:804)
        at com.ibm.db2.jcc.t4.b.a(b.java:441)
        at com.ibm.db2.jcc.t4.b.a(b.java:414)
        at com.ibm.db2.jcc.t4.b.<init>(b.java:352)
        at com.ibm.db2.jcc.DB2SimpleDataSource.getConnection(DB2SimpleDataSource.java:233)
        at com.ibm.db2.jcc.DB2SimpleDataSource.getConnection(DB2SimpleDataSource.java:200)
        at com.ibm.db2.jcc.DB2Driver.connect(DB2Driver.java:471)
        at com.ibm.db2.jcc.DB2Driver.connect(DB2Driver.java:113)
        at java.sql.DriverManager.getConnection(DriverManager.java:664)
        at java.sql.DriverManager.getConnection(DriverManager.java:208)
        at com.ibm.event.api.EventJDBCClient.startConnection(Unknown Source)
        at com.ibm.event.api.EventJDBCClient.connect(Unknown Source)
        at com.ibm.event.common.ConfigurationReaderImpl.getJDBCConection(ConfigurationReader.scala:196)
        at com.ibm.event.oltp.EventContext$.com$ibm$event$oltp$EventContext$$openDatabaseWithRetry(EventContext.scala:1844)
        at com.ibm.event.oltp.EventContext$.openDatabase(EventContext.scala:1545)
        at com.ibm.event.oltp.EventContext$.getEventContext(EventContext.scala:1902)
        at ExampleScalaApp$.main(ExampleScalaApp.scala:38)
        at ExampleScalaApp.main(ExampleScalaApp.scala)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.apache.spark.deploy.JavaMainApplication.start(SparkApplication.scala:52)
        at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:855)
        at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:161)
        at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:184)
        at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:86)
        at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:930)
        at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:939)
        at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
   SQLException information
   Error msg: DB2 SQL Error: SQLCODE=-10003, SQLSTATE=57011, SQLERRMC=null, DRIVER=4.25.4

   ```
   If you run oc get pods and you have dozens and dozens of pods in this state
   ```

   usermgmt-ldap-sync-cron-job-1634481600-xz2f4                      0/1     Pending     0          23h
   usermgmt-ldap-sync-cron-job-1634482800-klh6q                      0/1     Pending     0          23h
   usermgmt-ldap-sync-cron-job-1634484000-klshz                      0/1     Pending     0          22h
   usermgmt-ldap-sync-cron-job-1634485200-cwv6w                      0/1     Pending     0          22h
   usermgmt-ldap-sync-cron-job-1634486400-4rckz                      0/1     Pending     0          22h
   usermgmt-ldap-sync-cron-job-1634487600-v4lcj                      0/1     Pending     0          21h
   usermgmt-ldap-sync-cron-job-1634488800-mzzts                      0/1     Pending     0          21h
   ```
   Shawn Li and Jim Stroud fixed a situation like this once by
   1) untainting the worker nodes by running this from the infrastrucutre node while logged into the Openshift cluster
   ```
   for node in $(oc get no --no-headers | awk {'print $1'} | grep "worker"); do
   	oc adm taint node $node icp4data-
   done
   pwd
   ```
   2) Set up environment variables to for running of Db2 Event Store utilities by using https://www.ibm.com/docs/en/db2-event-store/2.0.0?topic=database-db2-event-store-utilities-setup-usage, in our case we ran
   ```
   DEPLOYMENT_ID="db2eventstore-1631578935585341"
   TOOLS_CONTAINER=$(oc get pods |grep $DEPLOYMENT_ID | grep -E "(eventstore)(.*)(tenant-tools)" | awk {'print $1'}) && ORIGIN_IP=`hostname -i | awk '{print $1}'`
   eventstoreUtils() { oc -it exec "${TOOLS_CONTAINER}" -- bash -c 'export ORIGIN_IP="${1}" && eventstore-utils "${@:2}"' bash "${ORIGIN_IP}" "${@}"; }
   ```
   3) Stopping Eventstore by running
   ```
   eventstoreUtils --tool stop
   ```
   4) Starting Evenstore by running
   ```
   eventstoreUtils --tool start
   ```
   Then the IoT applications worked fine

6. MacOS Upgrade to 12.0.1
After James Stroud upgrade from MacOS 11.6 to 12.0.1, none of my docker images appeared via `docker images` command despite having this 60 GB file
```
/Users/jamesstroud/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw
```
and Docker desktop was properly configured to use this `Docker.raw` file under `Preferences ... Resources ...Disk image location`.  I did not try (but probably should have) `Troubleshooting .. Reset to Factory Defaults` .  I uninstalled Docker desktop under `Troubleshooting`, moved the `Docker.app` to the Trash, downloaded and reinstalled Docker desktop, then rebuilt the demo docker container  and the the docker image appeared and the IoT container worked on MacOS 12.0.1

### Caveats
Watson Studio Local (wsl). This is legacy and has not been tested or tried in several years.
- Generally the eventstore server endpoint and the rest endpoint are the same, implying you only need to specify --endpoint
- This requires the user and password options

Developer container (developer)
- This requires the --endpoint of the container where the eventstore server is running, there is no REST server here so --endpointRest is not applicable
- This requires the user and password options

See the scripts help option for more details (i.e. `./dockershell.sh --help`)

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
To enter the container run the following command (for your case replace `2ed7b72a008a` with your actual CONTAINER ID for your `evenstore_demo:<version>` docker image as demonstrated above
```
docker exec -u 0 -it 2ed7b72a008a bash
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
2) Force remove (Delete) the container by running 
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

### Red Hat 8.x & CentOS 8 Stream
To get this demo container to work on Red Hat 8.x and CentOS 8 Stream do the following, which will uninstall `podman` and `buildah` and install `docker-ce`, start docker and have it run on boot
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

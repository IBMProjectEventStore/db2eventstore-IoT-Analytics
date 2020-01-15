### Docker Image for Event Store 2.0 Demo

The Dockerfile in this directory will build a docker image named `eventstore_demo`. The image contains remote applications and runtime environment for Event Store demo. Users can build the docker image, run the docker container from the image built, and run the pre-loaded examples in the docker container.

**Procedure:**
**Step 1: Build the docker image**
User need to run the shell script `build.sh` to build the docker image.
The image size is around 3.3 GB, build takes around 30 mins, depending on the network condition.
```
./build.sh
```

**Step 2: Start the docker container**
After the image is built, user can run the shell script `dockershell.sh` to start the container and run the examples.
The script takes 3 mandatory arguments and 3 optional ones.

`./dockershell.sh --IP <EventStore_Server_IP> --IPREST <EventStore_Rest_Endpoint> --user <EventStore_Username> --password <EventStore_Password> --deploymentType <deployment type> --serviceName <service name>`

How to run with different deployment types:

IBM Cloud Pak For Data (cp4d) // Default deployment type
- Generally this requires you to specify --IPREST as the rest endpoint differs from the eventstore server ip (i.e. --IP)
- This requires the --serviceName which is specific to the database and can be retrieved from the UI
- This requires the user and password options

Watson Studio Local (dsx)
- Generally the eventstore server ip and the rest endpoint are the same, implying you only need to specify --IP
- This requires the user and password options

Standalone container (standalone)
- This requires the --IP of the container where the eventstore server is running, there is no REST server here so --IPREST is not applicable
- This requires the user and password options

See the scripts help option for more details (i.e. `./dockershell.sh --help`)

After the above commnand:
- A docker container instance named `eventstore_demo_${user}` will be started. The container instance contains necessary run-time environments for running applications in Python, Java, JDBC, Scala, Kafka, REST (Node.js), and Spark.
- The environment will be setup with the necessary configurations to establish SSL connection with the SDKs where applicable (i.e. when not using a standalone deployment, which does not use SSL).
- Mount hostpath `${HOME}/eventstore_demo_volume` to `/root/user_volume` inside the container.

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
The script takes 3 mandatory arguments.  

`./dockershell.sh --IP <EventStore_Server_IP> --user <EventStore_Username> --password <EventStore_Password>`

After the above commnand:
- A docker container instance named `eventstore_demo_${user}` will be started. The container instance contains necessary run-time environments for running applications in Python, Java, JDBC, Scala, Kafka, REST (Node.js), and Spark.
- The docker container instance will create the configuration file at `/bluspark/external_conf/bluspark.conf` based on the Event Store server IP provided as argument to dockershell.sh. The configuration file contains the necessary configurations to establish SSL connection.
- Mount hostpath `${HOME}/eventstore_demo_volume` to `/root/user_volume` inside the container.

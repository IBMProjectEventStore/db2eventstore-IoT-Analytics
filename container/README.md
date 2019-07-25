### Docker Image for Event Store 2.0 Demo

The Dockerfile in this directory will build a docker image named `event_store_demo`. The image contains remote applications and runtime environment for Event Store demo. Users can build the docker image, run the docker container from the image built, and run the pre-loaded examples in the docker container.

**Procedure:**  
Step 1: Build the docker image
User need to run the shell script `build.sh` to build the docker image.
The image size is around 3.3 GB.
```
./build.sh
```

Step 2: Start the docker container
After the image is built, user can run the shell script `dockershell.sh` to start the container and run the examples.
# TODO:
```
./dockershell.sh 
```
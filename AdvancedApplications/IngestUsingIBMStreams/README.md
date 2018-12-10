# Instructions on How to Run the IBM Streams and Remote Applicaations For IBM Db2 Event Store

## Streams container setup

1. First setup docker on your system
2. Follow the steps in https://hub.docker.com/r/ibmcom/streams-qse/ to set up a docker container that has the IBM Streams Quick Start Edition.
For preparing this we used the version 4.2.4.0. Note thart we used the docker run command that maps a local directory inside the container using the -v option (as in the instructions)
  * Note that docker run may take a long time to finish
3. If you want to ssh into the container, you need to use the streamsadmin userid and password passw0rd, with the following:
  * `ssh -p 4022 streamsadmin@localhost`
  * Note: another way into the container is using: `docker exec -it <containerID> bash`
     * Then from root, run: `su streamsadmin`
  * Go to the home directory with: `cd ~`
  * The VNC server should be running using port 5901 internally. Do: `ps ux | grep vnc` to check
4. The hostdir and workspace dir will be mapped in /home/streamsaadmin to the local system's directories you used in the docker run above
5. Before running the streams app, you will need to make a TESTDB and a table to hold the data that we will insert from the Event Store Sink operator.
One way to do this is through the Jupyter Notebook "Event Store Table Creation". An alternative way is through scala using the sample scala application provided.
6. From a remote VNC client application, such as Screen Sharing on Mac, you should be able to start the VNC session using: <IP of where the docker container is running>:5905
  * The password is: `passw0rd`
  * Tip: When we first started the desktop in the container we changed it to a higher resolution where you can see how to do this in "First Steps" in the link above for the streamsqse container
7. You can start Streams Studio by going to the "Applications" menu and selecting "Streams Studio (Eclipse)" 
  * Tip: There are issues with permissions using the mapped workspace so change the default workspace from /home/streamsadmin/workspace. Select Browse and select streamsadmin directory, then select to Create Folder with name "new workspace". Select OK, which will use /home/streamsadmin/newworkspace to add streams apps
8. You will be asked to add Streams Domain connection in a pop-up window. 
  * In Domain id, enter the name `StreamsDomain`
  * In the Domain JMX Service URLs, select to Add and enter in the URL: `service:mx:jmxmp://localhost:9975`, and select OK to save it.
  * Now select the "Find Domain" button and select the streamsqse that has port `2810` and select OK, then select OK in the "select domain" window.
  * Save the domain by selecting Ok, where it will ask you for the streamsadmin password where you enter: `passw0rd`
  * At this point in StreamsStudio, you can go to the Streams Explorer tab (in the top left) and expand the Streams Domain Connections where you should see "Streams Domain [Connected]"
  * If you expand "Streams instances", you should se that the default: StreamsInstance@StreamsDomain is Running

## Creating a streams application to ingest into IBM Db2 Event Store

For IBM Streams, we have created an EventStoreSink operator in which tuples can be batched and inserted in batches to your external Db2 Event Store.

1. You should get the IBM Db2 Event Store Enterprise 1.1.3 streams sink operator using the following steps:
  * Go to the Applications menu and select Firefox and go to: https://github.com/IBMStreams/streamsx.eventstore
  * Select "releases" and select "streamsx.eventstore_1.1.0-RELEASE.tgz" under the EventStoreSink-For-Enterprise-1.1.3 release, and select to "Save File" which will place it in the /home/streamsadmin directory
  * untag the file with

     `tar -xvf streamsx.eventstore_1.1.0-RELEASE.tgz`

  * You should see the following directory now:

     /home/streamsadmin/streamsx.eventstore

2. Once you have the streamsx.evenstore directory, you need to bring that toolkit into StreamsStudio with the following:
  * Select the "Streams Explorer" tab
  * Expand "IBM Streams Installations 4.2.4.0 -> IBM Streams 4.2.4.0 -> Toolkit Locations"
  * Right click on "Toolkit Locations" and in the menu, select "Add Toolkit Location"
  * Select the Directory button and select "/home/streamsadmin/streamsx.eventstore", and select the OK button, then select OK again in the "Add Toolkit Location" window.
  * You should now see the new entry under "Toolkit locations"
3. Copy the ExampleStreamsApp.spl from GitHub into the host
4. Now we can set up the Streams application that will use the EventStoreSink operator into StreamsStudio
  * Get the ExamplesStreamsApp.tar and untar it, which will make the com.ibm.insertExampleEventStore directory
  * Go to the Project Explorer tab
  * Right click inside that tab area and select Import -> IBM Streams Studio -> SPL Project and select Next
  * In the "Source" entry, select the Browse button and select the directory you just untared: com.ibm.insertExampleEventStore
  * Select the project checkbox that is displayed in the lower area of the window for the project com.ibm.insertExampleEventStore and select the Finish button
  * In the console you will see that the app compiles successfully
5. Generate the csv file using the generator script as shown before:
  * Tip: Note that you need numpy and pandas installed:
     * `sudo yum install python-pip`
     * `sudo pip install numpy`
     * `sudo pip install pandas`
  * Now can run the generator.sh as discussed previously
     * Run it using: `./generator.sh -c 1000`
     * Will show the max and min timestamp and calculate the "range" that will be needed in the streams application as: max - min +1
  * Copy the file produced "sample_IOT_table.csv" to /home/streamsadmin
  * Note that for the ts column, find the min and max of the column in the CSV file and replace the value for "range" variable in the Custom operator's "state" to be equal to the MAX - Min + 1 of the ts column values in the CSV file (for the max and min from running generator.sh)
  * For the EventStoreSink operator in the SPL code, change the IP in connectionString parameter to the IP corresponding to you Event Store system.
  * Note that the streams app is meant to continually read in the CSV file and keep incrementing the ts values to create new unique rows and then insert them in batches to Event Store using the EventStoreSink operator.
  * Save the ExampleStreamsApp again by selecting the File menu and select "Save"
  * You should see the application successfully compiled in the Console view
6. To run the application, follow these steps:
  * Select the Streams Explorer tab and expand "Streams Instances"
  * Right click the "default:StreamsInstance.." and select "Show Instance Graph"
  * Go back to the Project Explorer tab,  and right click on the main composite: ExampleStreamsApp and select "Launch -> Launch Active Build Config to Running Instance"
  * Select Apply then Launch buttons
  * You should see the instance graph for the streams application, and if you hover over the EventStoreSink operator and you should see the number of successful batch inserts growing over time
7. To see the table count, use these steps:
  * Go to `https://eventstore_machine_IP/eventstore`
  * Double click on the TESTDB database name
  * Select the Monitoring tab and page down  and you can see the ingest rate and storage rate and number of rows for the IOT_TEMP table
  * If the number of rows does not change then refresh the page and you will see the row count increase
8. To stop the application, in StreamsAdmin, right click on the white area inside the instance graph for the app and select "Cancel Job"

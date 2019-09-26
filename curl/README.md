# Curl Examples using Db2 Event Store
This directory has examples of scoring a model using curl.  
The Event Store comes with IBM Watson Studio machine learning service. Once a user created and deployed a machine learning model using IBM Watson Studio machine learning, they can use curl to perform online scoring (online prediction) to get real-time prediction.

### Pre-Requisites

------

- Define \$IP, \$EVENT_USER and \$EVENT_PASSWORD, where userid and password are the credentials for your Event Store. (If running in the `eventstore_demo` container, these environment variable are already set)
- Finish running **`Event_Store_ML_Model_Deployment.ipynb`**  notebook to have the machine learning model deployed

### Sample Execution

------

1. Obtain authentication tocken by running auth.sh

   ```bash
   ./auth.sh
   ```

2. Run example script which demonstrates single scoring and batch scoring with curl commands

   ```bash
	./score.sh
   ```


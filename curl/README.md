# Curl Examples using Db2 Event Store
This directory has examples of scoring a model using curl

### Pre-Requisites

------

- Define \$CLUSTER_IP, \$userid and \$password, where userid and password are the credentials for your Event Store. By default `$userid=user`, `$password=password`
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


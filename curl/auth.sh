#!/bin/bash

# This is an example of obtaining a authentication token from the cluster. 
# a json file will be returned with an "accessToken" that can be used
#example command is 
#curl -k -X GET "https://9.30.111.222/v1/preauth/validateAuth" -u admin:password

AUTH_RES=$(curl -k -X GET "https://$IP/v1/preauth/validateAuth" -u $EVENT_USER:$EVENT_PASSWORD | python -m json.tool)
TOKEN=$(curl -k -X GET "https://$IP/v1/preauth/validateAuth" -u $EVENT_USER:$EVENT_PASSWORD | python -c "import sys, json; print (json.load(sys.stdin)['accessToken'])")

cat <<-EOL
Authentication result is:

${AUTH_RES}

Authentication token is:

${TOKEN}

Please export the token as the 'accessToken' environment variable, then run the './score.sh' script to get prediction
value using the deployed machine learning model.
EOL

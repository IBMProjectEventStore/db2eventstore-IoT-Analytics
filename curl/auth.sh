# This is an example of obtaining a authentication token from the cluster. 
# a json file will be returned with an "accessToken" that can be used
#example command is 
#curl -k -X GET "https://192.168.0.1/v1/preauth/validateAuth" -u admin:password

curl -k -X GET "https://$CLUSTER_IP/v1/preauth/validateAuth" -u $userid:$password

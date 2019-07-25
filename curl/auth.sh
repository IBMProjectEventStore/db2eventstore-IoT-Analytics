# This is an example of obtaining a authentication token from the cluster. 
# a json file will be returned with an "accessToken" that can be used
#example command is 
#curl -k -X GET "https://9.30.111.222/v1/preauth/validateAuth" -u admin:password

curl -k -X GET "https://$IP/v1/preauth/validateAuth" -u $USER:$PASSWOD | jq

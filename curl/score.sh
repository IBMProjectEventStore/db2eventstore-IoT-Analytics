# This is an example of using curl to do both batch scoring, and single scopring

#single scoring
echo "Single Scoring" 
curl -k -X POST \
    "https://$CLUSTER_IP/v3/project/score/Python27/spark-2.0/IOT_demo/Event_Store_IOT_Sensor_Temperature_Prediction_Model/5" \
    -H 'Content-Type: application/json' -H "Authorization: Bearer $accessToken" \
    -d ' { "deviceID" : 2, "sensorID": 24, "ts": 1541430459386, "ambient_temp": 30, "power": 10 }' \
    jq

#batch scoring
echo "Batch Scoring" 
curl -k -X POST \
    "https://$CLUSTER_IP/v3/project/score/Python27/spark-2.0/IOT_demo/Event_Store_IOT_Sensor_Temperature_Prediction_Model/5" \
    -H 'Content-Type: application/json' -H "Authorization: Bearer $accessToken" \
    -d '[ { "deviceID" : 2, "sensorID": 24, "ts": 1541430459386, "ambient_temp": 30, "power": 10 }, {"deviceID" : 1, "sensorID": 12, "ts": 1541230400000, "ambient_temp": 16, "power": 50}]' \
    jq

'use strict';

var querystring = require('querystring');
var https = require('https');
var request = require('request').defaults({strictSSL: false});

var eventStoreNamespace = "/com/ibm/event/api/v1"
var server = undefined
var engine = undefined
var user = undefined
var pass = undefined
var noAuth = undefined

/**
 * Assignment of parameters
 */
process.argv.forEach(function (val, index, array) {
  if (val.startsWith("--engine=")) {
    engine = val.substring("--engine=".length)
    console.log('Using Engine: ' + engine);
  }
  else if (val.startsWith("--server=")) {
    server = val.substring("--server=".length)
    console.log('Using Server: ' + server);
  }
  else if (val.startsWith("--user=")) {
    user = val.substring("--user=".length)
    console.log('Using Username: ' + user);
  }
  else if (val.startsWith("--password=")) {
    pass = val.substring("--password=".length)
    console.log('Using Password: ' + pass);
  }
  else if (val.startsWith("--no-auth")) {
    noAuth = true
    console.log('Not using Authentication');
  }
});
if (server === undefined || engine === undefined || user === undefined || pass === undefined) {
  console.log('***************************');
  console.log('');
  console.log('Error as not enough parameters were supplied:');
  console.log('Usage => node clusterTest.js --engine=<engineURL> --server=<serverURL> --user=<username> --pass=<password> --no-auth');
  console.log('');
  console.log('***************************');
  process.exit()
}

function displayOutput(url, error, response, body) {
  console.log ('==========================')
  console.log ('URL Called -> ' + url)
  console.log ('** Received response **')
  if (error !== null && error !== undefined) {
    console.log ('Error Returned -> ' + error)
  }
  console.log ('Response Returned -> ' + response)
  console.log ('Body Returned -> ' + body)
}

/**
 * Get the Bearer Token
 */
function getBearerToken(flow) {
  var username = user;
  var password = pass;
  var auth = "Basic " + new Buffer(username + ":" + password).toString("base64");
  console.log ('Authorization in header')
  console.log(auth)
  console.log ('Getting the IDP Bearer Token')
  console.log ('==========================')
  console.log(server + '/v1/preauth/validateAuth')
  request(
    {
        url: server + '/v1/preauth/validateAuth',
        headers: {
            "Authorization": auth
        },
        ecdhCurve: 'secp384r1'
    },
    function (error, response, body) {
      if(error){
        console.log (error)
        process.exit()
      }
      var token = JSON.parse(body).accessToken
      console.log ('Token from IDP Cluster successfully retrieved:')
      console.log ('==========================')
      console.log (token)
      console.log ('==========================')
      console.log ('')
      var callback = flow.shift()
      callback('bearer ' + token, flow);
    });
}

function callESAPIWithBody (eventStoreURL, method, token, body, flow) {
  console.log(server + eventStoreNamespace + eventStoreURL)
  request(
    {
      method: method,
      url: server + eventStoreNamespace + eventStoreURL,
      body: body,
      headers: {
          "Authorization": token,
          "cache-control": "no-cache",
          "content-type": "application/json"
      },
      ecdhCurve: 'secp384r1'
    },
    function (error, response, body) {
      if(error){
        console.log (error)
        process.exit()
      }
      displayOutput (server + eventStoreNamespace + eventStoreURL, error, response, body)
      console.log('')
      console.log('**Query Result:**')
      console.log(JSON.parse(body).data);
      var callback = flow.shift()
      if (callback != undefined) {
        callback (token, flow)
      }
    });
}

function callESAPI (eventStoreURL, method, token, flow) {
  console.log(eventStoreURL)
  request(
    {
      method: method,
      url: eventStoreURL,
      headers: {
          "Authorization": token,
          "cache-control": "no-cache",
          "content-type": "application/json"
      },
      ecdhCurve: 'secp384r1'
    },
    function (error, response, body) {
      if(error){
        console.log (error)
        process.exit()
      }
      displayOutput (eventStoreURL, error, response, body)
      var response = JSON.parse(body)
      console.log('RESPONSE -> ' + response.code);
      console.log('MESSAGE -> ' + response.message);
      if (response.rates != undefined) {
        console.log(response.rates);
      }
      var callback = flow.shift()
      if (callback != undefined) {
        callback (token, flow)
      }
    });
}
// === Generic API to call the event store ===
function callAPI (label, url, method, token, flow) {
  console.log ('')
  console.log ('Running test: ' + label)
  callESAPI(server + eventStoreNamespace + url, method, token, flow)
}
// === End Generic API to call the event store ===

// === SPARK SQL Support ===
function submitSparkQuery1 (token, flow) {
  console.log ('')
  console.log ('Submitting a SparkSql query')
  var query = 'select count(*) as count from IOT_TEMP where deviceID=1 and sensorID=31'
  console.log ('==========================')
  console.log ('Submitting -> \"' + query + '\"')
  console.log ('Result of SparkSql query:')
  var body = "{\"sql\":\"" + query + "\"}"
  callESAPIWithBody('/spark/sql?tableName=IOT_TEMP&databaseName=EVENTDB', 'POST', token, body, flow)
}
function submitSparkQuery2 (token, flow) {
  console.log ('')
  console.log ('Submitting a SparkSql query')
  var query = 'select * from IOT_TEMP where deviceID=1 and sensorID=31 limit 5'
  console.log ('==========================')
  console.log ('Submitting -> \"' + query + '\"')
  console.log ('Result of SparkSql query:')
  var body = "{\"sql\":\"" + query + "\"}"
  callESAPIWithBody('/spark/sql?tableName=IOT_TEMP&databaseName=EVENTDB', 'POST', token, body, flow)
}
// === End SPARK SQL Support ===

// === OLTP Support ===
function getDatabases (token, flow) {
  callAPI ('Get Database', '/oltp/databases', 'GET', token, flow)
}
function getTables (token, flow) {
  callAPI ('Get the list of Tables', '/oltp/tables?databaseName=EVENTDB', 'GET', token, flow)
}

function getTableInfo (token, flow) {
  callAPI ('Get the table Info', '/oltp/table?tableName=IOT_TEMP&databaseName=EVENTDB', 'GET', token, flow)
}

// === Connect Support ===
function connectEngine (token, flow) {
  console.log ('')
  console.log ('==========================')
  console.log ('IDP Cluster located at: ' + server)
  callAPI('Connect to Engine', '/init/engine?engine=' + engine, 'POST', token, flow)
  console.log ('==========================')
}
// === End Connect Support ===

// Get the Bearer Token && Submit a query
console.log ('')

// ==  ==  ==
// == Flow ==
// ==  ==  ==
// Connect to (1) Event Store, (2) Start Ingest, (3) Get generated ingest rate, (4) Stop Ingest
//var flow = []
//flow.push(connectEngine)
//flow.push(createDatabase)
//flow.push(createSampleTable)
//flow.push(startIngest)
//flow.push(getGeneratedRate)
//flow.push(stopIngest)
//flow.push(submitSparkQuery2)
//getBearerToken(flow);
// ==  ==  ==
// ==  ==  ==
// ==  ==  ==

// ==  ==  ==
// == Flow ==
// ==  ==  ==
// Connect to (1) Event Store, (2) Create a new Table, (3) Get Simulated Groom/Insert rates, (4) Drop the table

var flow = []
flow.push(connectEngine)
flow.push(getDatabases)
flow.push(getTableInfo)
//flow.push(getTables)
flow.push(submitSparkQuery1)
flow.push(submitSparkQuery2)

if (noAuth === undefined) {
  getBearerToken(flow);
}
else {
  var callback = flow.shift()
  callback("fake_token", flow)
}


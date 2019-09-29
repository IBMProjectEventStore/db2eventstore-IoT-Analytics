/****************************************************************************
** SOURCE FILE NAME: ExampleODBCApp.c
**
** SAMPLE: How to connect to query, and disconnect from a eventstore
**
** CLI FUNCTIONS USED:
**         SQLAllocHandle -- Allocate Handle
**         SQLSetConnectAttr -- Set Connection Attributes
**         SQLDriverConnect -- Connect to a Data Source with 
**							   explicitly defined connection string
**         SQLGetDiagRec -- Get Multiple Fields Settings of Diagnostic Record
**         SQLExecDirect -- Execute a Statement Directly
**         SQLBindCol -- Bind a Column to an Application Variable or
**         SQLFetch -- Fetch Next Row
**         SQLDisconnect -- Disconnect from a Data Source
**         SQLFreeHandle -- Free Handle Resources
**
** OUTPUT FILE: ExampleODBCApp
**
*****************************************************************************
**
** To compile this example, run ./runExampleODBCApp <install_path_of_odbc> 
** To clean the compiler gererated files, run ./runExampleODBCApp --clean
**
** For more info on how to setup the odbc environment, see the README file.
**
** For information on developing CLI apps, visit the DB2 knowledge center:
**       https://www.ibm.com/support/knowledgecenter/SSEPGG_11.5.0/com.ibm.db2.
**       luw.apdv.cli.doc/doc/c0007944.html?pos=2
**
** For information on using SQL statements, see the SQL Reference.
**
****************************************************************************/

#define MAX_UID_LENGTH 18
#define MAX_PWD_LENGTH 30
#define MAX_STMT_LEN 255
#define MAX_COLUMNS 255
#define MAX_IP_LENGTH 15
#define MAX_TABLE_NAME 128
#ifdef DB2WIN
#define MAX_TABLES 50
#else
#define MAX_TABLES 255
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sqlcli1.h>
#include "utilcli.h" /* Header file for CLI sample code */

int DbDriverConnect(SQLHANDLE, SQLHANDLE *, char *, char *, char *, char *, char *, char *);
int DbDriverDisconnect(SQLHANDLE *, char *);

int main(int argc, char *argv[])
{
  SQLRETURN cliRC = SQL_SUCCESS;
  int rc = 0;
  SQLHANDLE henv; /* environment handle */
  SQLHANDLE hdbc; /* connection handle */
  
  /* Database name */
  char dbAlias[SQL_MAX_DSN_LENGTH + 1] = "EVENTDB";
  /* Table name to access */
  char tableName[MAX_TABLE_NAME + 1] = "IOT_TEMP";
  /* User name of database */
  char user[MAX_UID_LENGTH + 1] = "";
  /* Password of database */
  char pswd[MAX_PWD_LENGTH + 1] = "";
  /* IP of database to connect */
  char ip[MAX_IP_LENGTH + 1] = "";
  /* Port name of connection endpoint */
  char port[] = "18730";
  /* Server certificate file path locally within container */
  char serverCertPath [255] = "";
  /* string pointer to env variables */
  char *envp;
 
  /* get user name from environment variable EVENT_USER */
  envp = getenv("EVENT_USER");
  if (envp == NULL)
  {
     printf("Error: could not find env variable EVENT_USER for db username.\n");
     return 1; 
  }
  strncpy( user, envp, MAX_UID_LENGTH + 1 );

  /* get password from environment variable EVENT_PASSWORD */
  envp = getenv("EVENT_PASSWORD");
  if (envp == NULL)
  {
     printf("Error: could not find env variable EVENT_PASSWORD for db password.\n");
     return 1; 
  }
  strncpy( pswd, envp, MAX_PWD_LENGTH + 1 );

  /* get database up from environment variable IP */
  envp = getenv("IP"); 
  if (envp == NULL)
  {
     printf("Error: could not find env variable IP for db host ip.\n");
     return 1; 
  }
  strncpy( ip, envp, MAX_IP_LENGTH + 1 );

  /* get database certificate from environment variable SERVER_CERT_PATH */
  envp = getenv("SERVER_CERT_PATH");
  if (envp == NULL)
  {
     printf("Error: could not find env variable SERVER_CERT_PATH for db certificate.\n");
     return 1; 
  }
  strncpy( serverCertPath, getenv("SERVER_CERT_PATH"), 255 + 1 );

  printf("\nTHIS SAMPLE SHOWS ");
  printf("HOW TO CONNECT TO, QUERY AND DISCONNECT FROM EVENTSTORE.\n");

  /* allocate an environment handle */
  cliRC = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
  if (cliRC != SQL_SUCCESS)
  {
    printf("\n--ERROR while allocating the environment handle.\n");
    printf("  cliRC = %d\n", cliRC);
    printf("  line  = %d\n", __LINE__);
    printf("  file  = %s\n", __FILE__);
    return 1;
  }
  
  /* set attribute to enable application to run as ODBC 3.0 application */
  cliRC = SQLSetEnvAttr(henv,
                     SQL_ATTR_ODBC_VERSION,
                     (void *)SQL_OV_ODBC3,
                     0);
  ENV_HANDLE_CHECK(henv, cliRC);

  /* connect to a database with SQLDriverConnect() */
  rc = DbDriverConnect(henv, &hdbc, dbAlias, user, pswd, ip, port, serverCertPath);
  if (rc != 0)
  {
    return rc;
  }

  /*********   Start using the connection  *************************/
  
  SQLHANDLE hstmt; /* statement handle */
  /* SQL statements buffer */
  SQLCHAR stmt[512] = "";

  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE CLI FUNCTIONS\n");
  printf("  SQLSetConnectAttr\n");
  printf("  SQLAllocHandle\n");
  printf("  SQLExecDirect\n");
  printf("  SQLFreeHandle\n");
  printf("TO EXECUTE SQL STATEMENTS DIRECTLY:\n");
 
  /* set ISOLATION LEVEL such that the data will be queriable immediately */
  /* after it is inserted. Note that this setting is for demonstration    */
  /* purpose and should not be used against a real eventstore instance.   */
  cliRC = SQLSetConnectAttr(hdbc,
                            SQL_ATTR_TXN_ISOLATION,
                            (SQLPOINTER)SQL_TXN_READ_UNCOMMITTED,
                            SQL_NTS);
  DBC_HANDLE_CHECK(hdbc, cliRC);
  
  /* allocate a statement handle */
  cliRC = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
  DBC_HANDLE_CHECK(hdbc, cliRC);

  /************* Initialize table on source database ****************/

  /* drop table if exist */
  rc =  DropTableIfExists(tableName, hdbc, hstmt);
  if (rc != 0) return rc;

  /* create table */
  sprintf((char *)stmt,
           "create table %s "
           "(DEVICEID INTEGER NOT NULL, "
           "SENSORID INTEGER NOT NULL, "
           "TS BIGINT NOT NULL, "
           "AMBIENT_TEMP DOUBLE NOT NULL, "
           "POWER DOUBLE NOT NULL, "
           "TEMPERATURE DOUBLE NOT NULL, "
           "CONSTRAINT \"TEST1INDEX\" "
           "PRIMARY KEY(DEVICEID, SENSORID, TS) "
           "include(TEMPERATURE)) "
           "DISTRIBUTE BY HASH (DEVICEID, SENSORID) "
           "organize by column stored as parquet", tableName); 
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  /****************** Insert data to target table *******************/

  /* insert rows */
  sprintf((char *)stmt, 
          "INSERT INTO %s "
          "VALUES (99,48,1541019342393,25.983183481618322,14.65874116573845,48.908846094198)",
          tableName);  
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  sprintf((char *)stmt,
          "INSERT INTO %s "
          "VALUES (99,24,1541019343497,22.54544424024718,9.834894630821138,39.065559149361725)",
          tableName);
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC); 

  sprintf((char *)stmt,
          "INSERT INTO %s "
          "VALUES (99,39,1541019344356,24.3246538655206,14.100638100780325,44.398837306747936)",
          tableName);
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC); 

  sprintf((char *)stmt,
          "INSERT INTO %s "
          "VALUES (99,1,1541019345216,25.658280957413456,14.24313156331591,45.29125502970843)",
          tableName);
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  /* insert from external tables */
  char extCSVPath[] = "/root/db2eventstore-IoT-Analytics/data/sample_IOT_table.csv";
  sprintf ((char *)stmt,
            "INSERT INTO %s "
            "SELECT * FROM external '%s' LIKE %s "
            "USING (delimiter ',' MAXERRORS 10 SOCKETBUFSIZE 30000 REMOTESOURCE 'JDBC')",
            tableName, extCSVPath, tableName);
   printf("\n  Directly execute %s.\n", stmt);
   cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
   STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  /*************** Fetch data from table ***************************/

  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE CLI FUNCTIONS\n");
  printf("  SQLExecDirect\n");
  printf("  SQLBindCol\n");
  printf("  SQLFetch\n");
  printf("TO PROCESS SQL QUERY RESULT SET:\n");


  SQLINTEGER deviceID, sensorID; 
  SQLBIGINT ts;
  SQLDOUBLE ambientTemp, power, temperature; 
   
  /* select the rows from the source table */
  sprintf((char *)stmt, "SELECT * FROM %s FETCH FIRST 10 ROWS ONLY", tableName);
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC); 

  /* bind the columns of the source table */
  cliRC = SQLBindCol(hstmt, 1, SQL_C_LONG, &deviceID, 0, NULL);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  cliRC = SQLBindCol(hstmt, 2, SQL_C_LONG, &sensorID, 0, NULL);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);   

  cliRC = SQLBindCol(hstmt, 3, SQL_C_SBIGINT, &ts, 0, NULL);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);   

  cliRC = SQLBindCol(hstmt, 4, SQL_C_DOUBLE, &ambientTemp, 0, NULL);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);   

  cliRC = SQLBindCol(hstmt, 5, SQL_C_DOUBLE, &power, 0, NULL);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);   

  cliRC = SQLBindCol(hstmt, 6, SQL_C_DOUBLE, &temperature, 0, NULL);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  /* fetch next row */
  cliRC = SQLFetch(hstmt);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  printf("\n");
  if (cliRC == SQL_NO_DATA_FOUND)
  {
    printf("  Data not found.\n");
  }
  while (cliRC != SQL_NO_DATA_FOUND)
  {
    printf("  %ld %ld %lld %.15f %.15f %.15f\n",
	        deviceID, sensorID, ts, ambientTemp, power, temperature);

    /* fetch next row */
    cliRC = SQLFetch(hstmt);
    STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);
  } 

  /*********   Stop using the connection  **************************/

  /* free the statement handle */
  cliRC = SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);
   
  /* disconnect from database */
  rc = DbDriverDisconnect(&hdbc, dbAlias);
  if (rc != 0)
  {
    return rc;
  }

  /* free the environment handle */
  cliRC = SQLFreeHandle(SQL_HANDLE_ENV, henv);
  ENV_HANDLE_CHECK(henv, cliRC);
  
  printf("\n");
  return 0;
} /* main */

/* connect to a database with additional connection parameters
   using SQLDriverConnect() */
int DbDriverConnect(SQLHANDLE henv,
				    SQLHANDLE *hdbc, 
                    char dbAlias[],
                    char user[],
                    char pswd[],
                    char hostip[],
                    char port[],
                    char sslcert[])
{
  SQLRETURN cliRC = SQL_SUCCESS;
  int rc = 0;
  SQLCHAR connStr[255];

  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE CLI FUNCTIONS\n");
  printf("  SQLAllocHandle\n");
  printf("  SQLSetConnectAttr\n");
  printf("  SQLDriverConnect\n");
  printf("TO CONNECT TO EVENTSTORE:\n");

  /* allocate a database connection handle */
  cliRC = SQLAllocHandle(SQL_HANDLE_DBC, henv, hdbc);
  ENV_HANDLE_CHECK(henv, cliRC);

  printf("\n  Connecting to the database %s ...\n", dbAlias);

  /* parse connection string */
  sprintf((char *)connStr,
          "DATABASE=%s; UID=%s; PWD=%s; "
          "Protocol=tcpip; Authentication=GSSPLUGIN; "
          "Security=ssl; SSLServerCertificate=%s; "
          "HOSTNAME=%s; PORT=%s;",
          dbAlias, user, pswd, sslcert, hostip, port);

  /* connect to a data source */
  cliRC = SQLDriverConnect(*hdbc,
                           (SQLHWND)NULL,
                           connStr,
                           SQL_NTS,
                           NULL,
                           0,
                           NULL,
                           SQL_DRIVER_NOPROMPT);
  DBC_HANDLE_CHECK(*hdbc, cliRC);

  printf("  Connected to the database %s.\n", dbAlias);
  return 0;
}

int DbDriverDisconnect(SQLHANDLE *hdbc, char dbAlias[])
{ 
  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE CLI FUNCTIONS\n");
  printf("  SQLDisconnect\n");
  printf("  SQLFreeHandle\n");
  printf("TO DISCONNECT FROM EVENTSTORE:\n");

  printf("\n  Disconnecting from the database %s...\n", dbAlias);

  /* setup return code */
  SQLRETURN cliRC = SQL_SUCCESS;
  int rc = 0;

  /* disconnect from the database */
  cliRC = SQLDisconnect(*hdbc);
  DBC_HANDLE_CHECK(*hdbc, cliRC);

  printf("  Disconnected from the database %s.\n", dbAlias);

  /* free the connection handle */
  cliRC = SQLFreeHandle(SQL_HANDLE_DBC, *hdbc);
  DBC_HANDLE_CHECK(*hdbc, cliRC);

  return 0;
}

int DropTableIfExists(char tableName[], /* table name to drop */
                      SQLHANDLE hdbc, /* connection handle */
                      SQLHANDLE hstmt /* statement handle */)
{
  SQLRETURN cliRC = SQL_SUCCESS;
  int rc = 0;
  SQLCHAR stmt[255] = "";
  sprintf((char *)stmt,"DROP TABLE %s", tableName);
  
  printf("\n  Dropping table %s if exists...\n", tableName);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);

  if (cliRC != SQL_SUCCESS) { 
    /* skip diagnostic if the error is due to non existence of table */
    SQLCHAR message[SQL_MAX_MESSAGE_LENGTH + 1];
    SQLINTEGER sqlcode;
    SQLSMALLINT length, i;
    i=1;
    /* get multiple field settings of diagnostic record */
    if (SQLGetDiagRec(SQL_HANDLE_STMT,
                      hstmt,
                      i,
                      NULL,
                      &sqlcode,
                      message,
                      SQL_MAX_MESSAGE_LENGTH + 1,
                      &length) == SQL_SUCCESS)
    {
      if (sqlcode == -204) 
      {
        printf("  %s", message);
        printf("  Skip dropping table.\n");
        return 0;
      }
      else 
        STMT_HANDLE_CHECK(hstmt, hdbc, cliRC); 
    }
  }

  printf("  Dropped table %s.\n", tableName);
  return 0;
} /* DropTableIfExists */

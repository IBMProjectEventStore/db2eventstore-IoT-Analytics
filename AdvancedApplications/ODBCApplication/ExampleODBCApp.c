/****************************************************************************
** (c) Copyright IBM Corp. 2007 All rights reserved.
** 
** The following sample of source code ("Sample") is owned by International 
** Business Machines Corporation or one of its subsidiaries ("IBM") and is 
** copyrighted and licensed, not sold. You may use, copy, modify, and 
** distribute the Sample in any form without payment to IBM, for the purpose of 
** assisting you in the development of your applications.
** 
** The Sample code is provided to you on an "AS IS" basis, without warranty of 
** any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR 
** IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
** MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some jurisdictions do 
** not allow for the exclusion or limitation of implied warranties, so the above 
** limitations or exclusions may not apply to you. IBM shall not be liable for 
** any damages you suffer as a result of using, copying, modifying or 
** distributing the Sample, even if IBM has been advised of the possibility of 
** such damages.
*****************************************************************************
**
** SOURCE FILE NAME: ExampleODBCApp.c
**
** SAMPLE: How to connect to and disconnect from a database
**
** CLI FUNCTIONS USED:
**         SQLAllocHandle -- Allocate Handle
**         SQLBrowseConnect -- Get Required Attributes to Connect
**                             to a Data Source
**         SQLConnect -- Connect to a Data Source
**         SQLDisconnect -- Disconnect from a Data Source
**         SQLDriverConnect -- Connect to a Data Source (Expanded)
**         SQLFreeHandle -- Free Handle Resources
**
** OUTPUT FILE: dbconn.out (available in the online documentation)
*****************************************************************************
**
** For more information on the sample programs, see the README file.
**
** For information on developing CLI applications, see the CLI Guide
** and Reference.
**
** For information on using SQL statements, see the SQL Reference.
**
** For the latest information on programming, building, and running DB2 
** applications, visit the DB2 application development website: 
**     http://www.software.ibm.com/data/db2/udb/ad
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

  /* set AUTOCOMMIT on */
  cliRC = SQLSetConnectAttr(hdbc,
                            SQL_ATTR_AUTOCOMMIT,
                            (SQLPOINTER)SQL_AUTOCOMMIT_ON,
                            SQL_NTS);
  DBC_HANDLE_CHECK(hdbc, cliRC);

  /* allocate a statement handle */
  cliRC = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
  DBC_HANDLE_CHECK(hdbc, cliRC);

  /******************** directly execute statement ****************/

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
            "organize by column stored as parquet",
            tableName); 
  printf("\n  Directly execute %s.\n", stmt);
  cliRC = SQLExecDirect(hstmt, stmt, SQL_NTS);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

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

  /* free the statement handle */
  cliRC = SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
  STMT_HANDLE_CHECK(hstmt, hdbc, cliRC);

  /*********   Stop using the connection  **************************/

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

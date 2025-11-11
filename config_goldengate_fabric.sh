#/bin/bash
## Variables used:
## GG_URL     - GoldenGate (k8s internal) URL for REST API access
## SRC_URL    - source database URL, like ggadmin@db23ai.oracle23ai:1521/FREEPDB1
## TRG_URL    - target ADB URL, like ggadmin@(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=gfde677d3a923a9_atp23ai_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
## SRC_PWD    - source database password for URL, like Welcome1234#
## TRG_PWD    - target database password for URL, like Welcome1234#
## SRC_USER   - source database user for goldengate
## TRG_USER   - target database user for goldengate
## GG_USER    - GoldenGate REST API username, like oggadmin
## GG_PWD     - GoldenGate REST API password, like Welcome1234#
## SRC_SCHEMA - schema to be synced in source database, like SH
## TRG_SCHEMA - schema to be synced in target database, like SH2

##stripping empty spaces from connection string to be safe
export TRG_URL=$(echo $TRG_URL|tr -d ' ')
export SRC_URL=$(echo $SRC_URL|tr -d ' ')
echo " "
echo " "	 
echo "Creating GG fabric credentials"
curl -X POST \
       $GG_URL/services/v2/credentials/Network/ggadminfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"'$TRG_USER'",
         "password":"'$TRG_PWD'"
     }'
while [ $? == "7" ]; do  
echo "RETRY - Creating GG fabric credentials"
curl -X POST \
       $GG_URL/services/v2/credentials/Network/ggadminfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"'$TRG_USER'",
         "password":"'$TRG_PWD'"
     }'
done
echo " "	 
echo "creating distribution path from GGoracle to GGfabric"

echo " "	 
echo "creating fabric replicat"
curl -X POST \
       $GGFAB_URL/services/v2/replicats/RS \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "srcCred",
      "domain": "OracleGoldenGate"
    },
    "begin": "now",
    "encryptionProfile": "LocalWallet",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "config": [
      "REPLICAT RS",
      "USERIDALIAS srcCred DOMAIN OracleGoldenGate",
      "ALLOWNOOPUPDATES",
	"",
	"DBOPTIONS ENABLE_INSTANTIATION_FILTERING",
	"",
	"DDLERROR DEFAULT ABEND",
	"",
	"REPERROR (DEFAULT,RETRYOP MAXRETRIES 1)",
	"REPERROR (26960, DISCARD)",
	"REPERROR (PROCEDURE, DISCARD)",
	"",
	"DDL           INCLUDE MAPPED",
	"DDLOPTIONS REPORT",
	"",
	"REPORTCOUNT EVERY 15 MINUTES, RATE",
	"",
	"MAPINVISIBLECOLUMNS",
	"",
	"MAP '$TRG_SCHEMA'.*, TARGET '$SRC_SCHEMA'.*;"
    ],
    "source": {
      "name": "ET"
    },
    "checkpoint": {
      "table": "GGADMIN.CHECKPOINTS"
    },
    "mode": {
      "type": "integrated",
      "parallel": false
    }
   }'
   
while [ $? == "7" ]; do  
echo "RETRY - creating fabric replicat"
curl -X POST \
       $GGFAB_URL/services/v2/replicats/RS \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "srcCred",
      "domain": "OracleGoldenGate"
    },
    "begin": "now",
    "encryptionProfile": "LocalWallet",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "config": [
      "REPLICAT RS",
      "USERIDALIAS srcCred DOMAIN OracleGoldenGate",
      "ALLOWNOOPUPDATES",
	"",
	"DBOPTIONS ENABLE_INSTANTIATION_FILTERING",
	"",
	"DDLERROR DEFAULT ABEND",
	"",
	"REPERROR (DEFAULT,RETRYOP MAXRETRIES 1)",
	"REPERROR (26960, DISCARD)",
	"REPERROR (PROCEDURE, DISCARD)",
	"",
	"DDL           INCLUDE MAPPED",
	"DDLOPTIONS REPORT",
	"",
	"REPORTCOUNT EVERY 15 MINUTES, RATE",
	"",
	"MAPINVISIBLECOLUMNS",
	"",
	"MAP '$TRG_SCHEMA'.*, TARGET '$SRC_SCHEMA'.*;"
    ],
    "source": {
      "name": "ET"
    },
    "checkpoint": {
      "table": "GGADMIN.CHECKPOINTS"
    },
    "mode": {
      "type": "integrated",
      "parallel": false
    }
   }'
done
echo " "	 
echo "starting fabric replicat"
curl -X PATCH $GGFAB_URL/services/v2/replicats/RS \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
       
while [ $? == "7" ]; do  
echo "RETRY - starting fabric replicat"
curl -X PATCH $GGFAB_URL/services/v2/replicats/RS \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
done

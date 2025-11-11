#/bin/bash
## Variables used:
## GG_URL     - GoldenGate (k8s internal) URL for REST API access
## GG_URL     - GoldenGate for MS Fabric (k8s internal) URL for REST API access
## GG_USER    - GoldenGate REST API username, like oggadmin
## GG_PWD     - GoldenGate REST API password, like Welcome1234#

echo " "
echo " "	 
echo "Creating GG fabric credentials"
curl -X POST \
       $GG_URL/services/v2/credentials/Network/ggadminfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"'$GG_USER'",
         "password":"'$GG_PWD'"
     }'
while [ $? == "7" ]; do  
echo "RETRY - Creating GG fabric credentials"
curl -X POST \
       $GG_URL/services/v2/credentials/Network/ggadminfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"'$GG_USER'",
         "password":"'$GG_PWD'"
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

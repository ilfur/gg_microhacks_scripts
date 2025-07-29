#/bin/bash
## Variables used:
## GG_URL     - GoldenGate (k8s internal) URL for REST API access
## SRC_URL    - source database URL, like ggadmin@db23ai.oracle23ai:1521/FREEPDB1
## TRG_URL    - target ADB URL, like ggadmin@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=gfde677d3a923a9_atp23ai_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
## SRC_PWD    - source database password for URL, like Welcome1234#
## TRG_PWD    - target database password for URL, like Welcome1234#
## SRC_USER   - source database user for goldengate
## TRG_USER   - target database user for goldengate
## GG_USER    - GoldenGate REST API username, like oggadmin
## GG_PWD     - GoldenGate REST API password, like Welcome1234#
## SRC_SCHEMA - schema to be synced in source database, like SH
## TRG_SCHEMA - schema to be synced in target database, like SH2

export GG_URL=http://oggora-east-goldengate-oracle-free-svc.oggfree:8080
export GG_USER=oggadmin
export GG_PWD=Welcome1234#
export SRC_URL="db23ai.oracle23ai:1521/FREEPDB1"
export SRC_USER="ggadmin"
export SRC_PWD="BrunhildeZ32##"
export TRG_URL="(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=gfde677d3a923a9_atp23ai_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
export TRG_USER="ggadmin"
export TRG_PWD="BrunhildeZ32##"
export SRC_SCHEMA=SH
export TRG_SCHEMA=SH2

curl -X POST \
       $GG_URL/services/v2/credentials/OracleGoldenGate/srcCred \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"'$SRC_USER'@'$SRC_URL'",
         "password":"'$SRC_PWD'"
     }'

curl -X POST \
       $GG_URL/services/v2/credentials/OracleGoldenGate/trgCred \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"'$TRG_USER'@'$TRG_URL'",
         "password":"'$TRG_PWD'"
     }'

curl -X POST \
       $GG_URL/services/v2/connections/srcConn \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
        "credentials":{
        "domain":"OracleGoldenGate",
        "alias":"srcCred"
        }}'

curl -X POST \
       $GG_URL/services/v2/connections/trgConn \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
        "credentials":{
        "domain":"OracleGoldenGate",
        "alias":"trgCred"
        }}'

curl -X POST \
       $GG_URL/services/v2/connections/trgConn/tables/heartbeat \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"frequency": 60}'

curl -X POST \
       $GG_URL/services/v2/connections/srcConn/tables/heartbeat \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"frequency": 60}'

curl -X POST \
       $GG_URL/services/v2/connections/srcConn/tables/checkpoint \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"add",
           "name":"'$SRC_USER'.checkpoints"
         }'

curl -X POST \
       $GG_URL/services/v2/connections/trgConn/tables/checkpoint \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"add",
           "name":"'$TRG_USER'.checkpoints"
         }'

curl -X POST \
       $GG_URL/services/v2/connections/srcConn/trandata/schema \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"info",
           "schemaName":"'$SRC_SCHEMA'"
       }'

curl -X POST \
       $GG_URL/services/v2/connections/trgConn/trandata/schema \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"info",
           "schemaName":"'$TRG_SCHEMA'"
       }'

curl -X POST \
       $GG_URL/services/v2/extracts/ES \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
        "domain": "OracleGoldenGate",
        "alias": "srcCred"
    },
    "status": "stopped",
    "begin": "now",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "encryptionProfile": "LocalWallet",
    "source": "tranlogs",
    "registration": {
        "share": true
    },
    "targets": [
        {
            "name": "ES",
            "sequence": 0,
            "sizeMB": 500
        }
    ],
    "config": [
        "EXTRACT ES",
        "USERIDALIAS srcCred DOMAIN OracleGoldenGate",
        "EXTTRAIL ES",
        "FETCHOPTIONS, USESNAPSHOT, NOUSELATESTVERSION, MISSINGROW REPORT",
        "WARNLONGTRANS 15 MINUTES, CHECKINTERVAL 5 MINUTES",
        "\t",
        "DDL           INCLUDE MAPPED",
        "\t",
        "PROCEDURE INCLUDE FEATURE ALL_SUPPORTED",
        "TRANLOGOPTIONS INTEGRATEDPARAMS (PARALLELISM 0, _ENABLE_PROCEDURAL_REPLICATION Y) _INFINITYTOZERO",
        "DDLOPTIONS REPORT",
        "TRANLOGOPTIONS EXCLUDETAG 00",
        "\t",
        "REPORTCOUNT EVERY 15 MINUTES, RATE",
        "\t",
        "STATOPTIONS REPORTFETCH",
        "\t",
        "TABLE '$SRC_SCHEMA'.*;",
        ""
    ]
}'
   
curl -X PATCH $GG_URL/services/v2/extracts/ES \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
       
curl -X POST \
       $GG_URL/services/v2/extracts/ET \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
        "domain": "OracleGoldenGate",
        "alias": "trgCred"
    },
    "status": "stopped",
    "begin": "now",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "encryptionProfile": "LocalWallet",
    "source": "tranlogs",
    "registration": {
        "share": true
    },
    "targets": [
        {
            "name": "ET",
            "sequence": 0,
            "sizeMB": 500
        }
    ],
    "config": [
        "EXTRACT ET",
        "USERIDALIAS trgCred DOMAIN OracleGoldenGate",
        "EXTTRAIL ET",
        "FETCHOPTIONS, USESNAPSHOT, NOUSELATESTVERSION, MISSINGROW REPORT",
        "WARNLONGTRANS 15 MINUTES, CHECKINTERVAL 5 MINUTES",
        "\t",
        "DDL           INCLUDE MAPPED",
        "\t",
        "PROCEDURE INCLUDE FEATURE ALL_SUPPORTED",
        "TRANLOGOPTIONS INTEGRATEDPARAMS (PARALLELISM 0, _LOGMINER_PARALLEL_READ N, max_sga_size 150)",
        "DDLOPTIONS REPORT",
        "TRANLOGOPTIONS EXCLUDETAG 00",
        "\t",
        "REPORTCOUNT EVERY 15 MINUTES, RATE",
        "\t",
        "STATOPTIONS REPORTFETCH",
        "\t",
        "TABLE '$TRG_SCHEMA'.*;"
    ]
}'

curl -X PATCH $GG_URL/services/v2/extracts/ET \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 

curl -X POST \
       $GG_URL/services/v2/replicats/RS \
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

curl -X PATCH $GG_URL/services/v2/replicats/RS \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
       
curl -X POST \
       $GG_URL/services/v2/replicats/RT \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "trgCred",
      "domain": "OracleGoldenGate"
    },
    "begin": "now",
    "encryptionProfile": "LocalWallet",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "config": [
      "REPLICAT RT",
      "USERIDALIAS trgCred DOMAIN OracleGoldenGate",
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
	"MAP '$SRC_SCHEMA'.*, TARGET '$TRG_SCHEMA'.*;"
    ],
    "source": {
      "name": "ES"
    },
    "checkpoint": {
      "table": "GGADMIN.CHECKPOINTS"
    },
    "mode": {
      "type": "nonintegrated",
      "parallel": false
    }
   }'

curl -X PATCH $GG_URL/services/v2/replicats/RT \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 

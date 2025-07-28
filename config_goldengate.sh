#/bin/bash
curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/credentials/OracleGoldenGate/srcCred \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"ggadmin@db23ai.oracle23ai:1521/FREEPDB1",
         "password":"Welcome1234#"
     }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/credentials/OracleGoldenGate/trgCred \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"ggadmin@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=gfde677d3a923a9_atp23ai_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))",
         "password":"Welcome1234#"
     }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/srcConn \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
        "credentials":{
        "domain":"OracleGoldenGate",
        "alias":"srcCred"
        }}'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/trgConn \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
        "credentials":{
        "domain":"OracleGoldenGate",
        "alias":"trgCred"
        }}'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/OracleGoldenGate.trgConn/tables/heartbeat \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"frequency":"60"}'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/OracleGoldenGate.srcConn/tables/heartbeat \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"frequency":"60"}'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/OracleGoldenGate.srcConn/tables/checkpoint \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"add",
           "name":"ggadmin.checkpoints"
         }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/OracleGoldenGate.trgConn/tables/checkpoint \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"add",
           "name":"ggadmin.checkpoints"
         }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/OracleGoldenGate.srcConn/trandata/schema \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"info",
           "schemaName":"HR"
       }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/connections/OracleGoldenGate.trgConn/trandata/schema \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
           "operation":"info",
           "schemaName":"HR2"
       }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/extracts/ES \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "srcConn",
      "domain": "OracleGoldenGate"
    },
    "encryptionProfile": "LocalWallet",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "targets": [
      {
        "name": "ES",
        "sizeMB": 500,
      }
    ],
    "config": [
      "EXTRACT ES",
      "USERIDALIAS srcCred DOMAIN OracleGoldenGate",
      "EXTTRAIL ES",
      "FETCHOPTIONS, USESNAPSHOT, NOUSELATESTVERSION, MISSINGROW REPORT",
      "WARNLONGTRANS 15 MINUTES, CHECKINTERVAL 5 MINUTES",
	"",
	"DDL           INCLUDE MAPPED",
	"",
	"PROCEDURE INCLUDE FEATURE ALL_SUPPORTED",
	"TRANLOGOPTIONS INTEGRATEDPARAMS (_ENABLE_PROCEDURAL_REPLICATION Y) _INFINITYTOZERO",
	"DDLOPTIONS REPORT",
	"TRANLOGOPTIONS EXCLUDETAG 00",
	"",
	"REPORTCOUNT EVERY 15 MINUTES, RATE",
	"",
	"STATOPTIONS REPORTFETCH",
	"",
	"TABLE HR.*;"
   ],
    "description": "Source HR Schema extract",
    "source": "tranlogs",
    "type": "Integrated",
    "registration": {
      "optimized": true
     },
    "begin": "now"
   }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/extracts/ET \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "trgConn",
      "domain": "OracleGoldenGate"
    },
    "encryptionProfile": "LocalWallet",
    "managedProcessSettings": "ogg:managedProcessSettings:Default",
    "targets": [
      {
        "name": "ET",
        "sizeMB": 500,
      }
    ],
    "config": [
      "EXTRACT ET",
      "USERIDALIAS srcCred DOMAIN OracleGoldenGate",
      "EXTTRAIL ET",
      "FETCHOPTIONS, USESNAPSHOT, NOUSELATESTVERSION, MISSINGROW REPORT",
      "WARNLONGTRANS 15 MINUTES, CHECKINTERVAL 5 MINUTES",
	"",
	"DDL           INCLUDE MAPPED",
	"",
	"PROCEDURE INCLUDE FEATURE ALL_SUPPORTED",
	"TRANLOGOPTIONS INTEGRATEDPARAMS (PARALLELISM 0, _LOGMINER_PARALLEL_READ N, max_sga_size 150)",
	"DDLOPTIONS REPORT",
	"TRANLOGOPTIONS EXCLUDETAG 00",
	"",
	"REPORTCOUNT EVERY 15 MINUTES, RATE",
	"",
	"STATOPTIONS REPORTFETCH",
	"",
	"TABLE HR.*;"
   ],
    "description": "Target HR Schema extract",
    "source": "tranlogs",
    "type": "Integrated",
    "registration": {
      "optimized": true
     },
    "begin": "now"
   }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/replicats/RS \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "srcConn",
      "domain": "OracleGoldenGate"
    },
    "begin": {
      "sequence": 0,
      "offset": 0
    },
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
	"MAP HR.*, TARGET HR.*;",
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

   curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/replicats/RT \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "credentials": {
      "alias": "trgConn",
      "domain": "OracleGoldenGate"
    },
    "begin": {
      "sequence": 0,
      "offset": 0
    },
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
	"MAP HR.*, TARGET HR.*;",
    ],
    "source": {
      "name": "ES"
    },
    "checkpoint": {
      "table": "GGADMIN.CHECKPOINTS"
    },
    "mode": {
      "type": "integrated",
      "parallel": false
    }
   }'

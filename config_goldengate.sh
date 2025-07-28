#/bin/bash
curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/credentials/OracleGoldenGate/srcConn \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"ggadmin@db23ai.oracle23ai:1521/FREEPDB1",
         "password":"Welcome1234#"
     }'

curl -X POST \
       https://ggstudio.84-235-173-41.nip.io/services/v2/credentials/OracleGoldenGate/trgConn \
       --user ggadmin:Welcome1234#   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
         "userid":"ggadmin@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=gfde677d3a923a9_atp23ai_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))",
         "password":"Welcome1234#"
     }'

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


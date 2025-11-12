#/bin/bash
## Variables used:
## GG_URL     - GoldenGate (k8s internal) URL for REST API access, WITHOUT protocol but with port
## GG_PROTOCOL- GoldenGate server protocol, http or https
## GGFAB_URL     - GoldenGate for MS Fabric (k8s internal) URL for REST API access
## GG_USER    - GoldenGate REST API username, like oggadmin
## GG_PWD     - GoldenGate REST API password, like Welcome1234#
## GG_DEPL    - GoldenGate deployment name

echo " "	 
echo "Creating GG fabric credentials"
curl -X POST \
       $GG_PROTOCOL://$GG_URL/services/v2/credentials/Network/ggadminfabric \
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
       $GG_PROTOCOL://$GG_URL/services/v2/credentials/Network/ggadminfabric \
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
curl -X POST \
       $GG_PROTOCOL://$GG_URL/services/v2/sources/gghack2ggfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "name": "gghack2ggfabric",
    "source": {
      "uri": "trail://'$GG_URL'/services/'$GG_DEPL'/distsrvr/v2/sources?trail=ET",
      "details": {
        "encryption": {
          "algorithm": "NONE"
        }
      }
    },
    "target": {
      "uri": "ws://'$GGFAB_URL'/services/'$GG_DEPL'/recvsrvr/v2/targets?trail=ET",
      "authenticationMethod": {
				"domain": "Network",
				"alias": "ggadminfabric"
			},
			"details": {
				"trail": {
					"seqLength": 9,
					"sizeMB": 500
				},
				"encryption": {
					"algorithm": "NONE"
				},
				"compression": {
					"enabled": false
				}
			}
    },
    "options": {
      "eofDelayCSecs": 10,
      "checkpointFrequency": 10,
      "critical": false,
      "autoRestart": {
        "retries": 10,
        "delay": 2
      },
      "streaming": true
    },
    "begin": {
      "sequence": 0,
      "offset": 0
    },
    "encryptionProfile": "LocalWallet",
    "$schema": "ogg:distPath"
}'
   
while [ $? == "7" ]; do  
curl -X POST \
       $GG_PROTOCOL://$GG_URL/services/v2/sources/gghack2ggfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "name": "gghack2ggfabric",
    "source": {
      "uri": "trail://'$GG_URL'/services/'$GG_DEPL'/distsrvr/v2/sources?trail=ET",
      "details": {
        "encryption": {
          "algorithm": "NONE"
        }
      }
    },
    "target": {
      "uri": "ws://'$GGFAB_URL'/services/'$GG_DEPL'/recvsrvr/v2/targets?trail=ET",
      "authenticationMethod": {
				"domain": "Network",
				"alias": "ggadminfabric"
			},
			"details": {
				"trail": {
					"seqLength": 9,
					"sizeMB": 500
				},
				"encryption": {
					"algorithm": "NONE"
				},
				"compression": {
					"enabled": false
				}
			}
    },
    "options": {
      "eofDelayCSecs": 10,
      "checkpointFrequency": 10,
      "critical": false,
      "autoRestart": {
        "retries": 10,
        "delay": 2
      },
      "streaming": true
    },
    "begin": {
      "sequence": 0,
      "offset": 0
    },
    "encryptionProfile": "LocalWallet",
    "$schema": "ogg:distPath"
}'
done

echo "starting distribution service"
curl -X PATCH $GG_PROTOCOL://$GG_URL/services/v2/sources/gghack2ggfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
       
while [ $? == "7" ]; do  
echo "RETRY - starting distribution service"
curl -X PATCH $GG_PROTOCOL://$GG_URL/services/v2/sources/gghack2ggfabric \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
done

echo " "	 
echo "creating fabric replicat"
echo " "	 
curl -X POST \
       $GG_PROTOCOL://$GGFAB_URL/services/v2/replicats/FABRIC \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "$schema": "ogg:replicat",
		"begin": {
			"sequence": 0,
			"offset": 0
		},
		"encryptionProfile": "LocalWallet",
		"managedProcessSettings": "ogg:managedProcessSettings:Default",
		"config": [
			"REPLICAT FABRIC",
			"MAP *.*, TARGET *.*;",
			""
		],
		"source": {
			"name": "ET"
		},
		"registration": "none",
		"mode": {
			"type": "nonintegrated",
			"parallel": false
		}
   }'

while [ $? == "7" ]; do
echo " "	 
echo "RETRY - creating fabric replicat"
curl -X POST \
       $GG_PROTOCOL://$GGFAB_URL/services/v2/replicats/FABRIC \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{
    "$schema": "ogg:replicat",
		"begin": {
			"sequence": 0,
			"offset": 0
		},
		"encryptionProfile": "LocalWallet",
		"managedProcessSettings": "ogg:managedProcessSettings:Default",
		"config": [
			"REPLICAT FABRIC",
			"MAP *.*, TARGET *.*;",
			""
		],
		"source": {
			"name": "ET"
		},
		"registration": "none",
		"mode": {
			"type": "nonintegrated",
			"parallel": false
		}
   }'
done
echo " "
echo "uploading properties file"
curl -X POST \
       $GG_PROTOCOL://$GGFAB_URL/services/v2/config/files/FABRIC.properties \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"lines": [
"gg.target=fabric_lakehouse",
"#TODO: format can be 'parquet' or 'orc' or one of the pluggable formatter types. Default is 'parquet'.",
"gg.format=parquet",
"#TODO: Edit the Fabric workspace name.",
"gg.eventhandler.onelake.workspace=mh_odaa",
"#TODO: Edit the Fabric lakehouse name.",
"gg.eventhandler.onelake.lakehouse=odaa_lh",
"#TODO: Edit the tenant ID of the application.",
"gg.eventhandler.onelake.tenantId=f71980b2-590a-4de9-90d5-6fbc867da951",
"#TODO: Edit the client ID of the application.",
"gg.eventhandler.onelake.clientId=ee88bf99-6dff-4025-b8c3-82f79102886a",
"#TODO: Edit the client secret for the authentication.",
"gg.eventhandler.onelake.clientSecret=2BN8Q~i5CkbyDP4QxgqIqIgw-_PkA3XKuLkEmb2E",
"#TODO: Edit the classpath to include Hadoop, Parquet, and Azure DataLake SDK dependencies.",
"gg.classpath=/mnt/deps/onelake/*:/mnt/deps/hadoop_3.4.2/*:/mnt/deps/parquet_1.16.0/*:/mnt/deps/azure-storage-blob_12.25.3/*:",
"#TODO: Edit the proxy configuration.",
"#jvm.bootoptions=-Dhttps.proxyHost=some-proxy-address.com -Dhttps.proxyPort=80 -Djava.net.useSystemProxies=true",
"#Mapping Parameters to create files and directories",
"gg.eventhandler.onelake.pathMappingTemplate=${catalogname}.lakehouse/Files/ogg/${groupName}/${schemaname}.schema/${tablename}"
],
"$schema": "ogg:config"
}'
		
while [ $? == "7" ]; do
echo " "
echo "RETRY - uploading properties file"
curl -X POST \
       $GG_PROTOCOL://$GGFAB_URL/services/v2//config/files/FABRIC.properties \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"lines": [
"gg.target=fabric_lakehouse",
"#TODO: format can be 'parquet' or 'orc' or one of the pluggable formatter types. Default is 'parquet'.",
"gg.format=parquet",
"#TODO: Edit the Fabric workspace name.",
"gg.eventhandler.onelake.workspace=mh_odaa",
"#TODO: Edit the Fabric lakehouse name.",
"gg.eventhandler.onelake.lakehouse=odaa_lh",
"#TODO: Edit the tenant ID of the application.",
"gg.eventhandler.onelake.tenantId=f71980b2-590a-4de9-90d5-6fbc867da951",
"#TODO: Edit the client ID of the application.",
"gg.eventhandler.onelake.clientId=ee88bf99-6dff-4025-b8c3-82f79102886a",
"#TODO: Edit the client secret for the authentication.",
"gg.eventhandler.onelake.clientSecret=2BN8Q~i5CkbyDP4QxgqIqIgw-_PkA3XKuLkEmb2E",
"#TODO: Edit the classpath to include Hadoop, Parquet, and Azure DataLake SDK dependencies.",
"gg.classpath=/mnt/deps/onelake/*:/mnt/deps/hadoop_3.4.2/*:/mnt/deps/parquet_1.16.0/*:/mnt/deps/azure-storage-blob_12.25.3/*:",
"#TODO: Edit the proxy configuration.",
"#jvm.bootoptions=-Dhttps.proxyHost=some-proxy-address.com -Dhttps.proxyPort=80 -Djava.net.useSystemProxies=true",
"#Mapping Parameters to create files and directories",
"gg.eventhandler.onelake.pathMappingTemplate=${catalogname}.lakehouse/Files/ogg/${groupName}/${schemaname}.schema/${tablename}"
],
"$schema": "ogg:config"
}'
done

echo "starting fabric replicat"
curl -X PATCH $GG_PROTOCOL://$GGFAB_URL/services/v2/replicats/FABRIC \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
       
while [ $? == "7" ]; do  
echo "RETRY - starting fabric replicat"
curl -X PATCH $GG_PROTOCOL://$GGFAB_URL/services/v2/replicats/FABRIC \
       --user $GG_USER:$GG_PWD   \
       --insecure \
       -H 'Cache-Control: no-cache' \
       -d '{"status": "running"}' 
done

#/bin/bash
## Variables used:
## GG_URL     - GoldenGate (k8s internal) URL for REST API access, WITHOUT protocol but with port
## GG_PROTOCOL- GoldenGate server protocol, http or https
## GG_URL     - GoldenGate for MS Fabric (k8s internal) URL for REST API access
## GG_USER    - GoldenGate REST API username, like oggadmin
## GG_PWD     - GoldenGate REST API password, like Welcome1234#
## GG_DEPL    - GoldenGate deployment name
export GG_PROTOCOL=http
echo " "
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
echo " "	 
echo "creating fabric replicat"
echo " "	 
echo "starting fabric replicat"
curl -X PATCH $GGFAB_URL/services/v2/replicats/ET \
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

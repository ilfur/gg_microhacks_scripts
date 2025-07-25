#!/bin/bash
# Loading the SH schema initially 
curl -v https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/peq5JVouDUrhcYFEzQ8GCznr4PBcuQzgCG1a9NBnLeip6Z9qiD6x77bdfnO0e0er/n/frul1g8cgfam/b/hr-sh-sample-data/o/sh.dmp -o sh.dmp
impdp SYSTEM/$ADMIN_PWD@//$DBHOST.$DBNAMESPACE:1521/freepdb1 directory=DATA_PUMP_DIR schemas=SH dumpfile=sh.dmp

# Now creating GGADMIN user in PDB and granting him GoldenGate read and apply roles
sqlplus SYSTEM/$ADMIN_PWD@//$DBHOST.$DBNAMESPACE:1521/freepdb1 <<EOF
ALTER PLUGGABLE DATABASE ADD SUPPLEMENTAL LOG DATA ;
ALTER DATABASE FORCE LOGGING;
ALTER SYSTEM SWITCH LOGFILE;
CREATE USER GGADMIN IDENTIFIED BY $ADMIN_PWD
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
GRANT CONNECT, RESOURCE, OGG_CAPTURE, OGG_APPLY to GGADMIN;
EOF



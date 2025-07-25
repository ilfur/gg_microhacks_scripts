#!/bin/bash
# Loading the SH schema initially 
curl -v https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/peq5JVouDUrhcYFEzQ8GCznr4PBcuQzgCG1a9NBnLeip6Z9qiD6x77bdfnO0e0er/n/frul1g8cgfam/b/hr-sh-sample-data/o/sh.dmp -o sh.dmp
impdp SYSTEM/$ADMIN_PWD@//$DBHOST.$DBNAMESPACE:1521/freepdb1 directory=DATA_PUMP_DIR schemas=SH dumpfile=sh.dmp

# Now creating GGADMIN user in PDB and granting him GoldenGate read and apply roles
sqlplus SYSTEM/$ADMIN_PWD@//$DBHOST.$DBNAMESPACE:1521/freepdb1 <<EOF
CREATE USER GGADMIN IDENTIFIED BY $ADMIN_PWD
  DEFAULT TABLESPACE 

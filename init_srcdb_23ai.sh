#!/bin/bash
## Variables used:
## SRC_URL    - source database URL, like ggadmin@db23ai.oracle23ai:1521/FREEPDB1
## SRC_PWD    - source database password for URL, like Welcome1234#
## SRC_USER   - source database user for goldengate
## SRC_SCHEMA - schema to be synced in source database, like SH
## ADMIN_PWD  - password for SYSTEM user of source PDB

# Loading the SH schema initially 
# curl -v https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/peq5JVouDUrhcYFEzQ8GCznr4PBcuQzgCG1a9NBnLeip6Z9qiD6x77bdfnO0e0er/n/frul1g8cgfam/b/hr-sh-sample-data/o/sh.dmp -o sh.dmp
# impdp SYSTEM/$ADMIN_PWD@//$SRC_URL directory=DATA_PUMP_DIR schemas=SH dumpfile=sh.dmp
# load REMOTELY through shell scripts...
git clone https://github.com/oracle-samples/db-sample-schemas
cd db-sample-schemas/sales_history
sqlplus SYSTEM/$ADMIN_PWD@//$SRC_URL <<EOF
@sh_install.sql
Welcome1234#


EOF

# Now creating GGADMIN user in PDB and granting him GoldenGate read and apply roles
sqlplus SYSTEM/$ADMIN_PWD@//$SRC_URL <<EOF
ALTER PLUGGABLE DATABASE ADD SUPPLEMENTAL LOG DATA ;
-- ALTER DATABASE FORCE LOGGING;
-- ALTER SYSTEM SWITCH LOGFILE;
ALTER USER $SRC_USER IDENTIFIED BY $SRC_PWD
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
GRANT CONNECT, RESOURCE, OGG_CAPTURE, OGG_APPLY to $SRC_USER;
EOF



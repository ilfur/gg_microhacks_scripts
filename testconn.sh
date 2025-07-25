#!/bin/bash
export PATH=/opt/oracle/instantclient_23_4:$PATH
export LD_LIBRARY_PATH=/opt/oracle/instantclient_23_4:$LD_LIBRARY_PATH
sqlplus system/$ADMIN_PWD@$DB_HOST:1521/$DB_SERVICE << EOF
whenever sqlerror exit failure;
select * from dual;
create table mydummy (mycol number);
drop table mydummy;
exit;
EOF
if [ $? -eq 0 ] ; then echo "connect successful" ; sleep 10 ; else echo "DB connect failed, waiting 1 min and exiting..." ; sleep 60 ; exit 5 ; fi

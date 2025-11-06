#!/bin/bash
## Variables used:
## TRG_URL    - target ADB URL, like ggadmin@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=gfde677d3a923a9_atp23ai_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
## TRG_PWD    - target goldengate database password, like Welcome1234#
## SRC_USER   - source database user for goldengate
## TRG_USER   - target database user for goldengate
## SRC_SCHEMA - schema to be synced in source database, like HR
## TRG_SCHEMA - schema to be synced in target database, like HR2
## TRG_ADMIN_PWD  - password of target ADB admin user
## DUMP_FILE  - URL to a pre-authenticated dump file in blob store/object store to be loaded by data pump

export TNS_ADMIN=~
export TRG_URL=$(echo $TRG_URL|tr -d ' ')

echo "ADP=$TRG_URL" >> $TNS_ADMIN/tnsnames.ora
cat $TNS_ADMIN/tnsnames.ora

sqlplus admin/$TRG_ADMIN_PWD@ADP <<EOF
ALTER USER GGADMIN IDENTIFIED BY $TRG_PWD ACCOUNT UNLOCK;
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'LOAD_CREDENTIAL',
    username => 'DUMMY',
    password => 'DUMMY'  );
END;
/
ALTER PLUGGABLE DATABASE ADD SUPPLEMENTAL LOG DATA;
CREATE USER $TRG_SCHEMA IDENTIFIED BY Welcome1234#
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;
/
DECLARE
    exported_schema VARCHAR2(64)  := '$SRC_SCHEMA';
    import_schema   VARCHAR2(64)  := '$TRG_SCHEMA'; 
    data_pump_dir   VARCHAR2(64)  := 'DATA_PUMP_DIR';
    --dump_file_name  VARCHAR2(256) := 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/G8mCAFoKUHHAg01q9_x7Uwr7JqVxT1C7xZ9gTGzyu2xAiIWe7q1e20UasXTsEb5a/n/fre3ftc1iva4/b/samples/o/sh.dmp';
    dump_file_name  VARCHAR2(256) := '$DUMP_FILE';
    credential_name VARCHAR2(64)  := 'LOAD_CREDENTIAL';
    parallel        NUMBER        := 4;
 
    job_handle      NUMBER;
    job_name        VARCHAR2(64);
    job_status      VARCHAR2(128);
    output_message  VARCHAR2(1024);
BEGIN
    job_name := dbms_scheduler.generate_job_name('import_');
    job_handle := dbms_datapump.open(operation => 'IMPORT', job_mode => 'SCHEMA', job_name => job_name); 
    dbms_datapump.add_file(handle => job_handle, filename => dump_file_name, directory => credential_name, filetype => dbms_datapump.ku\$_file_type_uridump_file); 
    dbms_datapump.add_file(handle => job_handle, filename => import_schema || '_import.log', directory => data_pump_dir, filetype => 3);
    dbms_datapump.metadata_remap(job_handle, 'REMAP_SCHEMA', exported_schema, import_schema);
    dbms_datapump.metadata_filter(handle => job_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || exported_schema || ''')');
    dbms_datapump.set_parallel(handle => job_handle, degree => parallel);
    dbms_datapump.start_job(handle => job_handle, skip_current => 0, abort_step => 0); 
    dbms_datapump.wait_for_job(handle => job_handle, job_state => job_status);
    output_message := 'Data Pump Import Execution: ''' || job_status || '''';
    dbms_output.put_line(output_message);
END;
/
EOF

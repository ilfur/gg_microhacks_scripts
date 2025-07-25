#!/bin/bash
echo "ADP=$ADB_CONN">>$TNS_ADMIN
sqlplus admin/$ADMIN_PWD@ADP <<EOF
ALTER USER GGADMIN IDENTIFIED BY $ADMIN_PWD ACCOUNT UNLOCK;
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'LOAD_CREDENTIAL',
    username => 'frul1g8cgfam/oracleidentitycloudservice/marcel.pfeifer@oracle.com',
    password => 'xMQ_Gb[f4peZ(i[2kI;]'  );
END;
/
DECLARE
    exported_schema VARCHAR2(64)  := 'SH';
    import_schema   VARCHAR2(64)  := 'SH2'; -- in case you want to remap schema
    data_pump_dir   VARCHAR2(64)  := 'DATA_PUMP_DIR';
    dump_file_name  VARCHAR2(256) := 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/peq5JVouDUrhcYFEzQ8GCznr4PBcuQzgCG1a9NBnLeip6Z9qiD6x77bdfnO0e0er/n/frul1g8cgfam/b/hr-sh-sample-data/o/sh.dmp';
    credential_name VARCHAR2(64)  := 'LOAD_CREDENTIAL';
    parallel        NUMBER        := 4;
 
    job_handle      NUMBER;
    job_name        VARCHAR2(64);
    job_status      VARCHAR2(128);
    output_message  VARCHAR2(1024);
BEGIN
    job_name := dbms_scheduler.generate_job_name('import_');
    job_handle := dbms_datapump.open(operation => 'IMPORT', job_mode => 'SCHEMA', job_name => job_name); 
    dbms_datapump.add_file(handle => job_handle, filename => dump_file_name, directory => credential_name, filetype => dbms_datapump.ku$_file_type_uridump_file); 
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

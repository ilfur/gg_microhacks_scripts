#!/bin/bash
## Variables used:
## SRC_URL    - source database URL, like ggadmin@db23ai.oracle23ai:1521/FREEPDB1
## SRC_PWD    - source database password for URL, like Welcome1234#
## SRC_USER   - source database user for goldengate
## SRC_SCHEMA - schema to be synced in source database, like SH
## SRC_ADMIN_PWD  - password for SYSTEM user of source PDB

# Loading the SH schema initially 
# First, create user SH and allow him to download the dmp file
sqlplus SYSTEM/$SRC_ADMIN_PWD@//$SRC_URL <<EOF
create user sh identified by Welcome1234#
   default tablespace users
   temporary tablespace temp
   quota unlimited on users;
grant connect, resource, create any directory to sh;
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => '*',
    ace => xs$ace_type(privilege_list => xs\$name_list('http'),
                       principal_name => 'SH',
                       principal_type => xs_acl.ptype_db));
END;
/
EOF

# Now, as user SH, download the DMP file (system is not allowed to do that)
sqlplus SH/Welcome1234#@//$SRC_URL <<EOF
create or replace directory load_dir as '/tmp';
DECLARE
  lv_url    VARCHAR2(250) := 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/AchwripxZjs7IxMRtWO2H_gkxFHU4d2uNDYKctfGmgsRodlHvaxxgjAKT0awXOxH/n/fre3ftc1iva4/b/export_bucket/o/SHBIG.dmp';
  lc_return BLOB;
  lhttp_url httpuritype;
    ---Varriables declared for writing the LOB to pdf file --
    l_file     UTL_FILE.FILE_TYPE;
    l_buffer   RAW(32767);
    l_amount   BINARY_INTEGER := 32767;
    l_pos      INTEGER := 1;
    l_blob     BLOB;
    l_blob_len INTEGER;
  BEGIN
    --create uri
    lhttp_url := httpuritype.createuri(lv_url);
    --get the PDF document
    lc_return := lhttp_url.getblob();
    -- Open the destination file.
    l_file := UTL_FILE.FOPEN('LOAD_DIR', 'SHBIG.dmp', 'wb');
    --Get the total length of the BLOB
    l_blob_len := DBMS_LOB.getlength(lc_return);
    -- Read chunks of the BLOB and write them to the file
    -- until complete.
    WHILE l_pos < l_blob_len LOOP
      DBMS_LOB.READ(lc_return, l_amount, l_pos, l_buffer);
      UTL_FILE.put_raw(l_file, l_buffer, FALSE);
      l_pos := l_pos + l_amount;
    END LOOP;
    -- Close the file.
    UTL_FILE.FCLOSE(l_file);
  EXCEPTION
    WHEN OTHERS THEN
      -- Close the file if something goes wrong.
      IF UTL_FILE.IS_OPEN(l_file) THEN
        UTL_FILE.FCLOSE(l_file);
      END IF;
    
      RAISE;
  END;
/
EOF

# as system user, load the dmp file
sqlplus SYSTEM/$SRC_ADMIN_PWD@//$SRC_URL <<EOF
DECLARE
    exported_schema VARCHAR2(64)  := 'SH';
    import_schema   VARCHAR2(64)  := 'SH'; 
    data_pump_dir   VARCHAR2(64)  := 'LOAD_DIR';
    dump_file_name  VARCHAR2(256) := 'SHBIG.dmp';
    credential_name VARCHAR2(64)  := 'LOAD_DIR';
    parallel        NUMBER        := 4;
 
    job_handle      NUMBER;
    job_name        VARCHAR2(64);
    job_status      VARCHAR2(128);
    output_message  VARCHAR2(1024);
BEGIN
    job_name := dbms_scheduler.generate_job_name('import_');
    job_handle := dbms_datapump.open(operation => 'IMPORT', job_mode => 'SCHEMA', job_name => job_name); 
    dbms_datapump.add_file(handle => job_handle, filename => dump_file_name, directory => data_pump_dir); 
    dbms_datapump.add_file(handle => job_handle, filename => import_schema || '_import.log', directory => data_pump_dir, filetype => 3);
    dbms_datapump.metadata_remap(job_handle, 'REMAP_SCHEMA', exported_schema, import_schema);
    dbms_datapump.metadata_filter(handle => job_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || exported_schema || ''')');
    dbms_datapump.start_job(handle => job_handle, skip_current => 0, abort_step => 0); 
    dbms_datapump.wait_for_job(handle => job_handle, job_state => job_status);
    output_message := 'Data Pump Import Execution: ''' || job_status || '''';
    dbms_output.put_line(output_message);
END;
/
EOF

#configure goldengate replication params
sqlplus SYSTEM/$SRC_ADMIN_PWD@//$SRC_URL <<EOF
alter session set container=cdb\$root;
alter system set enable_goldengate_replication=true scope=both;
EOF

# Now creating GGADMIN user in PDB and granting him GoldenGate read and apply roles
sqlplus SYSTEM/$SRC_ADMIN_PWD@//$SRC_URL <<EOF
ALTER PLUGGABLE DATABASE ADD SUPPLEMENTAL LOG DATA ;
-- ALTER DATABASE FORCE LOGGING;
-- ALTER SYSTEM SWITCH LOGFILE;
CREATE USER $SRC_USER IDENTIFIED BY $SRC_PWD
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
-- in case the user already exists, like GGADMIN
ALTER USER $SRC_USER IDENTIFIED BY $SRC_PWD ACCOUNT UNLOCK
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;
GRANT CONNECT, RESOURCE, OGG_CAPTURE, OGG_APPLY to $SRC_USER;
ALTER USER $SRC_USER QUOTA UNLIMITED ON USERS;
EOF



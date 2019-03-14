--------------------------------------------------------
--  File created - Sunday-March-10-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure DATA_TRANSFER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "DATA_TRANSFER" (
    source_schema VARCHAR2,
    destination_schema VARCHAR2
) IS
    v_sql varchar2(4000);
    v_sql1 varchar2(4000);
    -- Cursor for getting schema from source
    CURSOR c_src IS
    SELECT owner,
           object_name,
           object_type,
           last_ddl_time
    FROM dba_objects
    WHERE owner IN (
        source_schema);
     -- Cursor for getting schema from Destination
    CURSOR c_dsn IS
    SELECT owner,
           object_name,
           object_type,
           last_ddl_time
    FROM dba_objects
    WHERE owner IN (
        destination_schema);
  -- Nested Table for holding data from source and destination cursor
  type t1 is table of c_src%rowtype;
  type t2 is table of c_dsn%rowtype;
  v_src t1;
  v_dsn t2;
  v_source varchar2(100);
  v_destination varchar2(100);
 -------------------------------------
 -- Non Matching Tables From Source
 cursor C_non_match is select object_type,object_name from dba_objects where owner in(source_schema)
 minus select object_type,object_name from dba_objects where owner in(destination_schema);
 type t3 is table of C_non_match%rowtype; 
 v_non_match t3;
BEGIN
     -- disble constraints, storage, tablespace and schema name from dbms_metadata.get_ddl
     DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS',false);
     DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
     DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false);     
     DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', false);
     DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
     --dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'EMIT_SCHEMA', false);
     open c_src;
    fetch c_src bulk collect into v_src;
    close c_src;
    open c_dsn;
    fetch c_dsn bulk collect into v_dsn;
    close c_dsn;
    open C_non_match;
    fetch C_non_match bulk collect into v_non_match;
    close C_non_match;
    
    for i in v_src.first..v_src.last
    loop
       -- Destination dont have any object in their schema
       if(v_dsn.count=0) then
                  v_source:=v_src(i).object_type;
                  v_destination:=v_src(i).object_name;
                  select dbms_metadata.GET_DDL(v_source,v_destination,source_schema) 
                  into v_sql from dual;
                  v_sql1:=replace(replace(v_sql,'"'),source_schema||'.'||v_destination,destination_schema||'.'||v_destination);
                 execute immediate v_sql1;
        else
        -- Destination have objects in their Schema
        for j in v_dsn.first..v_dsn.last loop            
            if(v_src(i).object_name=v_dsn(j).object_name)then    --object name matched 
                if(v_src(i).last_ddl_time<v_dsn(j).last_ddl_time) then   -- then check for last update DDL time
                   continue;
                else 
                  v_source:=v_src(i).object_type;
                  v_destination:=v_src(i).object_name;
                  select dbms_metadata.GET_DDL(v_source,v_destination,source_schema) 
                  into v_sql from dual;
                  v_sql1:=replace(replace(v_sql,'"'),source_schema||'.'||v_destination,destination_schema||'.'||v_destination);
                 execute immediate v_sql1;            
                end if;
            end if;         
        end loop;    
      end if;
    end loop;   
    if(v_non_match.count=0) then
       return;
    else
       for k in v_non_match.first..v_non_match.last loop
          v_source:=v_non_match(k).object_type;
          v_destination:=v_non_match(k).object_name;
          select dbms_metadata.GET_DDL(v_source,v_destination,source_schema) into v_sql from dual;
           v_sql1:=replace(replace(v_sql,'"'),source_schema||'.'||v_destination,destination_schema||'.'||v_destination);
           execute immediate v_sql1;  
       end loop;    
    end if;
exception
       when others then
       -- if error comes then it will give the line no of error
       dbms_output.put_line('Error line :'||dbms_utility.format_error_backtrace);
END;

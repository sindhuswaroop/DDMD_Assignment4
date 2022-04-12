set serveroutput on;
--Create table block
--drop table department;
declare 
v_cnt number;
begin
    select count(*) into v_cnt from user_tables where table_name = upper('department');
    if v_cnt = 0 then
        execute immediate('
            CREATE TABLE DEPARTMENT(
            dept_id number(5) NOT NULL PRIMARY KEY,
            dept_name varchar(40) NOT NULL,
            dept_location varchar(40) NOT NULL)');
        dbms_output.put_line('Department table created');
        
    else
        dbms_output.put_line('Department table already exists');
    end if;
end;

--Create Sequence block
--drop sequence deptid_seq;    
declare 
v_count number;
begin
    select count(*) into v_count from user_sequences where sequence_name = upper('deptid_seq');
    if v_count = 0 then
        execute immediate('
            CREATE SEQUENCE deptid_seq
            START WITH 10000
            INCREMENT BY 1');
        dbms_output.put_line('Department ID Auto-generate Sequence created'); 
    else
        dbms_output.put_line('Department ID Auto-generate Sequence already exists');
    end if;
end;

--Procedure for inserting into DEPARTMENT table         
create or replace procedure deptTable(deptName department.dept_name%TYPE, deptLocation varchar) is

v_id number;
v_name number;
lengthDeptName number;
dept_loc varchar(50);
deptNameType number;
invalidDNameType exception;

begin

    begin
        if deptName is not null then
            select to_number(deptName) into deptNameType from dual;
            raise invalidDNameType;
        end if;
        exception when invalid_number then null;
    end;
    
    select deptid_seq.nextval into v_id from dual;
    select count(*) into v_name from department where dept_name = initcap(deptName);
    select length(deptName) into lengthDeptName from dual;
    dept_loc := upper(deptLocation);
    
    if(v_name = 0 and (dept_loc = 'MA' or dept_loc = 'TX' or 
        dept_loc = 'IL' or dept_loc = 'CA' or 
        dept_loc = 'NY' or dept_loc = 'NJ' or 
        dept_loc = 'NH' or dept_loc = 'RH') and lengthDeptName<=20) then
        execute immediate ('insert into department values(' || v_id || ', initcap(''' || deptName || '''), upper(''' || deptLocation || '''))');
        dbms_output.put_line('Record inserted successfully');
    elsif(v_name>0 and (dept_loc = 'MA' or dept_loc = 'TX' or 
        dept_loc = 'IL' or dept_loc = 'CA' or 
        dept_loc = 'NY' or dept_loc = 'NJ' or 
        dept_loc = 'NH' or dept_loc = 'RH') and lengthDeptName<=20) then
        execute immediate ('update department set dept_location ' || ' = '''|| dept_loc ||''' where dept_name = initcap('''||deptName||''')');
        dbms_output.put_line('Record updated successfully');
    elsif((dept_loc != 'MA' or dept_loc != 'TX' or 
        dept_loc != 'IL' or dept_loc != 'CA' or 
        dept_loc != 'NY' or dept_loc != 'NJ' or 
        dept_loc != 'NH' or dept_loc != 'RH') and lengthDeptName<=20) then
        dbms_output.put_line('Department Location invalid');
    elsif(lengthDeptName>20) then
        dbms_output.put_line('Department Name cannot be more than 20 characters long');
    else     dbms_output.put_line('Reaches here if null');
    end if;
    
    exception 
    when invalidDNameType then
        dbms_output.put_line('Please do not enter numbers as department name');
    when others then 
        if sqlcode = -1400 then 
            dbms_output.put_line('Department Name cannot be null/empty');
        else
             dbms_output.put_line('Contact ADMIN');
        end if;
end;
/

--Test case 1: Insert 6 records with unique dept name <20 characters and valid dept location
exec deptTable('data analytics','ma');
exec deptTable('engg management','nh');
exec deptTable('information science','tx');
exec deptTable('data science','il');
exec deptTable('human resources','ca');
exec deptTable('career design','nj');

--Test case 2: Update record with same dept name to different location 
exec deptTable('data analytics','ny');

--Test case 3: Insert record with dept name >20 characters
exec deptTable('data analytics engineering','ma');

--Test case 4: Insert record with dept name null/empty
exec deptTable('','rh');

--Test Case 5: Insert record with dept location different from those given
exec deptTable('engg management','ba');

--Test Case 6: Insert number in character format as department name
exec deptTable('123','MA');

--Test Case 7: Insert number in number format as department name
exec deptTable(123,'MA');

delete from department;
    
select * from DEPARTMENT;


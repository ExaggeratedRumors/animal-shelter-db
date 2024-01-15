begin
  for cur_rec in (select object_name, object_type 
                  from   user_objects
                  where  object_type in ('table', 'view', 'package', 'procedure', 'function', 'sequence', 'trigger', 'type')) loop
    begin
      if cur_rec.object_type = 'table' then
        if instr(cur_rec.object_name, 'store') = 0 then
          execute immediate 'drop ' || cur_rec.object_type || ' "' || cur_rec.object_name || '" cascade constraints';
        end if;
      elsif cur_rec.object_type = 'type' then
        execute immediate 'drop ' || cur_rec.object_type || ' "' || cur_rec.object_name || '" force';
      else
        execute immediate 'drop ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"';
      end if;
    exception
      when others then
        dbms_output.put_line('failed: drop ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"');
    end;
  end loop;
end;
/
create table emp as select * from scott.emp;
/
create table dept as select * from scott.dept;
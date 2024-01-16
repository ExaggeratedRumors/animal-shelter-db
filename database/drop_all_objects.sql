
Error starting at line : 6 in command -
declare  l_object varchar2(32000);

begin

  for i in (select object_name, object_type from dba_objects where owner='<owner>') loop

    if i.object_type='JOB' then

          l_object := 'begin dbms_scheduler.drop_job (job_name => ''<owner>'||i.object_name||'''); end;';

elsif i.object_type='PROGRAM' then

      l_object := 'begin dbms_scheduler.drop_program (program_name => ''<owner>'||i.object_name||'''); end;';

elsif i.object_type='RULE' then

      l_object := 'begin dbms_rule_adm.drop_rule (rule_name => ''<owner>'||i.object_name||''', force => TRUE); end;';

elsif i.object_type='RULE SET' then

      l_object := 'begin dbms_rule_adm.drop_rule_set (rule_set_name => ''<owner>'||i.object_name||''', delete_rules => TRUE); end;';

elsif i.object_type='CHAIN' then

      l_object := 'begin dbms_scheduler.drop_chain (chain_name => ''<owner>'||i.object_name||''', force => TRUE); end;';

elsif i.object_type='RULE' then

      l_object := 'begin dbms_rule_adm.drop_evaluation_context (evaluation_context_name => ''<owner>'||i.object_name||''', force => TRUE); end;';

else

          l_object := 'drop '||i.object_type||'<owner>'||i.object_name||';';

end if;

dbms_output.put_line(i_object);

dbms_output.put_line('/');

end loop;

end;
Error report -
ORA-04045: b³êdy podczas rekompilacji/weryfikacji SYS.DBMS_STANDARD
ORA-00600: kod b³êdu wewnêtrznego, argumenty: [kokiasg1], [], [], [], [], [], [], [], [], [], [], []
04045. 00000 -  "errors during recompilation/revalidation of %s.%s"
*Cause:    This message indicates the object to which the following
           errors apply.  The errors occurred during implicit
           recompilation/revalidation of the object.
*Action:   Check the following errors for more information, and
           make the necessary corrections to the object.

Error starting at line : 52 in command -
@drop_all_objects
Error report -
SP2-0310: Unable to open file: "drop_all_objects.sql"

create or replace package admin_package as
   
    PROCEDURE addDuty(
    --wypisuje Error: -2291 - ORA-02291: naruszono wi?zy spójno?ci (SYS.SYS_C007502) - nie znaleziono klucza nadrz?dnego
    -- gdy podano nieistniejacy index boxa lub emp
        p_emp_id IN NUMBER,
        p_box_id IN NUMBER,
        p_weekday IN NUMBER,
        p_start_hour IN NUMBER,
        p_end_hour IN NUMBER,
        p_responsibilities IN VARCHAR2
    );
    PROCEDURE removeDuty(
        p_emp_id IN NUMBER,
        p_box_id IN NUMBER,
        p_weekday IN NUMBER
    );
    PROCEDURE addBox(max_box_capacity in NUMBER, box_species VARCHAR2);
    
    
end admin_package;
/

create or replace package body admin_package as
    PROCEDURE addDuty(
        p_emp_id IN NUMBER,
        p_box_id IN NUMBER,
        p_weekday IN NUMBER,
        p_start_hour IN NUMBER,
        p_end_hour IN NUMBER,
        p_responsibilities IN VARCHAR2
    ) AS
        v_duty_exists NUMBER;
        dutyExists EXCEPTION;
        v_employee_ref ref t_employees;
        v_box_ref ref t_boxes;
    BEGIN
        SELECT REF(e) INTO v_employee_ref
        FROM employees e
        WHERE e.emp_id = p_emp_id;
    
        SELECT REF(b) INTO v_box_ref
        FROM boxes b
        WHERE b.box_id = p_box_id;
        
        
        SELECT COUNT(*) INTO v_duty_exists
        FROM duties d
        WHERE DEREF(d.emp).emp_id = p_emp_id
          AND DEREF(d.box).box_id = p_box_id
          AND d.weekday = p_weekday;
    
        IF v_duty_exists > 0 THEN
            raise dutyExists;
        end if;
        
        -- Insert using references
        INSERT INTO duties(duty_id, emp, box, weekday, start_hour, end_hour, responsibilities)
        VALUES (seq_duties.NEXTVAL, v_employee_ref, v_box_ref, p_weekday, p_start_hour, p_end_hour, p_responsibilities);
        DBMS_OUTPUT.PUT_LINE('Created duty for Employee #'||p_emp_id||' and Box #'||p_box_id || ' on day #' || p_weekday);
   
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Employee #'||p_emp_id||' or Box #'||p_box_id||' not found');
        WHEN dutyExists THEN
            DBMS_OUTPUT.PUT_LINE('Duty already exists for Employee #' || p_emp_id || ', Box #' || p_box_id || ', and Weekday #' || p_weekday);
            
    END addDuty;
    
    PROCEDURE removeDuty(
        p_emp_id IN NUMBER,
        p_box_id IN NUMBER,
        p_weekday IN NUMBER
    ) AS
        v_duty_exists NUMBER;
        dutyNotFound EXCEPTION;
    BEGIN
        -- Check if the duty exists
        SELECT COUNT(*) INTO v_duty_exists
        FROM duties d
        WHERE DEREF(d.emp).emp_id = p_emp_id
          AND DEREF(d.box).box_id = p_box_id
          AND d.weekday = p_weekday;

        IF v_duty_exists = 0 THEN
            raise dutyNotFound;
        END IF;

        DELETE FROM duties
        WHERE DEREF(emp).emp_id = p_emp_id
          AND DEREF(box).box_id = p_box_id
          AND weekday = p_weekday;

        DBMS_OUTPUT.PUT_LINE('Duty removed for Employee #' || p_emp_id || ', Box #' || p_box_id || ', and Weekday #' || p_weekday);

    EXCEPTION
        WHEN dutyNotFound THEN
            DBMS_OUTPUT.PUT_LINE('Duty not found for Employee #' || p_emp_id || ', Box #' || p_box_id || ', and Weekday #' || p_weekday);
    END removeDuty;
    
    
    PROCEDURE addBox(max_box_capacity in NUMBER, box_species VARCHAR2) as
        v_box_id NUMBER;
    BEGIN
        SELECT seq_boxes.NEXTVAL INTO v_box_id FROM dual;
        INSERT INTO 
        boxes (box_id, max_capacity, current_capacity, species) 
        VALUES (v_box_id, max_box_capacity,  0,   box_species);
    END;
end admin_package;
/

BEGIN
    admin_package.addDuty(1,1,1,8,16, 'Feeding');
    admin_package.addDuty(1,1,2,8,16, 'Feeding');
    admin_package.addDuty(1,1,3,8,16, 'Feeding');
    admin_package.addDuty(1,1,4,8,16, 'Feeding');
    admin_package.addDuty(1,1,5,8,16, 'Feeding');
    
    admin_package.addDuty(2,1,6,8,16, 'Feeding');
    admin_package.addDuty(2,1,7,8,16, 'Feeding');
end;

BEGIN
    admin_package.removeDuty(1,1,1);
    admin_package.removeDuty(1,1,2);
    admin_package.removeDuty(1,1,3);
    admin_package.removeDuty(1,1,4);
    admin_package.removeDuty(1,1,5);
    
    admin_package.removeDuty(2,1,6);
    admin_package.removeDuty(2,1,7);
end;

begin
    admin_package.addBox(10, 'Cat');
end;

select * from boxes;


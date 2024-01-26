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
    BEGIN
        -- Check if the duty already exists for the given employee and box
        SELECT COUNT(*)
        INTO v_duty_exists
        FROM duties
        WHERE emp_id = p_emp_id AND box_id = p_box_id AND weekday = p_weekday;
    
        IF v_duty_exists > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, v_duty_exists || ' Duty already exists for the employee and box.');
        END IF;
        
        INSERT INTO duties(emp_id, box_id, weekday, start_hour, end_hour, responsibilities)
        VALUES (p_emp_id, p_box_id, p_weekday, p_start_hour, p_end_hour, p_responsibilities);
        DBMS_OUTPUT.PUT_LINE('Duty added successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
    END addDuty;
    
    
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
    admin_package.addDuty(1,2,4,1,2,'test3');
end;

begin
    admin_package.addBox(10, 'Cat');
end;

select * from boxes;


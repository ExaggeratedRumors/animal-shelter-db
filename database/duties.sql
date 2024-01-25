

CREATE OR REPLACE PROCEDURE add_duty(
--wypisuje Error: -2291 - ORA-02291: naruszono wi?zy spójno?ci (SYS.SYS_C007502) - nie znaleziono klucza nadrz?dnego
-- gdy podano nieistniejacy index boxa lub emp
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
END add_duty;
/

BEGIN
    add_duty(1,2,4,1,2,'test3');
end;
/

select * from duties;

create or replace package employee_package as
   
    procedure addEmployee(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        role in varchar2
    );
    procedure getPets(pet_species in varchar2);
    FUNCTION getBoxIdBySpace(spaceLeft IN NUMBER) RETURN NUMBER;
    procedure getDuties(p_weekday IN NUMBER);
    PROCEDURE addPet(
        name IN VARCHAR2,
        species IN VARCHAR2,
        breed IN VARCHAR2,
        status IN VARCHAR2,
        health IN VARCHAR2,
        behaviour IN VARCHAR2,
        description IN VARCHAR2,
        picture IN BLOB
    );
    PROCEDURE removePet(remove_pet_id IN NUMBER);
end employee_package;
/


create or replace package body employee_package as

    procedure addEmployee(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        role in varchar2
    ) is
    begin
        insert into employees (
            emp_id,
            firstname,
            lastname,
            address,
            role
        ) values (
            seq_employees.nextval,
            firstname,
            lastname,
            address,
            role
        );
        commit;
    end addEmployee;

    PROCEDURE getPets(pet_species IN VARCHAR2) IS
        CURSOR pets_cursor IS
            SELECT * 
            FROM pets p
            WHERE LOWER(p.species) = LOWER(pet_species);
    
        pet_rec pets%ROWTYPE;
        pet_found BOOLEAN := FALSE;
    BEGIN
        dbms_output.put_line('Listing all ' || pet_species || 's:');
    
        FOR pet_rec IN pets_cursor LOOP
            dbms_output.put_line('Pet ID: ' || pet_rec.pet_id || ', Name: ' || pet_rec.name);
            pet_found := TRUE;
        END LOOP;
    
        IF NOT pet_found THEN
            dbms_output.put_line('No pets found for species ' || pet_species);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('An error occurred.');
    END getPets;


    FUNCTION getBoxIdBySpace(spaceLeft IN NUMBER) RETURN NUMBER IS
        v_box_id NUMBER;
    BEGIN
        SELECT box_id
        INTO v_box_id
        FROM boxes
        WHERE max_capacity - current_capacity >= spaceLeft
          AND ROWNUM = 1; --returns one box
        RETURN v_box_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END getBoxIdBySpace;

    PROCEDURE getDuties(p_weekday IN NUMBER) AS
        -- Declare cursor variables
        CURSOR duties_cursor IS
        SELECT d.emp_id, d.box_id, d.weekday, d.start_hour, d.end_hour, d.responsibilities, e.firstname AS emp_firstname, e.lastname AS emp_lastname
        FROM duties d
        JOIN employees e ON d.emp_id = e.emp_id
        WHERE d.weekday = p_weekday;

        v_emp_id NUMBER;
        v_box_id NUMBER;
        v_weekday NUMBER;
        v_start_hour NUMBER;
        v_end_hour NUMBER;
        v_responsibilities VARCHAR2(100);
        v_emp_firstname VARCHAR2(20);
        v_emp_lastname VARCHAR2(20);
    
    BEGIN
        -- Open the cursor
        OPEN duties_cursor;
        DBMS_OUTPUT.PUT_LINE('Duties for weekday '||p_weekday||':');
        LOOP
            FETCH duties_cursor INTO v_emp_id, v_box_id, v_weekday, v_start_hour, v_end_hour, v_responsibilities,
                                      v_emp_firstname, v_emp_lastname;
            EXIT WHEN duties_cursor%NOTFOUND;
    
            -- Process the fetched data
            DBMS_OUTPUT.PUT_LINE('Employee #'||v_emp_id ||', ' || v_emp_firstname || ' ' || v_emp_lastname);
            DBMS_OUTPUT.PUT_LINE('Box ID: ' || v_box_id);
            DBMS_OUTPUT.PUT_LINE('Weekday: ' || v_weekday);
            DBMS_OUTPUT.PUT_LINE('Start Hour: ' || v_start_hour);
            DBMS_OUTPUT.PUT_LINE('End Hour: ' || v_end_hour);
            DBMS_OUTPUT.PUT_LINE('Responsibilities: ' || v_responsibilities);
            DBMS_OUTPUT.PUT_LINE('-----------------------');
        END LOOP;
    
        -- Close the cursor
        CLOSE duties_cursor;
    
    EXCEPTION
        WHEN OTHERS THEN
            -- Handle exceptions as needed
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
    END getDuties;

    
    PROCEDURE addPet(
        name IN VARCHAR2,
        species IN VARCHAR2,
        breed IN VARCHAR2,
        status IN VARCHAR2,
        health IN VARCHAR2,
        behaviour IN VARCHAR2,
        description IN VARCHAR2,
        picture IN BLOB
    ) IS
        v_box_id NUMBER;
    BEGIN
        v_box_id := getBoxIdBySpace(1); -- get valid box

        IF v_box_id IS NOT NULL THEN
            -- Insert the new pet
            INSERT INTO pets (
                pet_id,
                name,
                species,
                breed,
                status,
                joined_at,
                donation_status,
                health,
                behaviour,
                description,
                picture,
                box
            ) VALUES (
                seq_pets.NEXTVAL,
                name,
                species,
                breed,
                status,
                SYSDATE,
                0,
                health,
                behaviour,
                description,
                picture,
                (SELECT REF(b) FROM boxes b WHERE b.box_id = v_box_id)
            );
    
            -- Increment current_capacity of the associated box
            UPDATE boxes SET current_capacity = current_capacity + 1 WHERE box_id = v_box_id;
            DBMS_OUTPUT.PUT_LINE('Added '|| name || ' the ' || species|| ' into box #' || v_box_id || '.');
            COMMIT;
        ELSE
            -- Handle the case when no box with available space is found
            DBMS_OUTPUT.PUT_LINE('No box with available space found.');
        END IF;
    END addPet;
    
    PROCEDURE removePet(remove_pet_id IN NUMBER) IS
            v_box_id NUMBER;
        BEGIN
            -- Find the box_id associated with the given pet_id
            SELECT DEREF(p.box).box_id INTO v_box_id
            FROM pets p
            WHERE p.pet_id = remove_pet_id;
        
            DELETE FROM pets WHERE pet_id = remove_pet_id;
    
            UPDATE boxes SET current_capacity = current_capacity - 1 WHERE box_id = v_box_id;
    
            DBMS_OUTPUT.PUT_LINE('Pet with ID ' || remove_pet_id || ' removed successfully.');
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Pet with ID ' || remove_pet_id || ' not found.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred while removing the pet with ID ' || remove_pet_id || ': ' || SQLERRM);
        END removePet;
end employee_package;
/

SET SERVEROUTPUT ON;


/* package demo */




--view pets
DECLARE
    v_species VARCHAR2(20) := 'cat'; -- Replace with the desired species
BEGIN
    employee_package.getPets(v_species);
END;
/


--add pet
DECLARE
    v_picture BLOB := NULL;
BEGIN

    employee_package.addPet(
        'Fluffy',   -- name
        'Cat',      -- species
        'Persian',  -- breed
        'Available', -- status
        'Good',     -- health
        'Friendly and playful',  -- behaviour
        'A lovely cat looking for a home',  -- description
        v_picture
    );
    
    employee_package.getpets('Cat');
END;
/

--remove pet
declare
    pet_id NUMBER :=2;
begin
    employee_package.removepet(pet_id);
    employee_package.getpets('Cat');
end;

--view pets
begin
    employee_package.getpets('cat');
end;



--duties
begin
    employee_package.getDuties(1);
end;



begin
    employee_package.addEmployee('jan','kowalski','warszawa','sprzatacz');
end;
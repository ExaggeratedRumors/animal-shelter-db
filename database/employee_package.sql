create or replace package employee_package as
   
    procedure addEmployee(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        role in varchar2
    );
    procedure getPets(species in varchar2);
    FUNCTION getBoxIdBySpace(spaceLeft IN NUMBER) RETURN NUMBER;
    procedure getDuties(weekday in number); 
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

    procedure getPets(species in varchar2) is
    begin
        for pet_rec in (
            select * 
            from pets 
            where species = species
        ) loop
            -- Print or process each pet record as needed
            dbms_output.put_line('Pet ID: ' || pet_rec.pet_id || ', Name: ' || pet_rec.name);
            -- Add more columns as needed
        end loop;
    end getPets;

    FUNCTION getBoxIdBySpace(spaceLeft IN NUMBER) RETURN NUMBER IS
        v_box_id NUMBER;
    BEGIN
        SELECT box_id
        INTO v_box_id
        FROM boxes
        WHERE max_capacity - current_capacity >= spaceLeft
          AND ROWNUM = 1; -- Assuming you want to return only one box (if multiple have the same spaceLeft)

        RETURN v_box_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL; -- Return NULL if no box is found
    END getBoxIdBySpace;

    procedure getDuties(weekday in number) is
    begin
        -- For now, the procedure does nothing
        null;
    end getDuties;
    
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
        -- Get the box ID with available space
        v_box_id := getBoxIdBySpace(1); -- Replace with the desired space
    
        -- Check if a box ID was found
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
            UPDATE boxes
            SET current_capacity = current_capacity + 1
            WHERE box_id = v_box_id;
    
            COMMIT;
        ELSE
            -- Handle the case when no box with available space is found
            DBMS_OUTPUT.PUT_LINE('No box with available space found.');
        END IF;
    END addPet;

    
end employee_package;
/

SET SERVEROUTPUT ON;

--view pets
DECLARE
    -- Call the procedure from the package
    v_species VARCHAR2(20) := 'cats'; -- Replace with the desired species
BEGIN
    employee_package.getPets(v_species);
END;
/


--add pet
DECLARE
    v_picture BLOB := NULL;
BEGIN

    employee_package.addPet(
        'Fluffy2',   -- name
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

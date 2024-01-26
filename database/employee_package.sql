create or replace package employee_package as
   
    procedure addEmployee(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        role in varchar2
    );
    procedure getPets(pet_species in varchar2);
    FUNCTION getBoxId(spaceLeft IN NUMBER, box_species varchar2) RETURN NUMBER;
    FUNCTION getEmptyBox(box_species varchar2) RETURN NUMBER;
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
    PROCEDURE printBoxesAndPets;
    FUNCTION getTransactions RETURN SYS_REFCURSOR;
    PROCEDURE printTransactions;
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


    FUNCTION getBoxId(spaceLeft IN NUMBER, box_species VARCHAR2) RETURN NUMBER IS
        v_box_id NUMBER;
    BEGIN
        SELECT box_id
        INTO v_box_id
        FROM boxes b
        WHERE max_capacity - current_capacity >= spaceLeft
          AND species = box_species
          AND NOT EXISTS (
            SELECT 1 FROM pets p
            WHERE p.box IS NOT NULL
              AND p.box = REF(b)
              AND UPPER(p.behaviour) = 'AGGRESSIVE'
          )
          AND ROWNUM = 1; -- Returns one box
    
        RETURN v_box_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END getBoxId;



    FUNCTION getEmptyBox(box_species varchar2) RETURN NUMBER IS
        v_box_id NUMBER;
    BEGIN
        SELECT box_id
        INTO v_box_id
        FROM boxes
        WHERE current_capacity = 0
            AND species = box_species
            AND ROWNUM = 1; --returns one box
        RETURN v_box_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END getEmptyBox;

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
        -- Check if the behavior is "Aggressive"
        IF UPPER(behaviour) = 'AGGRESSIVE' THEN
            v_box_id := getEmptyBox(species); -- Get a box with available space based on species
        ELSE
            v_box_id := getBoxId(1, species); -- Get a valid box based on the default criteria
        END IF;
    
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
            DBMS_OUTPUT.PUT_LINE('Added '|| name || ' the ' || species || ' into box #' || v_box_id || '.');
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
        
        
    PROCEDURE printBoxesAndPets IS
        CURSOR box_cursor IS
            SELECT b.box_id, b.species, b.max_capacity, b.current_capacity
            FROM boxes b;
    
        CURSOR pet_cursor (p_box_id NUMBER) IS
            SELECT p.pet_id, p.name, p.species, p.breed, p.behaviour
            FROM pets p
            WHERE p.box IS NOT NULL
              AND p.box.box_id = p_box_id;
    BEGIN
        FOR box_rec IN box_cursor
        LOOP
            DBMS_OUTPUT.PUT_LINE('Box ID: ' || box_rec.box_id);
            DBMS_OUTPUT.PUT_LINE('Species: ' || box_rec.species);
            DBMS_OUTPUT.PUT_LINE('Max Capacity: ' || box_rec.max_capacity);
            DBMS_OUTPUT.PUT_LINE('Current Capacity: ' || box_rec.current_capacity);
    
            -- Print information about pets inside the current box
            FOR pet_rec IN pet_cursor(box_rec.box_id)
            LOOP
                DBMS_OUTPUT.PUT_LINE('  Pet ID: ' || pet_rec.pet_id);
                DBMS_OUTPUT.PUT_LINE('  Name: ' || pet_rec.name);
                DBMS_OUTPUT.PUT_LINE('  Species: ' || pet_rec.species);
                DBMS_OUTPUT.PUT_LINE('  Breed: ' || pet_rec.breed);
                DBMS_OUTPUT.PUT_LINE('  Behaviour: ' || pet_rec.behaviour);
                DBMS_OUTPUT.PUT_LINE('---');
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('==================================');
        END LOOP;
    END printBoxesAndPets;
    
    FUNCTION getTransactions
    RETURN SYS_REFCURSOR
    IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT d.donation_id, d.donator_id, d.pet_id, d.value, d.donation_date,
                   dt.firstname AS donator_firstname, dt.lastname AS donator_lastname
            FROM donations d
            JOIN donators dt ON d.donator_id = dt.donator_id;
        
        RETURN v_cursor;
    END getTransactions;
    
    PROCEDURE printTransactions
    IS
        v_transaction_cursor SYS_REFCURSOR;
        v_donation_id NUMBER;
        v_donator_id NUMBER;
        v_pet_id NUMBER;
        v_value NUMBER;
        v_donation_date DATE;
        v_donator_firstname VARCHAR2(20);
        v_donator_lastname VARCHAR2(20);
    BEGIN
        v_transaction_cursor := getTransactions;
    
        -- Fetch and process the results
        LOOP
            FETCH v_transaction_cursor INTO v_donation_id, v_donator_id, v_pet_id, v_value, v_donation_date,
                                            v_donator_firstname, v_donator_lastname;
            EXIT WHEN v_transaction_cursor%NOTFOUND;
    
            -- Process the data as needed
            DBMS_OUTPUT.PUT_LINE('Donation ID: ' || v_donation_id || ', Donator: ' ||
                                 v_donator_firstname || ' ' || v_donator_lastname ||
                                 ', Pet ID: ' || v_pet_id || ', Value: ' || v_value ||
                                 ', Donation Date: ' || TO_CHAR(v_donation_date, 'YYYY-MM-DD HH24:MI:SS'));
        END LOOP;
    
        -- Close the cursor
        CLOSE v_transaction_cursor;
    END printTransactions;


end employee_package;
/

SET SERVEROUTPUT ON;


/* package demo */


--add employees
begin
    employee_package.addEmployee('jan','kowalski','warszawa','sprzatacz');
    employee_package.addEmployee('janusz','kowal','warsaw','recepcjonista');
end;


--view pets
DECLARE
    v_species VARCHAR2(20) := 'cat'; -- Replace with the desired species
BEGIN
    employee_package.getPets(v_species);
END;
/


--add Cat
DECLARE
    v_picture BLOB := NULL;
BEGIN

    employee_package.addPet(
        'Fluffy',   -- name
        'Cat',      -- species
        'Persian',  -- breed
        'Available', -- status
        'Good',     -- health
        'Friendly',  -- behaviour
        'A lovely cat looking for a home',  -- description
        v_picture
    );
    
    employee_package.getpets('Cat');
END;
/

--add aggressive dog
DECLARE
    v_picture BLOB := NULL;
BEGIN
    employee_package.addPet(
        'Baddy',    -- name
        'Dog',      -- species
        'Labrador', -- breed
        'Available', -- status
        'Good',     -- health
        'Aggressive',  -- behaviour
        'A strong and protective dog seeking a loving home',  -- description
        v_picture
    );
    
    employee_package.getpets('Dog');
END;
/


--add friendly dog
DECLARE
    v_picture BLOB := NULL;
BEGIN
    employee_package.addPet(
        'Buddy',    -- name
        'Dog',      -- species
        'Beagle', -- breed
        'Available', -- status
        'Good',     -- health
        'Friendly',  -- behaviour
        'A strong and protective dog seeking a loving home',  -- description
        v_picture
    );
    
    employee_package.getpets('Dog');
END;
/



--remove pet
declare
    pet_id NUMBER :=2;
begin
    employee_package.removepet(pet_id);
    employee_package.getpets('Dog');
end;

--view pets
begin
    employee_package.printboxesandpets;
end;


--duties
begin
    employee_package.getDuties(1);
end;


--print donation transactions
begin
    employee_package.printTransactions;
end;

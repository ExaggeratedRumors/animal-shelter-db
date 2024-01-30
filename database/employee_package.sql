/* API pracownika schroniska  */
/*---------------------------------------------------*/

create or replace package employee_package as
    /* Zarejestrowanie pracownika */
    procedure addEmployee(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        role in varchar2
    );
	
	/* Wypisanie listy zwierząt */
    procedure getPets(pet_species in varchar2);
	
	/* Pobranie ID boxa */
    FUNCTION getBoxId(spaceLeft IN NUMBER, box_species varchar2) RETURN NUMBER;
	
	/* Pobranie ID pustego Boxa */
    FUNCTION getEmptyBox(box_species varchar2) RETURN NUMBER;
	
	/* Pobranie dyżuru */
    FUNCTION getDuties(p_weekday IN NUMBER) RETURN SYS_REFCURSOR;
	
	/* Wyświetlenie dyżurów*/
    PROCEDURE printDuties(weekday NUMBER);
	
	/* Osadzenie zwierzęcia */
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
	
	/* Usunięcie zwierzęcia */
    PROCEDURE removePet(remove_pet_id IN NUMBER);
	
	/* Serwisowanie adopcji */
    PROCEDURE acceptAdoption(p_pet_id IN NUMBER);
	
	/* Wprowadzanie zwierzęcia do boxa */
	PROCEDURE putPetIntoBox(p_pet_id IN NUMBER);

	/* Wyświetlenie zwierząt oraz boxów */
    PROCEDURE printBoxesAndPets;
	
	/* Pobranie transakcji dotacji zwierzęcia */
    FUNCTION getTransactions RETURN SYS_REFCURSOR;
	
	/* Wyświetlenie transakcji dotacji zwierzęcia */
    PROCEDURE printTransactions;
	
	/* Zmiana statusu zwierzęcia */
    procedure changeStatus(p_pet_id NUMBER, p_new_status VARCHAR2);
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

    FUNCTION getDuties(p_weekday IN NUMBER) RETURN SYS_REFCURSOR AS
        v_duties_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_duties_cursor FOR
            SELECT d.duty_id,
                   DEREF(d.emp).firstname || ' ' || DEREF(d.emp).lastname AS employee_name,
                   DEREF(d.box).box_id,
                   d.start_hour,
                   d.end_hour,
                   d.responsibilities
              FROM duties d
             WHERE d.weekday = p_weekday;
    
        RETURN v_duties_cursor;
    END getDuties;
    
    
    PROCEDURE printDuties(weekday NUMBER) AS
        v_duties_cursor SYS_REFCURSOR;
        v_duty_id NUMBER;
        v_box_id NUMBER;
        v_employee_name VARCHAR2(50);
        v_start_hour NUMBER;
        v_end_hour NUMBER;
        v_responsibilities VARCHAR2(50);
    BEGIN
        v_duties_cursor := getDuties(weekday);
    
        LOOP
            FETCH v_duties_cursor INTO v_duty_id, v_employee_name, v_box_id, v_start_hour, v_end_hour, v_responsibilities;
            EXIT WHEN v_duties_cursor%NOTFOUND;
    
            DBMS_OUTPUT.PUT_LINE('Duty ID: ' || v_duty_id);
            DBMS_OUTPUT.PUT_LINE('Employee: ' || v_employee_name);
            DBMS_OUTPUT.PUT_LINE('Box ID: ' || v_box_id);
            DBMS_OUTPUT.PUT_LINE('Start Hour: ' || v_start_hour);
            DBMS_OUTPUT.PUT_LINE('End Hour: ' || v_end_hour);
            DBMS_OUTPUT.PUT_LINE('Responsibilities: ' || v_responsibilities);
            DBMS_OUTPUT.PUT_LINE('------------------------');
        END LOOP;
    
        CLOSE v_duties_cursor;
    END printDuties;


    
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
        v_pet_id NUMBER := seq_pets.NEXTVAL;
    BEGIN
        
        commit;
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
            picture
        ) VALUES (
            v_pet_id,
            name,
            species,
            breed,
            status,
            SYSDATE,
            0,
            health,
            behaviour,
            description,
            picture
        );
        putpetintobox(v_pet_id);
            
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('No box with available space found.');
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
        
		
	PROCEDURE acceptAdoption(p_pet_id IN NUMBER) IS
            v_box_id NUMBER;
        BEGIN
            -- Find the box_id associated with the given pet_id
            SELECT DEREF(p.box).box_id INTO v_box_id
            FROM pets p
            WHERE p.pet_id = p_pet_id;
            
            UPDATE boxes SET current_capacity = current_capacity - 1 WHERE box_id = v_box_id;
        
            UPDATE pets p set box = NULL WHERE p.pet_id = p_pet_id;
	        UPDATE pets p SET status = 'Adopted' WHERE p.pet_id = p_pet_id;

            DBMS_OUTPUT.PUT_LINE('Pet with ID ' || p_pet_id || ' removed successfully.');
           
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Pet with ID ' || p_pet_id || ' not found.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred while removing the pet with ID ' || p_pet_id || ': ' || SQLERRM);
        END acceptAdoption;


	PROCEDURE putPetIntoBox(p_pet_id IN NUMBER) IS
            v_box_id NUMBER;
			v_species varchar2(50);
			v_box ref t_boxes;
            v_behaviour varchar2(50);
            NoBoxLeft EXCEPTION;
        BEGIN   
			SELECT p.species INTO v_species FROM PETS p WHERE p.pet_id = p_pet_id;
            SELECT p.behaviour INTO v_behaviour FROM PETS p WHERE p.pet_id = p_pet_id; 
            
            -- Check if the behavior is "Aggressive"
            IF UPPER(v_behaviour) = 'AGGRESSIVE' THEN
                v_box_id := getEmptyBox(v_species); -- Get a box with available space based on species
            ELSE
                v_box_id := getBoxId(1, v_species); -- Get a valid box based on the default criteria
            END IF;
            if v_box_id is NULL THEN
                rollback;
                raise NoBoxLeft;
            end if;
                 
            SELECT REF(b) INTO v_box FROM boxes b WHERE b.box_id = v_box_id;
        
			UPDATE pets p SET box = v_box WHERE p.pet_id = p_pet_id;
            
			UPDATE pets p SET status = 'Available' WHERE p.pet_id = p_pet_id;
		

            UPDATE boxes SET current_capacity = current_capacity + 1 WHERE box_id = v_box_id;
            DBMS_OUTPUT.PUT_LINE('Added pet #'|| p_pet_id ||' into box #' || v_box_id || '.');
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Pet with ID ' || p_pet_id || ' not found.');
            WHEN NoBoxLeft THEN
                DBMS_OUTPUT.PUT_LINE('No box with enough space found.');
        END putPetIntoBox;

        
    PROCEDURE printBoxesAndPets IS
        CURSOR box_cursor IS
            SELECT b.box_id, b.species, b.max_capacity, b.current_capacity
            FROM boxes b;
    
        CURSOR pet_cursor (p_box_id NUMBER) IS
            SELECT p.pet_id, p.name, p.species, p.breed, p.behaviour, p.donation_status
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
                DBMS_OUTPUT.PUT_LINE('  Donation status: ' || pet_rec.donation_status || 'PLN');
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
            SELECT d.donation_id,
                   DEREF(d.donator).firstname AS donator_firstname,
                   DEREF(d.donator).lastname AS donator_lastname,
                   DEREF(d.pet).pet_id AS pet_id,
                   d.value,
                   d.donation_date
            FROM donations d;
        
        RETURN v_cursor;
    END getTransactions;
    
    PROCEDURE printTransactions
    IS
        v_transaction_cursor SYS_REFCURSOR;
        v_donation_id NUMBER;
        v_donator_firstname VARCHAR2(20);
        v_donator_lastname VARCHAR2(20);
        v_pet_id NUMBER;
        v_value NUMBER;
        v_donation_date DATE;
    BEGIN
        v_transaction_cursor := getTransactions;
    
        -- Fetch and process the results
        LOOP
            FETCH v_transaction_cursor INTO v_donation_id, v_donator_firstname, v_donator_lastname, v_pet_id, v_value, v_donation_date;
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
    
    
    procedure changeStatus(p_pet_id NUMBER, p_new_status VARCHAR2) AS
    BEGIN
        UPDATE pets
        SET status = p_new_status
        WHERE pet_id = p_pet_id;
    
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Pet status updated successfully.');
        
        if p_new_status = 'Deceased' then
            removePet(p_pet_id);
        end if;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Pet not found.');
    end changeStatus;


end employee_package;
/


/* Test API */
/*---------------------------------------------------*/

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

--add aggressive caat
DECLARE
    v_picture BLOB := NULL;
BEGIN
    employee_package.addPet(
        'Baddy',    -- name
        'Cat',      -- species
        'Alley', -- breed
        'Available', -- status
        'Good',     -- health
        'Aggressive',  -- behaviour
        'A strong and protective dog seeking a loving home',  -- description
        v_picture
    );
    
    employee_package.getpets('Cat');
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

--change pet status
declare
    new_status varchar2(20) := 'Deceased';
    pet_id NUMBER :=2;
begin
    employee_package.changeStatus(pet_id, new_status);
end;

--view pets
begin
    employee_package.printboxesandpets;
end;


--duties
begin
    employee_package.printDuties(1);
end;


--print donation transactions
begin
    employee_package.printTransactions;
end;

begin
    employee_package.acceptAdoption(1);
end;

select * from pets



CREATE OR REPLACE 
PACKAGE DONATOR AS 


    procedure addDonator(firstname varchar2, lastname varchar2, address varchar2);
    
    procedure donate(p_donator_id in number, p_amount in number, p_pet_id in number);
    
END DONATOR;
/


CREATE OR REPLACE
PACKAGE BODY DONATOR AS

    procedure addDonator(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2
    ) as 
    begin
        insert into donators o values (
            seq_donators.nextval,
            firstname,
            lastname,
            address,
            0
        );
        commit;
    end addDonator;


    PROCEDURE donate(
        p_donator_id IN NUMBER,
        p_amount IN NUMBER,
        p_pet_id IN NUMBER
    ) IS
        -- Declare variables to store references
        v_donator_ref REF t_donators;
        v_pet_ref REF t_pets;
        v_pet_status VARCHAR2(30);
        PetNotAvailableException EXCEPTION;
    BEGIN
        -- Find references for the given IDs
        SELECT REF(d), REF(p), p.status
        INTO v_donator_ref, v_pet_ref, v_pet_status
        FROM donators d, pets p
        WHERE d.donator_id = p_donator_id
          AND p.pet_id = p_pet_id;
          
        IF LOWER(v_pet_status) <> 'available' THEN
            raise PetNotAvailableException;
        END IF;

        INSERT INTO donations (
            donation_id,
            donator,
            pet,
            value,
            donation_date
        ) VALUES (
            seq_donations.NEXTVAL,
            v_donator_ref,
            v_pet_ref,
            p_amount,
            SYSDATE
        );

        UPDATE donators
        SET total_donations = total_donations + 1
        WHERE donator_id = p_donator_id;

        UPDATE pets
        SET donation_status = donation_status + p_amount
        WHERE pet_id = p_pet_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Donation added. Donator ID: ' || p_donator_id || ', Amount: ' || p_amount);
        EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Pet not found!');
    WHEN PetNotAvailableException THEN
        DBMS_OUTPUT.PUT_LINE('This pet cannot take donations.');
    END donate;

END DONATOR;
/

begin
    donator.addDonator('jaroslav','kaczynski','polska');
    donator.addDonator('donald','tusk','niemcy');
end;

begin
    donator.donate(1,4,6);
end;

select * from donations; --TODO
select * from donators;

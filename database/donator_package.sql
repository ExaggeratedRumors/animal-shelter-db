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
    BEGIN
        -- Find references for the given IDs
        SELECT REF(d), REF(p)
        INTO v_donator_ref, v_pet_ref
        FROM donators d, pets p
        WHERE d.donator_id = p_donator_id
          AND p.pet_id = p_pet_id;

        -- Insert a new donation into the 'donations' table
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

        -- Update total_donations in donators
        UPDATE donators
        SET total_donations = total_donations + 1
        WHERE donator_id = p_donator_id;

        -- Update donation_status in pets
        UPDATE pets
        SET donation_status = donation_status + p_amount
        WHERE pet_id = p_pet_id;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Donation added. Donator ID: ' || p_donator_id || ', Amount: ' || p_amount);
    END donate;

END DONATOR;
/

begin
    donator.addDonator('jaroslav','kaczynski','polska');
    donator.addDonator('donald','tusk','niemcy');
end;

begin
    donator.donate(1,4,1);
end;

select * from donations; --TODO
select * from donators;

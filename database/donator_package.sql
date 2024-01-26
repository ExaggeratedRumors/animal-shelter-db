CREATE OR REPLACE 
PACKAGE DONATOR AS 


    procedure addDonator(
        firstname varchar2,
        lastname varchar2,
        address varchar2
    );
    
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
    BEGIN
        -- Insert a new donation into the 'donations' table
        INSERT INTO donations (
            donation_id,
            donator_id,
            pet_id,
            value,
            donation_date
        ) VALUES (
            seq_donations.NEXTVAL,
            p_donator_id,
            p_pet_id,
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
    END donate;

END DONATOR;
/

begin
    donator.addDonator('jaroslav','kaczynski','polska');
end;

begin
    donator.donate(2,3,1);
end;
select * from donations

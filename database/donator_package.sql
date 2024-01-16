CREATE OR REPLACE 
PACKAGE DONATOR AS 


    procedure addDonator(
        firstname varchar2,
        lastname varchar2,
        address varchar2
    );
    
    /* wykonanie dotacji na wybrane zwierze */
    procedure donate(donator_id in number, amount in number, pet_id in number);
    
    /* wyswietl zwierzeta */
    procedure showPets(species in varchar2);  
    
    
    

END DONATOR;
/


CREATE OR REPLACE
PACKAGE BODY DONATOR AS

    procedure addDonator(
        firstname varchar2,
        lastname varchar2,
        address varchar2
    )as begin
        /* id jest zawsze 0 tymczasowo */
        insert into donators select 0, firstname, lastname, address, 0;
    
    end addDonator;


    procedure donate(donator_id in number, amount in number, pet_id in number) as begin
        /* id jest zawsze 0 tymczasowo */
        insert into donations select 0, pet_id, amount, SYSDATE;
        /* znajdz zwierze o pet_id i dodaj kwote */
    
    end donate;
    
    procedure showPets(species in varchar2) as
        cursor pet_cursor is select name, species, breed, joined_at, picture, donation_status, behaviour, health, description from pets;
    begin
        /* wyswietl zwierzeta */
    end showPets;
    

END DONATOR;
/
create or replace package owner_package as
    /* Wyœwietlenie zwierz¹t o okreœlonym gatunku */
    procedure addOwner(
        firstname in varchar2(20),
        lastname in varchar2(20),
        address in varchar2(50),
        adoptions in number
    );
    procedure getPets(species in varchar2(20));
    procedure adoptPet(pet_id in number);    
end owner;
/


create or replace package body owner_package as
    procedure addOwner(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        adoptions in number
    ) as 
        testy number;
    begin
        --insert into owners o values (1, firstname, lastname, address, adoptions, sysdate);
    end addOwner;
    procedure getPets(species in varchar2);
    procedure adoptPet(pet_id in number);    
end owner;
    
    
/* API darczyñcy œrodków dla zwierzêcia  */
/*---------------------------------------------------*/

create or replace 
package donator_package as 
    /* Zarejestrowanie darczyñcy */
    procedure addDonator(p_firstname varchar2, p_lastname varchar2, p_address varchar2);
    
    /* Uiszczenie dotacji */
    procedure donate(p_donator_id in number, p_amount in number, p_pet_id in number);
    
    /* Wyœwietlanie listy dotacji */
    procedure printDonations(p_donator_id in number);  
    
    /* Pobieranie listy dotacji */
    function getDonations(p_donator_id in number) return sys_refcursor;  
	
	/* Wyœwietlanie listy zwierz¹t o okreœlonym gatunku */
    procedure printPets(a_species in varchar2 default null);
    
    /* Pobieranie listy zwierz¹t o okreœlonym gatunku */
    function getPets(v_species in varchar2 default null) return sys_refcursor;
    
    /* Wyj¹tki */
    donatorAlreadyExists exception;
    incorrectDonationValue exception;
    petNotFound exception;
    petNotAvailable exception;
end donator_package;
/


create or replace package body donator_package as
    procedure adDdonator(
        p_firstname in varchar2,
        p_lastname in varchar2,
        p_address in varchar2
  ) as 
        v_donators number;
    begin
            v_donators := 0;
            select count(*) into v_donators
            from owners
            where firstname = p_firstname and lastname = p_lastname and address = p_address;
    
            if v_donators > 0 then
                raise donatorAlreadyExists;
            end if;
            
            insert into donators o values (
                seq_donators.nextval,
                p_firstname,
                p_lastname,
                p_address,
                0
            );
            commit;

        exception
        when donatorAlreadyExists then
                dbms_output.put_line('Donator already exists.');
    end addDonator;


    procedure donate(
        p_donator_id in number,
        p_amount in number,
        p_pet_id in number
    ) is
        v_donator_ref ref t_donators;
        v_pet_ref ref t_pets;
        v_pet_status varchar2(30);
    begin
            if p_amount < 1 then
                raise incorrectDonationValue;
            end if;
            
            select ref(d), ref(p), p.status
            into v_donator_ref, v_pet_ref, v_pet_status
            from donators d, pets p
            where d.donator_id = p_donator_id and p.pet_id = p_pet_id;
              
            if lower(v_pet_status) <> lower('Available') then
                raise petNotAvailable;
            end if;
    
            insert into donations (
                donation_id,
                donator,
                pet,
                value,
                donation_date
            ) values (
                seq_donators.nextval,
                v_donator_ref,
                v_pet_ref,
                p_amount,
                sysdate
            );
    
            update donators
            set total_donations = total_donations + 1
            where donator_id = p_donator_id;
    
            update pets
            set donation_status = donation_status + p_amount
            where pet_id = p_pet_id;
    
            commit;
            dbms_output.put_line('Donation added. Donator ID: ' || p_donator_id || ', amount: ' || p_amount);
        exception
            when no_data_found then
                dbms_output.put_line('Pet or donator not found.');
            when incorrectDonationValue then
                dbms_output.put_line('Donation amount cannot be lower than 1.');
            when petNotAvailable then
                dbms_output.put_line('This pet cannot take donations.');
    end donate;
    
    
    procedure printDonations(
        p_donator_id in number
    ) as
        donator_cursor sys_refcursor;
        v_donation_id number;
        v_donator_id number;
        v_firstname varchar2(30);
        v_lastname varchar2(30);
        v_pet_id number;
        v_pet_name varchar2(30);
        v_species varchar2(30);
        v_donation_status number;
        v_value number;
        v_donation_date date;
    begin
        donator_cursor := donator_package.getDonations(p_donator_id);
        loop
            fetch donator_cursor into v_donation_id, v_donator_id, v_firstname, 
                    v_lastname, v_pet_id, v_pet_name, v_species, v_donation_status,
                    v_value, v_donation_date;
            exit when donator_cursor%notfound;
            dbms_output.put_line(   'Donation ID: ' || v_donation_id
                                || ', Donator ID: ' || v_donator_id
                                || ', Pet ID: ' || v_pet_id
                                || ', Value: ' || v_value
                                || ', Donation status: ' || v_donation_status
                                );
        end loop;
        close donator_cursor;
    end printDonations;
    
    
    function getDonations(
        p_donator_id in number
    ) return sys_refcursor is
        v_cursor sys_refcursor;
    begin
        open v_cursor for 
            select  d.donation_id,
                    deref(d.donator).donator_id,
                    deref(d.donator).firstname,
                    deref(d.donator).lastname,
                    deref(d.pet).pet_id,
                    deref(d.pet).name,
                    deref(d.pet).species,
                    deref(d.pet).donation_status,
                    value,
                    donation_date
            from donations d
            where deref(d.donator).donator_id = p_donator_id;
        return v_cursor;
    end getDonations;
	
	
	procedure printPets(
        a_species in varchar2 default null
    ) as
        pet_cursor sys_refcursor;
        v_id number;
        v_name varchar2(100);
        v_breed varchar2(100);
        v_species varchar(100);
        v_status varchar2(100);
        v_joined date;
        v_health varchar2(100);
        v_behaviour varchar2(100);
        v_description varchar2(100);
        v_picture blob;
    begin
        pet_cursor := owner_package.getPets(a_species);
        loop
            fetch pet_cursor into v_id, v_name, v_species, v_breed, v_status,
                                v_joined, v_health, v_behaviour, v_description,
                                v_picture;
            exit when pet_cursor%notfound;
            dbms_output.put_line(   'Pet ID: ' || v_id
                                || ', Name: ' || v_name
                                || ', Species: ' || v_species
                                || ', Status: ' || v_status
                                );
        end loop;
        close pet_cursor;
    end printPets;
    
    
    function getPets(
        v_species in varchar2 default null
    ) return sys_refcursor is
        v_cursor sys_refcursor;
    begin
        if v_species is null then
            open v_cursor for 
                select  pet_id,
                        name,
                        species,
                        breed,
                        status,
                        joined_at,
                        health,
                        behaviour,
                        description,
                        picture  
                from pets
                where status = 'Available' and left_at is null;
            return v_cursor;
        else
            open v_cursor for
                select  pet_id,
                        name,
                        species,
                        breed,
                        status,
                        joined_at,
                        health,
                        behaviour,
                        description,
                        picture  
                from pets
                where lower(species) = lower(v_species) 
                    and status = 'Available' 
                    and left_at is null;
            return v_cursor;
        end if;
    end getPets;
end donator_package;
/

    
/* Test API */
/*---------------------------------------------------*/
delete from donations;
delete from donators;
select * from donators;
select * from donations;
select * from pets;

/* Uzupe³nij darczyñców. */
begin
    donator_package.addDonator('jaroslav','kaczynski','polska');
    donator_package.addDonator('donald','tusk','niemcy');
end;

/* Uiœæ dotacjê. */
declare
    v_donator_id number := 1;
    v_pet_id number := 9;
    v_amount number := 100;
begin
    donator_package.donate(v_donator_id, v_amount, v_pet_id);
end;

/* Wypisz dotacje. */
declare
    v_donator_id number := 1;
begin
    donator_package.printDonations(v_donator_id);
end;


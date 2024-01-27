/* API w³aœciciela/adoptuj¹cego zwierzêcia  */
/*---------------------------------------------------*/

create or replace package owner_package as
    /* Zarejestrowanie w³aœciciela */
    procedure addOwner(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2
    );
    
    /* Wyœwietlanie listy zwierz¹t o okreœlonym gatunku */
    procedure printPets(a_species in varchar2 default null);
    
    /* Pobieranie listy zwierz¹t o okreœlonym gatunku */
    function getPets(v_species in varchar2 default null) return sys_refcursor;
    
    /* Wyœwietlanie listy adopcji */
    procedure printAdoptions(v_owner_id in number);  
    
    /* Pobieranie listy adopcji */
    function getAdoptions(v_owner_id in number) return k_adoptions pipelined;  

    /* Adopcja zwierzêcia */
    procedure adoptPet(v_owner_id in number, v_pet_id in number, v_result out varchar2);
    
    /* Usuniêcie adopcji i powiadomienie o œmierci zwierzêcia */
    procedure cancelAdoption(v_owner_id in number, v_pet_id in number, v_result out varchar2);

    /* Wyj¹tki */
    ownerNotFoundException exception;
    petNotAvailable exception;
    petNotFound exception;
    tooManyAdoptions exception;
    
end owner_package;
/


create or replace package body owner_package as
    procedure addOwner(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2
    ) as 
    begin
        insert into owners o values (
            seq_owners.nextval,
            firstname,
            lastname,
            address,
            k_adoptions(),
            sysdate
        );
        commit;
    end addOwner;
    
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
        
        
    procedure printAdoptions(
        v_owner_id in number
    ) as
        cursor c_adoptions is
            select adoption_id, deref(pet).pet_id as pet_id, adoption_date, descriptions
            from table(getAdoptions(v_owner_id));
        v_adoptions t_adoptions;
        v_pet ref t_pets;
    begin
        for rec in c_adoptions loop
            dbms_output.put_line('Adoption ID: ' || rec.adoption_id || 
                             ', Pet ID: ' || rec.pet_id ||
                             ', Adoption Date: ' || TO_CHAR(rec.adoption_date, 'YYYY-MM-DD') ||
                             ', Description: ' || rec.descriptions);
        end loop;
    end printAdoptions;
    
    function getAdoptions(
        v_owner_id in  number
    ) return k_adoptions pipelined is v_adoptions k_adoptions;
    begin
        select adoptions into v_adoptions
        from owners
        where owner_id = v_owner_id;
        
        for i in 1..v_adoptions.count loop
            pipe row (v_adoptions(i));
        end loop;
        
        return;
    end getAdoptions;
    

    procedure adoptPet(
        v_owner_id in number,
        v_pet_id in number,
        v_result out varchar2
    ) as
        cursor v_owner_cur(m number) is select count(*) as adoptions 
            from table(
                select adoptions
                from owners
                where owner_id = m
            );
        v_pet_ref ref t_pets;
        v_rows number := 0;
        v_owners number := 0;
        v_adoptions_amount number := 0;
        v_adoptions k_adoptions;
        v_status varchar(30);
    begin  
            /* Sprawdzanie czy w³aœciciel istnieje w bazie. */
            select count(*) into v_owners
            from owners where owner_id = v_owner_id;

            if v_owners < 1 then
                raise ownerNotFoundException;
            end if;
            
            /* Sprawdzanie czy liczba zaadoptowanych zwierz¹t jest mniejsza od 3. */
            open v_owner_cur(v_owner_id);
            loop
                fetch v_owner_cur into v_adoptions_amount;
                exit when v_owner_cur%notfound;
            end loop;
            if v_adoptions_amount > 3 then
                raise tooManyAdoptions;
            end if;
        

            /* Sprawdzanie czy zwierzê o podanym ID istnieje i czy jego status jest wolny. */
            select count(pet_id) into v_rows
            from pets where pet_id = v_pet_id;

            select ref(p), p.status into v_pet_ref, v_status
            from pets p where p.pet_id = v_pet_id;
            
            if v_rows = 0 then
                raise petNotFound;
            elsif v_status <> 'Available' then
                raise petNotAvailable;
            end if;
            
            /* Powiêkszanie listy adopcji o kolejne zwierzê. */
            insert into table(
                select adoptions
                from owners
                where owner_id = v_owner_id
            ) values (
                seq_adoptions.nextval,
                v_pet_ref,
                sysdate,
                'Successed.'
            );

            /* Ustawienie statusu zwierzêcia na zaadoptowane. */
            update pets
            set status = 'Adopted'
            where pet_id = v_pet_id;
            commit;
            
            v_result := 'Success.';
        exception
            when ownerNotFoundException then
                v_result := 'Owner does not exist.';
            when petNotAvailable then
                v_result := 'Pet is not available to adopt.';
            when petNotFound then
                v_result := 'Pet does not exist.';
            when tooManyAdoptions then
                v_result := 'Owner has too much adopted animals.';
            when others then
                v_result := 'Uknown error.';
                dbms_output.put_line(sqlerrm);
    end adoptPet;
    
    
    procedure cancelAdoption(
        v_owner_id in number,
        v_pet_id in number,
        v_result out varchar2
    ) as
    begin
        delete from table(select o.adoptions from owners o where o.owner_id = v_owner_id) a 
        where deref(a.pet).pet_id = v_pet_id;
        
        v_result := 'Success.';
        commit;
    exception
        when no_data_found then
            v_result := 'Data not found';
        when others then
            v_result := 'Unknow error.';
            dbms_output.put_line(sqlerrm);
    end cancelAdoption;
end owner_package;
/
    
    
/* Test API */
/*---------------------------------------------------*/

delete from owners;
/


/* Uzupe³nij w³aœcicieli. */
begin
    owner_package.addOwner('Adi', 'Cherryson', 'Argoland 12/41');
    owner_package.addOwner('Karl', 'Pron', 'Argoland 41/65');
    owner_package.addOwner('Alicja', 'Lifter', 'Argoland 11/11');
    owner_package.addOwner('Rinah', 'Devi', 'Tartar 54/76');
    owner_package.addOwner('Zinia', 'Vett', 'Paradyzja 6/7');
end;
/

/* Wypisz zwierzêta. */
begin
    owner_package.printPets('Cat');
end;
/

select * from owners;

/* Zaadoptuj zwierzê. */
declare
    result varchar2(200);
    owner_id number := 1;
    pet_id1 number := 1;
    pet_id2 number := 2;
begin
    owner_package.adoptPet(owner_id, pet_id1, result);
    owner_package.adoptPet(owner_id, pet_id2, result);
    dbms_output.put_line('OPERATION RESULT: ' || result);
end;
/

/* Wypisz adopcje. */
begin
    owner_package.printAdoptions(1);
end;
/

/* Usuñ adopcjê. */
declare
    result varchar2(200);
    owner_id number := 1;
    pet_id number := 1;
begin
    owner_package.cancelAdoption(owner_id, pet_id, result);
    dbms_output.put_line('OPERATION RESULT: ' || result);
end;
/



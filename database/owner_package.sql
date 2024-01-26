/* API w³aœciciela/adoptuj¹cego zwierzêcia  */
/*---------------------------------------------------*/

create or replace package owner_package as
    /* Zarejestrowanie w³aœciciela */
    procedure addOwner(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        adoptions in k_adoptions
    );
    
    /* Wyœwietlanie listy zwierz¹t o okreœlonym gatunku */
    procedure printPets(a_species in varchar2 default null);
    
    /* Pobieranie listy zwierz¹t o okreœlonym gatunku */
    function getPets(v_species in varchar2 default null) return sys_refcursor;
    
    /* Adopcja zwierzêcia */
    procedure adoptPet(v_owner_id in number, v_pet_id in number, v_result out varchar2);
end owner_package;
/


create or replace package body owner_package as
    procedure addOwner(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        adoptions in k_adoptions
    ) as 
    begin
        insert into owners o values (
            seq_owners.nextval,
            firstname,
            lastname,
            address,
            adoptions,
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
            exit when pet_cursor%notfound;
            fetch pet_cursor into v_id, v_name, v_species, v_breed, v_status,
                                v_joined, v_health, v_behaviour, v_description,
                                v_picture;
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
        cursor v_pets_cur(n number) is select ref(p) 
            from pets p
            where n = p.pet_id;
        v_pet_ref ref t_pets;
        v_rows number := 0;
        v_adoptions number := 0;
    begin
            open v_owner_cur(v_owner_id);
            loop
                fetch v_owner_cur into v_adoptions;
                exit when v_owner_cur%notfound;
            end loop;
            if v_adoptions > 3 then
                v_result := 'ERROR: Owner has too much adopted pets.';
                return;
            end if;
        
            open v_pets_cur(v_pet_id);
            loop
                fetch v_pets_cur into v_pet_ref;
                exit when v_pets_cur%notfound;
                v_rows := v_rows + 1;
            end loop;
            close v_pets_cur;
            
            if v_rows = 0 then
                v_result := 'ERROR: Pet does not exist.';
                return;
            elsif v_rows > 1 then
                v_result := 'ERROR: Database is incorrect - many pets with selected ID.';
                return;
            end if;
            
            update pets
            set status = 'Adopted'
            where pet_id = v_pet_id;
            v_result := 'Success.';
            
            insert into adoptions
            values (seq_adoptions.nextval, v_pet_ref, sysdate, 'Successed.');
            commit;
        
        exception
            when no_data_found then
                v_result := 'ERROR: No data.';
            when others then
                v_result := 'ERROR: Uknown.';
    end adoptPet;
    
end owner_package;
/
    
    
/* Test API */
/*---------------------------------------------------*/

delete from owners;
/


/* Uzupe³nij w³aœcicieli */
begin
    owner_package.addOwner('Adi', 'Cherryson', 'Argoland 12/41', null);
    owner_package.addOwner('Karl', 'Pron', 'Argoland 41/65', null);
    owner_package.addOwner('Alicja', 'Lifter', 'Argoland 11/11', null);
    owner_package.addOwner('Rinah', 'Devi', 'Tartar 54/76', null);
    owner_package.addOwner('Zinia', 'Vett', 'Paradyzja 6/7', null);
end;
/

/* Wypisz zwierzêta */
begin
    owner_package.printPets('Cat');
end;


/* Zaadoptuj zwierzêta. */
declare
    result varchar2(200);
begin
    owner_package.adoptPet(seq_owners.currval, seq_pets.currval, result);
end;
select * from adoptions;

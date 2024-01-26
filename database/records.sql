SET SERVEROUTPUT ON;

/* Wprowadzanie rekordów */
declare
    v_picture BLOB := NULL;
begin
    admin_package.addBox(10, 'Cat');
    admin_package.addBox(10, 'Dog');
    admin_package.addBox(10, 'Dog');
    
    employee_package.addEmployee('Jan','Kowalski','adres1','sprzatacz');
    employee_package.addEmployee('Janusz','Kowal','adres2','recepcjonista');
    
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
    admin_package.addDuty(1,1,1,8,16, 'Feeding');
    admin_package.addDuty(1,1,2,8,16, 'Feeding');
    admin_package.addDuty(1,1,3,8,16, 'Feeding');
    admin_package.addDuty(1,1,4,8,16, 'Feeding');
    admin_package.addDuty(1,1,5,8,16, 'Feeding');
    
    admin_package.addDuty(2,1,6,8,16, 'Feeding');
    admin_package.addDuty(2,1,7,8,16, 'Feeding');
    
    donator.addDonator('jaroslav', 'kaczynski', 'polska');
    donator.addDonator('donald', 'tusk', 'niemcy');
    
    donator.donate(1,4,1);
    donator.donate(2,6,2);
    
    
    employee_package.printboxesandpets;
    employee_package.printTransactions;
end;

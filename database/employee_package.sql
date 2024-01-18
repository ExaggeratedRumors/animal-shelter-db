create or replace package employee_package as
    /* Wyœwietlenie zwierz¹t o okreœlonym gatunku */
    procedure addEmployee(
        firstname in varchar2(20),
        lastname in varchar2(20),
        address in varchar2(50),
        role in varchar2(50)
    );
    procedure getPets(species in varchar2(20));
    procedure getDuties(weekday in number);     
end employee;
/


create or replace package body employee_package as
    procedure addEmployee(
        firstname in varchar2,
        lastname in varchar2,
        address in varchar2,
        role in number
    ) as 
 
    begin
        --insert into employees o values (1, firstname, lastname, NULL, SYSDATE, NULL, role);
    end addEmployee;
    procedure getPets(species in varchar2);
    procedure getDuties(weekday in number);    
end employee_package;
    
    
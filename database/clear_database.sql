/* Usuwanie tabel wymaga �cis�ej kolejno�ci. */
/*---------------------------------------------------*/

drop package owner_package;
drop package employee_package;
drop package donator_package;

drop table adoptions;
drop table donations;
drop table duties;
drop table owners;
drop table donators;
drop table boxes;
drop table pets;
drop table employees;

drop type t_adoptions;
drop type t_donations;
drop type t_duties;
drop type t_owners;
drop type t_donators;
drop type t_boxes;
drop type t_pets;
drop type t_employees;
drop type k_adoptions;

drop sequence seq_pets;
drop sequence seq_employees;
drop sequence seq_boxes;
drop sequence seq_donators;
drop sequence seq_owners;
drop sequence seq_adoptions;

delete from pets;
delete from boxes;

/* Sprawdzanie czy na pewno nie pozosta�y zale�no�ci danego typu. */
/*---------------------------------------------------*/
select *
from user_dependencies
where referenced_name = 'T_BOXES';

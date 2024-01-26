/* Usuwanie tabel wymaga œcis³ej kolejnoœci. */
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

DROP SEQUENCE seq_pets;
DROP SEQUENCE seq_employees;
DROP SEQUENCE seq_boxes;
DROP SEQUENCE seq_donators;
DROP SEQUENCE seq_owners;
DROP SEQUENCE seq_adoptions;

DELETE FROM pets;
DELETE FROM boxes;


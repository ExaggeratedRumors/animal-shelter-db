/* Usuwanie tabel wymaga �cis�ej kolejno�ci. */
/*---------------------------------------------------*/

drop table adoptions;
drop table donations;
drop table duties;
drop table owners;
drop table donators;
drop table boxes;
drop table pets;
drop table employees;

DROP SEQUENCE seq_pets;
DROP SEQUENCE seq_employees;
DROP SEQUENCE seq_boxes;
DROP SEQUENCE seq_donators;
DROP SEQUENCE seq_owners;
DROP SEQUENCE seq_adoptions;
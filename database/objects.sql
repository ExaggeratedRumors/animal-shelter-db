create or replace type t_pets as object (
    pet_id number,
    name varchar2(20),
    species varchar2(20),
    breed varchar2(30),
    status varchar2(30),
    joined_at date,
    left_at date,
    donation_status number,
    health varchar2(30),
    behaviour varchar2(100),
    description varchar2(100),
    picture blob,
    box ref t_boxes
);
/


create or replace type t_adoptions as object (
    adoption_id number,
    pet ref t_pets,
    adoption_date date,
    descriptions varchar2(100)
);
/

create or replace type k_adoptions as table of t_adoptions;
/

create or replace type t_owners as object (
    owner_id number,
    firstname varchar2(20),
    lastname varchar2(20),
    address varchar2(50),
    adoptions k_adoptions,
    created_at date
);
/

create or replace type t_employees as object (
    emp_id number,
    firstname varchar2(20),
    lastname varchar2(20),
    address varchar2(50),
    salary number,
    joined_at date,
    left_at date,
    role varchar2(20)
);
/

create or replace type t_boxes as object (
    box_id number,
    max_capacity number,
    current_capacity number,
    species varchar2(20)
);
/

create or replace type t_duties as object (
    emp_id number,
    box_id number,
    weekday number,
    start_hour number,
    end_hour number,
    responsibilities varchar2(100)
);
/


create or replace type t_donators as object (
    donator_id number,
    firstname varchar2(20),
    lastname varchar2(20),
    address varchar2(50),
    total_donations number
);
/

create or replace type t_donations as object (
    donator_id number,
    pet_id number,
    value number,
    donation_date date
);
/


/* Tworzenie tabeli na podstawie typów */
/*---------------------------------------------------*/

create table pets of t_pets (
    primary key (pet_id)
);
/

create table adoptions of t_adoptions (
    primary key (adoption_id)
);
/

create table owners of t_owners (
    primary key (owner_id)
) nested table adoptions store as s_adoptions;
/

create table employees of t_employees (
    primary key (emp_id)
);
/

create table boxes of t_boxes (
    primary key (box_id)
);
/

create table duties of t_duties (
    primary key (emp_id, box_id),
    foreign key(emp_id) references employees(emp_id) on delete cascade,
    foreign key(box_id) references boxes(box_id) on delete cascade
);
/

create table donators of t_donators (
    primary key (donator_id)
);
/

create table donations of t_donations (
    primary key (donator_id, pet_id),
    foreign key(donator_id) references donators(donator_id) on delete cascade,
    foreign key(pet_id) references pets(pet_id) on delete cascade
);
/


/* Tworzenie sekwencji */
/*---------------------------------------------------*/

create sequence seq_pets minvalue 1 start with 1;/
create sequence seq_adoptions minvalue 1 start with 1;/
create sequence seq_owners minvalue 1 start with 1;/
create sequence seq_employees minvalue 1 start with 1;/
create sequence seq_boxes minvalue 1 start with 1;/
create sequence seq_donators minvalue 1 start with 1;/


<<<<<<< HEAD
/* Wprowadzanie rekordów */
/*---------------------------------------------------*/

insert into pets
values (1, 'testpet', 'dog', 'german shepherd', 'in shelter', null, null, 
        0, 'healthy', 'aggresive', null, null);



insert into boxes
values (1, 25, 1, 'dogs', k_pets(
        t_pets(2, 'testpet2', 'dog', 'german shepherd', 'in shelter', null, null, 
        0, 'healthy', 'aggresive', null, null)
        )
    );
    
    
=======
>>>>>>> 709bbee14f8353a51347058b39ed33c23463b41f

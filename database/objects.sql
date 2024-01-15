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
    picture blob
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

create or replace type t_owners as object (
    owner_id number,
    firstname varchar2(20),
    lastname varchar2(20),
    address varchar2(50),
    adoptions number,
    created_at date
);
/

create or replace type t_donators as object (
    donator_id number,
    firstname varchar2(20),
    lastname varchar2(20),
    address varchar2(50),
    total_donations number
)

create or replace type t_boxes as object (
    box_id number,
    max_capacity number,
    current_capacity number,
    spiecies varchar2(20)
);
/

create or replace type t_duties as object (
    emp_id number,
    box_id number,
    weekday number,
    start_hour hour,
    end_hour hour,
    responsibilities varchar2(100)
)

create or replace type t_donations as object (
    donator_id number,
    pet_id number,
    value number,
    donation_date date
);
/

create or replace type r_adoptions as object (
    owner_id number,
    pet_id number,
    adoption_date date,
    descriptions varchar2(100)
);
/

/*---------------------------------------------------*/

create table pets of t_pets (
    primary key (pet_id)
);
/

create table employees of t_employees (
    primary key (emp_id)
);
/

create table owners of t_owners (
    primary key (owner_id)
);
/

create table donators of t_donators (
    primary key (donator_id)
);
/

create table boxes of t_boxes (
    primary key (box_id)
);
/

create table donations of t_donations;
/

create table adoptions of t_adoptions;
/

create table duties of t_duties;
/

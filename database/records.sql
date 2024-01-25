
/* Wprowadzanie rekordów */
/*---------------------------------------------------*/
/* dodawanie zwierz?t obsluguje Employee */

--add box
DECLARE
    v_box_id NUMBER;
BEGIN
    SELECT seq_boxes.NEXTVAL INTO v_box_id FROM dual;
    INSERT INTO 
    boxes (box_id, max_capacity, current_capacity, species) 
    VALUES (v_box_id, 10,  0,   'Cats');
END;
/


SELECT pet_id, name, species, breed, status, joined_at, donation_status, health, behaviour, description
FROM pets;

SELECT box_id, max_capacity, current_capacity, species
FROM boxes;


DELETE FROM pets;
DELETE FROM boxes;

DROP SEQUENCE seq_pets;
DROP SEQUENCE seq_employees;
DROP SEQUENCE seq_boxes;
DROP SEQUENCE seq_donators;
DROP SEQUENCE seq_owners;
DROP SEQUENCE seq_adoptions;

/* Wprowadzanie rekordów */
/*---------------------------------------------------*/
/* dodawanie zwierz?t obsluguje Employee */



DELETE FROM pets;
DELETE FROM boxes;


--add box
DECLARE
    v_box_id NUMBER;
BEGIN
    SELECT seq_boxes.NEXTVAL INTO v_box_id FROM dual;
    INSERT INTO 
    boxes (box_id, max_capacity, current_capacity, species) 
    VALUES (v_box_id, 10,  0,   'Cat');
END;
/

--add box
DECLARE
    v_box_id NUMBER;
BEGIN
    SELECT seq_boxes.NEXTVAL INTO v_box_id FROM dual;
    INSERT INTO 
    boxes (box_id, max_capacity, current_capacity, species) 
    VALUES (v_box_id, 22,  0,   'Dog');
END;
/




SELECT pet_id, name, species, breed, status, joined_at, donation_status, health, behaviour, description
FROM pets;

SELECT box_id, max_capacity, current_capacity, species
FROM boxes;

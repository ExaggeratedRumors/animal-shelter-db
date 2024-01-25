
/* Wprowadzanie rekordów */
/*---------------------------------------------------*/



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



--add pet
DECLARE
    v_pet_id NUMBER;
    v_box_id NUMBER := 1;
BEGIN

    SELECT seq_pets.NEXTVAL INTO v_pet_id FROM dual;
    INSERT INTO pets ( pet_id,name,species,breed,status,joined_at,donation_status,health,behaviour,description,picture,box)
    VALUES (
        v_pet_id, --pet_id
        'Fluffy', --name
        'Cat', --species
        'Persian', --breed
        'Available', --status
        SYSDATE, --joinedat
        0, --donation
        'Good', --health
        'Friendly and playful', --behaviour
        'A lovely cat looking for a home', --description
        EMPTY_BLOB(), --picture
        (SELECT REF(b) FROM boxes b WHERE b.box_id = v_box_id)  -- box_id
    );
END;
/

SELECT pet_id, name, species, breed, status, joined_at, donation_status, health, behaviour, description
FROM pets;


SELECT box_id, max_capacity, current_capacity, species
FROM boxes;

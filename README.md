# animal-shelter-db

![](https://shields.io/badge/JDK-11.0.18-coral) ![](https://shields.io/badge/version-v1.0-aqua)  ![](https://shields.io/badge/PLSQL-red)

Objective data base project of animal shelter.

## Requirements

- JDK 11.0.18
- Oracle 19c

## Relation Diagram

<p align="center">
    <img src="images/relations-diagram.png" width="800"/> 
</p>


## Execution sequence

1. Run `clear_database.sql` to remove named objects.
2. Run `objects.sql` to create types, tables and sequences.
3. Run packets in any order.

## Packets

- `admin_package` - API for system admin.
- `employee_package` - API for shelter employee.
- `donator_package` - API for donators.
- `owner_package` - API for pets owners and adopters.
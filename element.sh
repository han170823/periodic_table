#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  element_data=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
  FROM elements 
  INNER JOIN properties USING(atomic_number) 
  INNER JOIN types USING(type_id)
  WHERE atomic_number = $1")
else
  element_data=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
  FROM elements 
  INNER JOIN properties USING(atomic_number) 
  INNER JOIN types USING(type_id)
  WHERE symbol = '$1' OR name = '$1'")
fi

if [[ -z $element_data ]]
then
  echo "I could not find that element in the database."
  exit
fi

IFS="|" read atomic_number element_name element_symbol element_type atomic_mass melt_point boil_point <<< "$element_data"

echo "The element with atomic number $atomic_number is $element_name ($element_symbol). It's a $element_type, with a mass of $atomic_mass amu. $element_name has a melting point of $melt_point celsius and a boiling point of $boil_point celsius."

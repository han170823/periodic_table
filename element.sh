#!/bin/bash

# PostgreSQL command shortcut (quiet output, pipe-delimited)
DB_CMD="psql -U freecodecamp -d periodic_table -t -A -c"

# Ensure an argument is passed to the script
if [[ $# -eq 0 ]]; then
  echo "You must supply an element name, symbol, or atomic number."
  exit 1
fi

INPUT="$1"

# Decide query based on whether input is numeric
if [[ "$INPUT" =~ ^[0-9]+$ ]]; then
  QUERY_RESULT=$($DB_CMD "
    SELECT e.atomic_number,
           e.name,
           e.symbol,
           t.type,
           p.atomic_mass,
           p.melting_point_celsius,
           p.boiling_point_celsius
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.atomic_number = $INPUT;
  ")
else
  QUERY_RESULT=$($DB_CMD "
    SELECT e.atomic_number,
           e.name,
           e.symbol,
           t.type,
           p.atomic_mass,
           p.melting_point_celsius,
           p.boiling_point_celsius
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.symbol = '$INPUT'
       OR e.name = '$INPUT';
  ")
fi

# Handle case where no matching element is found
if [[ -z "$QUERY_RESULT" ]]; then
  echo "Element not found in the periodic table database."
  exit 1
fi

# Break the query output into individual variables
IFS="|" read -r NUM NAME SYMBOL CATEGORY WEIGHT MELTING BOILING <<< "$QUERY_RESULT"

# Display formatted element information
echo "Element #$NUM is $NAME ($SYMBOL)."
echo "Category: $CATEGORY"
echo "Atomic mass: $WEIGHT amu"
echo "Melting point: $MELTING °C"
echo "Boiling point: $BOILING °C"

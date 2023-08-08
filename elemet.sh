#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    #        2. Get atomic_number from symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol ILIKE '$1'")
    # if not found
    if [[ -z $ATOMIC_NUMBER ]]
    then
      #     3. Get atomic_number from name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name ILIKE '$1'")
    fi
  else
    # get name
    ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1")
    # if not found
    if [[ ! -z $ELEMENT_NAME ]]
    then
      ATOMIC_NUMBER=$1
    fi
  fi

  if [[ ! -z $ATOMIC_NUMBER ]]
  then
    # get type with atomic_number
    TYPE=$($PSQL "SELECT type FROM types RIGHT JOIN properties USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    # get infos from properties join elements
    INFOS=$($PSQL "SELECT * FROM properties LEFT JOIN elements USING(atomic_number) WHERE atomic_number = $ATOMIC_NUMBER")
    # print result following request
    echo "$INFOS" | while IFS='|' read NUMBER MASS MELTING BOILING TYPE_ID SYMBOL NAME
    do
      echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  else
    echo "I could not find that element in the database."
  fi
fi
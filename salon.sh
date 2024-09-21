#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to My Salon, how can I help you?"
  #Get Menu Services
  MENU_SERVICES=$($PSQL "SELECT * FROM services")
  #Display Menu
  echo "$MENU_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  #If a number is not inserted
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #Send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    #Get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    #Check phone number
    CHECK_CUSTOMER_PHONE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CHECK_CUSTOMER_PHONE ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      #Insert new customer
      read CUSTOMER_NAME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      if [[ $NEW_CUSTOMER == "INSERT 0 1" ]]
      then
        echo "Inserted into customers, $CUSTOMER_NAME"
      fi
      #Get customer id and service name
      GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      #Get time for a new appointment
      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      #Insert new appointment
      NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $GET_CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi

  fi
}

MAIN_MENU
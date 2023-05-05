#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "~~ One Dragon Salon ~~"
#display services
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHow can we help you today?\n\nWe offer:"
  SERVICES=$($PSQL "SELECT * FROM services") 
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done 

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) APPOINTMENT ;;
    2) APPOINTMENT ;;
    3) APPOINTMENT ;;
    *) MAIN_MENU "I don't understand, please choose from our options." ;;
  esac
}

APPOINTMENT() {
  #get service id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") 

  #get phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi

  #get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #get time
  echo -e "\nWhen would you like for the appointment to be? Please enter it in 24 hour format: 14:10"
  read SERVICE_TIME



  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU



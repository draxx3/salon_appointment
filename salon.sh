#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Welcome to Aura and Rousy's Wonderful Salon! ~~\n"

MAIN_MENU() {
    if [[ $1 ]]
    then 
        echo "$1"
    else
        echo "How may we help you?"
    fi

    echo -e "1) Cut\n2) Color\n3) Perm\n4) Style\n5) Trim\n6) Exit"
    read SERVICE_ID_SELECTED

    case $SERVICE_ID_SELECTED in
        1|2|3|4|5) 
            SCHEDULE_APPOINTMENT "$SERVICE_ID_SELECTED" ;;
        6) 
            echo "Thanks for stopping in!" ;;
        *) 
            MAIN_MENU "Please pick a valid service." ;;
    esac
}

SCHEDULE_APPOINTMENT() {
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")

    # Ask for the phone number
    echo "What's your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_EXISTS=$($PSQL "SELECT COUNT(customer_id) FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ "$CUSTOMER_EXISTS" -eq 0 ]]
    then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # Insert new customer
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Insert appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME')")

    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU

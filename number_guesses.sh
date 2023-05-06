#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

if [[ ! -z $USER_ID ]]
then
  USER_DATA=$($PSQL "SELECT username, COUNT(user_id), MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE user_id = $USER_ID GROUP BY username;")
  echo "$USER_DATA" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
fi

RANDOM_NUM=$(( $RANDOM % 1000 ))
GUESSES=1
echo "Guess the secret number between 1 and 1000:"
read USER_INPUT
while [[ $USER_INPUT != $RANDOM_NUM ]]
do
  if [[ ! $USER_INPUT =~ ^[0-9]*$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_INPUT
  else
    if [[ $USER_INPUT > $RANDOM_NUM ]]
    then
      echo "It's lower than that, guess again:"
      ((GUESSES=$GUESSES+1))
      read USER_INPUT
    elif [[ $USER_INPUT < $RANDOM_NUM ]]
    then
      echo "It's higher than that, guess again:"
      ((GUESSES=$GUESSES+1))
      read USER_INPUT
    fi
  fi
done

GAME_ENTRY=$($PSQL "INSERT INTO games(user_id,guesses) VALUES($USER_ID,$GUESSES);")
echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUM. Nice job!"

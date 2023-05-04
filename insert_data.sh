#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]]
then
    #check if teams exist in teams
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    #if doesn't exist
    if [[ -z $W_TEAM_ID ]]
    then
      # insert teams
      INSERT_TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_ID == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi 
      #get new team ID
      W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    fi

    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    #if doesn't exist
    if [[ -z $O_TEAM_ID ]]
    then
      # insert teams
      INSERT_TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_ID == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      #get new team ID
      O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'") 
    fi

  #insert into games
  GAMES_ROW=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round)
                     VALUES($YEAR,$W_TEAM_ID,$O_TEAM_ID,$WINNER_GOALS,$OPPONENT_GOALS,'$ROUND')")
  if [[ $GAMES_ROW ==  "INSERT 0 1" ]]
  then 
    echo games row inserted
  fi

fi
done
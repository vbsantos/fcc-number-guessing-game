#!/bin/bash

# postgres base command
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 to 1000
secret_number=$((RANDOM % 1000 + 1))

# Prompt user for username
echo "Enter your username: "
read username

# Check if user already exists in the database
user_exists="$($PSQL "SELECT * FROM users WHERE username = '${username}';")"

if [ -n "${user_exists}" ]; then
    # Extract data for existing user
    IFS='|' read -r -a arr <<< "$user_exists"
    number_of_games="${arr[2]}"
    best_game="${arr[3]}"

    # Welcome back message
    echo "Welcome back, ${username}! You have played ${number_of_games} games, and your best game took ${best_game} guesses."
else
    # New user welcome message
    echo "Welcome, ${username}! It looks like this is your first time here."
    
    # Add user to the database
    create_user="$($PSQL "INSERT INTO users (username,number_of_games,best_game) VALUES ('${username}',0,1000);")"
    number_of_games="0"
    best_game="1000"
fi

# Ask user to guess the secret number
guesses=0
echo "Guess the secret number between 1 and 1000:"
while true; do
  read guess
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif (( guess < secret_number )); then
    echo "It's higher than that, guess again:"
    ((guesses++))
  elif (( guess > secret_number )); then
    echo "It's lower than that, guess again:"
    ((guesses++))
  else
    echo "You guessed it in $((guesses+1)) tries. The secret number was $secret_number. Nice job!"
    
    # Update user's game data if necessary
    if [ $(($guesses+1)) -lt $best_game ]; then
      $PSQL "UPDATE users SET best_game=$((guesses+1)) WHERE username='$username';"
    fi
    $PSQL "UPDATE users SET number_of_games=number_of_games+1 WHERE username='$username';"
    break
  fi
done

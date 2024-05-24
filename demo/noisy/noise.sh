#!/bin/sh

# Function to handle the SIGINT signal
trap 'echo "Received SIGINT, exiting..."; exit' INT

counter=1

while true; do
  echo $counter
  counter=$((counter + 1))
  sleep 1
done

#!/usr/bin/env bash

################################################################################
### Setup
################################################################################
# Define funtions
source functions

################################################################################
### First run! Starts syncthing and gets all the keys.
################################################################################
# Setup local
ID=$(./setup_syncthing.sh 1 | grep KEY | awk -F'KEY = ' '{print $2}')
printf "$ID#\n" > ../../data/syncthing_list

# Loop over all remotes
for file in ../../data/hosts/*er-*;do
  # Get IP
  IP=$(cat $file)
  # Copy scripts
  remote_copy setup_syncthing.sh $IP:
  remote_copy process_config.sh $IP:
  remote_copy connect_syncthing.sh $IP:
  remote_copy functions $IP:
  remote_copy variables $IP:
  remote_copy docker-compose.yml $IP:
  ID=$(remote_exec ./setup_syncthing.sh $IP | grep KEY | awk -F'KEY = ' '{print $2}')
  host=$(basename $file)
  printf "$ID#$host.$TF_VAR_domain\n" >> ../../data/syncthing_list
done


################################################################################
### Second run! Connect all syncthings with each other
################################################################################
# Setup local
./connect_syncthing.sh 1 ../../data/syncthing_list

# Loop over all remotes
for file in ../../data/hosts/*er-*;do
  # Get IP
  IP=$(cat $file)
  # Copy data file
  remote_copy ../../data/syncthing_list $IP:
  # Execute scripts
  remote_exec "./connect_syncthing.sh 0 syncthing_list" $IP
done

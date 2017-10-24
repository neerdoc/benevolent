#!/usr/bin/env bash
##############################################################
# Executes the docker swarm commands locally. Check first if
# swarm already exists.
##############################################################

# Exit if any of the intermediate steps fail
set -e

mkdir -p data

# Check if there are defined tokens
if [[ -f "data/manager.token" ]];then
  printf "Manager token found!\n"
  MANAGER=$(cat data/manager.token)
  # Check if we can connect with it
  docker swarm join "${MANAGER}"
  if [[ $? -ne 0 ]]; then
    printf "Could not connect to swarm. Recreating...\n"
    docker swarm init
    if [[ $? -ne 0 ]];then
      printf "Could not create swarm. Check that docker is installed.\n"
      exit 2
    fi
    docker swarm join-token --quiet manager > data/manager.token
    docker swarm join-token --quiet worker > data/worker.token
  else
    printf "Connected to master!\n"
  fi
else
  printf "No swarm found. Creating...\n"
  docker swarm init
  if [[ $? -ne 0 ]];then
    printf "Could not create swarm. Check that docker is installed.\n"
    exit 2
  fi
  docker swarm join-token --quiet manager > data/manager.token
  docker swarm join-token --quiet worker > data/worker.token
fi
if [[ -f "data/worker.token" ]];then
  printf "Worker token found!\n"
  WORKER=$(cat data/worker.token)
else
  docker swarm join-token --quiet worker > data/worker.token
  if [[ $? -ne 0 ]];then
    printf "Could not create woker token. Check that docker is installed.\n"
    exit 2
  fi
fi

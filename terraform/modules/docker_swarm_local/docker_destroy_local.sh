#!/usr/bin/env bash
##############################################################
# Destroy the local swarm node
##############################################################

# Exit if any of the intermediate steps fail
set -e

mkdir -p data

# Remove self from swarm
docker swarm leave --force
if [[ $? -ne 0 ]]; then
  printf "Could not leave swarm.\n"
  exit 2
else
  rm -fr data/manager.token
  rm -fr data/worker.token
fi

#!/usr/bin/env bash

if [[ -z "$1" ]];then
  NODES=($(ls data/hosts;))
  count=1
  printf "Choose an alternative:\n"
  printf "0 Exit\n"
  for NODE in ${NODES[@]}
  do
    printf "$count $NODE\n"
    count=$((count+1))
  done
  SELECT=""
  while ! [[ $SELECT =~ ^[0-9] ]] || [[ $SELECT -gt ${#NODES[@]} ]]
  do
    printf "Choose a number:"
    read SELECT
  done
  if [[ $SELECT == 0 ]]; then
    exit
  fi
  INDEX=$(($SELECT-1))
  SWARM_IP=$(cat data/hosts/"${NODES[$INDEX]}")
else
  SWARM_IP=$(cat data/hosts/"$1")
fi
SWARM_USER="core"

ssh \
    -o StrictHostKeyChecking=no \
    -o NoHostAuthenticationForLocalhost=yes \
    -o UserKnownHostsFile=/dev/null \
    -q \
    -i data/do-key \
    ${SWARM_USER}@${SWARM_IP}

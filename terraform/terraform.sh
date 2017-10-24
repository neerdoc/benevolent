#!/usr/bin/env bash
##############################################################
# This script is the full install of the setup and full
# destroy. Takes two arguments: The first is the terraform
# arguments. The second is to which of the defined folders the
# command should be applied.
##############################################################

# Exit if any of the intermediate steps fail
set -e

# Define approve terraform commands
COMMANDS=()
COMMANDS+=("init")
COMMANDS+=("get")
COMMANDS+=("plan")
COMMANDS+=("apply")
COMMANDS+=("destroy")
COMMANDS+=("validate")

# Define the planets
PLANETS=()
PLANETS+=("all")
PLANETS+=("acconts/digitalocean")

function show_help() {
  printf "terraform.sh <command> <planet>\n\n"
  printf "Usage:\n"
  printf "    <command> is a normal terraform command. Defined commands:\n"
  for cmd in ${COMMANDS[@]}
  do
    printf "        ${cmd}\n"
  done
  printf "    <planet> is the defined planet to apply the terraforming to. Defined planets:\n"
  for cmd in ${PLANETS[@]}
  do
    printf "        ${cmd}\n"
  done

  exit
}

# Check arguments
if [ "$1" == "-h" ]; then
  show_help
fi
if [ "$#" -ne 2 ];then
  printf "You must give 2 arguments.\n\n"
  show_help
fi
OK=0
for cmd in ${COMMANDS[@]}
do
  if [[ "$cmd" == "$1" ]];then
    OK=1
  fi
done
if [[ "$OK" == 0 ]];then
  printf "'$1' is not a valid argument.\n"
  show_help
fi
if [ "$2" != "all" ];then
  if [ ! -d "$2" ]; then
    printf "'$2' is not a terraform directory.\n"
    show_help
  fi
fi

# Single planet!
CURR_DIR=$(pwd)
if [ "$2" != "all" ];then
  cd "$2"
  terraform "$1"
  cd "$CURR_DIR"
  exit 0
fi

# Setup a function to make this more abstract
function terraform_planet() {
  printf "Current dir: $CURR_DIR\n"
  printf "change to: $2\n"
  cd "$2"
  terraform "$1"
  if [ "$?" -ne 0 ];then
    printf "Failed miserably.\n"
    printf "Exiting.\n"
    cd "$CURR_DIR"
    exit 1
  fi
  cd "$CURR_DIR"
}

##############################################
# Run through all planets!
##############################################
# Check if we destroyed all. If so, remove codes. Also, we should run destroy
# BACKWARDS!!
if [ "$1" == "destroy" ] && [ "$2" == "all" ];then
  terraform_planet "$1" "layers/swarm"
  terraform_planet "$1" "layers/swarm-master-init"
  terraform_planet "$1" "accounts/digitalocean"
  printf "Destroyed everything!\n"
  printf "Removing swarm keys.\n"
  rm -fr data/worker.token
  rm -fr data/manager.token
elif [ "$2" == "all" ];then
  # Setup account
  terraform_planet "$1" "accounts/digitalocean"
  # Create a temporary swarm master
  if [ ! -f "data/manager.token" ];then
    terraform_planet "$1" "layers/swarm-master-init"
  fi
  # Create the swarm
  terraform_planet "$1" "layers/swarm"
  # Remove the temporary swarm master
  if [ "$1" == "apply" ];then
    terraform_planet "destroy -force ." "layers/swarm-master-init"
    cp data/hosts/skynet-manager-00 data/hosts/skynet-temp-manager-00
  fi
else
  terraform_planet "$1" "$2"
fi

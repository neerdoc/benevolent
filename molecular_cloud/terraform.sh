#!/usr/bin/env bash
##############################################################
# This script is the full install of the setup and full
# destroy. Takes two arguments: The first is the terraform
# arguments. The second is to which of the defined folders the
# command should be applied.
##############################################################

# Exit if any of the intermediate steps fail
set -e

##############################################
# Setup
##############################################
# Define approve terraform commands
COMMANDS=()
COMMANDS+=("init")
COMMANDS+=("get")
COMMANDS+=("plan")
COMMANDS+=("apply")
COMMANDS+=("destroy")
COMMANDS+=("validate")
COMMANDS+=("roll")

# Define the planets
PLANETS=()
PLANETS+=("all")
PLANETS+=("acconts/digitalocean")

# Color constants
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
WHITE=`tput setaf 7`
LIGHT=`tput bold `
RESET=`tput sgr0`

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

# Setup a function to make this more abstract
function terraform_planet() {
  printf "${BLUE}Current dir:${RESET} $CURR_DIR\n"
  printf "${BLUE}Change to:${RESET} $2\n"
  printf "${BLUE}Command:${RESET} terraform $1\n"
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

# Setup function to count down delay
function countdown() {
  printf "Counting down...\n"
  SECONDS=$(printf $DELAY)
  for i in $(seq $DELAY 1)
  do
    printf "\r${RED}${i}${RESET} seconds remaining.                "
    sleep 1
  done
  printf "\r${RED}0${RESET} seconds remaining.         \n"
}

# Setup a function for rolling updates
function change_moon() {
  cd "$1"
  printf "Getting modules in current dir.\n"
  MODULES=( $(terraform state list | grep bedrock) )

  printf "Modules=\n${#MODULES[@]}\n"
  printf "First:\n${MODULES[0]}\n"

#exit
#  MODULES=$(terraform show |grep module )
  DELAY=$(( 2*ROLL_DELAY ))
  COUNT=0
  TOT=${#MODULES[@]}
  for mod in ${MODULES[@]}
  do
#    NAME=$(printf $mod | rev | sed 's/\./[/' | rev | sed 's/:/]/')
#    NAME=$(printf $mod | sed 's/://')
    NAME=$mod
    printf "${YELLOW}$NAME${RESET}\n"

    # Check if the swarm main IP is still there, replace if not.
    IPS=( $(ls ../../data/hosts |grep -v "skynet-temp-manager-00") )
    NM=$(terraform state show $NAME | grep skynet |awk -F" " '{print $3}')
    if [ "$NM" == "${IPS[0]}" ];then
      cp ../../data/hosts/${IPS[1]} ../../data/hosts/skynet-temp-manager-00
    else
      cp ../../data/hosts/${IPS[0]} ../../data/hosts/skynet-temp-manager-00
    fi

    # Destroy the resource
    printf "${RED}terraform plan -target $NAME$RESET\n"
    terraform apply -target "$NAME"

    # Destroy the resource
#    printf "${RED}terraform destroy -force -target $NAME$RESET\n"
#    terraform destroy -force -target "$NAME"


    # Create the resource again
#    printf "${RED}terraform apply -target $NAME$RESET\n"
#    terraform apply -target "$NAME"

    # Wait before continuing
    printf "TOT = $TOT\n"
    printf "COUNT = $COUNT\n"
    COUNT=$(( COUNT + 1 ))
    if [ "$COUNT" -lt "$TOT" ];then
      countdown
    fi
  done
}
##############################################
# Check arguments
##############################################
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

##############################################
# Apply rolling update
##############################################
if [ "$1" == "roll" ];then
  if [ -z ${ROLL_DELAY} ];then
    ROLL_DELAY=1
  fi
  if [ "$2" != "all" ];then
    printf "Applying rolling update with ${RED}${ROLL_DELAY}${RESET} minutes delay.\n"
    printf "Set the environment variable 'ROLL_DELAY' if you want to change it.\n"
    change_moon "$2"
    exit 0
  else
    printf "${RED}Roll command can only be applied to a directory.${RESET}\n"
    exit 2
  fi
fi

##############################################
# Run a single planet
##############################################
# Single planet!
CURR_DIR=$(pwd)
if [ "$2" != "all" ];then
  cd "$2"
  terraform "$1"
  cd "$CURR_DIR"
  exit 0
fi

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
    terraform_planet "destroy -force -target module.digitalocean_temp_manager_node.digitalocean_droplet.docker_swarm_temp_node" "layers/swarm-master-init"
    cp data/hosts/skynet-manager-00 data/hosts/skynet-temp-manager-00
  fi
else
  terraform_planet "$1" "$2"
fi

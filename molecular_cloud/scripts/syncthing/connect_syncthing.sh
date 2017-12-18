#!/usr/bin/env bash
# This script assumes there are nodes already setup and has an active docker
# installation.

# Load variables
source variables

# Define funtions
source functions

# Check if we are local or not
if [[ $1 == 1 ]];then
  DIR=$LOCAL_DIR
  GUI=$LOCAL_GUI
else
  DIR=$REMOTE_DIR
  GUI=$REMOTE_GUI
fi
CONF=$DIR/conf/config.xml

# Check that we can find the data file
if [[ ! -f $2 ]];then
  printf "Not a file\n"
  exit 1
fi

# Add all nodes
NODES=$(cat $2)
for each in ${NODES[@]};do
  TMP=$(echo $each |awk -F'#' '{print $1; print $2}')
  add_device ${TMP[@]}
done

# Get container ID
CONTAINER_ID=$(docker ps |grep $IMG |awk '{print $1}')
# Restart contianer with correct settings
docker restart "${CONTAINER_ID}" >/dev/null 2>&1

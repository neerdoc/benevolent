#!/usr/bin/env bash
# This script assumes there are nodes already setup and has an active docker
# installation. It checks first if there is a local syncthing container active.
# If not, it creates one according to the setup files. It then connects to the
# nodes and activates each of them.

# Load variables
source variables

# Check if we are local or not
if [[ $1 == 1 ]];then
  DIR=$LOCAL_DIR
  GUI=$LOCAL_GUI
else
  DIR=$REMOTE_DIR
  GUI=$REMOTE_GUI
fi

# Check if syncthing image exists.
exist_image=$(docker images | grep $IMG)
if [[ $? != 0 ]];then
  docker pull $IMG
fi

# Check if syncthing container is running
mkdir -p $DIR/conf
mkdir -p $DIR/data
USER=$(id -u)
exist_container=$(docker ps | grep $IMG)
if [[ $? != 0 ]];then
  docker run -d \
    -p $LOW_EXTERNAL:$LOW_INTERNAL \
    -p $HIGH_EXTERNAL:$HIGH_INTERNAL \
    -v $DIR/conf:/var/syncthing/config \
    -v $DIR/data:/var/syncthing/Sync \
    -u $USER \
    $IMG
  # Wait for container to start properly!
  sleep 10
fi

# Update settings
RES=$(./process_config.sh $DIR/conf/config.xml $GUI|awk '{print $1}')
printf "KEY = $RES\n"

# Get container ID
CONTAINER_ID=$(docker ps |grep $IMG |awk '{print $1}')
# Restart contianer with correct settings
docker restart "${CONTAINER_ID}" >/dev/null 2>&1

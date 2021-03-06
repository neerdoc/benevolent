#!/usr/bin/env bash
##############################################################
# Process the config.xml file generated by first startup.
# Make sure to do if/else in the changes since the config file
# will only be created if there is none. I.e., don't mess up
# any changes already made by the user!
##############################################################

# Exit if any of the intermediate steps fail
set -e

# Define funtions
source functions

# Extract input values
CONF=$1
GUI=$2

# Make sure we got a file name that is config.xml
if ! [[ -f "${CONF}" ]];then
  printf "Could not find the config file. Check your paths.\n" >&2
  exit 1
fi

# Check if GUI should be used or not
if [[ "${GUI}" == 1 ]];then
  sed -i -- 's/gui enabled="false"/gui enabled="true"/g' "${CONF}"
else
  sed -i -- 's/gui enabled="true"/gui enabled="false"/g' "${CONF}"
fi

# Turn off discovery
sed -i -- 's/<globalAnnounceEnabled>true<\/globalAnnounceEnabled>/<globalAnnounceEnabled>false<\/globalAnnounceEnabled>/g' "${CONF}"
sed -i -- 's/<localAnnounceEnabled>true<\/localAnnounceEnabled>/<localAnnounceEnabled>false<\/localAnnounceEnabled>/g' "${CONF}"

# Make sure the folder is correct
sed -i -- 's|path="\([a-zA-Z0-9/\.]*\)"|path="/var/syncthing/Sync"|g' "${CONF}"

# Get the ID key
ID=$(get_block_value "device" "id" "<address>dynamic</address>")
# Get the API key
API=$(get_key_value "apikey")

# Save outputs
printf $ID

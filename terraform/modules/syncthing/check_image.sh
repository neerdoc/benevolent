#!/usr/bin/env bash

# Waiting function

function wait_for_service {
    SERVICE_NAME=$1
    while true; do
        REPLICAS=$(docker service ls --filter "name=${SERVICE_NAME}" | grep ${SERVICE_NAME} | awk '{print $4}')
        if [[ ${REPLICAS} == "1/1" ]]; then
            break
        else
            echo "Waiting for the ${SERVICE_NAME} service..."
            sleep 5
        fi
    done
}

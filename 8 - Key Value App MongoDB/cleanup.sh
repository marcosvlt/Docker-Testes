#!/bin/bash

source .env

#check if .env file exists
if [ ! -f .env ]; then
    echo ".env file not found. Please create it with the required variables."
    exit 1
fi

#check if container is running
if docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "Stopping and removing container $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
else
    echo "Container $CONTAINER_NAME is not running. No need to stop."
fi

#check if docker network already exists
if docker network inspect "$NETWORK_NAME" &>/dev/null; then
    echo "Network $NETWORK_NAME already exists. Removing it..."  
    docker network rm "$NETWORK_NAME"
else
    echo "Network $NETWORK_NAME does not exist. No need to remove."
fi  

#check if volume already exists
if docker volume inspect "$DB_VOLUME_NAME" &>/dev/null; then
    echo "Volume $DB_VOLUME_NAME already exists. Removing it..."
    docker volume rm "$DB_VOLUME_NAME"
else
    echo "Volume $DB_VOLUME_NAME does not exist. No need to remove."
fi 


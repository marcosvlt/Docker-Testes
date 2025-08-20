#!/bin/bash


# Load environment variables from .env file
if [ ! -f .env ]; then
  echo ".env file not found. Please create it with the required variables."
  exit 1
fi
#shellcheck source=.env
source .env


# CHECKS

#check if docker network already exists
if docker network inspect "$NETWORK_NAME" &>/dev/null; then
  echo "Network $NETWORK_NAME already exists."  
else
  echo "Creating network $NETWORK_NAME..." 
  docker network create "$NETWORK_NAME"
fi

#check if volume already exists
if docker volume inspect "$DB_VOLUME_NAME" &>/dev/null; then
  echo "Volume $DB_VOLUME_NAME already exists."  
else
  echo "Creating volume $DB_VOLUME_NAME..."
  docker volume create "$DB_VOLUME_NAME"
fi

#check if container is already exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "Container $CONTAINER_NAME already exists. Please stop and remove it before running this script."
  exit 1
fi

# Start MongoDB container
docker run -d \
  --name "$CONTAINER_NAME" \
  -e MONGO_INITDB_ROOT_USERNAME="$ROOT_USER" \
  -e MONGO_INITDB_ROOT_PASSWORD="$ROOT_PASSWORD" \
  -e KEY_VALUE_DB="$KEY_VALUE_DB" \
  -e KEY_VALUE_USER="$KEY_VALUE_USER" \
  -e KEY_VALUE_PASSWORD="$KEY_VALUE_PASSWORD" \
  -p "$LOCALHOST_PORT":"$CONTAINER_PORT" \
  --network "$NETWORK_NAME" \
  -v "$DB_VOLUME_NAME":"$VOLUME_CONTAINER_PATH" \
  -v ./db-config/mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro \
  "$MONGO_IMAGE":"$MONGO_TAG"
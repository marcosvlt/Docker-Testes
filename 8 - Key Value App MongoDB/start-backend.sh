#!/bin/bash


# Load environment variables from .env file
if [ ! -f .env ]; then
  echo ".env file not found. Please create it with the required variables."
  exit 1
fi
#shellcheck source=.env
source .env

docker build -t "$BACKEND_IMAGE_NAME" -f backend/Dockerfile.dev backend

# Check if container exists
if [ "$(docker ps -aq -f name="$BACKEND_CONTAINER_NAME")" ]; then
    # Stop and remove the existing container
    docker stop "$BACKEND_CONTAINER_NAME"
    docker rm "$BACKEND_CONTAINER_NAME"
fi

# Run the backend container
echo "Starting backend container..."
docker run -d \
  --name "$BACKEND_CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  -p "$PORT":"$PORT" \
  -v ./backend/src:/app/src \
  --env-file .env \
  "$BACKEND_IMAGE_NAME" 
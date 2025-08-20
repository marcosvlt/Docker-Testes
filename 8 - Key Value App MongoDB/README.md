
## **Index**

1. [Project Overview](#key-value-rest-api-project-overview)
2. [Core Features](#core-features)
3. [API Endpoints & Behavior](#api-endpoints--behavior)
    - [POST /store](#1-post-store)
    - [GET /store/:key](#2-get-storekey)
    - [PUT /store/:key](#3-put-storekey)
    - [DELETE /store/:key](#4-delete-storekey)
    - [GET /health](#5-get-health)
4. [Docker & Deployment Setup](#docker--deployment-setup)
5. [Running a Basic MongoDB Server in Docker](#running-a-basic-mongodb-server-in-docker)
6. [Adding Authentication to MongoDB with Docker](#adding-authentication-to-mongodb-with-docker)
7. [MongoDB User Setup for Key-Value App](#1-goal)
8. [MongoDB Shell Script & Container Networking Setup](#mongodb-shell-script--container-networking-setup)
9. [Refactoring MongoDB Startup Scripts for Safety & Reusability](#refactoring-mongodb-startup-scripts-for-safety--reusability)
10. [Setting Up the Express Application and Connecting to MongoDB](#setting-up-the-express-application-and-connecting-to-mongodb)
11. [Running the Backend in Docker to Connect with MongoDB](#running-the-backend-in-docker-to-connect-with-mongodb)
12. [Backend Project Structure Improvements with Environment Variables & Startup Script](#backend-project-structure-improvements-with-environment-variables--startup-script)
13. [Enabling Hot Reloading in Backend with Nodemon & Volumes](#enabling-hot-reloading-in-backend-with-nodemon--volumes)
14. [Setting Up API Routes with Express Routers](#setting-up-api-routes-with-express-routers)
15. [Data Persistence with Mongoose in Express](#data-persistence-with-mongoose-in-express)
16. [Updating & Deleting Key-Value Pairs with Express + Mongoose](#updating--deleting-key-value-pairs-with-express--mongoose)
17. [Data Persistence & Cleanup in Key-Value REST API Project](#data-persistence--cleanup-in-key-value-rest-api-project)


## **Key-Value REST API Project Overview**

### **Goal**

Develop a **Key-Value REST API** using **Express.js** for the application and **MongoDB** for the database. The project will focus on **Docker**, **multi-container setups**, **volumes**, and **user-defined networks**.

* * *

## **Core Features**

### **Architecture**

- **Application**: Express.js API server.
    
- **Database**: MongoDB with persistent storage via Docker volumes.
    
- **Networking**: Containers connected via user-defined Docker network.
    
- **Automation**: Shell scripts to manage containers, networks, and volumes.
    

* * *

## **API Endpoints & Behavior**

### **1\. POST `/store`**

**Purpose**: Store a new key-value pair.  
**Rules**:

- Request body must contain both `"key"` and `"value"`.
    
- If either is missing → return **400 Bad Request**.
    
- If the key already exists → return **400 Bad Request**.
    
- Otherwise → store key-value and return **201 Created**.
    

* * *

### **2\. GET `/store/:key`**

**Purpose**: Retrieve value by key.  
**Rules**:

- If key does not exist → **404 Not Found**.
    
- If found → return **200 OK** with `{ key, value }`.
    

* * *

### **3\. PUT `/store/:key`**

**Purpose**: Update value for an existing key.  
**Rules**:

- Request body must contain `"value"`.
    
- If missing → **400 Bad Request**.
    
- If key does not exist → **404 Not Found**.
    
- If found → update and return **200 OK**.
    

* * *

### **4\. DELETE `/store/:key`**

**Purpose**: Remove a key-value pair.  
**Rules**:

- If key does not exist → **404 Not Found**.
    
- If found → delete and return **204 No Content**.
    

* * *

### **5\. GET `/health`**

**Purpose**: Health check endpoint.

- Always return **200 OK** with `"up"`.

* * *

## **Docker & Deployment Setup**

- **MongoDB Container**: Runs with volume for persistent storage.
    
- **Express App Container**: Connected to the same Docker network as MongoDB.
    
- **Networking**: Use `docker network create` for isolation and service communication.
    
- **Port Binding**: Map app’s port to localhost for external access.
    
- **Scripts**: Automate container/network/volume creation and removal.
    

* * *

# Running a Basic MongoDB Server in Docker

### 1\. **Introduction**

The lecture demonstrates how to quickly run a MongoDB server using Docker, starting from selecting the right image on Docker Hub to basic interaction with the database in a container.

* * *

### 2\. **Choosing the MongoDB Image**

- **Source**: Docker Hub → search for "MongoDB".
    
- **Recommended Version**: Use `7.0-ubuntu` tag (includes latest patches for security and stability).
    
- **Reasoning**: Ensures stability for future viewers while keeping security patches up-to-date.
    

* * *

### 3\. **Project Setup**

- Create a clean directory for the project, e.g., `Keyvalue-app`.
    
- Prepare to run the container with the chosen MongoDB image.
    

* * *

### 4\. **Running MongoDB with Docker**

**Command Example**:

```bash
docker run -d \
  --name mongodb \
  mongodb/mongodb-community-server:7.0-ubuntu22.04
```

- **`-d`**: Detached mode.
    
- **`--name mongodb`**: Names the container `mongodb`.
    
- **Image**: Pulls automatically if not available locally.
    

* * *

### 5\. **Verifying the Container**

- Check running containers:

```bash
docker ps
```

- View logs:

```bash
docker logs mongodb
```

- If status shows `Up` without errors, MongoDB is running correctly.

* * *

### 6\. **Interacting with MongoDB**

**Exec into the container and open the Mongo shell**:

```bash
docker exec -it mongodb mongosh
```

**Example Commands in Shell**:

```js
show dbs;       // List databases
use admin;      // Switch to admin DB
show collections; // List collections in admin
```

* * *

### 7\. **Security Considerations**

- **Issue**: Default setup has no authentication — anyone with access can run commands.
    
- **Implication**: Not secure for production; only acceptable for local development.
    
- **Future Step**: Implement basic security (user/password authentication).
    

* * *

### 8\. **Cleaning Up**

- Stop and remove the container:

```bash
docker rm -f mongodb
```

- Verify removal:

```bash
docker ps -a
```

* * *

### **Key Takeaways**

1.  Use stable, patched images (`7.0-ubuntu`) for consistency and security.
    
2.  Verify container health with `docker ps` and logs.
    
3.  MongoDB runs without authentication by default — **secure it before production use**.
    
4.  Docker makes setup and teardown quick, but persistence and security require extra steps.
    

* * *

&nbsp;

## **Adding Authentication to MongoDB with Docker**

### **1\. Objective**

- Set up a MongoDB server in Docker with **root username/password authentication**.
    
- Replace manual `docker run` commands with **shell scripts** for better reusability and manageability.
    
- Prepare for using **Docker Compose** in the next section.
    

* * *

### **2\. Creating Shell Scripts**

Two scripts were created:

1.  **`start-db.sh`** – Starts MongoDB with authentication.
    
2.  **`cleanup-db.sh`** – Stops and removes MongoDB containers (later use).
    

#### **Make scripts executable:**

```bash
chmod +x start-db.sh
chmod +x cleanup-db.sh
```

* * *

### **3\. Structuring the Start Script**

- Define variables for image, tag, container name, and credentials.
    
- Pass credentials as **environment variables** to `docker run`.
    

#### **Example: `start-db.sh`**

```bash
#!/bin/bash

# MongoDB settings
MONGO_IMAGE="mongo"
MONGO_TAG="7.0"
CONTAINER_NAME="mongodb"

# Root credentials
ROOT_USER="root-user"
ROOT_PASSWORD="root-password"

# Start MongoDB container
docker run -d \
  --name $CONTAINER_NAME \
  --rm \
  -e MONGO_INITDB_ROOT_USERNAME=$ROOT_USER \
  -e MONGO_INITDB_ROOT_PASSWORD=$ROOT_PASSWORD \
  $MONGO_IMAGE:$MONGO_TAG
```

* * *

### **4\. Running the Script**

```bash
./start-db.sh
docker ps        # Verify container is running
```

* * *

### **5\. Testing Authentication**

- **Without credentials**, MongoDB blocks operations:
    
    ```bash
    docker exec -it mongodb mongosh
    show dbs      # Results in "not authorized" error
    ```
    
- Users can still `use <dbname>` but cannot read or write until authenticated.
    

* * *

### **6\. Stopping the Container**

```bash
docker stop mongodb
```

- `--rm` flag ensures the container is **removed automatically** after stopping.

* * *

### **7\. Key Takeaways**

- Environment variables (`MONGO_INITDB_ROOT_USERNAME` / `MONGO_INITDB_ROOT_PASSWORD`) enable basic authentication.
    
- Shell scripts improve **repeatability** and make changes easier.
    
- Unauthorized access attempts now return **authorization errors**, securing database operations.
    
- Next step: transition to **Docker Compose** for simpler multi-container setups.
    

* * *

&nbsp;

## **1\. Goal**

- Create a **non-root MongoDB user** with read/write access only to the `key-value-db` database for the Key Value app.

* * *

## **2\. Initialization Script**

- **File**: `db-config/mongo-init.js`
    
- **Purpose**: Automatically run when MongoDB starts (if placed in `/docker-entrypoint-initdb.d/`).
    
- **Logic**:
    
    ```javascript
    #!/bin/bash
    
    # shellcheck source=.env
    # Load environment variables from .env file
    if [ ! -f .env ]; then
      echo ".env file not found. Please create it with the required variables."
      exit 1
    fi
    source .env
    
    # MongoDB settings
    MONGO_IMAGE="mongo"
    MONGO_TAG="7.0"
    CONTAINER_NAME="mongodb"
    
    # Start MongoDB container
    docker run -d \
      --name $CONTAINER_NAME \
      --rm \
      -e MONGO_INITDB_ROOT_USERNAME=$ROOT_USER \
      -e MONGO_INITDB_ROOT_PASSWORD=$ROOT_PASSWORD \
      -e KEY_VALUE_DB=$KEY_VALUE_DB \
      -e KEY_VALUE_USER=$KEY_VALUE_USER \
      -e KEY_VALUE_PASSWORD=$KEY_VALUE_PASSWORD \
      -v ./db-config/mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro \
      $MONGO_IMAGE:$MONGO_TAG
    ```
    
- Uses environment variables instead of hardcoding credentials (best practice).
    

* * *

## **3\. Docker Bind Mount**

- Mount the `mongo-init.js` file into the container:
    
    ```bash
    -v ./db-config/mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
    ```
    
- `:ro` makes it read-only inside the container.
    
- Alternative: Copy via `Dockerfile` (less flexible for local dev changes).
    

* * *

## **4\. Environment Variables**

create a .env file

```
# Root credentials
ROOT_USER="root-user"
ROOT_PASSWORD="123"

# Key-Value database credentials
KEY_VALUE_DB="key-value-db"
KEY_VALUE_USER="key-value-user"
KEY_VALUE_PASSWORD="123"
```

Example for `.env` or inline in the `docker run` command:

```bash
  -e KEY_VALUE_DB=$KEY_VALUE_DB \
  -e KEY_VALUE_USER=$KEY_VALUE_USER \
  -e KEY_VALUE_PASSWORD=$KEY_VALUE_PASSWORD \
```

* * *

## **5\. Running MongoDB with Script**

`./start-db.sh`

* * *

## **6\. Verification**

- Check container status:
    
    ```bash
    docker ps
    ```
    
- Check logs (note: no output unless you log inside `mongo-init.js`):
    
    ```bash
    docker logs mongo-keyvalue
    ```
    

* * *

This setup ensures:

- **Secure credentials management** via env variables.
    
- **Automated user creation** at container startup.
    
- **Persistent, reusable init scripts** via bind mounts.
    

&nbsp;

&nbsp;

# **MongoDB Shell Script & Container Networking Setup**

### **Purpose**

- Extend the MongoDB startup shell script to include **port mapping**, **volume persistence**, and **container networking**.
    
- Enable other containers to connect to MongoDB using a **user-defined network**.
    

* * *

### **Connectivity Configuration**

1.  **Port Mapping**
    
    ```bash
    LOCALHOST_PORT=27017
    CONTAINER_PORT=27017
    
    #add no start-db.sh
    -p $LOCALHOST_PORT:$CONTAINER_PORT \
    
    
    ```
    
    - Maps MongoDB’s default port from host to container.
2.  **Network Setup**
    
    ```bash
    Add do start-db.sh
    
    NETWORK_NAME=key-value-network
    
    
    #check if docker network already exists
    if docker network inspect $NETWORK_NAME &>/dev/null; then
      echo "Network $NETWORK_NAME already exists."
    else
      echo "Creating network $NETWORK_NAME..." 
      docker network create $NETWORK_NAME
    fi
    ```
    
    - Allows app and database containers to communicate by container name.

* * *

### **Storage Configuration**

1.  **Named Volume**
    
    ```bash
    VOLUME_NAME=mongodb_data
    VOLUME_CONTAINER_PATH=/data/db
    
    
    #check if volume already exists
    if docker volume inspect $DB_VOLUME_NAME &>/dev/null; then
      echo "Volume $DB_VOLUME_NAME already exists."
     
    else
      echo "Creating volume $DB_VOLUME_NAME..."
      docker volume create $DB_VOLUME_NAME
    fi
    ```
    
    - Ensures MongoDB data persists beyond container lifecycle.
2.  **Mount Order**
    
    - Ports → Volumes → Network → Environment Variables → Image.

* * *

### **Testing Container Connectivity**

1.  **Run a Debug Container**
    
    ```bash
    docker run --rm -it \
      --name debugsh \
      --network key-value-network \
      mongo:7.0 mongosh \
      "mongodb://key-value-user:87654321@mongodb/key-value-db"
    
    ```
    
    - Connects to MongoDB by **container name** (thanks to shared network).
2.  **Authentication Check**
    
    - Without credentials → unauthorized errors.
        
    - With credentials:
        
        ```bash
        mongosh "mongodb://key-value-user:key-value-password@mongodb/key-value-db"
        ```
        
        → Can query collections in `key-value-db`.
        
3.  **Permission Boundaries**
    
    - User restricted to specific DB.
        
    - Access to `admin` DB returns **unauthorized**.
        

* * *

### **Cleanup**

```bash
docker stop <container_id>
docker rm <container_id>
docker volume rm key-value-data
docker network rm key-value-net
```

* * *

### **Key Lessons**

- **User-defined networks** let containers resolve each other by name.
    
- **Named volumes** enable persistent storage across container restarts.
    
- **Port mapping** exposes container services to the host.
    
- **Least privilege principle**: restrict DB users to only necessary DBs.
    
- **Step-by-step validation** ensures configuration works before app integration.
    

* * *

&nbsp;

&nbsp;

# **Refactoring MongoDB Startup Scripts for Safety & Reusability**

### **Goal**

- Prevent errors when running the start script multiple times.
    
- Automatically create required **Docker volumes** and **networks**.
    
- Add friendly error messages and cleanup scripts for easier development.
    

* * *

### **Script Structure**

1.  **`setup.sh`**
    
    - Creates Docker **volume** and **network** if they don’t already exist.
        
    - Uses environment files for shared config:
        
        - `.env.network` → contains `NETWORK_NAME`
            
        - `.env.volume` → contains `VOLUME_NAME`
            
    - Checks existence:
        
        ```bash
        if docker volume ls -q --filter name=$VOLUME_NAME; then
            echo "Volume exists, skipping..."
        else
            docker volume create $VOLUME_NAME
        fi
        ```
        
2.  **`start-db.sh`**
    
    - Sources `.env` files and runs `setup.sh`.
        
    - Checks if the MongoDB container already exists:
        
        ```bash
        if docker ps -q --filter name=$DB_CONTAINER_NAME; then
            echo "Container exists, exiting."
            exit 1
        fi
        ```
        
    - Starts MongoDB with:
        
        - **Port mapping**
            
        - **Volume mount**
            
        - **Network attachment**
            
        - **Environment variables** (user, password, database name)
            
3.  **`.env.db`**
    
    - Stores DB container-specific vars like:
        
        ```bash
        export DB_CONTAINER_NAME=mongodb
        ```
        
4.  **`cleanup.sh`**
    
    - Stops & removes MongoDB container.
        
    - Removes volume & network **only if they exist**.
        
    - Order: Container → Volume → Network.
        
    - Skips deletion gracefully if resources don’t exist.
        

* * *

### **Benefits**

- **Idempotent scripts** — can be run multiple times without breaking.
    
- **Clear developer messages** — informs what’s being skipped or removed.
    
- **Reusable configs** — all variables centralized in `.env` files.
    
- **Safety first** — no accidental resource recreation or deletion.
    
- **Easier team workflow** — consistent environment setup & teardown.
    

* * *

### **Key Commands**

```bash
# Create volume & network if missing
docker volume create key-value-data
docker network create key-value-net

# Start DB container
docker run -d --rm \
  --name mongodb \
  -p 27017:27017 \
  -v key-value-data:/data/db \
  --network key-value-net \
  -e MONGO_INITDB_ROOT_USERNAME=...
  -e MONGO_INITDB_ROOT_PASSWORD=...
  -e MONGO_INITDB_DATABASE=key-value-db \
  mongo:7.0-ubuntu22.04

# Cleanup
docker kill mongodb
docker volume rm key-value-data
docker network rm key-value-net
```

* * *

&nbsp;

&nbsp;

# **Setting Up the Express Application and Connecting to MongoDB**

### **Goal**

- Initialize an Express backend that connects to a MongoDB container via Mongoose.
    
- Prepare the groundwork for API routes.
    
- Ensure database connection before accepting incoming requests.
    

* * *

### **Steps Covered**

#### 1\. **Database Container Verification**

- Ran `start-db.sh` to ensure MongoDB container is up.
    
- Verified running container via:
    
    ```bash
    docker ps
    ```
    
- Confirmed DB connectivity using a temporary `mongosh` container attached to the same network.
    

#### 2\. **Backend Setup**

- Created **`backend/`** directory.
    
- Initialized Node.js project:
    
    ```bash
    npm init -y
    ```
    
- Installed dependencies:
    
    ```bash
    npm install express@4.19.2 mongoose@8.5.1 body-parser@1.20.2 --save-exact
    ```
    
- Added `node_modules` to `.dockerignore`.
    

#### 3\. **Project Structure**

```
backend/
 ├── src/ (or server.js at root)
 ├── package.json
 ├── .dockerignore
```

#### Add start on package.json

`<span style="color: #9cdcfe;">"start"</span><span style="color: #cccccc;">:</span> <span style="color: #ce9178;">"node src/server.js"</span><span style="color: #cccccc;">,</span>`

#### 4\. **Server Code (`server.js`)**

- Imported modules:
    
    ```javascript
    const express = require('express');
    const mongoose = require('mongoose');
    const bodyParser = require('body-parser');
    ```
    
- Set up middleware:
    
    ```javascript
    app.use(bodyParser.json());
    ```
    
- Implemented **health check route**:
    
    ```javascript
    app.get('/health', (req, res) => res.status(200).send('up'));
    ```
    
- Connected to MongoDB with Mongoose:
    
    ```javascript
    const express = require('express');
    const mongoose = require('mongoose');
    const bodyParser = require('body-parser');
    
    require('dotenv').config({ path: '../.env' })
    
    const dbPassword = process.env.DB_PASSWORD;
    
    
    app.use(bodyParser.json());
    
    const app = express();
    const PORT = process.env.PORT || 3000; 
    
    app.get('/health', (req, res) => res.status(200).send('up'));
    
    
    mongoose.connect('mongodb://mongodb/key-value-db', {
      auth: { username: 'key-value-user', password: dbPassword },
      connectTimeoutMS: 500
    })
    .then(() => {
      console.log('Connected to DB');
      app.listen(3000, () => console.log('Listening on port 3000'));
    })
    .catch(err => console.error('Something went wrong', err));
    ```
    

#### 5\. **Connection Problem**

- App couldn’t resolve `mongodb` hostname when run locally.
    
- Cause: Hostname resolution works **only inside the same Docker network**.
    
- Solution: Run the Express app inside a container connected to the same Docker network as MongoDB.
    

* * *

### **Key Concepts Learned**

- **Order of startup matters** — start server only after DB connection succeeds.
    
- **Container networking** — service hostnames work only when containers share a Docker network.
    
- **Separation of concerns** — DB container and API container should be isolated but connected via Docker network.
    
- **Health endpoint** — useful for testing API availability.
    

* * *

&nbsp;

&nbsp;

# **Running the Backend in Docker to Connect with MongoDB**

### **Goal**

- Containerize the backend so it can connect to the MongoDB container using Docker networking.
    
- Use a development Dockerfile for local work.
    

* * *

### **Steps Covered**

#### 1\. **Why This is Needed**

- Running the backend **locally** prevents it from resolving the MongoDB container hostname.
    
- Containers in the same Docker network can communicate using service names.
    

* * *

#### 2\. **Creating `Dockerfile.dev`**

```dockerfile
# Base image
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy dependencies first
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy remaining project files
COPY . .

# Default command
CMD ["npm", "start"]
```

* * *

#### 3\. **Building the Backend Image**

```bash
# Inside backend folder
docker build -t key-value-backend -f Dockerfile.dev .
```

* * *

#### 4\. **Running the Backend Container**

```bash
docker run -d \
  --name backend \
  --network key-value-network \
  -p 3000:3000 \
  --env-file ../.env \
  key-value-backend
```

- **`--network key-value-net`** ensures backend can talk to MongoDB container by hostname.
    
- **`-p 3000:3000`** maps local port 3000 to container port 3000.
    

* * *

#### 5\. **Verifying Connection**

- Check logs:

```bash
docker logs backend
```

- Successful output: **Connected to DB** and **Listening on port 3000**.
    
- Test endpoints:
    

```bash
curl localhost:3000/health
# Expected: "up"
```

* * *

### **Key Concepts Learned**

- **Container networking** allows service discovery via container names.
    
- **Development Dockerfile** keeps setup simple for local development.
    
- **Build and run workflow**: build → run → test.
    
- **Health check endpoint** is useful for quick service status verification.
    

* * *

&nbsp;

&nbsp;

# **Backend Project Structure Improvements with Environment Variables & Startup Script**

### **Goal**

- Refactor backend startup process for flexibility, reusability, and better environment configuration.
    
- Automate container build and run with a dedicated script.
    
- Remove hardcoded database connection details.
    

* * *

### **Main Improvements**

#### 1\. **Stop and Remove Old Backend Container**

```bash
docker rm -f backend
docker ps        # Check running containers
docker ps -a     # Verify removal
```

* * *

#### 2\. **Create `start-backend.sh` Script**

- Similar to DB startup script but tailored for backend.
    
- Key changes:
    
    - Removed MongoDB image and volume configuration (not needed for backend).
        
    - Moved database credentials to `.env.db`.
        
    - Used `.env.network` for shared Docker network configuration.
        
    - Added variables for:
        
        - Backend container name (`backend`)
            
        - Backend image name (`key-value-backend`)
            
        - MongoDB host (`mongodb`)
            
        - Container port (`3000`)
            
    - Script builds Docker image before running container.
        

**Example:**

```bash
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
  --env-file .env \
  "$BACKEND_IMAGE_NAME" 
```

* * *

#### 3\. **Update `server.js` to Use Environment Variables**

```javascript
const port = process.env.PORT;
const dbName = process.env.KEY_VALUE_DB;
const username = process.env.KEY_VALUE_USER;
const password = process.env.KEY_VALUE_PASSWORD;
const host = process.env.MONGODB_HOST;

const uri = `mongodb://${username}:${password}@${host}:27017/${dbName}`;
```

- Replaced hardcoded values with `process.env` variables.
    
- Makes the backend portable for different DB hosts and credentials.
    

* * *

#### 4\. **Benefits of This Refactor**

- **Flexibility**: Change DB host, name, user, password without code changes.
    
- **Reusability**: Same image can be deployed in different environments.
    
- **Cleaner Scripts**: Startup logic centralized in `start-backend.sh`.
    
- **Consistency**: Environment variables shared across backend and DB scripts.
    
- **Safety**: Avoids accidental persistence or incorrect credentials.
    

* * *

#### 5\. **Usage Flow**

```bash
chmod +x start-backend.sh      # Make script executable
./start-backend.sh             # Build and run backend
docker logs backend            # Check connection to MongoDB
curl localhost:3000/health     # Test service health
docker kill backend            # Stop backend
```

* * *

&nbsp;

# **Enabling Hot Reloading in Backend with Nodemon & Volumes**

### **Problem**

- Current setup requires:
    
    - Stop container → Rebuild image → Restart container
- No **fast feedback loop** during development.
    

* * *

### **Solution**

1.  **Install Nodemon as Dev Dependency**
    
    ```bash
    cd backend
    npm install --save-dev --save-exact nodemon@3.1.4
    ```
    
2.  **Update `package.json`**
    
    ```json
    "scripts": {
      "start": "node src/server.js",
      "dev": "nodemon src/server.js"
    }
    ```
    
3.  **Update `Dockerfile.dev`**
    
    - Change startup command to use `npm run dev` instead of `npm start`.
    
    Example:
    
    ```dockerfile
    CMD ["npm", "run", "dev"]
    ```
    
4.  **Bind Mount Source Code for Hot Reloading**
    
    - Modify `start-backend.sh` (or docker run) to include:
    
    ```bash
    -v ./backend/src:/app/src
    ```
    
    - Maps local code to container → Nodemon can detect file changes.
5.  **Verify Hot Reloading**
    
    ```bash
    docker logs -f backend
    ```
    
    - Make a code change (e.g., edit `server.js`).
        
    - Container log should show Nodemon **restarting the server automatically**.
        

* * *

### **Benefits**

- **Fast feedback loop**: Instant reload on code change.
    
- **No manual rebuilds**: Dev environment stays live.
    
- **Cleaner workflow**: Just keep container running while coding.
    

* * *

&nbsp;

# **Setting Up API Routes with Express Routers**

### **1\. Confirm Environment**

- Both **database** and **backend** containers must be running.
    
- Verify:
    
    - Run `start-db.sh` and `start-backend.sh`.
        
    - Check health endpoint:
        
        ```bash
        curl http://localhost:3000/health
        # Response: "up"
        ```
        
    - Logs confirm **Nodemon** is watching for file changes.
        

* * *

### **2\. Required Dependencies**

- Ensure these are installed in the backend:
    
    ```bash
      "dependencies": {
        "body-parser": "^1.20.3",
        "dotenv": "^17.2.1",
        "express": "^4.21.2",
        "mongoose": "^8.17.1"
    ```
    

* * *

### **3\. Define Routes**

- API needs **CRUD endpoints** for key-value pairs:
    
    - `POST /store` → Create entry
        
    - `GET /store/:key` → Retrieve entry
        
    - `PUT /store/:key` → Update entry
        
    - `DELETE /store/:key` → Delete entry
        

* * *

### **4\. Split Routes into Modules**

- Create **routes/** folder with two files:
    
    - `store.js` → All key-value store routes.
        
    - `health.js` → Health check route.
        

**store.js**

```js
const express = require('express');


const storeRouter = express.Router();

storeRouter.post('/', (req, res) => {});
storeRouter.get('/:key', (req, res) => {});
storeRouter.put('/:key', (req, res) => {});
storeRouter.delete('/:key', (req, res) => {}); 

module.exports =  storeRouter ; 
```

**health.js**

```js
const express = require('express');

const healthRouter = express.Router();

healthRouter.get('/', (req, res) => res.status(200).send('up and running'));

module.exports = healthRouter;
```

* * *

### **5\. Connect Routers in `server.js`**

```js
const express = require("express");

// Import routers
const healthRouter = require("./routes/health");
const storeRouter = require("./routes/store");

// Mount routers
app.use("/health", healthRouter);
app.use("/store", storeRouter);


```

* * *

### **6\. Test API Endpoints**

- Using **Postman or curl**:

```bash
curl http://localhost:3000/health
# -> "up and running"

curl -X POST http://localhost:3000/store
# -> "Creating key value pair"

curl http://localhost:3000/store/example
# -> "Getting key value pair"

curl -X PUT http://localhost:3000/store/example
# -> "Updating key value pair"

curl -X DELETE http://localhost:3000/store/example
# -> "Deleting key value pair"
```

* * *

### ✅ **Result**

- API routes are modular, organized, and functional.
    
- Each request type returns the correct response.
    
- Ready to extend with **database persistence** in the next step.
    

* * *

&nbsp;
# Data Persistence with Mongoose in Express

## 1\. Setting Up a Model with Mongoose

- Create a **schema** to define how key-value pairs are stored in MongoDB.
    
- Requirements:
    
    - `key`: String, **required**, **unique**
        
    - `value`: String, **required**, not unique
        

```js
const mongoose = require('mongoose');

const keyValueSchema = new mongoose.Schema({
  key: { type: String, required: true, unique: true },
  value: { type: String, required: true },
});

const KeyValue = mongoose.model('KeyValue', keyValueSchema);

module.exports = {
  KeyValue,
};
```

* * *

## 2\. Error Handling with Try/Catch

- Wrap all route handlers in **try/catch** to handle errors gracefully.
    
- Return consistent JSON error responses.
    
- Example (simplified error handling):
    

```js
try {
  // logic here
} catch (err) {
  res.status(500).json({ message: "Internal Server Error" });
}
```

* * *

## 3\. Creating Key-Value Pairs

```js
const express = require('express');
const { KeyValue } = require('../models/keyValue');

const keyValueRouter = express.Router();

keyValueRouter.post('/', async (req, res) => {
  const { key, value } = req.body;
  console.log('Received key:', key, 'value:', value);

  if (!key || !value) {
    return res
      .status(400)
      .json({ error: 'Both "key" and "value" are required' });
  }
  try {
    const existingKey = await KeyValue.findOne({ key });

    if (existingKey) {
      return res.status(400).json({ error: 'Key already exists' });
    }

    const keyValue = new KeyValue({ key, value });
    await keyValue.save();

    return res
      .status(201)
      .json({ message: 'Key-Value pair stored successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

keyValueRouter.get('/:key', async (req, res) => {
  const { key } = req.params;

  try {
    const keyValue = await KeyValue.findOne({ key });

    if (!keyValue) {
      return res.status(404).json({ error: 'Key not found' });
    }

    return res.status(200).json({ key, value: keyValue.value });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
});

keyValueRouter.put('/:key', async (req, res) => {
  const { key } = req.params;
  const { value } = req.body;

  if (!value) {
    return res.status(400).json({ error: '"value" is required' });
  }

  try {
    const keyValue = await KeyValue.findOneAndUpdate(
      { key },
      { value },
      { new: true }
    );

    if (!keyValue) {
      return res.status(404).json({ error: 'Key not found' });
    }

    return res.status(200).json({
      message: 'Key-value pair updated successfully',
      key: keyValue.key,
      value: keyValue.value,
    });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
});

keyValueRouter.delete('/:key', async (req, res) => {
  const { key } = req.params;

  try {
    const keyValue = await KeyValue.findOneAndDelete({ key });

    if (!keyValue) {
      return res.status(404).json({ error: 'Key not found' });
    }

    return res
      .status(200)
      .json({ message: 'Key-value pair deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = keyValueRouter
```

* * *

## 4\. Testing with Postman

- **POST** `/store` with body `{ "key": "hello", "value": "world" }`  
    → Returns *201 Created* if successful, or *400* if duplicate/missing fields.
    
- **GET** `/store/hello`  
    → Returns `{ "key": "hello", "value": "world" }` if exists, or *404* if not found.
    

* * *

# ✅ Summary

- Introduced **Mongoose schema/model** for data persistence.
    
- Implemented **input validation, duplicate checks, and error handling**.
    
- Built **POST** and **GET** endpoints with robust response handling.
    
- Verified endpoints using **Postman**.
    

Next steps (future lecture): Implement **Update** and **Delete** functionality.

* * *

&nbsp;

# Updating & Deleting Key-Value Pairs with Express + Mongoose

## 1\. Updating a Key-Value Pair (PUT `/store/:key`)

- **Key** comes from `req.params`.
    
- **Value** comes from `req.body`.
    
- Validate: If `value` is missing → return `400 Bad Request`.
    
- Use `findOneAndUpdate` to update only the `value`.
    
- Return the updated document (`{ new: true }` ensures updated version is returned).
    
- If key not found → return `404 Not Found`.
    

```js
keyValueRouter.put('/:key', async (req, res) => {
  const { key } = req.params;
  const { value } = req.body;

  if (!value) {
    return res.status(400).json({ error: '"value" is required' });
  }

  try {
    const keyValue = await KeyValue.findOneAndUpdate(
      { key },
      { value },
      { new: true }
    );

    if (!keyValue) {
      return res.status(404).json({ error: 'Key not found' });
    }

    return res.status(200).json({
      message: 'Key-value pair updated successfully',
      key: keyValue.key,
      value: keyValue.value,
    });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
});

```

* * *

## 2\. Deleting a Key-Value Pair (DELETE `/store/:key`)

- **Key** comes from `req.params`.
    
- Use `findOneAndDelete` to remove it from the database.
    
- If not found → return `404 Not Found`.
    
- If successful → return `200 OK` (with message) or `204 No Content`.
    

```js
keyValueRouter.delete('/:key', async (req, res) => {
  const { key } = req.params;

  try {
    const keyValue = await KeyValue.findOneAndDelete({ key });

    if (!keyValue) {
      return res.status(404).json({ error: 'Key not found' });
    }

    return res
      .status(200)
      .json({ message: 'Key-value pair deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
});

```

* * *

## 3\. Testing in Postman

- **PUT `/store/hello`**
    
    - Body: `{ "value": "universe" }`  
        → Returns *200 OK* with updated value.
- **DELETE `/store/hello`**
    
    - Removes the entry.
        
    - Subsequent GET returns *404 Not Found*.
        
- Deleted keys can be re-used (new POST will work).
    

* * *

## ✅ Summary

- Implemented **PUT** route to update values by key.
    
- Implemented **DELETE** route to remove key-value pairs.
    
- Used **Mongoose methods**: `findOneAndUpdate`, `findOneAndDelete`.
    
- Handled edge cases: missing value, key not found.
    
- Tested endpoints with **Postman** for validation.
    

* * *

👉 You now have **full CRUD functionality**:

- **Create** → POST
    
- **Read** → GET
    
- **Update** → PUT
    
- **Delete** → DELETE
    

* * *

&nbsp;

# Data Persistence & Cleanup in Key-Value REST API Project

## 1\. **Container Stop & Removal**

- Stopping the backend and MongoDB containers with `docker stop backend` and `docker stop mongodb` ensures no containers are running.
    
- MongoDB was run with the `--rm` flag (`-–m`), so when stopped, the container is automatically removed.
    

* * *

## 2\. **Volumes & Persistent Data**

- Running `docker volume ls` shows that the **key-value-data** volume still exists even after containers are stopped.
    
- Volumes ensure that data is **persisted** even when the container is deleted.
    
- When restarting containers with the **same volume name**, previously stored keys/values can still be retrieved.
    

👉 **Important:** If the volume name changes, Docker treats it as new storage → old data will not be accessible.

* * *

## 3\. **Validating Persistence**

- Restarting the database and backend containers allows access to previously stored data.
    
- Example:
    
    - If a `hello` key existed before stopping, after restart it still exists.
        
    - Confirm with **POST** (detects duplicate key) and **GET** requests.
        

* * *

## 4\. **Cleanup Process**

- Stop and remove containers:
    
    ```bash
    docker stop backend
    docker stop mongodb
    ```
    
- Run cleanup script to remove volumes and networks:
    
    ```bash
    ./cleanup.sh
    ```
    
    - Removes `key-value-data` volume.
        
    - Removes `key-value-net` network.
        
- Optional: remove all images for a **fresh start**:
    
    ```bash
    docker image ls -q | xargs docker rmi -f
    ```
    

* * *

## 5\. **Transition to Next Topic**

- Running long and complex `docker run` commands highlights the need for a **more robust and scalable solution**.
    
- This leads naturally to **Docker Compose**, which simplifies multi-container setups.
    

* * *

✅ **Summary**:

- Containers are ephemeral, but **volumes persist data** across container lifecycles.
    
- Data is recoverable as long as the **same volume name** is used.
    
- Cleanup ensures a clean environment before the next stage.
    
- Next step → Learn **Docker Compose** for easier management of multi-container applications.
    

* * *

&nbsp;
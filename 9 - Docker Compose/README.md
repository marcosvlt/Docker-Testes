# Index: Docker Compose Notes

1. [Key Takeaways on Docker Compose](#key-takeaways-on-docker-compose)
   1. [Why Use It?](#1-why-use-it)
   2. [Challenges It Solves](#2-challenges-it-solves)
   3. [Features](#3-features)
   4. [Main Use Cases](#4-main-use-cases)
   
2. [Key Takeaways on Docker Compose Versions](#key-takeaways-on-docker-compose-versions)
   1. [Two Variants of Docker Compose](#1-two-variants-of-docker-compose)
   2. [Behavior and Compatibility](#2-behavior-and-compatibility)
   3. [Troubleshooting](#3-troubleshooting)
   
3. [First Steps with Docker Compose](#first-steps-with-docker-compose)
   1. [Project Setup](#1-project-setup)
   2. [Compose File Basics](#2-compose-file-basics)
   3. [Running Services](#3-running-services)
   4. [Verifying the Setup](#4-verifying-the-setup)
   5. [Stopping Services](#5-stopping-services)
   6. [Key Insights](#6-key-insights)
   
4. [Setting Up Environment Variables in Docker Compose](#setting-up-environment-variables-in-docker-compose)
   1. [Two Ways to Declare Environment Variables](#1-two-ways-to-declare-environment-variables)
   2. [Best Practice – Separate `.env` Files for Credentials](#2-best-practice--separate-env-files-for-credentials)
   3. [Multiple `env_file` Support](#3-multiple-env_file-support)
   4. [Security Consideration](#4-security-consideration)
   5. [Next Step](#5-next-step)
   
5. [Database Initialization Script in Docker Compose](#database-initialization-script-in-docker-compose)
   1. [Purpose of Initialization Script](#1-purpose-of-initialization-script)
   2. [Mounting Script into Container](#2-mounting-script-into-container)
       - [Shorthand Bind Mount](#shorthand-bind-mount)
       - [Explicit Bind Mount](#explicit-bind-mount-preferred-for-readability)
   3. [Running and Validating Initialization](#3-running-and-validating-initialization)
   4. [Key Lessons Learned](#4-key-lessons-learned)
   
6. [Docker Compose: Volumes and Networks](#docker-compose-volumes-and-networks)
   1. [Declaring Volumes and Networks](#1-declaring-volumes-and-networks)
   2. [Using Them in Services](#2-using-them-in-services)
   3. [Persistence](#3-persistence)
   4. [Network Isolation](#4-network-isolation)
   5. [Compose Prefix Behavior](#5-compose-prefix-behavior)
   6. [Custom Project Name](#6-custom-project-name)
   7. [Resource Cleanup](#7-resource-cleanup)
   
7. [Backend Service Setup with Docker Compose](#backend-service-setup-with-docker-compose)
   1. [Building a Custom Image](#1-building-a-custom-image)
   2. [Expose Ports](#2-expose-ports)
   3. [Environment Configuration](#3-environment-configuration)
   4. [Networking](#4-networking)
   5. [Application Connectivity](#5-application-connectivity)
   6. [Workflow with Docker Compose](#6-workflow-with-docker-compose)
   
8. [Service Dependencies and Running with Docker Compose](#service-dependencies-and-running-with-docker-compose)
   1. [Defining Service Dependencies](#1-defining-service-dependencies)
   2. [Starting Services](#2-starting-services)
   3. [Logs Behavior](#3-logs-behavior)
   4. [Application Verification](#4-application-verification)
   5. [Missing Piece – Hot Reloading](#5-missing-piece--hot-reloading)
   
9. [Enabling Hot Reloading with Docker Compose](#enabling-hot-reloading-with-docker-compose)
   1. [Current Setup Recap](#1-current-setup-recap)
   2. [Enabling Hot Reloading](#2-enabling-hot-reloading)
       - [Using the `develop` Key](#using-the-develop-key)
       - [Example Configuration](#example-configuration)
   3. [Running with Watch Mode](#3-running-with-watch-mode)
   4. [Verifying Hot Reloading](#4-verifying-hot-reloading)
   5. [Why Use `develop+watch` Instead of Bind Mounts?](#5-why-use-developwatch-instead-of-bind-mounts)
   6. [Final Notes](#6-final-notes)
   
10. [Docker Compose CLI Management](#docker-compose-cli-management)
    1. [Docker Compose CLI Basics](#1-docker-compose-cli-basics)
    2. [Service Management](#2-service-management)
    3. [Monitoring and Logs](#3-monitoring-and-logs)
    4. [Targeted Control](#4-targeted-control)
    5. [Cleaning Up](#5-cleaning-up)
    
11. [Exploring Docker Compose CLI](#exploring-docker-compose-cli)
    1. [Documentation is Built-in](#1-documentation-is-built-in)
    2. [`stats` Command (Example)](#2-stats-command-example)
    3. [Service Name Convenience](#3-service-name-convenience)
    4. [Practical Debugging](#4-practical-debugging)
    5. [Cleanup](#5-cleanup)


# Key Takeaways on Docker Compose

#### 1\. Why Use It?

- Simplifies multi-container applications by replacing long `docker run` commands with a single declarative file (`docker-compose.yml`).
    
- Manages dependencies, networking, volumes, and environment variables in a central place.
    

#### 2\. Challenges It Solves

- Manual linking of containers is error-prone.
    
- Startup order issues (e.g., backend starting before the database).
    
- Complex management of networks and volumes.
    
- Difficulty in replicating environments consistently.
    
- Distributed and conflicting environment variable configurations.
    

Compose addresses these issues with a declarative, consistent, and reproducible setup.

#### 3\. Features

- Define services (containers), networks, and volumes in YAML.
    
- Support for dependencies (`depends_on`) and startup order.
    
- Easy port mapping, environment variables, and persistent storage.
    
- Works across local, testing, staging, and simple production environments.
    

#### 4\. Main Use Cases

- Local development: Run complex applications with one command.
    
- Testing and staging: Replicate production-like environments for CI/CD.
    
- CI/CD pipelines: Start services with `docker compose up -d`, run tests, then bring everything down.
    
- Simple production deployments: Suitable for smaller applications without requiring Kubernetes or Swarm.
    

&nbsp;

Here’s a **key takeaway summary** of your lecture:

* * *

### Key Takeaways on Docker Compose Versions

#### 1\. Two Variants of Docker Compose

- **Standalone version (`docker-compose`)**
    
    - Installed separately (e.g., via Homebrew or manual installation on Linux).
        
    - Identified by the dash (`docker-compose`).
        
- **Plugin version (`docker compose`)**
    
    - Installed by default with Docker Desktop.
        
    - Installed during official Linux/Ubuntu setup instructions.
        
    - Uses a space instead of a dash.
        

#### 2\. Behavior and Compatibility

- Both versions provide the **same functionality** and work the same way.
    
- Command syntax differs only in the dash vs. space.
    
- Version numbers are aligned; no feature differences.
    

#### 3\. Troubleshooting

- If `docker-compose` returns an error like *"command not found"*, use `docker compose`.
    
- For all upcoming lectures, you can safely use **either variant** depending on your setup.
    

&nbsp;

# First Steps with Docker Compose

## 1\. Project Setup

- Working in a folder called **compose**, which contains:
    
    - `backend/` with the **Key Value app code** (no `node_modules`, no `.env`, only source code + Dockerfile).
        
    - `compose.yaml` file at the top level (not inside `backend/`).
        
- Application (`server.js`) depends on **MongoDB**, so the first Compose service will be the database.
    

* * *

## 2\. Compose File Basics

- Preferred naming: `compose.yaml`
    
    - Older format `docker-compose.yaml` is still supported.
- Define services under `services:`.
    
- Example service definition for MongoDB:
    

```yaml
services:
  db:
    image: mongodb/mongodb-community-server:7.0-ubuntu2004
    ports:
      - "27017:27017"
```

- Ports can be defined in short (`"host:container"`) or long form.

* * *

## 3\. Running Services

- Start services with:

```bash
docker compose up -d

```

- Without `-d` (detached mode), logs stream directly to the terminal.
    
- Docker Compose automatically:
    
    - Pulls missing images.
        
    - Creates a **default network** for the project.
        
    - Names containers (e.g., `compose-db-1`).
        

* * *

## 4\. Verifying the Setup

- Check running containers:

```bash
docker ps
```

- Check networks you see that compose created a newtork

```bash
docker network ls
```

- Connect to the MongoDB container using another container on the same network:

```bash
docker run --rm -it --name debugsh --network 9-dockercompose_default mongo:7.0 mongosh mongodb://mongodb
```

- Databases available are the default MongoDB databases.

* * *

## 5\. Stopping Services

- Stop with `CTRL+C` (if running in foreground).
    
- Or gracefully stop with:
    

```bash
docker compose down
```

- Note: Sometimes shutdown may take ~10 seconds before termination.

* * *

## 6\. Key Insights

- **Docker Compose simplifies orchestration**: manages containers, networks, and lifecycle automatically.
    
- Achieved the same result as manual `docker run` commands but with a **single YAML configuration file**.
    
- This is the foundation for scaling up to multi-service applications.
    

* * *

&nbsp;

# **Setting Up Environment Variables in Docker Compose**

1.  **Two Ways to Declare Environment Variables**
    
    - **Inline with `environment` key**: Define variables directly in `compose.yaml`.  
        Example:
        
        ```yaml
        environment:
          - MONGO_INITDB_ROOT_USERNAME=root
          - MONGO_INITDB_ROOT_PASSWORD=root_password
        ```
        
        Downside: credentials are stored in source control if committed.
        
    - **Using `.env` files**: Store sensitive variables in separate files (commonly excluded from commits).  
        Example:
        
        ```yaml
        env_file:
          - .env
          
        ```
        
2.  **Best Practice – Separate `.env` Files for Credentials**
    
    - **`.env.db-root-creds`** → holds root credentials.
        
    - **`.env.db-key-value`** → holds key-value DB credentials.
        
    - Helps organize secrets and simplifies passing credentials to both DB and application.
        
3.  **Multiple `env_file` Support**
    
    - Compose allows loading **several `.env` files** into the same container.
        
    - Useful for separating root credentials from application-specific credentials.
        
4.  **Security Consideration**
    
    - Compose files (`compose.yaml`) should be versioned.
        
    - Sensitive data should **never be committed**; always keep credentials in `.env` files excluded by `.gitignore`.
        
5.  **Next Step**
    
    - With credentials defined and injected, you still need to configure MongoDB initialization scripts so that the **key-value user and database** are automatically created at container startup.

&nbsp;


# Database Initialization Script in Docker Compose

## 1\. Purpose of Initialization Script

- The goal was to **initialize the key-value database** in MongoDB.
    
- The script (`mongo-init.js`) creates a **user with read/write access** to the key-value database using environment variables.
    

### Example (`mongo-init.js`)

```js
const keyValueDb = process.env.KEY_VALUE_DB;
const keyValueUser = process.env.KEY_VALUE_USER;
const keyValuePassword = process.env.KEY_VALUE_PASSWORD;

db.getSiblingDB(keyValueDb).createUser({
  user: keyValueUser,
  pwd: keyValuePassword,
  roles: [
    {
      role: "readWrite",
      db: keyValueDb
    }
  ]
});
```

* * *

## 2\. Mounting Script into Container

Two approaches were demonstrated to map the init script into the container:

### Shorthand Bind Mount

```yaml
volumes:
  - ./db-config/mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
```

### Explicit Bind Mount (preferred for readability)

```yaml
volumes:
  - type: bind
    source: ./db-config/mongo-init.js
    target: /docker-entrypoint-initdb.d/mongo-init.js
    read_only: true
```

> The explicit syntax improves readability by clearly showing the mount type.

* * *

## 3\. Running and Validating Initialization

- `docker compose down` was used to **clean up containers and networks** before starting fresh.
    
- After running `docker compose up`, the logs confirmed the script executed successfully (via custom `print` log line).
    
- Validation:
    
    - Connection to the database showed **authorization errors on `admin`** (expected).
        
    - Connection to the **key-value DB worked successfully**, confirming correct role assignment.
        

```
docker run --rm -it --name debugsh --network 9-dockercompose_default mongo:7.0 mongosh mongodb://key-value-user:123456
@mongodb/key-value-db
```

* * *

## 4\. Key Lessons Learned

- Use **init scripts** to automate user/database creation at container startup.
    
- Store **credentials in `.env` files**, not directly in Compose files.
    
- Prefer **explicit bind mounts** in Docker Compose for clarity.
    
- Always **validate initialization** by checking logs and testing DB connections.
    

* * *

&nbsp;

# **Docker Compose: Volumes and Networks**

1.  **Declaring Volumes and Networks**
    
    - Use top-level `volumes:` and `networks:` in `docker-compose.yml`.
        
    - Example:
        
        ```yaml
        volumes:
          mongodb-data:
        networks:
          key-value-net:
        ```
        
2.  **Using Them in Services**
    
    - Volumes and networks are only created if used by a service.
        
    - Example for MongoDB:
        
        ```yaml
        services:
          db:
            volumes:
              - type: volume
                source: mongodb-data
                target: /data/db
            networks:
              - key-value-net
        ```
        
3.  **Persistence**
    
    - The MongoDB data is stored in `/data/db` inside the container.
        
    - Binding the named volume ensures data persists even if the container is removed.
        
4.  **Network Isolation**
    
    - By defining a custom network (`key-value-net`), services can communicate securely and be isolated from other containers.
5.  **Compose Prefix Behavior**
    
    - Docker Compose automatically prefixes resources with the project name (e.g., `compose_mongodb-data`).
        
    - This helps avoid name collisions across different Compose projects.
        
6.  **Custom Project Name**
    
    - You can customize the prefix by adding a `name:` at the top of your `docker-compose.yml`:
        
        ```yaml
        name: key-value-app
        ```
        
    - Now resources will be created with the new prefix (e.g., `key-value-app_mongodb-data`).
        
7.  **Resource Cleanup**
    
    - `docker compose down` removes containers and networks, but not volumes.
        
    - To remove volumes:
        
        ```bash
        docker volume rm <volume-name>
        ```
        

# **Backend Service Setup with Docker Compose**

1.  **Building a Custom Image**
    
    - Instead of pulling from Docker Hub, use the local Dockerfile to build your image.
        
    - Define with `build:` option:
        
        ```yaml
        services:
          backend:
            build:
              context: ./backend
              dockerfile: Dockerfile.dev
        ```
        
2.  **Expose Ports**
    
    - Map the container port `3000` to host port `3000`:
        
        ```yaml
        ports:
          - "3000:3000"
        ```
        
3.  **Environment Configuration**
    
    - Use both an `.env` file and inline environment variables:
        
        ```yaml
        env_file:
          - .env
          
        ```
        
4.  **Networking**
    
    - Attach the backend service to the same custom network as the database (`key-value-net`).
        
    - Enables the backend to connect to the database using `db` as hostname.
        
5.  **Application Connectivity**
    
    - In `server.js`, the backend reads:
        
        - `MONGODB_HOST=db` → ensures connectivity to the database container.
            
        - `PORT=3000` → backend listens for HTTP requests.
            
6.  **Workflow with Docker Compose**
    
    - Compose automatically builds the image before running the container.
        
    - Ensures the backend always uses the latest local code changes.
        

* * *

&nbsp;
# **Service Dependencies and Running with Docker Compose**

### 1\. Defining Service Dependencies

- Use `depends_on` to explicitly declare dependencies between services.
    
- Ensures a service (e.g., backend) only starts after its dependencies (e.g., database, cache) are running.
    
    ```yaml
    services:
      backend:
        depends_on:
          - db
    
    ```
    

### 2\. Starting Services

- To start all services and rebuild images if needed:
    
    ```bash
    docker compose up --build
    ```
    
- This command triggers both:
    
    - `docker build` for services with a `build:` option.
        
    - `docker run` to start containers.
        

### 3\. Logs Behavior

- When running `docker compose up`, logs from all services are streamed together.
    
- Each service is color-coded for readability, but outputs may appear interleaved.
    
- Example: You’ll see database logs, backend logs, and connection messages all in the same stream.
    

### 4\. Application Verification

- Once running, confirm backend connectivity:
    
    - Backend logs show successful DB connection.
        
    - Application listens on port `3000`.
        
- Test endpoints with requests (e.g., `POST /store`, then `GET /store`) to validate functionality.
    

### 5\. Missing Piece – Hot Reloading

- Even though the backend runs `nodemon`, hot reloading does **not** work yet.
    
- Reason: no **bind mounts** are defined in `docker-compose.yml`.
    
- Without mounts or `docker compose watch`, code changes on the host do not sync into the container.
    

&nbsp;

# Enabling Hot Reloading with Docker Compose

## 1\. Current Setup Recap

- Backend and database services were successfully configured and running with Docker Compose.
    
- The application could handle requests, but **hot reloading (via Nodemon)** was not yet enabled.
    

* * *

## 2\. Enabling Hot Reloading

### Using the `develop` Key

- Docker Compose offers a `develop` configuration with a **`watch`** option.
    
- This syncs local source code with the container so Nodemon detects changes automatically.
    

### Example Configuration

```yaml
services:
  backend:
    build: ./backend
    develop:
      watch:
        - action: sync
          path: ./backend/src
          target: /app/src
          ignore:
            - node_modules
```

* * *

## 3\. Running with Watch Mode

- Standard command:
    
    ```bash
    docker compose up
    ```
    
    → Starts services but does **not** enable hot reloading.
    
- Correct command:
    
    ```bash
    docker compose up --watch
    ```
    
    → Enables hot reloading and syncs changes between local files and the container.
    

* * *

## 4\. Verifying Hot Reloading

- Example update to `server.js`:
    
    ```javascript
    app.get
    ("/", (req, res) => {
      res.json({ message: "Welcome to our key value store" });
    });
    ```
    
- After saving, changes are reflected immediately inside the running container.
    

* * *

## 5\. Why Use `develop+watch` Instead of Bind Mounts?

- **Bind mounts (`volumes`)**:
    
    ```yaml
    volumes:
      - ./backend/src:/app/src
    ```
    
    → Caused issues where Nodemon failed to detect file changes.
    
- **Develop + Watch**:  
    → More reliable, native solution for syncing code and triggering Nodemon.
    

* * *

## 6\. Final Notes

- Docker Compose allows **declarative configuration** of services, volumes, and networks.
    
- Simplifies container orchestration compared to running `docker` commands manually.
    
- Using `--watch` significantly improves development workflow by enabling **fast feedback loops**.
    

* * *

&nbsp;

# Docker Compose CLI Management

1.  **Docker Compose CLI Basics**
    
    - `docker compose` can be used instead of `docker-compose` (newer syntax, backward-compatible).
        
    - Use `--help` to explore available commands and options.
        
2.  **Service Management**
    
    - `docker compose up`: Create and start containers.
        
    - `docker compose down`: Stop and remove containers, networks (add `-v` to remove volumes, `--remove-orphans` to clean up unused containers).
        
    - `docker compose start/stop [service]`: Start or stop specific services.
        
    - Services can be started individually, and dependencies will be handled automatically (if defined).
        
3.  **Monitoring and Logs**
    
    - `docker compose ps`: Shows only containers belonging to the current project (more focused than `docker ps`).
        
    - `docker compose logs [service]`: View logs by service name, no need for container IDs.
        
4.  **Targeted Control**
    
    - Services can be managed independently (useful in multi-service projects).
        
    - Dependency resolution works automatically when declared in the compose file.
        
    - Without declared dependencies, services may fail if required components are not running.
        
5.  **Cleaning Up**
    
    - Volumes are **not removed** by default with `docker compose down`.
        
    - Use `-v` flag to explicitly remove volumes when tearing down.
        
    - Orphaned containers can appear if service names change—clean with `--remove-orphans`.
        

* * *

&nbsp;

# Exploring Docker Compose CLI

1.  **Documentation is Built-in**
    
    - `--help` flag is your best tool.
        
    - Works with all levels: `docker compose --help`, `docker compose <command> --help`.
        
    - Example: `docker compose stats --help` shows options and usage.
        
2.  **`stats` Command (Example)**
    
    - `docker compose stats`: Displays live stream of CPU/memory usage of running containers.
        
    - Options:
        
        - Show all containers, or filter by specific service.
            
        - Example: `docker compose stats backend` → stats only for the `backend` service.
            
    - Useful for quick performance insights.
        
3.  **Service Name Convenience**
    
    - With Docker Compose, you can refer to **services by name** (`backend`, `db`) instead of container IDs.
        
    - Makes interaction much simpler than using raw Docker CLI.
        
4.  **Practical Debugging**
    
    - Some commands may show quirks in terminal output (like scrolling with `stats`).
        
    - Solution: scroll down to see live updates.
        
5.  **Cleanup**
    
    - At the end of testing, use:
        
        ```bash
        docker compose down -v
        ```
        
        to remove containers, networks, and volumes completely.
        

* * *

&nbsp;


# Index

- [Key Summary: Using Environment Variables in Docker](#key-summary-using-environment-variables-in-docker)
    - [Methods to Set Environment Variables](#methods-to-set-environment-variables)
    - [Example Output](#example-output)
    - [Tips](#tips)
    - [Cleanup Commands](#cleanup-commands)
- [Key Summary: Using `.env` Files with Docker](#key-summary-using-env-files-with-docker)
    - [What You Learned](#what-you-learned)
    - [Why Use `.env` Files?](#why-use-env-files)
    - [Example `.env` Files](#example-env-files)
    - [How to Exclude `.env` Files from Docker Images](#how-to-exclude-env-files-from-docker-images)
    - [Docker Run with `.env` File](#docker-run-with-env-file)
    - [Verify It's Working](#verify-its-working)
    - [Conclusion](#conclusion)

# Key Summary: Using Environment Variables in Docker

**Goal:** Learn how to pass and override environment variables in Docker containers for better flexibility and configuration management.

* * *

# Methods to Set Environment Variables

1.  **In the Dockerfile (Default Values)**
    
    ```dockerfile
    ENV PORT=5000
    ENV APP_NAME="My Awesome Application"
    ```
    
    Access in Node.js:
    
    ```js
    const port = process.env.PORT;
    const appName = process.env.APP_NAME;
    ```
    

1.  **During `docker run` (Override Defaults)**  
    Use `-e` or `--env` flag to pass env vars at runtime:
    
    ```bash
    docker run -d -p 8080:8080 \
      -e PORT=8080 \
      -e APP_NAME="Running on 8080" \
      --name express_8080 \
      express
    ```
    

* * *

# Example Output

```bash
curl http://localhost:8080
# Hello from Running on 8080
```

* * *

# Tips:

- Setting env vars in Dockerfile ensures **default values**.
    
- Use `-e` in `docker run` to **override** without rebuilding images.
    
- Multiple env vars can be passed using multiple `-e` flags.
    
- Use `docker logs <container>` to verify which env vars are used at runtime.
    

* * *

# Cleanup Commands

```bash
# Stop and remove all containers
docker kill $(docker ps -q)
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Use -f to force remove if necessary
docker rmi -f $(docker images -q)
```

* * *

**Conclusion:**  
Environment variables enhance flexibility, allowing configuration **without modifying images**. Defaults are defined in Dockerfile; runtime values can override them using the `docker run` command.

# Key Summary: Using `.env` Files with Docker

## What You Learned:

You can manage multiple environment variables more efficiently in Docker using `.env` files, instead of cluttering the `docker run` command with multiple `-e` flags.

* * *

# Why Use `.env` Files?

- **Organized Configuration**: Easier to manage many environment variables.
    
- **Environment-Specific Files**: Use different files for dev, prod, staging, etc.
    
- **Improved Security**: Sensitive data stays out of Docker images.
    

* * *

# Example `.env` Files

**.env.prod**

```env
PORT=9000
APP_NAME=My Prod App
```

**.env.dev**

```env
PORT=3000
APP_NAME=My Dev App
```

* * *

# How to Exclude `.env` Files from Docker Images

Add this to `.dockerignore`:

```
**/.env*
```

* * *

# Docker Run with `.env` File

```bash
# Run with production env
docker run --env-file .env.prod -d -p 9000:9000 --name express-prod express

# Run with development env
docker run --env-file .env.dev -d -p 3000:3000 --name express-dev express
```

* * *

# Verify It's Working

```bash
# Check logs
docker logs express-prod
docker logs express-dev

# Curl the app
curl http://localhost:9000  # Outputs: Hello from My Prod App
curl http://localhost:3000  # Outputs: Hello from My Dev App
```

* * *

# Conclusion:

`.env` files simplify environment variable management in Docker, especially for **development**. They help maintain cleaner commands, avoid hardcoding, and support environment-specific configurations.
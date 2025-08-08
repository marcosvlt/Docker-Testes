# Index

- [Building a Multi-Stage Dockerfile for a React App](#building-a-multi-stage-dockerfile-for-a-react-app)
    - [Goal](#1-goal)
    - [.dockerignore Setup](#2-dockerignore-setup)
    - [First Stage: Build with Node](#3-first-stage-build-with-node)
    - [Testing the Build Stage](#4-testing-the-build-stage)
    - [Example Dockerfile (Build Stage Only)](#5-example-dockerfile-build-stage-only)
- [Multi-Stage Dockerfile: Build & Serve a React App with Nginx](#multi-stage-dockerfile-build--serve-a-react-app-with-nginx)
    - [Purpose](#1-purpose)
    - [Multi-Stage Workflow](#2-multi-stage-workflow)
    - [Example Multi-Stage Dockerfile](#3-example-multi-stage-dockerfile)
    - [Building & Running the Container](#4-building--running-the-container)
    - [Updating the App](#5-updating-the-app)
    - [Deployment Insight](#6-deployment-insight)
    - [Cleanup](#7-cleanup)

# Building a Multi-Stage Dockerfile for a React App 

### 1\. **Goal**

- Create a **multi-stage Dockerfile**:
    
    1.  **Build stage** → Compile production bundle with Node.
        
    2.  **Serve stage** → Use an HTTP server (later, `nginx`) to serve the bundle.
        

* * *

### 2\. **`.dockerignore` Setup**

Ignore unnecessary files when building the image:

```
node_modules
build
```

- **Reason**:
    
    - `node_modules` will be installed fresh inside the container.
        
    - `build` should always be generated during the Docker build, not copied from local.
        

* * *

### 3\. **First Stage: Build with Node**

- **Base image**: `node:22-alpine` (lightweight, faster download/build).
    
- **Working directory**: `/app`
    
- **Steps**:
    
    1.  Copy `package.json` + `package-lock.json`.
        
    2.  Install dependencies with `npm ci`.
        
    3.  Copy all source files (safe because `.dockerignore` excludes unwanted dirs).
        
    4.  Run `npm run build` to produce `/build` folder.
        

* * *

### 4\. **Testing the Build Stage**

1.  Build the image:
    
    ```bash
    docker build -t react-app:alpine .
    ```
    
2.  Run a container with a shell:
    
    ```bash
    docker run -it react-app:alpine sh
    ```
    
3.  Inside container:
    
    ```bash
    ls        # confirm build/ and node_modules/
    tree build  # view static/js, static/css, media files
    ```
    
4.  Exit container:
    
    ```bash
    exit
    ```
    

* * *

### 5\. **Example Dockerfile (Build Stage Only)**

```dockerfile
# 1 Build production
FROM node:22-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build
# 2 serve the bundle
```

- This stage produces the **optimized production files** in `/app/build`.
    
- Serving stage (with `nginx`) will be added in the next step.
    

* * *

Here’s a **clear, structured summary** of that lecture, with code examples.

* * *

# Multi-Stage Dockerfile: Build & Serve a React App with Nginx

### 1\. **Purpose**

- Use **multi-stage builds** to:
    
    - Produce **smaller, leaner, and more secure** final images.
        
    - Separate the **build stage** (compile app) from the **serve stage** (host static files).
        
- Serve the production-ready React app via **Nginx 1.27.0**.
    

* * *

### 2\. **Multi-Stage Workflow**

1.  **Stage 1 – Build**
    
    - Use `node:22-alpine`.
        
    - Install dependencies and run `npm run build`.
        
    - Output is in `/app/build`.
        
2.  **Stage 2 – Serve**
    
    - Use `nginx:1.27.0`.
        
    - Copy the `/app/build` folder from Stage 1 into Nginx’s default web root:
        
        ```
        /usr/share/nginx/html
        ```
        

* * *

### 3\. **Example Multi-Stage Dockerfile**

```dockerfile
# 1 Build production
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# 2 serve the bundle
FROM nginx:1.27.0
COPY --from=build /app/build /usr/share/nginx/html

```

* * *

### 4\. **Building & Running the Container**

#### Build image:

```bash
docker build -t react-app:nginx .
```

#### Run container (map host port 9000 to Nginx port 80):

```bash
docker run -d -p 9000:80 react-app:nginx
```

- Visit: **[http://localhost:9000](http://localhost:9000/)**

* * *

### 5\. **Updating the App**

- Modify source code.
    
- Rebuild image with a new tag (e.g., `blue`):
    

```bash
docker build -t react-app:blue .
docker run -d -p 9001:80 react-app:blue
```

- **Now both versions run side-by-side**:
    
    - `http://localhost:9000` → old version
        
    - `http://localhost:9001` → new version
        

* * *

### 6\. **Deployment Insight**

- This setup mimics **blue-green deployment**:
    
    - Keep old version live while introducing the new one.
        
    - Gradually shift traffic to the new container.
        
    - Decommission the old container after validation.
        
- Benefits: **Zero downtime**, smooth rollouts.
    

* * *

### 7\. **Cleanup**

Stop and remove all running containers:

```bash
docker stop $(docker ps -q)
```

Remove all images:

```bash
docker rmi $(docker images -q)
```


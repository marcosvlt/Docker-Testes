# **Index**

- [Purpose of Volumes](#purpose-of-volumes)
- [Types of Docker Volumes](#types-of-docker-volumes)
    - [Anonymous Volumes](#1-anonymous-volumes)
    - [Bind Mounts](#2-bind-mounts)
    - [Named Volumes](#3-named-volumes)
- [Key Benefits Recap](#key-benefits-recap)
- [Bind Mounts for React Development](#1-bind-mounts-for-react-development)
    - [Why Use Bind Mounts?](#why-use-bind-mounts)
    - [Step-by-Step Setup](#step-by-step-setup)
- [Docker Named Volumes](#docker-named-volumes)
    - [What They Are](#what-they-are)
    - [Key Benefits](#key-benefits)
    - [Common Use Cases](#common-use-cases)
    - [Example: Sharing Data Between Nginx Containers](#example-sharing-data-between-nginx-containers)
- [Managing Docker Volumes with the CLI](#managing-docker-volumes-with-the-cli)
    - [Listing Volumes](#1-listing-volumes)
    - [Inspecting a Volume](#2-inspecting-a-volume)
    - [Creating a Volume](#3-creating-a-volume)
    - [Removing a Volume](#4-removing-a-volume)
    - [Filtering and Cleaning Up](#5-filtering-and-cleaning-up)
    - [Example Workflow](#6-example-workflow)
    - [Key Takeaways](#key-takeaways)


# **Purpose of Volumes**

- **Persist Data Beyond Container Lifecycle**  
    Data stored in volumes is **independent** of the container’s filesystem, so it remains available even after the container stops or is removed.
    
- **Share Data Between Containers**  
    Multiple containers can access the same volume simultaneously.
    
- **Enable Backup & Recovery**  
    Since volumes live outside the container’s filesystem, data remains safe if a container crashes.
    
- **Increase Flexibility**  
    Decouples data from the application runtime, making deployment and management easier.
    

* * *

# **Types of Docker Volumes**

## **1. Anonymous Volumes**

- Automatically created by Docker.
    
- **No name**, making them hard to reuse or manage.
    
- Suitable only for **temporary data** that doesn’t need persistence.
    
- **Not commonly used**.
    

## **2. Bind Mounts**

- Link **specific files or directories** from the host to the container.
    
- Useful for **real-time development** (e.g., hot reloading in a React app).
    
- Reflects changes instantly between host and container.
    

**Example – Bind Mount for Development**:

```
docker run -d \
  --name react-dev \
  -p 3000:3000 \
  -v $(pwd):/app \
  -w /app \
  node:22 \
  npm start
```

Here:

- `-v $(pwd):/app` mounts the current directory into `/app` inside the container.
    
- Hot reload works because files sync instantly.
    

## **3. Named Volumes**

- Created and managed via Docker CLI.
    
- Can be **reused across containers**.
    
- Ideal for **persistent storage**.
    

**Example – Create and Use Named Volume**:

```
# Create a named volume
docker volume create my_data

# Use the volume in a container
docker run -d \
  --name db \
  -v my_data:/var/lib/mysql \
  mysql:8.0
```

Here:

- `my_data` persists MySQL database files.
    
- Even if the container is removed, `my_data` retains the data.
    

* * *

### **Key Benefits Recap**

1.  **Data Persistence** – Survives container removal.
    
2.  **Data Sharing** – Accessible by multiple containers.
    
3.  **Backup & Recovery** – Independent from container’s filesystem.
    
4.  **Flexibility** – Decouples data from app runtime.

# **1\. Bind Mounts for React Development**

## **Why Use Bind Mounts?**

- Enables **hot reloading** during development.
    
- Lets container reference **local source code** without rebuilding the image.
    
- Useful for consistent setup across environments—no need to install Node locally.
    

* * *

## **Step-by-Step Setup**

### **1\. Create Development Dockerfile**

```dockerfile
# 1. Build our production bundle
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json .
RUN npm ci

COPY . .
CMD ["npm", "start"]


```

* * *

### **2\. Build Development Image**

```bash
docker build -t react-app:dev -f Dockerfile.dev .
```

* * *

### **3\. Run Without Bind Mount (No Hot Reload)**

```bash
docker run -d --rm -p 3000:3000 react-app:dev
```

- This won’t hot reload because files inside the container don’t change when host files change.

* * *

### **4\. Run With Bind Mounts (Hot Reload Enabled)**

```bash
docker run --rm -d -p 3000:3000 \
  -v "$(pwd)/public:/app/public" \
  -v "$(pwd)/src:/app/src" \
  react-app:dev

```

**Explanation:**

- `-v host_path:container_path`
    
- Host `./public` → Container `/app/public`
    
- Host `./src` → Container `/app/src`
    
- Hot reload works because the dev server (`npm start`) detects changes in mounted folders.
    

* * *

### **5\. Editing Code**

- Change a file in `src/` locally.
    
- Browser refreshes automatically without rebuilding the Docker image.
    

* * *

### **Key Points**

- **Bind mounts** bypass the need to rebuild images for code changes.
    
- **Hot reloading** only works if the process inside the container supports it.
    
- Great for large, complex setups—one `docker run` command can set up everything.

# **Docker Named Volumes**

## **What They Are**

- **Named volumes** are Docker-managed storage areas.
    
- Exist **independently of container lifecycles**—deleting containers does not delete the volume or its data.
    
- Commonly used to **share data between containers** and **persist data** outside the container filesystem.
    

* * *

## **Key Benefits**

1.  **Persistence** – Data survives container removal.
    
2.  **Data Sharing** – Multiple containers can access the same data.
    
3.  **Consistency** – All containers see the same updates instantly.
    
4.  **Scalability** – Supports horizontal scaling with shared storage.
    

* * *

## **Common Use Cases**

- Databases (e.g., MySQL, Postgres) where data must survive restarts.
    
- Web servers serving the same static content from multiple containers.
    
- Any scenario where data needs to be **centralized and reusable**.
    

* * *

## **Example: Sharing Data Between Nginx Containers**

### **1\. Create a Named Volume**

```bash
docker volume create website-data
```

* * *

### **2\. Start First Container (Main)**

```bash
docker run -d \
  -p 3000:80 \
  --name website-main \
  -v website-data:/usr/share/nginx/html \
  nginx:1.27.0
```

- Mounts the `website-data` volume into Nginx's HTML directory.

* * *

### **3\. Start Additional Containers Using the Same Volume**

```bash
docker run -d \
  -p 3001:80 \
  --name website-readonly1 \
  -v website-data:/usr/share/nginx/html \
  nginx:1.27.0

docker run -d \
  -p 3002:80 \
  --name website-readonly2 \
  -v website-data:/usr/share/nginx/html \
  nginx:1.27.0

docker run -d \
  -p 3003:80 \
  --name website-readonly3 \
  -v website-data:/usr/share/nginx/html \
  nginx:1.27.0
```

- All containers share the same volume content.

* * *

### **4\. Modify Content in One Container**

```bash
docker exec -it website-main sh -c \
  'echo "Hello World" > /usr/share/nginx/html/index.html'
```

- The change appears instantly in **all containers** mounting the same volume.

* * *

### **5\. Verify Across Containers**

```bash
docker exec -it website-readonly1 cat /usr/share/nginx/html/index.html
```

- Output will match the updated content from `website-main`.

* * *

### **Horizontal Scaling Insight**

- Since all containers share identical data via the same volume:
    
    - You can run many containers in parallel.
        
    - Place a **load balancer** in front to distribute traffic.
        
    - Any content update propagates instantly to all containers.
        


* * *

# **Managing Docker Volumes with the CLI**

## **1\. Listing Volumes**

- Show all volumes:

```bash
docker volume ls
```

- Default driver: `local`
    
- Can filter or format output:
    

```bash
docker volume ls --filter name=website-data
docker volume ls --filter dangling=true
docker volume ls -q   # names only
```

* * *

## **2\. Inspecting a Volume**

- Get detailed info (name, driver, created time, mount point):

```bash
docker volume inspect website-data
```

- On macOS/Windows, volumes are stored in a VM (not directly visible on the host filesystem).

* * *

## **3\. Creating a Volume**

```bash
docker volume create website-data
```

* * *

## **4\. Removing a Volume**

- Volumes in use by containers **cannot** be removed.
    
- Stop and remove containers first:
    

```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)

# Remove the volume
docker volume rm website-data
```

* * *

## **5\. Filtering and Cleaning Up**

- Filter unused ("dangling") volumes:

```bash
docker volume ls --filter dangling=true
```

- Remove dangling volumes:

```bash
docker volume rm $(docker volume ls --filter dangling=true -q)
```

- Alternative full cleanup:

```bash
docker system prune
```

* * *

## **6\. Example Workflow**

```bash
# Create volumes
docker volume create website-data
docker volume create another-volume

# Filter by name
docker volume ls --filter name=website-data

# Show dangling volumes
docker volume ls --filter dangling=true

# Remove unused volumes
docker volume rm $(docker volume ls --filter dangling=true -q)
```

* * *

## **Key Takeaways**

- **`docker volume ls`** → list volumes
    
- **`docker volume inspect`** → details about a volume
    
- **`docker volume create`** → create a named volume
    
- **`docker volume rm`** → remove a volume (only if unused)
    
- **Dangling volumes** are unused and can be cleaned up for space.
    

* * *


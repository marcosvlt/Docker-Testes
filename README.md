
# Índice

- [Logging Into DockerHub in the Docker CLI](#logging-into-dockerhub-in-the-docker-cli)
    - [1. Criando uma Conta](#1-creating-an-account)
    - [2. Docker CLI Login](#2-docker-cli-login)
    - [3. Search and Pull Images via CLI](#3-search-and-pull-images-via-cli)
    - [4. Image Versioning Behavior](#4-image-versioning-behavior)
    - [5. Best Practices](#5-best-practices)
    - [6. Performance Tip](#6-performance-tip)
- [Docker Image Tagging, Pulling & Pushing – Summary Notes](#docker-image-tagging-pulling--pushing--summary-notes)
    - [1. Image Tagging Essentials](#1-image-tagging-essentials)
    - [2. Tag Versioning Best Practices](#2-tag-versioning-best-practices)
    - [3. Managing Images Locally](#3-managing-images-locally)
    - [4. Pulling Images & Tags](#4-pulling-images--tags)
    - [5. Build & Tag Custom Image](#5-build--tag-custom-image)
    - [6. Push to Docker Hub](#6-push-to-docker-hub)
    - [7. Repository Management](#7-repository-management)
    - [8. Pro Tip](#8-pro-tip)
- [Dockerfile Overview – Notes](#dockerfile-overview--notes)
    - [O que é um Dockerfile?](#what-is-a-dockerfile)
    - [Dockerfile Structure](#dockerfile-structure)
    - [Benefits of Dockerfiles](#benefits-of-dockerfiles)
    - [Docker’s Layered Architecture](#dockers-layered-architecture)
    - [Key Insight](#key-insight)
- [Dockerfile Practice: Automating Nginx Customization](#dockerfile-practice-automating-nginx-customization)
    - [Objective](#objective)
    - [Steps](#steps)
    - [Dockerfile Contents](#dockerfile-contents)
    - [Build the Docker Image](#build-the-docker-image)
    - [Run the Container](#run-the-container)
    - [Clean Up and Retag (Optional)](#clean-up-and-retag-optional)
    - [Key Concepts Highlighted](#key-concepts-highlighted)

---

# Logging Into DockerHub in the Docker CLI

## 1\. **Creating an Account**

- Go to [hub.docker.com](https://hub.docker.com/)
    
- Sign up using:
    
    - Email/password
        
    - GitHub or Google
        
- After signing up:
    
    - Set username, view/edit profile
        
    - Optional: set/reset password if using GitHub/Google
        

* * *

## 2\. **Docker CLI Login**

- Login to Docker Hub via CLI:
    
    ```bash
    docker login
    ```
    
    - Enter **username**
        
    - Use **Personal Access Token (PAT)** instead of password:
        
        - Create PAT in Docker Hub → Profile → Security → New Access Token
            
        - Example name: `docker-cli`, set permissions (e.g., Read/Write)
            

* * *

## 3\. **Search and Pull Images via CLI**

- **Search for images:**
    
    ```bash
    docker search ubuntu
    ```
    
    - Shows available images by name (not tags).
- **Pull an image:**
    
    ```bash
    docker pull ubuntu            # pulls 'latest' tag
    docker pull ubuntu:24.04     # pulls specific version
    docker pull ubuntu:22.04
    ```
    

* * *

## 4\. **Image Versioning Behavior**

- `docker images` shows:
    
    - Image **name**, **tag**, **ID**, and **size**
- Note: Multiple tags can point to the **same image ID/digest**
    
- Pulling a tag already in local cache = no download
    

* * *

## 5\. **Best Practices**

- **Login** required to push images; not needed for pull.
    
- **Always pin image versions** (avoid `latest` in production).
    
- Use **Docker Hub UI** to explore:
    
    - Official images
        
    - Tags and their digests
        
    - Image documentation
        

* * *

## 6\. **Performance Tip**

- Pulled images are **cached locally**, speeding up future `docker run` commands.

* * *

# Docker Image Tagging, Pulling & Pushing – Summary Notes

## 1\. **Image Tagging Essentials**

- **Tag = Identifier** for an image version (e.g., `node:lts-slim`, `ubuntu:22.04`)
    
- **Tag types:**
    
    - `lts`, `lts-slim`, `lts-alpine` – long-term support versions
        
    - `slim` – reduced size, fewer dependencies
        
    - `alpine` – minimal base image, smallest size, often fewer vulnerabilities
        
    - **Numbered Tags** – precise versions (e.g., `20.15-slim`, `22.04`)
        
- **Size & Security Tip**: Use `slim` or `alpine` if minimal size/security is important.
    

* * *

## 2\. **Tag Versioning Best Practices**

- **Always pin versions** (e.g., `ubuntu:22.04`) instead of using `latest` to avoid unexpected updates.
    
- **Update regularly**: Monitor and update pinned versions to get security patches.
    

* * *

## 3\. **Managing Images Locally**

- List local images:
    
    ```bash
    docker images
    ```
    
- Remove image:
    
    ```bash
    docker rmi IMAGE_NAME
    docker rmi -f IMAGE_NAME   # Force removal
    ```
    
- Show only image IDs:
    
    ```bash
    docker images -q
    ```
    

* * *

## 4\. **Pulling Images & Tags**

- Pull single tag:
    
    ```bash
    docker pull IMAGE:TAG
    ```
    
- Pull all tags (for small images):
    
    ```bash
    docker pull --all-tags hello-world
    ```
    

* * *

## 5\. **Build & Tag Custom Image**

- Example Dockerfile:
    
    ```Dockerfile
    FROM ubuntu:latest
    RUN echo "Hello from Docker"
    ```
    
- Build and tag image:
    
    ```bash
    docker build -t simple_hello_world .
    ```
    
- Add version tag and Docker Hub repo info:
    
    ```bash
    docker tag simple_hello_world YOUR_USERNAME/simple_hello_world:v0.1
    ```
    

* * *

## 6\. **Push to Docker Hub**

- Push image to Docker Hub:
    
    ```bash
    docker push YOUR_USERNAME/simple_hello_world:v0.1
    ```
    
- Images must be tagged in format:  
    `username/repository:tag`
    

* * *

## 7\. **Repository Management**

- By default, repositories on Docker Hub are **public**.
    
- You can make a repository **private** (limit: 1 private repo on free plan).
    
- Delete a repo in Docker Hub:  
    Profile → Repositories → Settings → Delete Repository
    

* * *

## 8\. **Pro Tip**

- For production: Push via **CI/CD pipeline** (recommended over manual push)

&nbsp;

#  Dockerfile Overview – Notes

## What is a Dockerfile?

- A **Dockerfile** defines the **programmatic steps** to create Docker images.
    
- Instructions are written **top to bottom** and executed in order.
    

* * *

# Dockerfile Structure

1.  **FROM** – defines **base image** (must be first).
    
2.  **Instructions** – RUN, COPY, CMD, etc.
    
    - Each **instruction** builds on top of the previous one.
        
    - Syntax varies; some accept 1 or multiple arguments.
        
3.  **Final instruction** defines container's **default behavior** (e.g., CMD).
    

* * *

## Benefits of Dockerfiles

- ✅ **Custom Images** – tailor images exactly to app needs.
    
- ✅ **Reproducibility** – same Dockerfile = same image everywhere.
    
- ✅ **Automation** – builds image **automatically** without manual steps.
    
- ✅ **Transparency/Documentation** – readable steps show how image is built.
    
- ✅ **Optimization Potential**:
    
    - Use smaller base images (e.g., `alpine`) for **security** and **smaller size**.
        
    - **Order instructions** to maximize Docker **caching** and speed up builds.
        

* * *

## Docker’s Layered Architecture

- Every **instruction creates a new image layer**.
    
    - These are called **intermediate images**.
        
    - Each has a **unique image ID**.
        
- **Docker reuses layers** if nothing changes → faster builds via **caching**.
    

### Example Flow:

1.  `FROM ubuntu` → Layer/Image A
    
2.  `RUN apt-get install ...` → Layer B (based on A)
    
3.  `COPY . /app` → Layer C (based on B)
    

If **only Layer C changes**, Docker **reuses** Layers A and B.

* * *

## Key Insight

- Understanding the **layered structure** is crucial for:
    
    - **Build speed optimization**
        
    - **Image size reduction**
        
    - **Efficient caching**
        

* * *

## Index

- [Introduction](#introduction)
- [1. Setup for Demonstration](#1-setup-for-demonstration)
    - [Project Initialization](#project-initialization)
    - [Simple Application (index.js)](#simple-application-indexjs)
- [2. Initial Dockerfile (Using Full Node Image)](#2-initial-dockerfile-using-full-node-image)
    - [Dockerfile.size (Vanilla Version)](#dockerfilesize-vanilla-version)
    - [Build Command](#build-command)
    - [Result](#result)
- [3. Optimizing with Slim Base Image](#3-optimizing-with-slim-base-image)
    - [Updated Base Image](#updated-base-image)
    - [Build Command](#build-command-1)
    - [Result](#result-1)
- [4. Optimizing Further with Alpine Image](#4-optimizing-further-with-alpine-image)
    - [Updated Base Image](#updated-base-image-1)
    - [Build Command](#build-command-2)
    - [Result](#result-2)
- [5. Docker History and Caching](#5-docker-history-and-caching)
    - [Docker History Command](#docker-history-command)
    - [Insights](#insights)
- [6. Trade-offs When Choosing Base Images](#6-trade-offs-when-choosing-base-images)
- [7. Key Takeaways](#7-key-takeaways)
- [Example: Compare Build Sizes](#example-compare-build-sizes)
- [Conclusion](#conclusion)

# Optimizing Docker Images – Using Smaller Base Images

## Introduction

- Optimizing Docker images leads to **faster builds**, **smaller sizes**, and **more secure containers**.
    
- The lecture focuses on **base image selection**, showing how image size and build time are affected.
    
- Premature optimization is discouraged, but **small improvements compound** over time, especially in CI/CD environments.
    

* * *

## 1\. Setup for Demonstration

### Project Initialization

Commands used to set up a **sample Node.js/TypeScript** project with dependencies:

```bash
npm init -y

# Install production dependency
npm install express@4.21.2 --save-exact

# Install development dependencies
npm install jest@29.7.0 typescript@5.5.3 @types/express@4.17.21 --save-dev --save-exact
```

### Simple Application (index.js)

```javascript
// index.js
console.log("Hello world");
```

* * *

## 2\. Initial Dockerfile (Using Full Node Image)

### Dockerfile.size (Vanilla Version)

```Dockerfile
# Dockerfile.size
FROM node:22
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY index.js ./
CMD ["node", "index.js"]
```

### Build Command

```bash
docker build -t image-size:vanilla -f Dockerfile.size .
```

### Result

```bash
docker images
# image-size:vanilla ~1.17GB
```

* * *

## 3\. Optimizing with Slim Base Image

### Updated Base Image

```Dockerfile
FROM node:22-slim
```

### Build Command

```bash
docker build -t image-size:slim -f Dockerfile.size .
```

### Result

```bash
docker images
# image-size:slim ~0.29GB (about 1/4th of vanilla size)
```

* * *

## 4\. Optimizing Further with Alpine Image

### Updated Base Image

```Dockerfile
FROM node:22-alpine
```

### Build Command

```bash
docker build -t image-size:alpine -f Dockerfile.size .
```

### Result

```bash
docker images
# image-size:alpine ~0.18GB (about 1/6th of vanilla size)
```

* * *

## 5\. Docker History and Caching

### Docker History Command

```bash
docker history image-size:vanilla
```

### Insights

- Each Dockerfile instruction = a **layer**.
    
- Docker **caches layers**. If a command doesn’t change, its **cache is reused**.
    
- **Base image changes** invalidate the cache for all subsequent layers.
    
- Cached layers speed up builds; **uncached layers cause rebuilds** and longer build times.
    

* * *

## 6\. Trade-offs When Choosing Base Images

| Base Image | Size | Pros | Cons |
| --- | --- | --- | --- |
| `node:22` | ~1.17GB | Full-featured, includes all tools | Large size, slower download/build |
| `node:22-slim` | ~0.29GB | Smaller, faster download/build | Some tools/libraries may be missing |
| `node:22-alpine` | ~0.18GB | Very small, fewer vulnerabilities | Compatibility issues, may require tweaks |

* * *

## 7\. Key Takeaways

1.  **Smaller base images** = smaller Docker images + faster builds.
    
2.  **Slim and Alpine** are great starting points, but ensure they meet app requirements.
    
3.  Docker’s **layer caching** helps speed up builds—reuse where possible.
    
4.  Balance **size optimization** with **functionality and ease of use**.
    

* * *

## Example: Compare Build Sizes

```bash
docker images

# IMAGE TAG           SIZE
# image-size:vanilla   1.17GB
# image-size:slim      0.29GB
# image-size:alpine    0.18GB
```

* * *

## Conclusion

Optimizing Docker images doesn’t mean chasing the smallest possible size at all costs. Instead, **choose the base image wisely**, leverage **Docker caching**, and aim for a **balance between performance, security, and maintainability**.


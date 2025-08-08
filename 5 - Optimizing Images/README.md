# Index

- [Optimizing Docker Images – Using Smaller Base Images](#optimizing-docker-images--using-smaller-base-images)
    - [Introduction](#introduction)
    - [1. Setup for Demonstration](#1-setup-for-demonstration)
    - [2. Initial Dockerfile (Using Full Node Image)](#2-initial-dockerfile-using-full-node-image)
    - [3. Optimizing with Slim Base Image](#3-optimizing-with-slim-base-image)
    - [4. Optimizing Further with Alpine Image](#4-optimizing-further-with-alpine-image)
    - [5. Docker History and Caching](#5-docker-history-and-caching)
    - [6. Trade-offs When Choosing Base Images](#6-trade-offs-when-choosing-base-images)
    - [7. Key Takeaways](#7-key-takeaways)
    - [Example: Compare Build Sizes](#example-compare-build-sizes)
    - [Conclusion](#conclusion)
- [Docker Optimization: Instruction Ordering and Dependency Management](#docker-optimization-instruction-ordering-and-dependency-management)
    - [Overview](#overview)
    - [1. Ordering Dockerfile Instructions](#1-ordering-dockerfile-instructions)
    - [2. Installing Only Production Dependencies](#2-installing-only-production-dependencies)
    - [Verifying the Difference](#verifying-the-difference)
    - [Bonus: Preparing for Multi-Stage Builds](#bonus-preparing-for-multi-stage-builds)
    - [Summary](#summary)

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


# Docker Optimization: Instruction Ordering and Dependency Management

## Overview

The lecture focuses on **two key techniques** to optimize Docker images for **faster builds**, **smaller image sizes**, and **improved security**:

1.  **Reordering Dockerfile instructions** to leverage **Docker's caching mechanism**.
    
2.  **Installing only production dependencies** using `npm ci --only=production`.
    

* * *

## 1. Ordering Dockerfile Instructions

### Key Idea

Docker builds images **layer by layer**. If a layer changes, **all subsequent layers are invalidated** in the cache.

**Rule of Thumb**:

> Put commands that change **least frequently** at the **top** of the Dockerfile, and the commands that change **most frequently** at the **bottom**.

### Good Example (Optimized)

```Dockerfile
# Dockerfile.order
FROM node:20

WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source code
COPY . .

# Run the app
CMD ["node", "index.js"]
```

### Not So Good Example (Suboptimal)

```Dockerfile
# Dockerfile.bad
FROM node:20

WORKDIR /app

# Copy entire project first
COPY . .

# Install dependencies
RUN npm ci

CMD ["node", "index.js"]
```

### Why It Matters

If `index.js` changes, the Docker layer cache for `COPY . .` breaks, forcing `npm ci` to re-run — **even if `package.json` didn't change**. This **slows down builds**.

#### Example Output

- **Optimized Build (cached)**: `npm ci` takes **~0s**
    
- **Suboptimal Build (no cache)**: `npm ci` takes **~3s+**
    

* * *

## 2. Installing Only Production Dependencies

### Key Idea

In Node.js, `package.json` differentiates between:

- `"dependencies"` → needed **at runtime**
    
- `"devDependencies"` → needed **only during development/build**
    

**Install only production dependencies** in your Dockerfile with:

```bash
npm ci --only=production
```

### Good Dockerfile

```Dockerfile
# Dockerfile.deps.good
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

CMD ["node", "index.js"]
```

### Not So Good Dockerfile

```Dockerfile
# Dockerfile.deps.bad
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm ci  # Installs devDependencies too

COPY . .

CMD ["node", "index.js"]
```

### Why It Matters

- **Reduces image size**: e.g., ~50MB smaller
    
- **Improves build time**: faster installation
    
- **Enhances security**: fewer packages = smaller attack surface
    

* * *

## Verifying the Difference

To inspect installed modules inside the container:

```bash
docker run --rm -it image-name bash
ls node_modules
```

- Dev dependencies like `jest`, `typescript` will **not be present** in the optimized image.

* * *

## Bonus: Preparing for Multi-Stage Builds

If you need to **build (e.g., transpile TypeScript)** and then **run**, use **multi-stage builds**:

```Dockerfile
# First stage: build
FROM node:22 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci -only=production
COPY src/ src/

# Stage 2: Final Image using Distroless
FROM gcr.io/distroless/nodejs
WORKDIR /app
COPY --from=build /app/node_modules node_modules
COPY --from=build /app/src src


CMD ["src/index.js"]
```

* * *

## Summary

| Technique | Benefit |
| --- | --- |
| Order Dockerfile commands | Faster builds via Docker cache |
| Install only prod dependencies | Smaller, safer, faster images |
| Multi-stage builds | Split dev/runtime concerns cleanly |

> ✨ **Pro Tip**: Always think about what changes most frequently in your app and structure your Dockerfile accordingly.

* * *



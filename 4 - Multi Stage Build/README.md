
# 📚 Index

- [Key Concepts: Multi-Stage Builds in Docker](#key-concepts-multi-stage-builds-in-docker)
  - [❗Problem](#problem)
  - [🛠 Solution: Multi-Stage Builds](#solution-multi-stage-builds)
  - [What Are Multi-Stage Builds?](#what-are-multi-stage-builds)
  - [🚀 Benefits](#benefits)
  - [Example: Multi-Stage Dockerfile (for Node.js App)](#example-multi-stage-dockerfile-for-nodejs-app)
  - [How it Works](#how-it-works)
  - [🧪 Build & Run Example](#build--run-example)
  - [💡 Key Point](#key-point)
- [Integrating TypeScript into a Node.js Project with Docker Multi-Stage Builds](#integrating-typescript-into-a-nodejs-project-with-docker-multi-stage-builds)
  - [Introduction](#introduction)
  - [1. Setting Up TypeScript](#1-setting-up-typescript)
  - [2. Converting JavaScript to TypeScript](#2-converting-javascript-to-typescript)
  - [3. Build and Run the Application](#3-build-and-run-the-application)
  - [4. Key Notes on Running TypeScript](#4-key-notes-on-running-typescript)
  - [5. Summary of Changes Made](#5-summary-of-changes-made)
- [Updating Dockerfile for a TypeScript Project with Multi-Stage Builds](#updating-dockerfile-for-a-typescript-project-with-multi-stage-builds)
  - [Overview](#overview)
  - [1. Ignore Local Build Artifacts](#1-ignore-local-build-artifacts)
  - [2. Modify Dockerfile for TypeScript Build](#2-modify-dockerfile-for-typescript-build)
  - [3. Build and Run the Container](#3-build-and-run-the-container)
  - [4. Why These Changes Matter](#4-why-these-changes-matter)
  - [5. Understanding the Final CMD Instruction](#5-understanding-the-final-cmd-instruction)
  - [6. Key Takeaways](#6-key-takeaways)
  - [Conclusion](#conclusion)


# Key Concepts: Multi-Stage Builds in Docker

* * *

## ❗Problem:

- When using **Distroless images** for better security and smaller size, you **cannot install dependencies** like `npm`, because tools like `npm` or shell utilities do not exist in distroless images.
    
- You need to **build the app** in one environment (with tools) and **run it** in another (secure, lean).
    

* * *

## 🛠 Solution: Multi-Stage Builds

* * *

## **What Are Multi-Stage Builds?**

- Dockerfile can have **multiple `FROM` statements**, each starting a new **stage**.
    
- You can **build in one stage** (with a full-featured base image like Node.js) and then **copy the built app** into a minimal or distroless base image in the next stage.
    

* * *

## 🚀 Benefits:

| Benefit | Description |
| --- | --- |
| Smaller Images | Final image contains only the runtime essentials. |
| Better Security | No compilers, package managers, or shells in the final image. |
| Clear Separation | Clean distinction between build and runtime concerns. |

* * *

## Example: Multi-Stage Dockerfile (for Node.js App)

`npm init -y`

`npm i express@4.19.2 --save-exact`

```Dockerfile
# Stage 1: Build Stage
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Stage 2: Final Image using Distroless
FROM gcr.io/distroless/nodejs:22
WORKDIR /app
COPY --from=build /app/node_modules node_modules
COPY src src
ENV PORT=3000

CMD ["src/index.js"]
```

* * *

## How it Works:

1.  **Stage 1 (`node:22-alpine`)**:
    
    - Installs dependencies using `npm ci`
        
    - Copies your source code
        
2.  **Stage 2 (Distroless)**:
    
    - Copies the **built app only** from Stage 1.
        
    - No shell, no `npm` — just runs the app securely.
        

* * *

## 🧪 Build & Run Example

```bash
docker build -t express-multistage .
docker run -p 3000:3000 express-multistage
```

* * *

## 💡 Key Point:

You **can’t use Distroless for building**, only for running.  
Multi-stage builds allow you to **build in one stage** and then **run in a secure, minimal environment**.

Let me know if you want the follow-up example where this is fully implemented.

# Integrating TypeScript into a Node.js Project with Docker Multi-Stage Builds

## Introduction

This lesson introduces **TypeScript** to a Node.js project, aiming to demonstrate how it affects the **build process** and **Dockerfile**. The focus is on integrating TypeScript with minimal changes and using Docker multi-stage builds to compile TypeScript to JavaScript while still running the app with a **Distroless Node.js image**.

* * *

## 1\. Setting Up TypeScript

### Install TypeScript and Express Types

Install TypeScript and the type definitions for Express as **development dependencies**:

```bash
npm i --save-dev --save-exact typescript@5.3.3 @types/express@4.17.21 
```

### Initialize TypeScript Project

Run the TypeScript initializer to generate a configuration file:

```bash
npx tsc --init
```

### Modify `tsconfig.json`

Specify an output directory for compiled JavaScript:

```json
{
  "outDir": "./dist"
}
```

* * *

## 2\. Converting JavaScript to TypeScript

### Rename and Update Source File

- Rename `index.js` to `index.ts`.
    
- Convert `require` syntax to ES module `import`.
    

#### Before:

```js
const express = require('express');
```

#### After:

```ts
import express from 'express';
```

This change enables **type inference** for Express handlers and removes TypeScript errors.

* * *

## 3\. Build and Run the Application

### Add a Build Script to `package.json`

```json
"scripts": {
  "build": "tsc"
}
```

### Compile TypeScript to JavaScript

```bash
npm run build
```

- Outputs compiled files to the `dist/` directory.
    
- Main output file: `dist/index.js`
    

### Run the Compiled Application

```bash
PORT=3000 node dist/index.js
```

Verify with:

```bash
curl http://localhost:3000
# Output: Hello from express
```

* * *

## 4\. Key Notes on Running TypeScript

- Running `index.ts` directly with Node.js will **fail** due to ES module syntax:

```bash
node src/index.ts
# Error: Cannot use import statement outside of a module
```

- Correct approach: **Compile with TypeScript** first, then run the JavaScript output.
    
- Example of valid `.ts` that can run as `.js` directly:
    

```ts
console.log('Hello');  // Can be saved as .ts and run if no TypeScript features are used
```

* * *

## 5\. Summary of Changes Made

- Installed `typescript` and `@types/express`.
    
- Converted `index.js` → `index.ts` and updated import syntax.
    
- Created a build script: `npm run build`.
    
- Configured TypeScript to output compiled files in the `dist/` directory.
    
- Demonstrated that **only compiled JavaScript** should be run in production.
    

* * *

&nbsp;

# Updating Dockerfile for a TypeScript Project with Multi-Stage Builds

## Overview

This lesson focuses on adapting the **Dockerfile** to support **TypeScript** in a **multi-stage build** environment, compiling TypeScript into JavaScript, and running the app using a **Distroless Node.js 22 image**.

* * *

## 1\. Ignore Local Build Artifacts

### Add `dist/` to `.dockerignore`

Prevent local build artifacts from being copied into the Docker image to ensure a clean, repeatable build inside the container.

```
# .dockerignore
dist/
```

* * *

## 2\. Modify Dockerfile for TypeScript Build

### Key Changes:

- Add `COPY` for source code and `tsconfig.json` to the **build stage**.
    
- Add `RUN npm run build` to compile TypeScript.
    
- Copy the compiled `dist/` directory into the **Distroless runtime stage**.
    

### Updated Dockerfile Example

```dockerfile
# Stage 1: Build Stage
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src src
COPY tsconfig.json tsconfig.json

RUN npm run build


# Stage 2: Final Image using Distroless
FROM gcr.io/distroless/nodejs
WORKDIR /app
COPY --from=build /app/node_modules node_modules
COPY --from=build /app/dist dist
ENV PORT=3000

CMD ["dist/index.js"]
```

* * *

## 3\. Build and Run the Container

### Build Image

```bash
docker build -t express-ts:0.0.1 .
```

### Run Container

```bash
docker run -d -p 3000:3000 express-ts:0.0.1
```

### Verify Application

```bash
curl http://localhost:3000
# Expected Output: Hello from express
```

* * *

## 4\. Why These Changes Matter

### Ensuring Build Consistency

- All compilation happens inside the container, making the build **independent of local machine setup**.
    
- Avoids relying on pre-built local files, ensuring **reproducibility**.
    

### Proper File Handling

- `src/` and `tsconfig.json` are only needed in the build stage.
    
- Only `dist/` and `node_modules/` are included in the **final image**.
    
- Final image is **minimal and secure**, perfect for production.
    

* * *

## 5\. Understanding the Final CMD Instruction

### Default Distroless Behavior

Distroless Node.js images have **Node.js as the default entrypoint**. Therefore:

```dockerfile
CMD ["dist/index.js"]
```

This effectively runs:

```bash
node dist/index.js
```

* * *

## 6\. Key Takeaways

| Step | Purpose |
| --- | --- |
| `.dockerignore` update | Avoid copying unnecessary local files |
| Build stage additions | Compile TypeScript inside Docker |
| Distroless stage copies | Only include production-ready files |
| `CMD` update | Run compiled JavaScript via Node in Distroless |
| Result | Clean, secure, efficient Docker image with TypeScript support |

* * *

## Conclusion

- TypeScript integration introduces new **build-time steps**, but Docker multi-stage builds manage this efficiently.
    
- Final image remains **lean** and **secure**, using **Distroless** best practices.
    
- If any part is unclear, reviewing the build process in steps can help clarify.
    

* * *
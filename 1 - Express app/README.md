# Index

- [Quick Start: Express.js Hello World App](#quick-start-expressjs-hello-world-app)
    - [1. Setup: Create a New Project Directory](#1-setup-create-a-new-project-directory)
    - [2. Initialize Node Project](#2-initialize-node-project)
    - [3. Install Dependencies (with pinned versions)](#3-install-dependencies-with-pinned-versions)
    - [4. Create `index.js` File](#4-create-indexjs-file)
    - [5. Add Start Script to `package.json`](#5-add-start-script-to-packagejson)
    - [6. Run the Application](#6-run-the-application)
    - [7. Test Your Server](#7-test-your-server)
    - [Summary: What You Learned](#summary-what-you-learned)
- [Updated Express.js App Code](#updated-expressjs-app-code)
    - [1. `index.js`](#1-indexjs)
    - [How to Test (with Postman or cURL)](#how-to-test-with-postman-or-curl)
        - [Register a User (POST)](#register-a-user-post)
        - [Get Registered Users (GET)](#get-registered-users-get)
    - [Key Concepts Used](#key-concepts-used)
- [Dockerize Our Express App](#dockerize-our-express-app)
    - [Your App Directory Structure](#your-app-directory-structure)
    - [Final Dockerfile (Clean Version)](#final-dockerfile-clean-version)
    - [How to Build and Run](#how-to-build-and-run)
        - [Build the Docker Image](#1-build-the-docker-image)
        - [Run the Docker Container](#2-run-the-docker-container)
        - [Test it with cURL](#3-test-it-with-curl)
    - [Key Concepts Recap](#key-concepts-recap)

# Quick Start: Express.js Hello World App

### 1\.  Setup: Create a New Project Directory

```bash
mkdir containerize-express-app
cd containerize-express-app
```

* * *

### 2\. Initialize Node Project

```bash
npm init -y
```

You now have a `package.json` file.

* * *

### 3\. Install Dependencies (with pinned versions)

```bash
npm install express@4.9.2 body-parser@1.20.2 --save-exact
```

You now have:

- `package-lock.json`
    
- `node_modules/`
    
- `package.json` updated with dependencies.
    

* * *

### 4\. Create `index.js` File

```js
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Middleware to parse JSON request bodies
app.use(bodyParser.json());

// Simple GET route
app.get('/', (req, res) => {
  res.send('Hello world');
});

// Start the server
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
```

* * *

### 5\. Add Start Script to `package.json`

Add under `"scripts"` section:

```json
"scripts": {
  "start": "node index.js"
}
```

* * *

### 6\. Run the Application

```bash
npm start
```

Console Output:

```
Server listening on port 3000
```

* * *

### 7\. Test Your Server

In a new terminal:

```bash
curl http://localhost:3000
```

Expected Output:

```
Hello world
```

* * *

### Summary: What You Learned

| Step | Tool/Command | Purpose |
| --- | --- | --- |
| Init Node Project | `npm init -y` | Create `package.json` |
| Install Packages | `npm install express body-parser` | Setup Express + body parsing middleware |
| Run Server | `npm start` | Starts server on port 3000 |
| Test Server | `curl http://localhost:3000` | Confirm server response |

* * *

# Updated Express.js App Code

### 1\. 📄 `index.js`

```js
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;
const users = [];

app.use(bodyParser.json());

app.get('/', (req, res) => {
    res.send('Hello world!');
});

// Get registered users
app.get('/users', (req, res) => {
    return res.json({ users });
})

// Register a new user
app.post('/users', (req, res) => {
    const newUserId = req.body.userId;
    if (!newUserId) {
        return res.status(400).send('Missing userId.');
    }

    if (users.includes(newUserId)) {
        return res.status(400).send('userId already exists.');
    }

    users.push(newUserId);
    return res.status(201).send('User registered.');
});

app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
});
```

* * *

### How to Test (with Postman or cURL)

### Start the Server

```bash
npm start
```

* * *

### Register a User (POST)

**Endpoint:** `POST http://localhost:3000/users`  
**Request Body (JSON):**

```json
{ "userId": "alice123" }
```

**Possible Responses:**

- `201 Created` → "User registered"
    
- `400 Bad Request` → "Missing userId"
    
- `400 Bad Request` → "UserId already exists"
    

* * *

### Get Registered Users (GET)

**Endpoint:** `GET http://localhost:3000/users`  
**Response:**

```json
{ "users": ["alice123"] }
```

* * *

### Key Concepts Used

| Concept | Code Used | Purpose |
| --- | --- | --- |
| Middleware | `app.use(bodyParser.json())` | Parse JSON request body |
| Data Storage | `const users = []` | Simple in-memory list (resets on restart) |
| Route: GET | `app.get('/users', ...)` | Return list of users |
| Route: POST | `app.post('/users', ...)` | Add new user, validate input, handle errors |
| Error Handling | `res.status(400).send('...')` | Send clear error messages |
| Success Response | `res.status(201).send('User registered')` | Confirmation of user creation |

* * *

# <span style="color: oklch(0.2974 0.0362 281.74);">Dockerize Our Express App</span>

* * *

## Your App Directory Structure

```
ContainerizeExpressApp/
├── Dockerfile
├── package.json
├── package-lock.json
└── src/
    └── index.js
```

Update package.json

```json
{
  "name": "1---express-app",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": "",
  "dependencies": {
    "body-parser": "1.20.2",
    "express": "4.9.2"
  }
}

```

* * *

## Final Dockerfile (Clean Version)

```Dockerfile
# Base image: Node.js version 22
FROM node:22

# Set working directory inside the container
WORKDIR /app

# Copy only the package files to install dependencies
COPY package*.json ./

# Install dependencies using npm ci for clean, repeatable builds
RUN npm ci

# Copy the rest of the application (index.js inside src/)
COPY src/index.js ./index.js

# Expose the app port
EXPOSE 3000

# Run the application
CMD ["node", "index.js"]
```

* * *

## How to Build and Run

### 1\. Build the Docker Image

```bash
docker build -t express_app:v0.0.1 .
```

### 2\. Run the Docker Container

```bash
docker run -d -p 3000:3000 --name express_app express_app:v0.0.1
```

### 3\. Test it with cURL

- **Hello World (GET):**
    
    ```bash
    curl http://localhost:3000/
    ```
    
- **Get Users (GET):**
    
    ```bash
    curl http://localhost:3000/users
    ```
    

* * *

## Key Concepts Recap

| Step | Command/Concept | Purpose |
| --- | --- | --- |
| Base Image | `FROM node:22` | Provides Node.js environment |
| Set Workdir | `WORKDIR /app` | Organizes where files/commands will be executed |
| Copy Dependency Files | `COPY package*.json ./` | Only package.json & lock copied first for better caching |
| Install Deps | `RUN npm ci` | Fast, clean, deterministic install using lock file |
| Copy App Code | `COPY src/index.js ./index.js` | Copies app source code |
| Expose Port | `EXPOSE 3000` | Documents the app's port for container mapping |
| Start App | `CMD ["node", "index.js"]` | Defines the default command to run your app |

* * *


// src/index.js
const express = require('express');
const app = express();

// Read port from environment variable, fallback to 3000
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`Hello from ${process.env.APP_NAME} on port ${port}`);
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

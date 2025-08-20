const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const healthRouter = require('./routes/health');
const keyValueRouter = require('./routes/store');




console.log('DB Password:', process.env.KEY_VALUE_PASSWORD);

const app = express();
app.use(bodyParser.json());

const PORT = process.env.PORT || 3000; 

app.use('/health', healthRouter);
app.use('/store', keyValueRouter);

console.log('Connecting to DB...');
mongoose.connect(`mongodb://${process.env.MONGODB_HOST}/${process.env.KEY_VALUE_DB}`, {
  auth: { username: process.env.KEY_VALUE_USER, 
          password: process.env.KEY_VALUE_PASSWORD },
  connectTimeoutMS: 500
})
.then(() => {
  console.log('Connected to DB');
  app.listen(PORT, () => console.log('Listening on port PORT:', PORT));
})
.catch(err => console.error('Something went wrong', err));
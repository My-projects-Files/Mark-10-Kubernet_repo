const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Welcome to the app!');
});

app.get('/status', (req, res) => {
  res.json({ message: 'App is running!' });
});

app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on port 3000');
});


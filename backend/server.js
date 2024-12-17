const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const createDriver = require('./createDriver');
const createOfficer = require('./createOfficer');
const authRoutes = require('./routes/auth');
const auth = require('./middleware/auth');

dotenv.config();

const app = express();

mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Could not connect to MongoDB', err));

app.use(express.json());

app.use('/auth', authRoutes);

app.post('/driver', createDriver);
app.post('/officer', createOfficer);

// Protected routes
app.get('/driver/profile', auth, (req, res) => {
  // Implement driver profile retrieval
  res.send({ message: 'Driver profile route' });
});

app.get('/officer/profile', auth, (req, res) => {
  // Implement officer profile retrieval
  res.send({ message: 'Officer profile route' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server running on port ${port}`));


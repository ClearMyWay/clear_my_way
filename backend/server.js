const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const createDriver = require('./createDriver');
const createOfficer = require('./createOfficer');
const authRoutes = require('./routes/auth');
const auth = require('./middleware/auth');

// Import additional routes
const driverRoutes = require('./routes/driver');
const officerRoutes = require('./routes/officer');
const vehicleRoutes = require('./routes/vehicle');
const otpRoutes = require('./routes/otp');

dotenv.config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Routes
app.use('/auth', authRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/driver', driverRoutes);
app.use('/api/officer', officerRoutes);
app.use('/api/vehicle', vehicleRoutes);
app.use('/api/otp', otpRoutes);

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

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Could not connect to MongoDB', err));

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`Server running on port ${port}`));


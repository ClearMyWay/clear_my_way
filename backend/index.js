require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const authRoutes = require('./routes/auth');
const vehicleRoutes = require('./routes/vehicle');
const driverRoutes = require('./routes/driver');
const officerRoutes = require('./routes/officer');
const emergencyRoutes = require('./routes/emergency');
const createDriver = require('./createDriver');
const createOfficer = require('./createOfficer');
const auth = require('./middleware/auth');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected'))
.catch((err) => console.error('MongoDB connection error:', err));

// Socket.io connection
io.on('connection', (socket) => {
  console.log('New client connected');
  socket.on('disconnect', () => console.log('Client disconnected'));
});

// Make io accessible to our router
app.use((req, res, next) => {
  req.io = io;
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/officers', officerRoutes);
app.use('/api/emergency', emergencyRoutes);

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

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));


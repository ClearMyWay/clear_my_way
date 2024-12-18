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

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

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

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));


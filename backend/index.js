const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const officerRegister = require('./models/Officerregister');

// Import routes
const auth = require('./routes/auth');
const driver = require('./routes/driver');
const officer = require('./routes/officer');
const vehicle = require('./routes/vehicle');
const otpRoutes = require('./routes/otp');
const emergency = require('./routes/emergency');

dotenv.config(); // Load environment variables

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Middleware
app.use(cors());
app.use(express.json({ limit: "10mb" }));

// Socket.io connection
io.on('connection', (socket) => {
  console.log(`New client connected: ${socket.id}`);

  // Handle officer location updates
  socket.on('update_location', async (data) => {
    const { Username, lat, lng } = data;

    if (!Username || !lat || !lng) {
      console.error('Invalid location data');
      return;
    }

    // Update officer's location in the database
    try {
      await officerRegister.findByIdAndUpdate(
        Username,
        { socketId: socket.id, lat, lng },
        { new: true, upsert: true }
      );
      console.log(`Updated location for officer: ${Username}`);
    } catch (error) {
      console.error('Error updating officer location:', error);
    }
  });

  // Handle disconnection
  socket.on('disconnect', async () => {
    console.log(`Client disconnected: ${socket.id}`);
    await officerRegister.findOneAndUpdate({ socketId: socket.id }, { socketId: null });
  });
});

// Make io accessible to our router
app.use((req, res, next) => {
  req.io = io;
  next();
});

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.DB_CONNECTION, 
    );
    console.log('MongoDB connected successfully');
  } catch (err) {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  }
};

connectDB();

// Define Routes
app.use('/api/auth', auth);
app.use('/otp', otpRoutes);
app.use('/api/drivers', driver);
app.use('/api/officer', officer);
app.use('/api/vehicles', vehicle);
app.use('/api/emergency', emergency);

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));

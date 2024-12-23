const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/auth');
const otpRoutes = require('./routes/otp');
const mapRoutes = require('./routes/map'); // Import map routes

const app = express();

// ...existing code...

app.use('/auth', authRoutes);
app.use('/otp', otpRoutes);
app.use('/map', mapRoutes); // Use map routes

// ...existing code...

module.exports = app;

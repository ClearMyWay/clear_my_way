const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const Driver = require('../models/Driver');
const Officer = require('../models/Officer');
const { sendOtp, verifyOtp } = require('../services/otpService'); // Import OTP service functions
const auth = require('../middleware/auth'); // Import OTP verification middleware
const router = express.Router();

router.post('/login/vehicle',auth.authMiddleware, async (req, res) => {
  try {
    const { vehicleNumber, password } = req.body;
    const VehicleNumber = await Driver.findOne({ vehicleNumber });
    if (!VehicleNumber || !(await VehicleNumber.comparePassword(password))) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    const token = jwt.sign({ vehicleNumber: vehicleNumber }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({ token, driver: { id: driver._id, name: driver.name, email: driver.email } });
  } catch (error) {
    console.error('Driver login error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Officer login
router.post('/login/officer', async (req, res) => {
  try {
    const { email, password } = req.body;
    const officer = await Officer.findOne({ email }).select('+password');
    if (!officer || !(await bcrypt.compare(password, officer.password))) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Create a new token and send it to the officer
    const token = jwt.sign({ id: officer._id, role: 'officer' }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({
      token,
      officer: { id: officer._id, name: officer.name, email: officer.email, badgeNumber: officer.badgeNumber }
    });
  } catch (error) {
    console.error('Officer login error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Send OTP
router.post('/otp/send', authMiddleware, async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    if (!phoneNumber) {
      return res.status(400).json({ message: 'Phone number is required' });
    }
    const otp = await sendOtp(phoneNumber);
    res.json({ message: 'OTP sent', otpId: otp._id });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ message: 'Failed to send OTP', error: error.message });
  }
});



module.exports = router;
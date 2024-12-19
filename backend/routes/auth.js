const express = require('express');
const jwt = require('jsonwebtoken');
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
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/login/officer', async (req, res) => {
  try {
    const { email, password } = req.body;
    const officer = await Officer.findOne({ email });
    if (!officer || !(await officer.comparePassword(password))) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Create a new token and send it to the officer
    const token = jwt.sign({ id: officer._id, role: 'officer' }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({
      token,
      officer: { id: officer._id, name: officer.name, email: officer.email, badgeNumber: officer.badgeNumber }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// OTP routes
router.post('/otp/send', async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    const otp = await sendOtp(phoneNumber);
    res.json({ message: 'OTP sent', otpId: otp._id });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});



module.exports = router;
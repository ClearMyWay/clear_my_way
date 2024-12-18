const express = require('express');
const jwt = require('jsonwebtoken');
const Driver = require('../models/Driver');
const Officer = require('../models/Officer');
const { sendOtp, verifyOtp } = require('../services/otpService'); // Import OTP service functions
const auth = require('../middleware/auth');
const otpVerified = require('../middleware/otpVerified'); // Import OTP verification middleware

const router = express.Router();

router.post('/login/driver', async (req, res) => {
  try {
    const { email, password } = req.body;
    const driver = await Driver.findOne({ email });
    if (!driver || !(await driver.comparePassword(password))) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    const token = jwt.sign({ id: driver._id, role: 'driver' }, process.env.JWT_SECRET, { expiresIn: '1d' });
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
    const token = jwt.sign({ id: officer._id, role: 'officer' }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({ token, officer: { id: officer._id, name: officer.name, email: officer.email, badgeNumber: officer.badgeNumber } });
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

router.post('/otp/verify', async (req, res) => {
  try {
    const { otpId, otpCode } = req.body;
    const isValid = await verifyOtp(otpId, otpCode);
    if (!isValid) {
      return res.status(401).json({ message: 'Invalid OTP' });
    }
    res.json({ message: 'OTP verified' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message }); // Fixed typo here
  }
});

// Add OTP verification requirement to sensitive routes
router.get('/sensitive-data', auth, otpVerified, (req, res) => {
  // Placeholder for your sensitive data controller
  res.json({ message: 'Sensitive data accessed' });
});

module.exports = router;
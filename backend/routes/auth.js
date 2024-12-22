const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const Driver = require('../models/Driver');
const Officer = require('../models/Officer');
const { sendOtp, verifyOtp } = require('../services/socketOtpService');
const { authMiddleware } = require('../middleware/auth');
const otpVerified = require('../middleware/otpVerified');

const router = express.Router();

// Helper function to generate JWT token
const generateToken = (user, role) => {
  return jwt.sign({ id: user._id, role }, process.env.JWT_SECRET, { expiresIn: '1d' });
};

// Driver login
router.post('/login/driver', async (req, res) => {
  try {
    const { email, password } = req.body;
    const driver = await Driver.findOne({ email }).select('+password');
    if (!driver || !(await bcrypt.compare(password, driver.password))) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    const token = generateToken(driver, 'driver');
    res.json({ 
      token, 
      driver: { 
        id: driver._id, 
        name: driver.name, 
        email: driver.email,
        phoneNumber: driver.phoneNumber
      } 
    });
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
    const token = generateToken(officer, 'officer');
    res.json({ 
      token, 
      officer: { 
        id: officer._id, 
        name: officer.name, 
        email: officer.email, 
        badgeNumber: officer.badgeNumber,
        phoneNumber: officer.phoneNumber
      } 
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

// Verify OTP
router.post('/otp/verify', authMiddleware, async (req, res) => {
  try {
    const { otpId, otpCode } = req.body;
    if (!otpId || !otpCode) {
      return res.status(400).json({ message: 'OTP ID and code are required' });
    }
    const isValid = await verifyOtp(otpId, otpCode);
    if (!isValid) {
      return res.status(401).json({ message: 'Invalid OTP' });
    }
    res.json({ message: 'OTP verified successfully' });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ message: 'Failed to verify OTP', error: error.message });
  }
});

// Access sensitive data (example of a protected route)
router.get('/sensitive-data', authMiddleware, otpVerified, (req, res) => {
  try {
    // This is a placeholder for actual sensitive data retrieval
    // In a real application, you would fetch and return the appropriate sensitive data here
    res.json({ 
      message: 'Sensitive data accessed successfully', 
      data: {
        userId: req.user.id,
        role: req.user.role,
        accessTime: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Sensitive data access error:', error);
    res.status(500).json({ message: 'Failed to retrieve sensitive data', error: error.message });
  }
});

// Logout (optional, as JWT is stateless)
router.post('/logout', authMiddleware, (req, res) => {
  // In a stateless JWT setup, logout is typically handled client-side
  // by removing the token. However, you can implement additional security measures here.
  res.json({ message: 'Logged out successfully' });
});

module.exports = router;
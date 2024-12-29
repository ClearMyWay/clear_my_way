const jwt = require('jsonwebtoken');
const User = require('../models/User.js');

// Function to login user and generate JWT token
exports.login = async (req, res) => {
  // ...existing code...
  const token = jwt.sign({ _id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
  // ...existing code...
};

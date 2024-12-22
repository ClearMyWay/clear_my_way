const jwt = require('jsonwebtoken');

// Middleware to authenticate JWT token
module.exports = (req, res, next) => {
  try {
    const token = req.header('Authorization');
    if (!token) {
      return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    // Ensure the token starts with "Bearer "
    if (!token.startsWith('Bearer ')) {
      return res.status(400).json({ message: 'Invalid token format. Expected Bearer token.' });
    }

    // Extract the actual token from "Bearer <token>"
    const actualToken = token.split(' ')[1];

    // Verify the token
    const decoded = jwt.verify(actualToken, process.env.JWT_SECRET);
    req.user = decoded;

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired. Please log in again.' });
    }
    res.status(400).json({ message: 'Invalid token.', error: error.message });
  }
};

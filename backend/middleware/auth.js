const jwt = require('jsonwebtoken');

// Middleware to authenticate JWT token
const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    if (!authHeader) {
      return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    // Ensure the token starts with "Bearer "
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(400).json({ message: 'Invalid token format. Expected Bearer token.' });
    }

    // Extract the actual token from "Bearer <token>"
    const token = authHeader.split(' ')[1];

    // Verify the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Attach the user information to the request
    req.user = decoded.user;

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired. Please log in again.' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(400).json({ message: 'Invalid token.' });
    }
    console.error('Auth middleware error:', error);
    res.status(500).json({ message: 'Internal server error.' });
  }
};

module.exports = { authMiddleware };
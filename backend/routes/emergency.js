const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const { handleEmergencyRequest, handleRoadClear } = require('../controllers/emergencyControlloer');

const router = express.Router();

// Emergency request route
router.post('/request', authMiddleware, handleEmergencyRequest);

// Road clear notification route
router.post('/clear', authMiddleware, handleRoadClear);

module.exports = router;

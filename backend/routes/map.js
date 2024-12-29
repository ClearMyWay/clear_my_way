const express = require('express');
const { getLiveLocation, getEta } = require('../controllers/mapController.js');
const auth = require('../middleware/auth.js');
const otpVerified = require('../middleware/otpVerified.js');

const router = express.Router();

// Route to get live location of the ambulance
router.get('/live-location', auth, otpVerified, getLiveLocation);

// Route to get estimated time of arrival (ETA) of the ambulance
router.get('/eta', auth, otpVerified, getEta);

module.exports = router;

const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const Vehicle = require('../models/Vehicle');
const Officer = require('../models/Officer');

const router = express.Router();

router.post('/request', authMiddleware, async (req, res) => {
  try {
    const { vehicleId, pickup, dropoff } = req.body;
    const vehicle = await Vehicle.findById(vehicleId).populate('driver');
    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    // Find nearby officers
    const nearbyOfficers = await Officer.find({
      currentLocation: {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: pickup.coordinates
          },
          $maxDistance: 5000 // 5km radius
        }
      }
    });

    // Notify officers (in a real app, you'd use push notifications or WebSockets)
    nearbyOfficers.forEach(officer => {
      req.io.emit('emergencyAlert', {
        officerId: officer._id,
        vehicleNumber: vehicle.vehicleNumber,
        pickup,
        dropoff
      });
    });

    res.json({ message: 'Emergency request sent', notifiedOfficers: nearbyOfficers.length });
  } catch (error) {
    res.status(500).json({ message: 'Error processing emergency request', error: error.message });
  }
});

router.post('/clear', authMiddleware, async (req, res) => {
  try {
    const { vehicleId } = req.body;
    const vehicle = await Vehicle.findById(vehicleId).populate('driver');
    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    // Notify driver (in a real app, you'd use push notifications or WebSockets)
    req.io.emit('roadCleared', {
      driverId: vehicle.driver._id,
      message: 'The road ahead has been cleared for your passage.'
    });

    res.json({ message: 'Road cleared notification sent' });
  } catch (error) {
    res.status(500).json({ message: 'Error processing clear notification', error: error.message });
  }
});

module.exports = router;
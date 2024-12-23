const express = require('express');
const Driver = require('../models/Driver');
const { authMiddleware } = require('../middleware/auth');
const upload = require('../middleware/multer');
const createDriver = require('../controllers/createDriver');

const router = express.Router();

router.post('/DriverDetails',createDriver);

router.get('/', authMiddleware, async (req, res) => {
  try {
    const drivers = await Driver.find().populate('vehicle');
    res.json(drivers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching drivers', error: error.message });
  }
});

// Update a driver by ID
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const updatedDriver = await Driver.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedDriver) {
      return res.status(404).json({ message: 'Driver not found' });
    }
    res.json(updatedDriver);
  } catch (error) {
    res.status(400).json({ message: 'Error updating driver', error: error.message });
  }
});

// Delete a driver by ID
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const deletedDriver = await Driver.findByIdAndDelete(req.params.id);
    if (!deletedDriver) {
      return res.status(404).json({ message: 'Driver not found' });
    }
    res.json({ message: 'Driver deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting driver', error: error.message });
  }
});

module.exports = router;
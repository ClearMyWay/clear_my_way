const express = require('express');
const Officer = require('../models/Officer');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    const newOfficer = new Officer(req.body);
    await newOfficer.save();
    res.status(201).json(newOfficer);
  } catch (error) {
    res.status(400).json({ message: 'Error creating officer', error: error.message });
  }
});

router.get('/', authMiddleware, async (req, res) => {
  try {
    const officers = await Officer.find();
    res.json(officers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching officers', error: error.message });
  }
});

router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const updatedOfficer = await Officer.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updatedOfficer);
  } catch (error) {
    res.status(400).json({ message: 'Error updating officer', error: error.message });
  }
});

module.exports = router;
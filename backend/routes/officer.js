const express = require('express');
const OfficerRegister = require('../models/OfficerRegister');
const { authMiddleware } = require('../middleware/auth');
const upload = require('../middleware/multer');
const createOfficer = require('../controllers/createOfficer');
const router = express.Router();
const jwt = require('jsonwebtoken')
require('dotenv').config();


const JWT_SECRET = process.env.JWT_SECRET 
const apiKey = process.env.API_KEY
const sendOtp = async (number) => {
  console.log(number);
  const otpUrl = `https://2factor.in/API/V1/${apiKey}/SMS/+91${number}/AUTOGEN`;
  const response = await fetch(otpUrl);
  const data = await response.json();
  return data;
};

router.post('/OfficerDetails',  createOfficer);

router.post('/update-location', async (req, res) => {
  const { Username, lat, lng } = req.body;

  if (!Username || !lat || !lng) {
    return res.status(400).send({ error: 'Invalid data' });
  }

  try {
    await OfficerRegister.findByIdAndUpdate(
      Username,
      { lat, lng, lastUpdated: new Date() },
      { new: true, upsert: true }
    );
    res.send({ message: 'Location updated successfully' });
  } catch (error) {
    console.error('Error updating location:', error);
    res.status(500).send({ error: 'Failed to update location' });
  }
});

router.post('/sign-up', async (req, res) => {
  console.log(req.body)
  try {
    const { Username, mobileNumber, Password } = req.body;

    // Check if the officer already exists based on the username
    const existingOfficer = await OfficerRegister.findOne({ Username: Username });

    if (existingOfficer) {
      return res.status(400).json({ message: 'Officer already exists' });
    }

    // Hash the password
     const encryptedPassword = jwt.sign({ Password }, JWT_SECRET);

    // Create a new officer with the hashed password
    const newOfficer = new OfficerRegister({
      Username,
      mobileNumber,
      Password: encryptedPassword,
    });
    sendOtp(mobileNumber);
    await newOfficer.save();

    // Generate a JWT token
    const payload = { id: newOfficer._id, username: newOfficer.Username };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    // Send the token back to the frontend
    res.status(201).json({
      message: 'Officer registered successfully',
      token,
      officer: {
        Username: newOfficer.Username,
      },
    });
  } catch (error) {
    console.error('Error creating officer:', error);
    res.status(400).json({ message: 'Error creating officer', error: error.message });
  }
});

router.post('/login', async (req, res) => {
  console.log(req.body)
  try {
    const { Username, Password } = req.body;

    // Check if the officer exists based on the username
    const officer = await OfficerRegister.findOne({ Username: Username });

    if (!officer) {
      return res.status(400).json({ message: 'Officer not found' });
    }

    // Compare the entered password with the stored hashed password
    const decoded = jwt.verify(officer.Password, process.env.JWT_SECRET);

    if (decoded.Password === Password) {
      return res.status(200).json({ message: 'Login successful' });
    } else {
      return res.status(400).json({ message: 'Invalid password' });
    }
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ message: 'Error logging in', error: error.message });
  }
});

// router.put('/:id', authMiddleware, async (req, res) => {
//   try {
//     const updatedOfficer = await Officer.findByIdAndUpdate(req.params.id, req.body, { new: true });
//     res.json(updatedOfficer);
//   } catch (error) {
//     res.status(400).json({ message: 'Error updating officer', error: error.message });
//   }
// });

module.exports = router;
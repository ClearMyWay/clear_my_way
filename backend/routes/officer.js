const express = require('express');
const Officer = require('../models/Officer.js');
const { authMiddleware } = require('../middleware/auth.js');
const upload = require('../middleware/multer');
const createOfficer = require('../controllers/createOfficer.js');
const router = express.Router();
const jwt = require('jsonwebtoken');
require('dotenv').config();


const JWT_SECRET = process.env.JWT_SECRET 
const apiKey = process.env.API_KEY


router.post('/OfficerDetails',  createOfficer)

router.post('/update-location', async (req, res) => {
  const { email, lat, lng } = req.body;
  console.log(req.body);

  if (!email || !lat || !lng) {
    return res.status(400).send({ error: 'Invalid data' });
  }

  try {
    await Officer.findOneAndUpdate(
      {email},
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
  console.log(req.body);
  try {
    const { email, mobileNumber, Password } = req.body;

    // Check if the officer exists based on the email
    const existingOfficer = await Officer.findOne({ email: email });

    if (!existingOfficer) {
      return res.status(404).json({ message: 'Officer not found' });
    }

    // Hash the new password
    const encryptedPassword = jwt.sign({ Password }, JWT_SECRET);

    // Define the update object
    const updateFields = {
      mobileNumber: mobileNumber || existingOfficer.mobileNumber, // Use the new mobile number or keep the existing one
      Password: encryptedPassword, // Update the password with the encrypted one
    };

    // Update the officer details using findOneAndUpdate
    const updatedOfficer = await Officer.findOneAndUpdate(
      { email: email }, // Find officer by email
      updateFields, // Fields to update
      { new: true } // Return the updated document
    );

    // Generate a new JWT token
    const payload = { id: updatedOfficer._id, username: updatedOfficer.Username };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    // Send the response back to the frontend
    res.status(200).json({
      message: 'Officer details updated successfully',
      token,
      officer: {
        Username: updatedOfficer.Username,
        email: updatedOfficer.email,
      },
    });
  } catch (error) {
    console.error('Error updating officer:', error);
    res.status(500).json({ message: 'Error updating officer', error: error.message });
  }
});




router.post('/get-details', async (req, res) => {
  console.log(req.body)
  try {
    const { email } = req.body;

    // Check if the officer already exists based on the username
    const existingOfficer = await Officer.findOne({ email: email });

    // Send the token back to the frontend
    res.status(201).json({
      existingOfficer
    });
  } catch (error) {
    console.error('Error creating officer:', error);
    res.status(400).json({ message: 'Error creating officer', error: error.message });
  }
});




router.post('/login', async (req, res) => {
  console.log(req.body)
  try {
    const { email, Password } = req.body;

    // Check if the officer exists based on the username
    const officer = await Officer.findOne({ email: email });

    if (!officer) {
      return res.status(400).json({ message: 'Officer not found' });
    }

    // Compare the entered password with the stored hashed password
    const decoded = jwt.verify(officer.Password, JWT_SECRET);

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
router.post('/logout', async (req, res) => {
  console.log(req.body)
  try {
    const { email } = req.body;

    // Check if the officer exists based on the username
    const officer = await Officer.findOne({ email: email });
    existingOfficer.lng = null;
    existingOfficer.lat = null;
    
    await existingOfficer.save();
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
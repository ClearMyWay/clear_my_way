const express = require('express');
const VehicleRegister = require('../models/vehicleRegister.js');
const upload = require('../middleware/multer.js');
const createVehicle = require('../controllers/createVehicle.js');
const { authMiddleware } = require('../middleware/auth.js');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const router = express.Router();

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET 
const apiKey = process.env.API_KEY

router.post('/VehicleDetails',  createVehicle);


router.post('/sign-up', async (req, res) => {
  const { vehicleNumber, OwnerNumber, Password } = req.body;
  console.log(req.body);

  if (!vehicleNumber || !Password) {
    return res.status(400).json({ message: 'Vehicle number and password are required' });
  }

  try {
    // Check if the vehicle already exists
    const existingVehicle = await VehicleRegister.findOne({ vehicleNumber });
    if (existingVehicle) {
      return res.status(400).json({ message: 'Vehicle already exists' });
    }

    // Encrypt the password using JWT (encode the password)
    const encryptedPassword = jwt.sign({ Password }, JWT_SECRET); // Password expires in 1 day (adjust as needed)

    // Create and save the new vehicle
    const newVehicle = new VehicleRegister({
      vehicleNumber,
      OwnerNumber,
      Password: encryptedPassword, // Store the encrypted password
    });

    await newVehicle.save();
    res.status(201).json({ message: 'Vehicle added successfully', newVehicle });
  } catch (error) {
    console.log(error)
    res.status(400).json({ message: 'Error creating vehicle', error: error.message });
  }
});


router.post('/login', async (req, res) => {
  const { vehicleNumber, Password } = req.body;
  console.log(req.body);

  if (!vehicleNumber || !Password) {
    return res.status(400).json({ message: 'Vehicle number and password are required' });
  }

  try {
    // Find the vehicle based on the vehicle number
    const vehicle = await VehicleRegister.findOne({ vehicleNumber });
    console.log(vehicle);
    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    // Decode the JWT password
    try {
      const decoded = jwt.verify(vehicle.Password, JWT_SECRET);
      // console.log('decoded: ',decoded);
      // Compare the decoded password with the entered password
      if (decoded.Password === Password) {
        return res.status(200).json({ message: 'Login successful' });
      } else {
        return res.status(400).json({ message: 'Invalid password' });
      }
    } catch (error) {
      console.log(error);
      return res.status(400).json({ message: 'Failed to verify password', error: error.message });
    }

  } catch (error) {
    res.status(500).json({ message: 'Error logging in', error: error.message });
  }
});


// router.put('/:id', authMiddleware, async (req, res) => {
//   try {
//     const updatedVehicle = await Vehicle.findByIdAndUpdate(req.params.id, req.body, { new: true });
//     res.json(updatedVehicle);
//   } catch (error) {
//     res.status(400).json({ message: 'Error updating vehicle', error: error.message });
//   }
// });

module.exports = router;
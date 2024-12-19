const express = require('express');
const Vehicle = require('../models/Vehicle');
const upload = require('../middleware/multer');
const createVehicle = require('../controllers/createVehicle')
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET 

router.post('/VehicleDetails',  upload.single('VC'), createVehicle);

router.post('/sign-up', async (req, res) => {
  const { vehicleNumber, password } = req.body;

  if (!vehicleNumber || !password) {
    return res.status(400).json({ message: 'Vehicle number and password are required' });
  }

  try {
    // Check if the vehicle already exists
    const existingVehicle = await Vehicle.findOne({ vehicleNumber });
    if (existingVehicle) {
      return res.status(400).json({ message: 'Vehicle already exists' });
    }

    // Encrypt the password using JWT (encode the password)
    const encryptedPassword = jwt.sign({ password }, process.env.JWT_SECRET, { expiresIn: '1d' }); // Password expires in 1 day (adjust as needed)

    // Create and save the new vehicle
    const newVehicle = new Vehicle({
      vehicleNumber,
      password: encryptedPassword, // Store the encrypted password
    });

    await newVehicle.save();

    res.status(201).json({ message: 'Vehicle added successfully', newVehicle });
  } catch (error) {
    res.status(400).json({ message: 'Error creating vehicle', error: error.message });
  }
});


router.post('/login', async (req, res) => {
  const { vehicleNumber, password } = req.body;

  if (!vehicleNumber || !password) {
    return res.status(400).json({ message: 'Vehicle number and password are required' });
  }

  try {
    // Find the vehicle based on the vehicle number
    const vehicle = await Vehicle.findOne({ vehicleNumber });

    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    // Decode the JWT password
    try {
      const decoded = jwt.verify(vehicle.password, process.env.JWT_SECRET);

      // Compare the decoded password with the entered password
      if (decoded.password === password) {
        return res.status(200).json({ message: 'Login successful' });
      } else {
        return res.status(400).json({ message: 'Invalid password' });
      }
    } catch (error) {
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
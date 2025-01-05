const express = require('express');
const Vehicle = require('../models/Vehicle.js');
const upload = require('../middleware/multer.js');
const createVehicle = require('../controllers/createVehicle.js');
const { authMiddleware } = require('../middleware/auth.js');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const router = express.Router();

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET 

router.post('/VehicleDetails',  createVehicle);


router.post('/sign-up', async (req, res) => {
  const { ownerNumber, vehicleNumber, Password } = req.body;
  console.log(req.body);

  // Validate that both ownerNumber, vehicleNumber, and Password are provided
  if (!ownerNumber || !vehicleNumber || !Password) {
    return res.status(400).json({ message: 'Owner number, vehicle number, and password are required' });
  }

  try {
    // Encrypt the password (it's better to use bcrypt for password hashing instead of JWT)
    const encryptedPassword = jwt.sign({ Password }, JWT_SECRET); // Password expires in 1 day (adjust as needed)

    // Define the update object
    const updateFields = {
      Password: encryptedPassword, // Encrypt and update the password
    };

    // Find the vehicle by both ownerNumber and vehicleNumber and update the details
    const updatedVehicle = await vehicle.findOneAndUpdate(
      { ownerNumber: ownerNumber, vehicleNumber: vehicleNumber }, // Find vehicle by ownerNumber and vehicleNumber
      updateFields, // Fields to update (Password in this case)
      { new: true } // Return the updated document
    );

    // Check if the vehicle exists
    if (!updatedVehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    res.status(200).json({
      message: 'Vehicle details updated successfully',
      updatedVehicle, // Return the updated vehicle details
    });
  } catch (error) {
    console.log(error);
    res.status(400).json({ message: 'Error updating vehicle', error: error.message });
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
    const vehicle = await Vehicle.findOne({ vehicleNumber });
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
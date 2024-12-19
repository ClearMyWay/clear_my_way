const express = require('express');
const Officer = require('../models/Officer');
const { authMiddleware } = require('../middleware/auth');
const upload = require('../middleware/multer');
const createOfficer = require('../controllers/createOfficer');
const router = express.Router();

router.post('/OfficerDetails',  upload.single('ID'), createOfficer);

router.post('/sign-up', async (req, res) => {
  try {
    const { Username, Password } = req.body;

    // Check if the officer already exists based on the username
    const existingOfficer = await officerRegister.findOne({ Username: Username });

    if (existingOfficer) {
      return res.status(400).json({ message: 'Officer already exists' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(Password, 10);

    // Create a new officer with the hashed password
    const newOfficer = new officerRegister({
      Username,
      Password: hashedPassword,
    });

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
  try {
    const { Username, Password } = req.body;

    // Check if the officer exists based on the username
    const officer = await officerRegister.findOne({ Username: Username });

    if (!officer) {
      return res.status(400).json({ message: 'Officer not found' });
    }

    // Compare the entered password with the stored hashed password
    const isMatch = await bcrypt.compare(Password, officer.Password);

    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid password' });
    }

    // Generate a JWT token
    const payload = { id: officer._id, username: officer.Username };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    // Send the token back to the frontend
    res.status(200).json({
      message: 'Login successful',
      token,
      officer: {
        Username: officer.Username,
      },
    });
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
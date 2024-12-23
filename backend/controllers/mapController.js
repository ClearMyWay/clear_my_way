const axios = require('axios');
const Ambulance = require('../models/Ambulance'); // Assuming you have an Ambulance model

// Function to get live location of the ambulance
exports.getLiveLocation = async (req, res) => {
  try {
    const ambulance = await Ambulance.findOne({ status: 'active' }); // Example query to get active ambulance
    if (!ambulance) {
      return res.status(404).json({ message: 'No active ambulance found' });
    }
    res.json({ location: ambulance.location });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Function to get estimated time of arrival (ETA) of the ambulance
exports.getEta = async (req, res) => {
  try {
    const { destination } = req.query;
    const ambulance = await Ambulance.findOne({ status: 'active' }); // Example query to get active ambulance
    if (!ambulance) {
      return res.status(404).json({ message: 'No active ambulance found' });
    }
    const response = await axios.get(`https://api.openrouteservice.org/v2/directions/driving-car?api_key=${process.env.OPENROUTESERVICE_API_KEY}&start=${ambulance.location.coordinates.join(',')}&end=${destination}`);
    const eta = response.data.features[0].properties.segments[0].duration / 60; // Convert seconds to minutes
    res.json({ eta: `${eta} minutes` });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

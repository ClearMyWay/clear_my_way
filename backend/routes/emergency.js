const express = require('express');
const router = express.Router();
const axios = require('axios');
const turf = require('@turf/turf');
const officerRegister = require('../models/OfficerRegister');
require('dotenv').config();

// Get LocationIQ API Key from environment variables
const LOCATIONIQ_API_KEY = process.env.Location_IQ_API_KEY;

// Handle SOS request
router.post('/sos', async (req, res) => {
    const { currentLat, currentLon, destinationLat, destinationLon } = req.body;
    console.log(req.body);
  
    if (!currentLat || !currentLon || !destinationLat || !destinationLon) {
      return res.status(400).send({ error: 'Invalid coordinates' });
    }
  
    try {
      // Fetch route from LocationIQ
      const routeResponse = await axios.get(
        `https://us1.locationiq.com/v1/directions/driving/${currentLon},${currentLat};${destinationLon},${destinationLat}?key=${LOCATIONIQ_API_KEY}&steps=true&geometries=geojson`
      );
  
      const route = routeResponse.data.routes[0].geometry.coordinates;
      const routeLine = turf.lineString(route);
  
      // Fetch all officers with real-time locations
      const officers = await officerRegister.find(); // Replace with your Officer schema/model
  
      const officersInRange = officers.filter((officer) => {
        const officerPoint = turf.point([officer.lng, officer.lat]);
        const distance = turf.pointToLineDistance(officerPoint, routeLine, { units: 'kilometers' });
        return distance <= 5; // Check if officer is within 5 km of the route
      });
  
      // Notify officers in range via Socket.IO
      const io = req.io;
      officersInRange.forEach((officer) => {
        io.to(officer.socketId).emit('ambulance_route', { route });
      });
  
      res.send({ message: 'SOS activated', officersInRange });
    } catch (error) {
      console.error('Error processing SOS request:', error);
      res.status(500).send({ error: 'Failed to process SOS request' });
    }
  });
  
module.exports = router;

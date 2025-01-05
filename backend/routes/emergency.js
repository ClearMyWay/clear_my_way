const express = require('express');
const Officer = require('../models/Officer.js');
const router = express.Router();
require('dotenv').config();
const axios = require('axios');
const turf = require('@turf/turf');

const LOCATIONIQ_API_KEY = process.env.API_KEY;

let activeSockets = {};

router.post('/sos', async (req, res) => {
  const { currentLat, currentLon, destinationLat, destinationLon, socketId, vehicleNumber } = req.body;

  if (!currentLat || !currentLon || !destinationLat || !destinationLon || !vehicleNumber) {
      return res.status(400).send({ error: 'Invalid coordinates or missing vehicle number' });
  }

  try {
      // Fetch route from LocationIQ API
      const routeResponse = await axios.get(
          `https://us1.locationiq.com/v1/directions/driving/${currentLon},${currentLat};${destinationLon},${destinationLat}?key=${LOCATIONIQ_API_KEY}&steps=true&geometries=geojson`
      );

      const route = routeResponse.data.routes[0].geometry.coordinates;
      const routeLine = turf.lineString(route);

      // Fetch all officers with real-time locations
      const officers = await Officer.find();

      // Filter officers within 1km of the route
      const officersInRange = officers.filter((officer) => {
          const officerPoint = turf.point([officer.lng, officer.lat]);
          const distance = turf.pointToLineDistance(officerPoint, routeLine, { units: 'kilometers' });
          return distance <= 1; // Check if officer is within 1 km of the route
      });

      const io = req.io;

      // Notify officers in range
      officersInRange.forEach((officer) => {
          io.to(officer.socketId).emit('custom_message', {
              message: 'SOS alert: You are near the route. Please respond ASAP!',
              route,
              callId: socketId,
              currentLocation: { lat: currentLat, lon: currentLon },
          });
      });

      // Handle ambulance socket with vehicle number
      if (!activeSockets[vehicleNumber]) {
          // Add the ambulance socket with vehicle number
          activeSockets[vehicleNumber] = socketId;
          io.to(socketId).emit('emergency_call', {
              message: 'You have received an emergency call. Please respond.',
              callId: socketId,
          });
      } else {
          // Update the existing ambulance socket
          io.to(activeSockets[vehicleNumber]).emit('emergency_call', {
              message: 'Ambulance is already connected. Updated information sent.',
          });
      }

      // Handle disconnection of ambulance
      io.on('connection', (socket) => {
          socket.on('disconnect', () => {
              if (activeSockets[vehicleNumber] === socket.id) {
                  delete activeSockets[vehicleNumber]; // Remove the ambulance socket on disconnect
                  console.log(`Ambulance with vehicle number ${vehicleNumber} disconnected.`);
              }
          });
      });

      res.send({ message: 'SOS activated', officersInRange });
  } catch (error) {
      console.error('Error processing SOS request:', error);
      res.status(500).send({ error: 'Failed to process SOS request' });
  }
});

// Export the router so it can be used in other parts of the app
module.exports = router;

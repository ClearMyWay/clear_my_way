const mongoose = require("mongoose");
const Vehicle = require("../models/Vehicle");

const createVehicle = async (req, res) => {
  console.log(req);
  try {
    const { 
      agency, 
      vehicleNumber, 
      vehicleModel, 
      ownerNumber, 
      rcNumber, 
      vehicleColor, 
      vehiclePhoto 
    } = req.body;

    if (!vehiclePhoto) {
      return res.status(400).send("Vehicle photo is required");
    }

    // Validate the base64 format (optional)
    if (!/^data:image\/\w+;base64,/.test(vehiclePhoto)) {
      return res.status(400).send("Invalid base64 image format");
    }

    // Create the vehicle document with the base64 image directly
    const newVehicle = new Vehicle({
      agency,
      vehicleNumber,
      vehicleModel,
      ownerNumber,
      rcNumber,
      vehicleColor,
      vehiclePhoto, // Save the base64 image directly in the database
    });

    // Save vehicle data to MongoDB
    await newVehicle.save();
    console.log("Vehicle details saved to MongoDB successfully.");

    res.status(201).send({
      message: "Vehicle details saved successfully",
      vehicle: newVehicle, // Return the saved vehicle data
    });
  } catch (err) {
    console.error("Error processing request:", err);
    res.status(500).send({ error: "Failed to process request" });
  }
};

module.exports = createVehicle;

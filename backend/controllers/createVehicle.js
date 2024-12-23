const fs = require('fs'); // Import fs for file system operations
const path = require('path'); // Import path module for handling file paths
const mongoose = require('mongoose');
const  Vehicle = require("../models/Vehicle");

const createVehicle = async (req, res) => {
  // console.log(req.body);

  try {
    const { agency, vehicleNumber, vehicleModel, ownerNumber, rcNumber, vehicleColor, vehiclePhoto } = req.body;

    if (!vehiclePhoto) {
      return res.status(400).send("Vehicle photo is required");
    }

    // Decode base64 and save to file
    const base64Data = vehiclePhoto.replace(/^data:image\/\w+;base64,/, ""); // Remove metadata if included
    const buffer = Buffer.from(base64Data, "base64");

    // Define the file path for saving the image locally
    const fileName = `vehicle_${Date.now()}.png`; // Customize filename
    const filePath = path.join('E:', 'clearMyWay', 'backend', 'uploads', fileName);

    // Save the file to the specified path
    fs.writeFileSync(filePath, buffer);

    console.log("File saved successfully:", filePath);

    // Create the vehicle document to be saved in MongoDB
    const newVehicle = new Vehicle({
      agency,
      vehicleNumber,
      vehicleModel,
      ownerNumber,
      rcNumber,
      vehicleColor,
      vehiclePhotoPath: filePath, // Save the local file path (or URL if using AWS S3, etc.)
    });

    // Save vehicle data to MongoDB
    await newVehicle.save();
    console.log('Vehicle details saved to MongoDB successfully.');

    res.status(201).send({
      message: "Vehicle details saved successfully",
      vehiclePhotoPath: filePath // Return the path to the saved vehicle photo (or URL if using S3)
    });
  } catch (err) {
    console.error("Error processing request:", err);
    res.status(500).send({ error: "Failed to process request" });
  }
};

module.exports = createVehicle;

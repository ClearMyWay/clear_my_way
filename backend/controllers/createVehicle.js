const fs = require('fs'); // Import fs for file system operations
const path = require('path'); // Import path module for handling file paths
const mongoose = require('mongoose');
const Vehicle = require("../models/Vehicle");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");

// Configure AWS S3
const s3Client = new S3Client({
  region: "ap-south-1",
  credentials: {
    accessKeyId: process.env.aws_access_key,
    secretAccessKey: process.env.aws_secret_access_key,
  },
});

const BUCKET_NAME = 'clearmyway'; // Replace with your actual S3 bucket name

const createVehicle = async (req, res) => {
  try {
    const { agency, vehicleNumber, vehicleModel, ownerNumber, rcNumber, vehicleColor, vehiclePhoto } = req.body;

    if (!vehiclePhoto) {
      return res.status(400).send("Vehicle photo is required");
    }

    // Decode base64 image data
    const base64Data = vehiclePhoto.replace(/^data:image\/\w+;base64,/, ""); // Remove metadata if included
    const buffer = Buffer.from(base64Data, "base64");

    // Generate unique file name
    const fileName = `vehicle_${Date.now()}.png`;

    // S3 upload parameters
    const params = {
      Bucket: BUCKET_NAME,
      Key: fileName,
      Body: buffer,
    };

    // Upload to S3
    const uploadResult = await s3.upload(params).promise();
    console.log("File uploaded successfully to S3:", uploadResult.Location);

    // Create the vehicle document to be saved in MongoDB
    const newVehicle = new Vehicle({
      agency,
      vehicleNumber,
      vehicleModel,
      ownerNumber,
      rcNumber,
      vehicleColor,
      vehiclePhotoPath: uploadResult.Location, // Save the S3 file URL in MongoDB
    });

    // Save vehicle data to MongoDB
    await newVehicle.save();
    console.log('Vehicle details saved to MongoDB successfully.');

    res.status(201).send({
      message: "Vehicle details saved successfully",
      vehiclePhotoPath: uploadResult.Location, // Return the S3 file URL
    });
  } catch (err) {
    console.error("Error processing request:", err);
    res.status(500).send({ error: "Failed to process request" });
  }
};

module.exports = createVehicle;

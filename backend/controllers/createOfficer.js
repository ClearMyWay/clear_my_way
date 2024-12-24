const fs = require('fs'); // Import fs for file system operations
const path = require('path'); // Import path module for handling file paths
const mongoose = require('mongoose');
const  Officer  = require("../models/Officer");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");

// Configure AWS S3
const s3Client = new S3Client({
  region: "ap-south-1",
  credentials: {
    accessKeyId: process.env.aws_access_key,
    secretAccessKey: process.env.aws_secret_access_key,
  },
});

const BUCKET_NAME = 'clearmyway';


const createOfficer = async (req, res) => {
  console.log(req.body);
  try {
    const { name, email,  Designation, phoneNumber, StationName, IDCardPhoto } = req.body;

    // Check if the uploaded file is present
    

    // Read the file and save it locally
    const base64Data =  IDCardPhoto.replace(/^data:image\/\w+;base64,/, ""); // Convert buffer to base64
    const buffer = Buffer.from(base64Data, 'base64');

    // Define the file path for saving the image locally
    const fileName = `officer_${Date.now()}.png`; // Customize filename
    const params = {
      Bucket: BUCKET_NAME,
      Key: fileName,
      Body: buffer,
    };

    // Upload to S3
    const uploadResult = await s3.upload(params).promise();
    console.log("File uploaded successfully to S3:", uploadResult.Location);

    // Create the officer document to be saved in MongoDB
    const officer = new Officer({
      name,
      email,
      Designation,
      phoneNumber,
      StationName,
      ID: uploadResult.Location, // Save the local file path (you can also use a URL if using S3 or other services)
    });

    // Save officer data to MongoDB
    await officer.save();
    console.log('Officer details saved to MongoDB successfully.');

    res.status(201).send({
      message: "Officer details saved successfully",
      officerIDPath: uploadResult.Location // Return the path to the saved officer ID (or URL if using S3)
    });
  } catch (err) {
    console.error("Error processing request:", err);
    res.status(500).send({ error: "Failed to process request" });
  }
};

module.exports = createOfficer;

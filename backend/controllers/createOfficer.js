const mongoose = require('mongoose');
const Officer = require("../models/Officer");

const createOfficer = async (req, res) => {
  console.log(req.body);
  try {
    const { 
      name, 
      email, 
      Designation, 
      phoneNumber, 
      StationName, 
      IDCardPhoto 
    } = req.body;

    if (!IDCardPhoto) {
      return res.status(400).send("ID Card photo is required");
    }

    // Validate the base64 format (optional)
    if (!/^data:image\/\w+;base64,/.test(IDCardPhoto)) {
      return res.status(400).send("Invalid base64 image format");
    }

    // Create the officer document with the base64 image directly
    const officer = new Officer({
      name,
      email,
      Designation,
      phoneNumber,
      StationName,
      IDCardPhoto, // Save the base64 image directly in the database
    });

    // Save officer data to MongoDB
    await officer.save();
    console.log('Officer details saved to MongoDB successfully.');

    res.status(201).send({
      message: "Officer details saved successfully",
      officer,
    });
  } catch (err) {
    console.error("Error processing request:", err);
    res.status(500).send({ error: "Failed to process request" });
  }
};

module.exports = createOfficer;

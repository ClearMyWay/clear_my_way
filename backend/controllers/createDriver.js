const fs = require('fs'); // Import fs for file system operations
const path = require('path'); // Import path module for handling file paths
const { Driver } = require("../models/Driver");

const createDriver = async (req, res) => {
  console.log('Request Body:', req.body);

  const { driverName, gender, dob, email, phoneNumber, licenseNumber, DL } = req.body;

  if (!DL) {
    return res.status(400).send("Driver License photo is required");
  }

  try {
    // Decode base64 and save to file
    const base64Data = DL.replace(/^data:image\/\w+;base64,/, ""); // Remove metadata if included
    const buffer = Buffer.from(base64Data, "base64");

    // Define the file path for saving the image locally
    const fileName = `driver_${Date.now()}.png`; // Customize filename
    const filePath = path.join('E:', 'clearMyWay', 'backend', 'uploads', fileName);

    // Save the file to the specified path
    fs.writeFileSync(filePath, buffer);

    console.log("Driver License photo saved successfully:", filePath);

    // Create the driver document to be saved in MongoDB
    const driver = new Driver({
      DriverName: driverName,
      Gender: gender,
      DOB: dob,
      Email: email,
      phoneNumber,
      LicenseNumber: licenseNumber,
      DL: filePath, // Save the local file path (or URL if using AWS S3, etc.)
    });

    // Save driver data to MongoDB
    await driver.save();
    console.log('Driver details saved to MongoDB successfully.');

    res.status(201).send({
      message: "Driver details saved successfully",
      driverLicensePath: filePath // Return the path to the saved driver license photo (or URL if using S3)
    });
  } catch (err) {
    console.error('Error saving driver:', err.message);
    res.status(500).send({ error: "Failed to save driver: " + err.message });
  }
};

module.exports = createDriver;

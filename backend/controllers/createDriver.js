const { Driver } = require("../models/Driver");

const createDriver = async (req, res) => {
  console.log('Request Body:', req.body);

  const { driverName, gender, dob, email, phoneNumber, licenseNumber, DL } = req.body;

  if (!DL) {
    return res.status(400).send("Driver License photo is required");
  }

  try {
    // Validate the base64 format (optional)
    if (!/^data:image\/\w+;base64,/.test(DL)) {
      return res.status(400).send("Invalid base64 image format");
    }

    // Create the driver document with the base64 image directly
    const driver = new Driver({
      DriverName: driverName,
      Gender: gender,
      DOB: dob,
      Email: email,
      phoneNumber,
      LicenseNumber: licenseNumber,
      DL, // Save the base64 image directly in MongoDB
    });

    // Save driver data to MongoDB
    await driver.save();
    console.log('Driver details saved to MongoDB successfully.');

    res.status(201).send({
      message: "Driver details saved successfully",
      driver, // Return the saved driver data
    });
  } catch (err) {
    console.error('Error saving driver:', err.message);
    res.status(500).send({ error: "Failed to save driver: " + err.message });
  }
};

module.exports = createDriver;

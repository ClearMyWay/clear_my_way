const { Driver } = require("../models/Driver");

const createDriver= async (req, res) => {
  console.log('Request Body:', req.body);
  console.log('Uploaded File:', req.file);

  const { DriverName, Gender, DOB, Email, phoneNumber, LicenseNumber } = req.body;
  const DL = req.file?.path;

  try {
    const driver = new Driver({ DriverName, Gender, DOB, Email, phoneNumber, LicenseNumber, DL });
    await driver.save();
    res.status(201).send(driver);
  } catch (err) {
    console.error('Error saving driver:', err.message);
    res.status(400).send('Error saving driver: ' + err.message);
  }
};


module.exports =  createDriver ;

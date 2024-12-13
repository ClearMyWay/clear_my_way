const { Officer } = require("../models/Vehicle");

const createOfficer= async (req, res) => {
  console.log('Request Body:', req.body);
  console.log('Uploaded File:', req.file);

  const { Name, IdNumber, Designation, phoneNumber, Email, StationName } = req.body;
  const ID = req.file?.path;

  try {
    const officer = new Officer({ Name, IdNumber, Designation, phoneNumber, Email, StationName, ID });
    await officer.save();
    res.status(201).send(officer);
  } catch (err) {
    console.error('Error saving officer:', err.message);
    res.status(400).send('Error saving officer: ' + err.message);
  }
};


module.exports =  createDriver ;

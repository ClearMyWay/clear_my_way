const { Vehicle } = require("../models/Vehicle");

const createVehicle= async (req, res) => {
  console.log('Request Body:', req.body);
  console.log('Uploaded File:', req.file);

  const { Agency, vehicleNumber, vehicleModel, ownerNumber, rcNumber, vehicleColor } = req.body;
  const vehiclePhoto = req.file?.path;

  try {
    const vehicle = new Vehicle({ Agency, vehicleNumber, vehicleModel, ownerNumber, rcNumber, vehicleColor, vehiclePhoto });
    await vehicle.save();
    res.status(201).send(vehicle);
  } catch (err) {
    console.error('Error saving vehicle:', err.message);
    res.status(400).send('Error saving vehicle: ' + err.message);
  }
};



module.exports =  createVehicle ;

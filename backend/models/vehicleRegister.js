const mongoose = require('mongoose');

const VehicleRegSchema = new mongoose.Schema({
  vehicleNumber: { type: String, required: true, unique: true },
  OwnerNumber: { type: String, required: true, unique: false},
  Password:  { type: String, required: true, unique: true },
});

VehicleRegSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('vehicleRegister', VehicleRegSchema);
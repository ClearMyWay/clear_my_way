const mongoose = require('mongoose');

const VehicleSchema = new mongoose.Schema({

  agency: { type:String},
  vehicleNumber: { type: String, required: true, unique: true },
  vehicleModel: { type: String},
  ownerNumber: { type: String},
  rcNumber: { type: String},
  vehicleColor: { type: String},
  vehiclePhoto:  { type: String },
  OwnerNumber: { type: String, required: false, unique: false},
  Password:  { type: String, required: false, unique: true },
});


VehicleSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Vehicle', VehicleSchema);
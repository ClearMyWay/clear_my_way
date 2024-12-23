const mongoose = require('mongoose');

const VehicleSchema = new mongoose.Schema({

  agency: { type:String, required: true},
  vehicleNumber: { type: String, required: true, unique: true },
  vehicleModel: { type: String, required: true},
  ownerNumber: { type: String, required: true},
  rcNumber: { type: String, required: true},
  vehicleColor: { type: String, required: true},
  vehiclePhotoPath:  { type: String, required: true }
});


VehicleSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Vehicle', VehicleSchema);
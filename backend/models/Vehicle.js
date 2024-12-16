const mongoose = require('mongoose');

const VehicleSchema = new mongoose.Schema({
  vehicleNumber: { type: String, required: true, unique: true },
  type: { type: String, required: true, default: 'AMBULANCE' },
  isActive: { type: Boolean, default: true },
  currentLocation: {
    type: { type: String, default: 'Point' },
    coordinates: [Number]
  },
  driver: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver' }
}, { timestamps: true });

VehicleSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Vehicle', VehicleSchema);
const mongoose = require('mongoose');

const VehicleSchema = new mongoose.Schema({
  vehicleNumber: { 
    type: String, 
    required: true, 
    unique: true 
  },
  type: { 
    type: String, 
    required: true, 
    default: 'AMBULANCE' 
  },
  isActive: { 
    type: Boolean, 
    default: true 
  },
  currentLocation: {
    type: { 
      type: String, 
      default: 'Point', 
      enum: ['Point'] 
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  driver: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Driver' 
  },
  status: {
    type: String,
    enum: ['available', 'on_duty', 'maintenance'],
    default: 'available'
  },
  lastMaintenance: {
    type: Date
  }
}, { timestamps: true });

VehicleSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Vehicle', VehicleSchema);
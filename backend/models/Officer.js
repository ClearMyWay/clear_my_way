const mongoose = require('mongoose');

const OfficerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  Designation: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  StationName: { type: String, required: true },
  ID: { type: String, required: true },
  mobileNumber: { type: String, required: false, unique: true },
  Password: { type: String, required: false,  unique: true },
  socketId: { type: String }, 
  lat: { type: Number },
  lng: { type: Number },
  lastUpdated: { type: Date, default: Date.now },
});

OfficerSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

OfficerSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

OfficerSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Officer', OfficerSchema);
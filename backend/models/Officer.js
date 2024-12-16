const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const OfficerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  badgeNumber: { type: String, required: true, unique: true },
  station: { type: String, required: true },
  isOnDuty: { type: Boolean, default: true },
  currentLocation: {
    type: { type: String, default: 'Point' },
    coordinates: [Number]
  }
}, { timestamps: true });

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
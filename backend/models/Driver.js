const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const DriverSchema = new mongoose.Schema({
  DriverName: { type: String, required: true },
  Gender: { type: String, required: true },
  DOB: { type: String, required: true },
  Email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  LicenseNumber: { type: String, required: true, unique: true },
  DL: { type: String, required: true }, // Store file path
  password: { type: String, required: true },
});

DriverSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

DriverSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

const Driver = mongoose.model("Driver", DriverSchema);

module.exports = { Driver };


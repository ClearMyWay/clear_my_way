const mongoose = require("mongoose");

const DriverSchema = new mongoose.Schema({
    DriverName: { type: String, required: true },
    Gender: { type: String, required: true },
    DOB: { type: String, required: true },
    Email: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    LicenseNumber: { type: String, required: true },
    DL: { type: String, required: true }, // Store file path
  });

  const Driver = mongoose.model("Driver", DriverSchema);

  module.exports = { Driver };
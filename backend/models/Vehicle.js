const mongoose = require("mongoose");

const VehicleSchema = new mongoose.Schema({
    agency: { type: String, required: true },
    vehicleNo: { type: String, required: true },
    vehicleModel: { type: String, required: true },
    ownerName: { type: String, required: true },
    rcNo: { type: String, required: true },
    vehicleColor: { type: String, required: true },
    vehiclePhoto: { type: String, required: true }, // Store file path
  });

  const Vehicle = mongoose.model("Vehicle", VehicleSchema);

  module.exports = { Vehicle };
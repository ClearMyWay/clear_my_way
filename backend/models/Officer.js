const mongoose = require("mongoose");

const OfficerSchema = new mongoose.Schema({
    Name: { type: String, required: true },
    IdNumber: { type: String, required: true },
    Designation: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    Email: { type: String, required: true },
    StationName: { type: String, required: true },
    ID: { type: String, required: true }, // Store file path
  });

  const Officer = mongoose.model("Officer", OfficerSchema);

  module.exports = { Officer };
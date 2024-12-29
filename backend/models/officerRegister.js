const mongoose = require("mongoose");

const OfficerRegSchema = new mongoose.Schema({
    Username: { type: String, required: true,  unique: true },
    mobileNumber: { type: String, required: true, unique: true },
    Password: { type: String, required: true,  unique: true },
    socketId: { type: String }, 
    lat: { type: Number },
    lng: { type: Number },
    lastUpdated: { type: Date, default: Date.now },
})

const OfficerRegister =
  mongoose.models.OfficerRegister ||
  mongoose.model('OfficerRegister', OfficerRegSchema);

module.exports = OfficerRegister;
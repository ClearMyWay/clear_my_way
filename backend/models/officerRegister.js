const mongoose = require("mongoose");

const OfficerRegSchema = new mongoose.Schema({
    Username: { type: String, required: true,  unique: true },
    mobileNumber: { type: String, required: true, unique: true },
    Password: { type: String, required: true,  unique: true }
})

const officerRegister = mongoose.model("Register", OfficerRegSchema);

module.exports = { officerRegister };
const mongoose = require("mongoose");

const OfficerRegSchema = new mongoose.Schema({
    Username: { type: String, required: true },
    Password: { type: String, required: true }
})

const Register = mongoose.model("Register", OfficerRegSchema);

module.exports = { Register };
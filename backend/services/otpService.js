const Otp = require('../models/Otp');
const crypto = require('crypto');

async function sendOtp(phoneNumber) {
  const otpCode = crypto.randomInt(100000, 999999).toString();
  const otp = new Otp({ phoneNumber, otpCode });
  await otp.save();
  // Implement actual OTP sending logic here (e.g., SMS gateway)
  return otp;
}

async function verifyOtp(otpId, otpCode) {
  const otp = await Otp.findById(otpId);
  if (!otp || otp.otpCode !== otpCode) {
    return false;
  }
  await Otp.findByIdAndDelete(otpId); // Delete OTP after verification
  return true;
}

module.exports = { sendOtp, verifyOtp };

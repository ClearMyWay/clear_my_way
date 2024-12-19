const crypto = require('crypto');
const Otp = require('../models/Otp');
const { sendOtp } = require('./smsService'); 

// Generate OTP
const generateOtp = () => {
  return crypto.randomBytes(3).toString('hex'); 
};

// Send OTP via SMS
const sendOtpToPhone = async (phoneNumber) => {
  const otpCode = generateOtp();
  const expirationTime = new Date(Date.now() + 5 * 60 * 1000); // OTP expires in 5 minutes

  const otp = new Otp({
    phoneNumber,
    otpCode,
    expiresAt: expirationTime,
  });

  await otp.save();

  // Send OTP to phone via SMS service (e.g., Twilio)
  await sendOtp(phoneNumber, otpCode);  // Assuming this function sends OTP via SMS

  return otp;
};

// Verify OTP
const verifyOtp = async (phoneNumber, otpCode) => {
  const otpRecord = await Otp.findOne({ phoneNumber }).sort({ createdAt: -1 });

  if (!otpRecord) {
    return { valid: false, message: 'OTP not found for this phone number' };
  }

  if (new Date() > otpRecord.expiresAt) {
    return { valid: false, message: 'OTP expired' };
  }

  if (otpRecord.otpCode !== otpCode) {
    return { valid: false, message: 'Invalid OTP' };
  }

  // OTP is valid
  return { valid: true, message: 'OTP verified successfully' };
};

module.exports = { sendOtpToPhone, verifyOtp };

const Otp = require('../models/Otp');

async function otpVerified(req, res, next) {
  const { otpId, otpCode } = req.body;
  const isValid = await Otp.findById(otpId);
  if (!isValid || isValid.otpCode !== otpCode) {
    return res.status(401).json({ message: 'OTP verification failed' });
  }
  next();
}

module.exports = otpVerified;
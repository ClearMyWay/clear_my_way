const { sendOtpToPhone, verifyOtp } = require('../services/otpService');

// Controller to send OTP
const sendOtp = async (req, res) => {
  const { phoneNumber } = req.body;

  // Validate input
  if (!phoneNumber) {
    return res.status(400).json({ message: 'Phone number is required' });
  }

  try {
    // Generate and send OTP
    const otp = await sendOtpToPhone(phoneNumber);
    res.status(200).json({ message: 'OTP sent successfully', otpId: otp._id });
  } catch (error) {
    console.error('Error sending OTP:', error.message);
    res.status(500).json({ message: 'Failed to send OTP', error: error.message });
  }
};

// Controller to verify OTP
const verifyOtpController = async (req, res) => {
  const { phoneNumber, otpCode } = req.body;

  // Validate input
  if (!phoneNumber || !otpCode) {
    return res.status(400).json({ message: 'Phone number and OTP code are required' });
  }

  try {
    // Verify OTP
    const result = await verifyOtp(phoneNumber, otpCode);

    if (result.valid) {
      return res.status(200).json({ message: result.message });
    } else {
      return res.status(400).json({ message: result.message });
    }
  } catch (error) {
    console.error('Error verifying OTP:', error.message);
    res.status(500).json({ message: 'Failed to verify OTP', error: error.message });
  }
};

module.exports = { sendOtp, verifyOtp: verifyOtpController };

const Otp = require('../models/Otp');
const moment = require('moment');

const OTP_EXPIRY_MINUTES = process.env.OTP_EXPIRY_MINUTES || 10;
const MAX_ATTEMPTS = process.env.MAX_ATTEMPTS || 5;

const verifyOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;

        if (!phone || !otp) {
            return res.status(400).json({ msg: "Phone and OTP are required" });
        }

        // Find the most recent OTP for this phone number
        const otpRecord = await Otp.findOne({ phone }).sort({ createdAt: -1 });

        if (!otpRecord) {
            return res.status(400).json({ msg: "Invalid OTP" });
        }

        // Check if OTP is expired
        const otpAge = moment().diff(moment(otpRecord.createdAt), 'minutes');
        if (otpAge > OTP_EXPIRY_MINUTES) {
            return res.status(400).json({ msg: "OTP has expired" });
        }

        // Check if OTP matches
        if (otpRecord.otp !== otp) {
            // Increment the attempt count
            otpRecord.attempts = (otpRecord.attempts || 0) + 1;
            await otpRecord.save();

            if (otpRecord.attempts >= MAX_ATTEMPTS) {
                await Otp.deleteOne({ _id: otpRecord._id });
                return res.status(400).json({ msg: "Maximum attempts exceeded. OTP has been invalidated." });
            }

            return res.status(400).json({ msg: "Invalid OTP" });
        }

        // Delete the OTP record after successful verification
        await Otp.deleteOne({ _id: otpRecord._id });

        res.json({ 
            success: true, 
            msg: "OTP verified successfully" 
        });

    } catch (err) {
        res.status(500).json({ msg: err.message });
    }
};

module.exports = verifyOtp;
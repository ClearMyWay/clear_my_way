const express = require('express');
const Otp = require('../models/Otp');
const nodemailer = require('nodemailer');

const router = express.Router();

// Generate 6 digit OTP
function generateOtp() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send OTP via email (you can replace this with SMS service integration)
async function sendOtpEmail(email, otp) {
    let transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: 'your-email@gmail.com',
            pass: 'your-email-password'
        }
    });

    let mailOptions = {
        from: 'your-email@gmail.com',
        to: email,
        subject: 'Your OTP Code',
        text: `Your OTP code is ${otp}`
    };

    await transporter.sendMail(mailOptions);
}

// Request OTP
router.post('/request-otp', async (req, res) => {
    try {
        const { phone, email } = req.body;

        if (!phone) {
            return res.status(400).json({ msg: "Phone number is required" });
        }

        const otp = generateOtp();

        // Save OTP to database
        const newOtp = new Otp({
            phone,
            otp
        });

        await newOtp.save();

        // Send OTP via email (replace with SMS service in production)
        if (email) {
            await sendOtpEmail(email, otp);
        }

        res.json({ 
            success: true, 
            msg: "OTP sent successfully",
            otp // Remove this in production
        });

    } catch (err) {
        res.status(500).json({ msg: err.message });
    }
});

// Verify OTP
router.post('/verify-otp', async (req, res) => {
    try {
        const { phone, otp } = req.body;

        const otpRecord = await Otp.findOne({ phone, otp });

        if (otpRecord) {
            await Otp.deleteOne({ _id: otpRecord._id });
            res.status(200).send('OTP verified successfully');
        } else {
            res.status(400).send('Invalid OTP');
        }
    } catch (err) {
        res.status(500).json({ msg: err.message });
    }
});

module.exports = router;
const twilio = require('twilio');
const { Twilio_Number, Twilio_SID, Twilio_token } = process.env;

const client = twilio(Twilio_SID, Twilio_token);

// Function to send SMS
const sendOtp = async (phoneNumber, otpCode) => {
  console.log(phoneNumber, otpCode)
  try {
    const message = await client.messages.create({
      body: `Your OTP is: ${otpCode}`,
      from: Twilio_Number,
      to: phoneNumber,
    });
    console.log(`Message sent: ${message.sid}`);
    return message;
  } catch (error) {
    console.error('Error sending SMS:', error.message);
    throw new Error('Failed to send SMS');
  }
};

module.exports = { sendOtp };

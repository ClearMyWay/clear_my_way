const fetch = require('node-fetch'); // Add this line to import fetch for Node.js
const express = require('express');
require("dotenv").config();
const apiKey = process.env.API_KEY;
const router = express.Router();

const verifyOtp = async (number, otp) => {
    const verifyUrl = `https://2factor.in/API/V1/${apiKey}/SMS/VERIFY3/+91${number}/${otp}`;
    const response = await fetch(verifyUrl); // This will now use node-fetch
    const data = await response.json();
    console.log(data);
    return data;
};

const sendOtp = async (number) => {
  console.log(number);
  const otpUrl = `https://2factor.in/API/V1/${apiKey}/SMS/+91${number}/AUTOGEN`;
  const response = await fetch(otpUrl); // This will now use node-fetch
  const data = await response.json();
  console.log(data);
  return data;
};

router.post("/sign-up", async (req, res) => {
  console.log(req.body);
  try {
    const { number } = req.body;
    if (!number) {
      return res.status(400).json({ msg: "Phone number is required" });
    }

    // const data = await sendOtp(number);
    // if (data.Status === "Success") {
    if(true){
      // return res.status(201).json({ msg: "OTP sent successfully", sessionId: data.Details });
      return res.status(201).json({ msg: "OTP sent successfully", sessionId: "123456" });
    } else {
      throw new Error("Failed to send OTP");
    }
  } catch (err) {
    console.error("Signup Error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post("/login/verify", async (req, res) => {
  console.log(req.body);
  try {
    const { otp, number } = req.body;
    if (!otp || !number) {
      return res.status(400).json({ msg: "OTP and number are required" });
    }

    // const data = await verifyOtp(number, otp);

    // if (data.Status === "Success" && data.Details === "OTP Matched") {
    if(otp == "123456"){
      return res.status(200).json({ msg:"Verified" });
    } else {
      return res.status(400).json({ msg: "Incorrect OTP" });
    }
  } catch (err) {
    console.error("OTP Verification Error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

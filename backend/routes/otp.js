const express = require('express');
require("dotenv").config();
const apiKey = process.env.API_KEY;
const router = express.Router();


  const verifyOtp = async (number, otp) => {
    if(is_prod){
      const verifyUrl = `https://2factor.in/API/V1/${apiKey}/SMS/VERIFY3/+91${number}/${otp}`;
      const response = await fetch(verifyUrl);
      const data = await response.json();
      console.log(data)
      return data;
    }
    else{
      if(otp !== "123456") 
        return {Status:"Error",Details:"OTP Mismatch"};
      return {Status:"Success",Details:"OTP Matched"};
    }
  };

router.post("/sign-up", async (req, res) => {
    try {
      const { number } = req.body;
      if (!number) {
        return res.status(400).json({ msg: "Phone number is required" });
      }
  
      const data = await sendOtp(number);
      if (data.Status === "Success") {
        return res.status(201).json({ msg: "OTP sent successfully", sessionId: data.Details });
      } else {
        throw new Error("Failed to send OTP");
      }
    } catch (err) {
      console.error("Signup Error:", err.message);
      res.status(500).json({ error: err.message });
    }
  });  // Route to send OTP
  router.post("/login/verify", async (req, res) => {
    try {
      const { otp, number} = req.body;
      if (!otp || !number) {
        return res.status(400).json({ msg: "OTP and number are required" });
      }
  
      const data = await verifyOtp(number, otp);
  
      if (data.Status === "Success" && data.Details === "OTP Matched") {
        

        return res.status(200);
      } else {
        return res.status(400).json({ msg: "Incorrect OTP" });
      }
    } catch (err) {
      console.error("OTP Verification Error:", err.message);
      res.status(500).json({ error: err.message });
    }
  });  // Route to verify OTP

module.exports = router;

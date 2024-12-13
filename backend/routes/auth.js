const express = require("express");
const authRouter = express.Router();
const tokenIsValid = require("../middleware/tokenIsValid"); 
const createVehicle = require("../controllers/createVehicle");
const createVehicle = require("../controllers/createDriver");
const createVehicle = require("../controllers/createOfficer");
require('dotenv').config();
const upload = require("../middleware/multer")

// authRouter.post("/tokenIsValid", tokenIsValid);
authRouter.post("/createVehicle", upload.single("vehiclePhoto"), createVehicle)
authRouter.post("/createDriver", upload.single("vehiclePhoto"), createDriver)
authRouter.post("/createOfficer", upload.single("vehiclePhoto"), createOfficer)

module.exports = authRouter;
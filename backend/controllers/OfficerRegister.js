const { Register } = require("../models/Register");
const bcrypt = require('bcrypt');

const OfficerRegister= async (req, res) => {
    console.log('Request Body:', req.body);  
    const { Username, Password } = req.body;

    try{
        const hash = await bcrypt.hash(Password, 12);
        const user = new Register(Username, hash)
        user.save();
        res.status(201).send(user);
    }catch (err) {
        console.error('Sorry Couldnt Register', err.message);
    }
    module.exports = OfficerRegister;
};
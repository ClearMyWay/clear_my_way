import { Router } from 'express';
import createOtp from '../controllers/createOtp';
import verifyOtp from '../controllers/verifyOtp';

const router = Router();

// Route to send OTP
router.post('/send', createOtp);

// Route to verify OTP
router.post('/verify', verifyOtp);

export default router;
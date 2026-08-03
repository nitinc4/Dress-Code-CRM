const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');

// Clock In / Check In
router.post('/check-in', async (req, res) => {
  try {
    const { userId, location } = req.body;
    const today = new Date().toISOString().split('T')[0];

    let attendance = await Attendance.findOne({ userId, date: today });
    if (attendance && attendance.status === 'Checked In') {
      return res.status(400).json({ message: 'Already checked in today' });
    }

    attendance = new Attendance({
      userId,
      date: today,
      checkInTime: new Date(),
      status: 'Checked In',
      location: location || 'Factory - Unit 1, Bangalore, India'
    });

    await attendance.save();
    res.status(201).json({ message: 'Checked in successfully', attendance });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Clock Out / Check Out
router.post('/check-out', async (req, res) => {
  try {
    const { userId } = req.body;
    const today = new Date().toISOString().split('T')[0];

    const attendance = await Attendance.findOne({ userId, date: today, status: 'Checked In' });
    if (!attendance) {
      return res.status(400).json({ message: 'No active check-in found for today' });
    }

    attendance.checkOutTime = new Date();
    attendance.status = 'Checked Out';
    await attendance.save();

    res.json({ message: 'Checked out successfully', attendance });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user attendance history
router.get('/user/:userId', async (req, res) => {
  try {
    const history = await Attendance.find({ userId: req.params.userId }).sort({ checkInTime: -1 }).limit(30);
    res.json(history);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

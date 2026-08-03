const express = require('express');
const router = express.Router();
const Leave = require('../models/Leave');

// Apply for leave
router.post('/apply', async (req, res) => {
  try {
    const { userId, leaveType, fromDate, toDate, noOfDays, reason } = req.body;
    const newLeave = new Leave({
      userId,
      leaveType,
      fromDate,
      toDate,
      noOfDays,
      reason
    });
    await newLeave.save();
    res.status(201).json({ message: 'Leave request submitted successfully', leave: newLeave });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user leaves
router.get('/user/:userId', async (req, res) => {
  try {
    const leaves = await Leave.find({ userId: req.params.userId }).sort({ createdAt: -1 });
    res.json(leaves);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Admin get all pending leaves
router.get('/all', async (req, res) => {
  try {
    const leaves = await Leave.find().populate('userId', 'name role').sort({ createdAt: -1 });
    res.json(leaves);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

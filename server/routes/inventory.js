const express = require('express');
const router = express.Router();
const Inventory = require('../models/Inventory');

// Create inventory item
router.post('/', async (req, res) => {
  try {
    const item = new Inventory(req.body);
    await item.save();
    res.status(201).json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all inventory
router.get('/', async (req, res) => {
  try {
    const inventory = await Inventory.find();
    res.json(inventory);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update stock
router.put('/:id', async (req, res) => {
  try {
    req.body.lastUpdated = Date.now();
    const item = await Inventory.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

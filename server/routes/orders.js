const express = require('express');
const router = express.Router();
const Order = require('../models/Order');

// Create Order (by Sales Rep)
router.post('/', async (req, res) => {
  try {
    const order = new Order(req.body);
    await order.save();
    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all orders (for Admin / Master)
router.get('/', async (req, res) => {
  try {
    // Populate references to show detailed data instead of just IDs
    const orders = await Order.find()
      .populate('customer')
      .populate('products.product')
      .populate('assignedMaster', 'name')
      .populate('assignedTailor', 'name')
      .populate('assignedHandworker', 'name');
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get specific order by ID
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('customer')
      .populate('products.product');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update order (status change, assigning to master/tailor/handworker)
router.put('/:id', async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

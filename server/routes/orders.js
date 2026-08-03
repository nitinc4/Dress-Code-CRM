const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Customer = require('../models/Customer');

// Create Order (by Sales Rep)
router.post('/', async (req, res) => {
  try {
    console.log('\n========================================');
    console.log('[SERVER POST /orders] Incoming order payload:', JSON.stringify(req.body, null, 2));
    const { customerName, customerPhone, customerAddress, measurements } = req.body;

    // Find or create customer record
    let customer = await Customer.findOne({
      $or: [{ phone: customerPhone }, { contact: customerPhone }]
    });
    if (!customer && customerPhone) {
      customer = new Customer({
        name: customerName || 'Valued Customer',
        contact: customerPhone,
        phone: customerPhone,
        address: customerAddress || '',
        measurements: measurements || {}
      });
      await customer.save();
      console.log('[SERVER POST /orders] New Customer Created:', customer._id);
    } else if (customer && measurements) {
      customer.measurements = { ...customer.measurements, ...measurements };
      await customer.save();
      console.log('[SERVER POST /orders] Existing Customer Updated:', customer._id);
    }

    const orderData = {
      ...req.body,
      customer: customer ? customer._id : null,
      customerName: customerName || (customer ? customer.name : 'Customer'),
      customerPhone: customerPhone || (customer ? customer.phone : '0000000000'),
    };

    const order = new Order(orderData);
    await order.save();
    console.log('[SERVER POST /orders] Order saved successfully with ID:', order._id);
    console.log('========================================\n');
    res.status(201).json(order);
  } catch (error) {
    console.error('[SERVER POST /orders ERROR]:', error.message, error.stack);
    res.status(500).json({ error: error.message });
  }
});

// Get all orders (for Admin / Master)
router.get('/', async (req, res) => {
  try {
      const orders = await Order.find()
      .populate('customer')
      .populate('assignedMaster', 'name')
      .populate('assignedTailor', 'name')
      .populate('originalTailor', 'name')
      .populate('assignedHandworker', 'name')
      .populate('assignedCuttingMaster', 'name')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get specific order by ID
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('customer');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update order
router.put('/:id', async (req, res) => {
  try {
    const updateData = { ...req.body };
    const currentOrder = await Order.findById(req.params.id);

    if (updateData.assignedTailor && !currentOrder.originalTailor) {
      updateData.originalTailor = updateData.assignedTailor;
    }

    const order = await Order.findByIdAndUpdate(req.params.id, updateData, { new: true });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

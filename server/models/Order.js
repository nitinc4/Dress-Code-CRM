const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  customer: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true },
  products: [{
    product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    quantity: { type: Number, default: 1 },
    notes: { type: String }
  }],
  status: { 
    type: String, 
    enum: ['pending', 'assigned_to_master', 'in_production', 'quality_check', 'ready_for_delivery', 'delivered'],
    default: 'pending'
  },
  priority: { type: String, enum: ['normal', 'high', 'urgent'], default: 'normal' },
  dueDate: { type: Date },
  assignedMaster: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  assignedTailor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  assignedHandworker: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', orderSchema);

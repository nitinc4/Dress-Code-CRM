const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  customer: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer' },
  customerName: { type: String, required: true },
  customerPhone: { type: String, required: true },
  customerAddress: { type: String },
  garmentCategory: { type: String },
  design: { type: String },
  fabricDetails: { type: Object },
  pricingBreakdown: { type: Object },
  totalCost: { type: Number, default: 0 },
  discount: { type: Number, default: 0 },
  paymentStatus: { type: String, default: 'pending' },
  measurements: { type: Object },
  addons: { type: String },
  status: { 
    type: String, 
    enum: ['pending', 'In Production', 'assigned_to_master', 'in_production', 'quality_check', 'ready_for_delivery', 'delivered', 'completed'],
    default: 'pending'
  },
  priority: { type: String, enum: ['normal', 'high', 'urgent'], default: 'normal' },
  eventDate: { type: Date },
  dueDate: { type: Date },
  assignedMaster: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  assignedTailor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  assignedHandworker: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', orderSchema);

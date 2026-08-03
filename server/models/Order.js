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
    enum: ['sales', 'fabric_dispensing', 'cutting', 'hand_work', 'stitching', 'trial', 'alterations', 'trial_2', 'delivery', 'completed'],
    default: 'sales'
  },
  priority: { type: String, enum: ['normal', 'high', 'urgent'], default: 'normal' },
  eventDate: { type: Date },
  dueDate: { type: Date },
  assignedMaster: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  assignedTailor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  originalTailor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  assignedHandworker: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', orderSchema);

const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  contact: { type: String, required: true },
  measurements: { type: mongoose.Schema.Types.Mixed }, // Flexible schema for diverse measurements
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Sales rep who onboarded
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Customer', customerSchema);

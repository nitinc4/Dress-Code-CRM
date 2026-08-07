const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
  email: { type: String, required: true },
  password: { type: String, required: true },
  name: { type: String, default: 'Admin' },
  role: { type: String, default: 'admin' },
  loginTime: { type: Date }
}, {
  collection: 'admin', // Explicitly map to the "admin" collection
  timestamps: true // Automatically adds createdAt and updatedAt
});

module.exports = mongoose.model('Admin', adminSchema);

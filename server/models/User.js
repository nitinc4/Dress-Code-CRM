const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { 
    type: String, 
    enum: ['admin', 'sales_rep', 'master', 'tailor', 'hand_worker', 'cutting_master', 'warehouse_manager', 'customer'], 
    required: true 
  },
  status: { type: String, enum: ['active', 'inactive', 'on_leave'], default: 'active' },
  email: { type: String },
  profilePicture: { type: String },
  bankingDetails: {
    accountName: { type: String },
    accountNumber: { type: String },
    bankName: { type: String },
    ifsc: { type: String }
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema);

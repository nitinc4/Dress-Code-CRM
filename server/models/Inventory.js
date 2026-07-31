const mongoose = require('mongoose');

const inventorySchema = new mongoose.Schema({
  itemName: { type: String, required: true },
  category: { type: String }, // e.g., thread, fabric roll, buttons
  quantity: { type: Number, required: true, default: 0 },
  unit: { type: String, default: 'pcs' }, // pcs, meters, etc.
  lowStockThreshold: { type: Number, default: 10 },
  lastUpdated: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Inventory', inventorySchema);

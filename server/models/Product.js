const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  category: { type: String, enum: ['mens_wear', 'womens_wear', 'fabric', 'addon'], required: true },
  description: { type: String },
  price: { type: Number },
  laborHours: { type: Number },
  metersNeeded: { type: Number },
  image: { type: String },
  requiredMeasurements: [{ type: String }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Product', productSchema);

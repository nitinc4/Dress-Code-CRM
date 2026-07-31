const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Basic health check route
app.get('/', (req, res) => {
  res.json({ message: 'Dress Code CRM API is running' });
});

// Database connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/dress_code_crm';

mongoose.connect(MONGODB_URI)
  .then(() => console.log('Connected to MongoDB successfully.'))
  .catch(err => console.error('Could not connect to MongoDB:', err));

const authRoutes = require('./routes/auth');
const customerRoutes = require('./routes/customers');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const inventoryRoutes = require('./routes/inventory');

app.use('/api/auth', authRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/inventory', inventoryRoutes);

app.listen(PORT, () => {
  console.log(`Server is listening on port ${PORT}`);
});

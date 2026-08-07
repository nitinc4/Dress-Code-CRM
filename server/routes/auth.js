const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Customer = require('../models/Customer');
const Admin = require('../models/Admin');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecret_for_development_only';

// Register User (Admin use case primarily)
router.post('/register', async (req, res) => {
  try {
    const { name, phone, password, role } = req.body;
    let user = await User.findOne({ phone });
    if (user) return res.status(400).json({ message: 'User already exists' });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({ name, phone, password: hashedPassword, role });
    await user.save();

    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Check Phone (For Customer App)
router.post('/check-phone', async (req, res) => {
  try {
    const { phone } = req.body;
    const user = await User.findOne({ phone, role: 'customer' });
    const customer = await Customer.findOne({ $or: [{ phone }, { contact: phone }] });
    
    res.json({
      userExists: !!user,
      customerExists: !!customer,
      name: customer ? customer.name : null
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Register Customer (For Customer App)
router.post('/register-customer', async (req, res) => {
  try {
    const { name, phone, password } = req.body;
    let user = await User.findOne({ phone, role: 'customer' });
    if (user) return res.status(400).json({ message: 'User already exists' });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create User record for auth
    user = new User({ name, phone, password: hashedPassword, role: 'customer' });
    await user.save();

    // Check if Customer record exists (from sales exec)
    let customer = await Customer.findOne({ $or: [{ phone }, { contact: phone }] });
    if (!customer) {
      // Create Customer record for CRM
      customer = new Customer({ name, phone, contact: phone });
      await customer.save();
    }

    // Auto login
    const payload = { userId: user._id, role: user.role };
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({ token, user: { id: user._id, name: user.name, role: user.role } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Login User
router.post('/login', async (req, res) => {
  try {
    const { phone, email, password } = req.body;
    const identifier = phone || email;
    
    if (!identifier) {
      return res.status(400).json({ message: 'Please provide phone or email' });
    }

    // 1. Check if it's an Admin trying to log in via the dedicated admin collection
    if (email) {
      const admin = await Admin.findOne({ email: identifier });
      if (admin) {
        // Checking against plain text password as stored in the admin collection
        if (password !== admin.password) {
          return res.status(400).json({ message: 'Invalid credentials' });
        }
        
        // Update login time
        admin.loginTime = new Date();
        await admin.save();

        const payload = { userId: admin._id, role: admin.role || 'admin' };
        const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

        return res.json({ token, user: { id: admin._id, name: admin.name || 'Admin', role: admin.role || 'admin' } });
      }
    }

    // 2. Fallback to User collection (for employees/customers)
    const user = await User.findOne({ 
      $or: [{ phone: identifier }, { email: identifier }] 
    });
    
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    const payload = { userId: user._id, role: user.role };
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

    res.json({ token, user: { id: user._id, name: user.name, role: user.role } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all users (for assigning tasks)
router.get('/', async (req, res) => {
  try {
    const users = await User.find({}, '-password');
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user by ID
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id, '-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update Profile (Employee or Admin)
router.put('/profile/:id', async (req, res) => {
  try {
    const { email, profilePicture, bankingDetails, name } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (name) user.name = name;
    if (email) user.email = email;
    if (profilePicture) user.profilePicture = profilePicture;
    if (bankingDetails) {
      user.bankingDetails = { ...user.bankingDetails, ...bankingDetails };
    }

    await user.save();
    res.json({ message: 'Profile updated successfully', user });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
require('dotenv').config();

const users = [
  { name: 'Admin User', phone: '1000000000', email: 'admin@dresscode.com', password: 'password123', role: 'admin' },
  { name: 'Sales Rep 1', phone: '2000000000', password: 'password123', role: 'sales_rep' },
  { name: 'Master 1', phone: '3000000000', password: 'password123', role: 'master' },
  { name: 'Tailor 1', phone: '4000000000', password: 'password123', role: 'tailor' },
  { name: 'Hand Worker 1', phone: '5000000000', password: 'password123', role: 'hand_worker' },
  { name: 'Warehouse Mgr 1', phone: '6000000000', password: 'password123', role: 'warehouse_manager' },
  { name: 'Cutting Master 1', phone: '7000000000', password: 'password123', role: 'cutting_master' }
];

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to DB');
    
    for (const u of users) {
      let existing = await User.findOne({ phone: u.phone });
      if (existing) {
        console.log(`User ${u.role} already exists with phone ${u.phone}.`);
        continue;
      }
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(u.password, salt);
      const newUser = new User({ name: u.name, phone: u.phone, password: hashedPassword, role: u.role });
      await newUser.save();
      console.log(`Created user ${u.role} with phone ${u.phone}`);
    }
    
    await mongoose.disconnect();
    console.log('Seed completed successfully.');
  } catch(e) {
    console.error('Seed failed:', e);
  }
}

seed();

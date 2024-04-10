// Import required modules
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('./userModel');
const { Admin } = require('./adminModel'); // Assuming models are in a separate file

// Create an Express router
const router = express.Router();


router.post('/loginadmin', async (req, res) => {
    try {
      const { username, password } = req.body;
      const admin = await Admin.findOne({ username });
      if (!admin) {
        return res.status(404).json({ error: 'Admin not found' });
      }
      const isPasswordValid = await bcrypt.compare(password, admin.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid password' });
      }
      const token = jwt.sign(
        { userId: admin._id, role: 'admin' }, // Set role as 'admin'
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );
      res.status(200).json({ token });
    } catch (error) {
      console.error('Error during admin login:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });



router.post('/admin/register', async (req, res) => {
    try {
      const { username, password, email, name } = req.body;
      const existingAdmin = await Admin.findOne({ username });
      if (existingAdmin) {
        return res.status(400).json({ error: 'Admin already exists' });
      }
      const admin = new Admin({ username, password, email, name });
      await admin.save();
      const token = generateToken(admin);
      res.status(201).json({ token });
    } catch (error) {
      console.error('Error during admin registration:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

// Route for user login
router.post('/loginuser', async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );
    res.status(200).json({ token });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});


router.post('/user/register', async (req, res) => {
    try {
      const { username, password, email, name } = req.body;
      const existingUser = await User.findOne({ username });
      if (existingUser) {
        return res.status(400).json({ error: 'User already exists' });
      }
      const user = new User({ username, password, email, name });
      await user.save();
      const token = generateToken(user);
      res.status(201).json({ token });
    } catch (error) {
      console.error('Error during user registration:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

// Export the router
module.exports = router;

// Import required modules
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('./userModel'); // Assuming models are in a separate file

// Create an Express router
const router = express.Router();

// Route for user login
router.post('/login', async (req, res) => {
  try {
    // Extract username and password from request body
    const { username, password } = req.body;

    // Find the user by username
    const user = await User.findOne({ username });

    // If user not found, send error response
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if password matches
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' } // Token expires in 1 hour
    );

    // Send token in response
    res.status(200).json({ token });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Route for user logout (dummy route, as JWT tokens are stateless)
router.post('/logout', (req, res) => {
  // No action needed for logout in JWT-based authentication
  res.status(200).json({ message: 'Logout successful' });
});

// Export the router
module.exports = router;

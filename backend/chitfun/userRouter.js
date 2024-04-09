const express = require('express');
const { Chit } = require('./chitModel');
const { User } = require('./userModel');
const router = express.Router();
const bcrypt = require("bcryptjs")
const { Payment } = require('./paymentModel');



// Route for viewing chit details for a specific month
router.post('/chit/details', async (req, res) => {
    try {
      const { month } = req.body;
  
      // Find the chit document for the specified month
      const chit = await Chit.findOne({ month });
  
      if (!chit) {
        return res.status(404).json({ error: 'Chit not found for the specified month' });
      }
  
      res.status(200).json(chit);
    } catch (error) {
      console.error('Error viewing chit:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  // Route for placing bids for a specific month
  router.post('/chit/bid', async (req, res) => {
    try {
      const { month, userId, bidAmount } = req.body;
  
      // Find the chit document for the specified month
      const chit = await Chit.findOne({ month });
  
      if (!chit) {
        return res.status(404).json({ error: 'Chit not found for the specified month' });
      }
  
      // Add the bid to the bids array
      chit.bids.push({ userId, bidAmount });
  
      // Save the updated chit document
      await chit.save();
  
      res.status(201).json({ message: 'Bid placed successfully' });
    } catch (error) {
      console.error('Error placing bid:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  // Route for viewing payment history
  router.get('/paymentsuser', async (req, res) => {
    try {
      const { userId } = req.body;
  
      // Find all payments made by the user
      const payments = await Payment.find({ userId });
  
      res.status(200).json({ payments });
    } catch (error) {
      console.error('Error fetching payment history:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  module.exports = router;
  
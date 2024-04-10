const express = require('express');
const Chit = require('./chitModel');
const Payment = require('./paymentModel');
const router = express.Router();
const User = require('./userModel');


// Route for setting up a new chit
router.post('/chit/setup', async (req, res) => {
  try {
    // Extract chit details from request body
    const { month, totalAmount, commission } = req.body;

    // Create a new chit document
    const newChit = new Chit({
      month,
      totalAmount,
      commission,
      bids: [] // Initialize bids array
    });

    // Save the new chit to the database
    await newChit.save();

    res.status(201).json({ message: 'Chit setup successful' });
  } catch (error) {
    console.error('Error setting up chit:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Route for viewing chit details for a specific month
router.post('/chit/view', async (req, res) => {
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
  
  // Define a route to fetch all bids for all users
router.get('/admin/bids', async (req, res) => {
    try {
      const chits = await Chit.find();
      let allBids = [];
      for (const chit of chits) {
        for (const bid of chit.bids) {
          const user = await User.findById(bid.userId);
          const bidInfo = {
            username: user.username,
            email: user.email,
            bidAmount: bid.bidAmount,
            month: chit.month
          };
          allBids.push(bidInfo);
        }
      }
      allBids.sort((a, b) => a.bidAmount - b.bidAmount);
      res.status(200).json(allBids);
    } catch (error) {
      console.error('Error fetching bids:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  

  router.get('/paymentsAll', async (req, res) => {
    try {
      // Find all users
      const users = await User.find();
  
      // For each user, find their payment history
      const userPayments = await Promise.all(users.map(async (user) => {
        const payments = await Payment.find({ userId: user._id });
        return { user, payments };
      }));
  
      res.status(200).json({ userPayments });
    } catch (error) {
      console.error('Error fetching payment status:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

module.exports = router;

const express = require('express');
const AuctionRouter = express.Router();
const { Chit } = require('./chitModel');
const { User } = require('./userModel');

const calculateWinner = async (chitId) => {
    try {
      const chit = await Chit.findById(chitId);
      if (!chit) {
        throw new Error('Chit not found');
      }
      chit.bids.sort((a, b) => a.bidAmount - b.bidAmount);
      const winner = chit.bids[0];
      return winner;
    } catch (error) {
      console.error('Error calculating winner:', error);
      throw error;
    }
  };
  
  const deductOrganizerCommission = async (chitId, winner, commissionPercentage) => {
    try {
      const commissionAmount = winner.bidAmount * (commissionPercentage / 100);
      winner.corpusAfterDeduction = winner.bidAmount - commissionAmount;
      await Chit.findByIdAndUpdate(chitId, {
        $set: {
          winningBid: winner,
          commissionAmount
        }
      });
      return winner;
    } catch (error) {
      console.error('Error deducting organizer commission:', error);
      throw error;
    }
  };
  
  const distributeRemainingAmount = async (chitId) => {
    try {
      const chit = await Chit.findById(chitId);
      if (!chit) {
        throw new Error('Chit not found');
      }
      const totalParticipants = chit.bids.length;
      const remainingAmount = chit.totalAmount - chit.commissionAmount;
      const sharePerParticipant = remainingAmount / totalParticipants;
      for (const bid of chit.bids) {
        await User.findByIdAndUpdate(bid.userId, { $inc: { balance: sharePerParticipant } });
      }
      return true;
    } catch (error) {
      console.error('Error distributing remaining amount:', error);
      throw error;
    }
  };


// POST route to perform auction setup
AuctionRouter.post('/auctionSetup', async (req, res) => {
  try {
    const { chitId } = req.body;
    const commissionPercentage = 5; // Organizer's commission percentage
    const winner = await calculateWinner(chitId);
    const winnerWithCommission = await deductOrganizerCommission(chitId, winner, commissionPercentage);
    await distributeRemainingAmount(chitId);
    const response = {
      winner: winnerWithCommission,
      commissionDeducted: winnerWithCommission.commissionAmount,
      message: 'Auction setup completed successfully'
    };
    res.status(200).json(response);
  } catch (error) {
    console.error('Error setting up auction:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = AuctionRouter;

const mongoose = require('mongoose');

const bidSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  bidAmount: {
    type: Number,
    required: true
  }
});

const chitSchema = new mongoose.Schema({
  month: {
    type: Number,
    required: true
  },
  totalAmount: {
    type: Number,
    required: true
  },
  commission: {
    type: Number,
    required: true
  },
  bids: [bidSchema]
});

const Chit = mongoose.model('Chit', chitSchema);

module.exports = Chit;

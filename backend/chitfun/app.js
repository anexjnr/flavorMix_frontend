const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const authRouter = require('./authRouter');
const adminRouter = require('./adminRouter');
const userRouter = require('./userRouter');
const auctionRouter = require('./autionRouter');
const bcrypt = require("bcryptjs")

// Initialize Express app
const app = express();


app.use(bodyParser.json()); // Parse JSON bodies
app.use(bodyParser.urlencoded({ extended: true }));
// Middleware
//app.use(cors()); // Enable Cross-Origin Resource Sharing
//app.use(bodyParser.json()); // Parse JSON request bodies

// Connect to MongoDB
mongoose.connect('mongodb+srv://anex:anex123@cluster0.bgkikbl.mongodb.net/chitDb?retryWrites=true&w=majority', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Error connecting to MongoDB:', err));

// Routes
app.use('/api/auth', authRouter);
app.use('/api/admin', adminRouter);
app.use('/api/user', userRouter);
app.use('/api/auction', auctionRouter);


// Start the server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

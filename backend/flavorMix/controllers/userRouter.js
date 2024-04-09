const jwt = require("jsonwebtoken");
require('dotenv').config();
const express = require('express');
const router = express.Router();
const User = require('../models/userModel');
const nodemailer = require('nodemailer');
const Hotel = require('../models/hotelModel');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});


router.post('/signup', async (req, res) => {
  try {
      const { firstName, lastName, mobileNumber, email, password } = req.body;
      const existingEmail = await User.findOne({ email });
      const existingMobile = await User.findOne({ mobileNumber });
      if (existingEmail) {
          return res.status(400).json({ message: 'Email already exists. Please log in.' });
      }
      if (existingMobile) {
          return res.status(402).json({ message: 'MobileNumber already exists. Try Another Number.' });
      }
      const user = new User({ firstName, lastName, mobileNumber, email, password });
      await user.save();
      const otp = generateOTP();
      await sendConfirmationEmail(email, otp);
      user.otp = otp;
      await user.save();

      const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });

      res.status(201).json({ 
          message: 'User created successfully. Please check your email for confirmation.', 
          userId: user._id, // Include the userId in the response
          token 
      });
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error' });
  }
});


router.post('/verifyotp', async (req, res) => {
    try {
      const { userId, otp } = req.body;
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      if (user.otp !== otp) {
        return res.status(400).json({ message: 'Invalid OTP' });
      }
      user.otpVerified = true;
      user.otp = undefined;
      await user.save();
      res.status(200).json({ message: 'OTP verification successful' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error' });
    }
  });  


  router.post('/signin', async (req, res) => {
    try {
      const { email, password } = req.body;
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      if (!user.otpVerified) {
        return res.status(401).json({ message: 'Please verify your OTP before logging in' });
      }
      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        return res.status(402).json({ message: 'Invalid credentials' });
      }
      const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
  
      res.status(200).json({ message: 'Sign in successful', userId: user._id, token }); // Include userId in the response
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error' });
    }
  });  


  router.post('/forgotpassword', async (req, res) => {
    try {
        const { email } = req.body;
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'Email is not registered' });
        }
        const token = generateUniqueToken(); // Function to generate a unique token
        const otp = generateOTP();
        await passwordChangeEmail(email, otp, token); // Pass the token to the email function
        user.passwordResetToken = token; // Store the token in the user document
        user.otp = otp;
        await user.save();

        res.status(200).json({ message: 'An OTP has been sent to your email for password reset.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});


router.post('/resetpassword', async (req, res) => {
  try {
      const { email, otp, newPassword, confirmPassword, token } = req.body; // Include token in the request body
      const user = await User.findOne({ email, passwordResetToken: token }); // Verify token along with email
      if (!user) {
          return res.status(404).json({ message: 'Email or token is invalid' });
      }
      if (user.otp !== otp) {
          return res.status(401).json({ message: 'Invalid OTP' });
      }
      if (newPassword !== confirmPassword) {
          return res.status(402).json({ message: 'Passwords do not match' });
      }
      if (newPassword.length < 8) {
          return res.status(405).json({ message: 'Password must be at least 8 characters long' });
      }
      user.password = newPassword;
      user.otp = undefined;
      user.passwordResetToken = undefined; // Reset the token after password reset
      await user.save();
      res.status(200).json({ message: 'Password reset successful' });
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error' });
  }
});


function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

async function sendConfirmationEmail(email, otp) {
    try {
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Confirm your email address',
            text: `Your OTP for email verification is: ${otp}`
        };

        await transporter.sendMail(mailOptions);
    } catch (error) {
        console.error('Error sending confirmation email:', error);
        throw new Error('Error sending confirmation email');
    }
}

async function passwordChangeEmail(email, otp, token) {
  try {
      const mailOptions = {
          from: process.env.EMAIL_USER,
          to: email,
          subject: 'Password Reset OTP',
          text: `Your OTP for password reset is: ${otp}.`
      };

      await transporter.sendMail(mailOptions);
  } catch (error) {
      console.error('Error sending password change email:', error);
      throw new Error('Error sending password change email');
  }
}


const { v4: uuidv4 } = require('uuid');

function generateUniqueToken() {
    return uuidv4();
}

Hotel.collection.createIndex({ location: '2dsphere' }, function(err, result) {
  if (err) {
    console.error('Error creating geospatial index:', err);
  } else {
    console.log('Geospatial index created successfully.');
  }
});

// Route to handle incoming requests
router.post('/calculateMenuCombinations', async (req, res) => {
  try {
    const { userId, totalAmount, numberOfPeople, userLocation } = req.body;

    // Query MongoDB to get hotels/restaurants within a certain distance from user location
    const hotels = await Hotel.find({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: userLocation.coordinates
          }
        }
      }
    });

    // Prepare response object
    const response = {
      userId
    };

    // Loop through hotels and calculate combinations
    let hotelsWithCombinations = 0;
    for (const hotel of hotels) {
      const combinations = generateCombinations(hotel.menuItems, hotel.prices, totalAmount, numberOfPeople);
if (combinations.length > 0) {
    const approximateTotalBill = totalAmount; // Set approximateTotalBill to totalAmount entered by user
    const distance = calculateDistance(userLocation.coordinates, hotel.location.coordinates);
    response[hotel.name] = {
        ...hotel.toObject(),
        approximateTotalBill,
        distance,
        combinations
    };
        hotelsWithCombinations++;
      }
    }

    // Check if no hotels with combinations found
    if (hotelsWithCombinations === 0) {
      return res.status(404).json({ message: 'No hotels found with suitable combinations.' });
    }

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Function to generate combinations of menu items
function generateCombinations(menuItems, prices, totalAmount, numberOfPeople) {
  const combinations = [];
  const n = menuItems.length;
  const maxCombinations = 6; // Maximum number of combinations

  // Iterate through all possible combinations
  for (let mask = 0; mask < (1 << n) && combinations.length < maxCombinations; mask++) {
    let totalPrice = 0;
    const combination = [];

    // Check if the number of items in the combination equals the number of people
    let itemCount = 0;

    // Iterate through each item
    for (let i = 0; i < n; i++) {
      if (mask & (1 << i)) {
        itemCount++;
        totalPrice += prices[i];
        combination.push(menuItems[i]);
      }
    }

    // Check if the combination is valid
    if (itemCount === numberOfPeople && totalPrice <= totalAmount) {
      combinations.push({ combination, totalPrice });
    }
  }

  return combinations;
}


// Function to calculate distance between two coordinates using Haversine formula
function calculateDistance(coord1, coord2) {
  const [lat1, lon1] = coord1;
  const [lat2, lon2] = coord2;

  const R = 6371e3; // Earth radius in meters
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;

  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  const distance = R * c;
  return distance;
}

module.exports = router;
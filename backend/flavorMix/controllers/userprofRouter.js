const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });
const jwt = require('jsonwebtoken');
const UserProfile = require('../models/userProfile');
const User = require('../models/userModel');
const path = require('path');


function verifyToken(req, res, next) {
  const token = req.headers.authorization; // Assuming token is passed in the Authorization header
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId; // Include userId in the request for further processing
    next(); // Proceed to the next middleware or route handler
  } catch (err) {
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
}

router.use(verifyToken);

router.post('/userprofile', upload.single('profilePic'), async (req, res) => {
  try {
    const { userId, age, place } = req.body;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    const { firstName, lastName, mobileNumber, email } = user;
    if (!req.file) {
      return res.status(400).json({ error: 'Please upload an image file' });
    }
    
    const allowedExtensions = ['.png', '.jpg', '.jpeg'];
    const fileExtension = path.extname(req.file.originalname).toLowerCase();
    if (!allowedExtensions.includes(fileExtension)) {
      return res.status(400).json({ error: 'Only PNG, JPEG, and JPG files are allowed' });
    }

    // Create new user profile
    const userProfile = new UserProfile({
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      email: email,
      age: age,
      place: place,
      profilePic: req.file.path // Assuming multer has saved the file and provided the path
    });

    await userProfile.save();

    res.status(201).json(userProfile);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});


router.post('/viewuserprofile', async (req, res) => {
    try {
      const { userId } = req.body;
  
      if (!userId) {
        return res.status(400).json({ error: 'userId is required in the request body' });
      }
      const userProfile = await UserProfile.findOne({ userId: userId }).populate('userId', 'firstName lastName');
  
      if (!userProfile) {
        const defaultPicLink = 'https://drive.google.com/file/d/1FuAKg1gph1pr0Znw72-b1IVhzGNDT-jB/view?usp=sharing';
            return res.status(404).json({ error: 'User profile not found', defaultProfilePic: defaultPicLink });
      }
  
      res.json({
        profilePic: userProfile.profilePic,
        fullName: `${userProfile.userId.firstName} ${userProfile.userId.lastName}`
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Server error' });
    }
  });


  router.post('/fullviewuserprofile', async (req, res) => {
    try {
      const { userId } = req.body;
  
      if (!userId) {
        return res.status(400).json({ error: 'userId is required in the request body' });
      }
      const userProfile = await UserProfile.findOne({ userId: userId }).populate('userId', 'firstName lastName email mobileNumber age place profilePic');
  
      if (!userProfile) {
        const defaultPicLink = 'https://drive.google.com/file/d/1FuAKg1gph1pr0Znw72-b1IVhzGNDT-jB/view?usp=sharing';
        return res.status(404).json({ error: 'User profile not found', defaultProfilePic: defaultPicLink });
      }
  
      res.json({
        profilePic: userProfile.profilePic,
        fullName: `${userProfile.userId.firstName} ${userProfile.userId.lastName}`,
        email: userProfile.userId.email,
        mobileNumber: userProfile.userId.mobileNumber,
        age: userProfile.age,
        place: userProfile.place
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Server error' });
    }
});


router.post('/viewprofilepicture', async (req, res) => {
    try {
        const { userId } = req.body;

        if (!userId) {
            return res.status(400).json({ error: 'userId is required in the request body' });
        }
        let userProfile = await UserProfile.findOne({ userId: userId });

        let profilePic;

        if (userProfile) {
            profilePic = userProfile.profilePic;
        } else {
            const defaultPicLink = 'https://drive.google.com/file/d/1FuAKg1gph1pr0Znw72-b1IVhzGNDT-jB/view?usp=sharing';
            return res.status(404).json({ error: 'User profile not found', defaultProfilePic: defaultPicLink });
        }

        res.json({
            profilePic: profilePic
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;

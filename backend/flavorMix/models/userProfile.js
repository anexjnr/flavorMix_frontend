const mongoose = require('mongoose');
const { Schema } = mongoose;

const userProfileSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  age: {
    type: Number
  },
  place: {
    type: String
  },
  profilePic: {
    type: String 
  }
});

const UserProfile = mongoose.model('UserProfile', userProfileSchema);

module.exports = UserProfile;

const mongoose = require('mongoose');

const daySchema = new mongoose.Schema({
    dayOfWeek: { type: String, required: true },
    openTime: String,
    closeTime: String
});

const hotelSchema = new mongoose.Schema({
    name: { type: String, required: true },
    Address: { type: String, required: true },
    City: { type: String, required: true },
    Country: { type: String, required: true },
    State: { type: String, required: true },
    PostalCode: { type: String, required: true },
    type: { type: String, enum: ['Hotel', 'Restaurant', 'Tea Shop', 'Other'], required: true },
    starRating: { type: Number, default: 0 },
    picture: String,
    menuItems: [String],
    prices: [Number],
    foodType: { type: String, required: true },
    reservation: { type: Boolean, default: false },
    occupancy: { type: Number, default: 0 },
    location: {
        type: { type: String, default: 'Point' },
        coordinates: [Number]
    },
availableWeekDays: [daySchema],
adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin' },
creationTimestamp: { type: Date, default: Date.now },
});

hotelSchema.virtual('googleMapsUrl').get(function() {
    if (this.location && this.location.coordinates && this.location.coordinates.length === 2) {
        const lat = this.location.coordinates[1];
        const lng = this.location.coordinates[0];
        return `https://www.google.com/maps/search/?api=1&query=${lat},${lng}&query_place_id=${this._id}`;
    }
    return null;
});

const Hotel = mongoose.model('Hotel', hotelSchema);

module.exports = Hotel;

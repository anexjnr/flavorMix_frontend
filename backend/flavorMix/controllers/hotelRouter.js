const express = require('express');
const router = express.Router();
const Hotel = require('../models/hotelModel');
const { KMeans } = require('shaman');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');

// Create a hotel
router.post('/hotels', async (req, res) => {
    try {
        const hotel = new Hotel(req.body);
        await hotel.save();
        res.status(201).send(hotel);
    } catch (error) {
        res.status(400).send(error);
    }
});

// Get all hotels
router.get('/hotels', async (req, res) => {
    try {
        const hotels = await Hotel.find();
        res.send(hotels);
    } catch (error) {
        res.status(500).send(error);
    }
});

// Get a hotel by ID
router.post('/hotels/get-by-id', async (req, res) => {
    try {
        const hotelId = req.body.id;
        const hotel = await Hotel.findById(hotelId);
        if (!hotel) {
            return res.status(404).send();
        }
        res.send(hotel);
    } catch (error) {
        res.status(500).send(error);
    }
});

// Update a hotel by ID
router.patch('/hotels/update-by-id', async (req, res) => {
    try {
        const hotelId = req.body.id;
        const updatedFields = req.body.updatedFields; // Assuming you pass the updated fields in req.body.updatedFields
        const hotel = await Hotel.findByIdAndUpdate(hotelId, updatedFields, { new: true, runValidators: true });
        if (!hotel) {
            return res.status(404).send();
        }
        res.send(hotel);
    } catch (error) {
        res.status(400).send(error);
    }
});

// Delete a hotel by ID
router.delete('/hotels/delete-by-id', async (req, res) => {
    try {
        const hotelId = req.body.id;
        const hotel = await Hotel.findByIdAndDelete(hotelId);
        if (!hotel) {
            return res.status(404).send();
        }
        res.send(hotel);
    } catch (error) {
        res.status(500).send(error);
    }
});

router.post('/hotels/google-maps-url', async (req, res) => {
    try {
        const hotelId = req.body.id;
        const hotel = await Hotel.findById(hotelId);
        if (!hotel) {
            return res.status(404).json({ message: 'Hotel not found' });
        }
        if (!hotel.location || !hotel.location.coordinates || hotel.location.coordinates.length !== 2) {
            return res.status(400).json({ message: 'Hotel location is missing or invalid' });
        }
        const lat = hotel.location.coordinates[1];
        const lng = hotel.location.coordinates[0];
        const googleMapsUrl = `https://www.google.com/maps/search/?api=1&query=${lat},${lng}&query_place_id=${hotel._id}`;
        res.json({ googleMapsUrl });
    } catch (error) {
        res.status(500).json({ message: 'Internal server error' });
    }
});


// Function to calculate distance between two coordinates
function calculateDistance(coords1, coords2) {
    const [lat1, lon1] = coords1;
    const [lat2, lon2] = coords2;
    const earthRadius = 6371; // Radius of the Earth in kilometers
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = earthRadius * c;
    return distance; // Distance in kilometers
}

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
        console.error('Token Verification Error:', err);
        return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }    
  }
  
  // Apply JWT verification middleware to the desired routes
  router.use(verifyToken);
  
  // Endpoint to receive user input and perform hotel search
  router.post('/search', async (req, res) => {
    try {
        const { userId, totalAmount, numberOfPeople, reservation, userLocation, day, time } = req.body;
        console.log('Search Request:', { userId, totalAmount, numberOfPeople, reservation, userLocation, day, time });

        // Retrieve menu items with prices from the database
        const menuItemsWithPrices = await fetchMenuItemsWithPrices();
        console.log('Menu items with prices:', menuItemsWithPrices);

        // Retrieve all hotels from the database
        const hotels = await Hotel.find();
        console.log('Total Hotels:', hotels.length);

        // Filter hotels based on criteria
        const filteredHotels = await Promise.all(hotels.map(async hotel => {
            const distance = calculateDistance(userLocation.coordinates, hotel.location.coordinates);
            const isWithinDistance = distance <= 1 ? distance * 1000 : distance; // Convert to meters if less than 1 km
            const isReservationEnabled = hotel.reservation;
            const isOperating = await checkOperatingHours(day, time, hotel.availableWeekDays); // Wait for the promise to resolve
        
            // Check if at least one item in the menu is within the approximate total budget
            const menuCombinations = getMenuCombinations(menuItemsWithPrices, totalAmount);
        
            console.log('Menu combinations for', hotel.name + ':', menuCombinations);
            console.log('Hotel:', hotel.name, 'Distance:', isWithinDistance, 'Reservation:', isReservationEnabled, 'Operating:', isOperating);
        
            return { hotel, isWithinDistance, isReservationEnabled, isOperating, menuCombinations };
        }));        

        // Filter out hotels that don't meet the criteria
       // Filter out hotels that don't meet the criteria
       const finalFilteredHotels = filteredHotels.filter(hotel => {
        if (hotel.isWithinDistance && hotel.isOperating && hotel.menuCombinations && hotel.menuCombinations.length > 0) {
            // Calculate the amount each person can spend
            const amountPerPerson = searchRequest.totalAmount / searchRequest.numberOfPeople;
    
            // Check if any menu combination fits within the budget for each person
            const suitableCombination = hotel.menuCombinations.find(combination => {
                const combinationTotalPrice = combination.reduce((total, item) => total + item.price, 0);
                return combinationTotalPrice <= amountPerPerson;
            });
    
            return suitableCombination && !hotel.reservation; // Return true only if there's a suitable combination and no reservation required
        } else {
            return false;
        }
    });

        // If no restaurants are found, return a custom response
        if (finalFilteredHotels.length === 0) {
            return res.status(404).json({ error: 'No restaurants meeting the criteria were found.' });
        }

        // Prepare the response
        const response = finalFilteredHotels.map(({ hotel }) => ({
            name: hotel.name,
            address: hotel.Address,
            city: hotel.City,
            state: hotel.State,
            country: hotel.Country,
            distanceFromUser: calculateDistance(userLocation.coordinates, hotel.location.coordinates) <= 1 ?
                calculateDistance(userLocation.coordinates, hotel.location.coordinates) * 1000 :
                calculateDistance(userLocation.coordinates, hotel.location.coordinates),
            approximateTotalBill: totalAmount / numberOfPeople,
            availableWeekdays: hotel.availableWeekDays.map(day => ({
                dayOfWeek: day.dayOfWeek,
                openTime: day.openTime,
                closeTime: day.closeTime
            })),
            menuCombinations: getMenuCombinations(hotel.menuItems, totalAmount),
            reservationEnabled: hotel.reservation
        }));

        res.json(response);
    } catch (error) {
        console.error('Search Error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Assume you have a function to fetch data from the database
async function fetchOperatingHoursFromDB() {
    try {
        // Your database querying code here
        const operatingHoursData = await Hotel.find({}, { availableWeekDays: 1 });
        return operatingHoursData.map(doc => doc.availableWeekDays); // Extracting availableWeekDays array from each document
    } catch (error) {
        console.error("Error fetching operating hours from the database:", error);
        return []; // Return an empty array in case of error
    }
}

// Modified checkOperatingHours function to accept operating hours data fetched from the database
async function checkOperatingHours(day, time) {
    try {
        if (typeof day !== 'string') {
            throw new TypeError('Day must be a string.');
        }

        // Convert day to lowercase for case-insensitive comparison
        const dayOfWeek = day.toLowerCase();

        const availableWeekDays = await fetchOperatingHoursFromDB(); // Fetch operating hours from the database

        for (const hours of availableWeekDays) {
            for (const hour of hours) {
                if (typeof hour.dayOfWeek === 'string' && hour.dayOfWeek.toLowerCase() === dayOfWeek) { // Check if day matches
                    const openTime = convertTo24Hour(hour.openTime);
                    const closeTime = convertTo24Hour(hour.closeTime);
                    const requestedTime = convertTo24Hour(time);

                    if (requestedTime >= openTime && requestedTime <= closeTime) {
                        return true; // Restaurant is open at the requested day and time
                    }
                }
            }
        }
        
        return false; // Restaurant is not open at the requested day and time
    } catch (error) {
        console.error("Error in checkOperatingHours:", error);
        return false;
    }
}

// Function to convert time to 24-hour format
function convertTo24Hour(time) {
    const [hours, minutes] = time.split(':');
    let hour = parseInt(hours);
    const isPM = time.includes('PM');
    
    if (isPM && hour !== 12) {
        hour += 12;
    } else if (!isPM && hour === 12) {
        hour = 0;
    }

    return hour * 100 + parseInt(minutes);
}


// Function to construct search date and time from provided day and time
function constructSearchDateTime(day, time) {
    // Get current date
    const currentDate = new Date();
    
    // Map day to its index (0 for Sunday, 1 for Monday, ..., 6 for Saturday)
    const dayIndex = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'].indexOf(day.toLowerCase());

    if (dayIndex === -1) {
        throw new Error('Invalid day provided');
    }

    // Set search date to the next occurrence of the provided day
    currentDate.setDate(currentDate.getDate() + (dayIndex + 7 - currentDate.getDay()) % 7);

    // Parse the time string and set the time
    const [hours, minutes] = time.match(/(\d+):(\d+)([ap]m)/i).slice(1, 4);
    let searchDateTime = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate(), parseInt(hours), parseInt(minutes), 0, 0);

    // Adjust searchDateTime for PM time
    if (time.toLowerCase().includes('pm') && hours !== '12') {
        searchDateTime.setHours(searchDateTime.getHours() + 12);
    }

    return searchDateTime;
}

function getMenuCombinations(menuItemsWithPrices, totalAmount) {
    console.log("Menu items with prices:", menuItemsWithPrices);
    console.log("Total amount:", totalAmount);

    const { menuItems, prices } = menuItemsWithPrices;
    const combinations = [];

    // Generate all possible combinations of menu items
    function getMenuCombinations(menuItemsWithPrices, totalAmount) {
        const { menuItems, prices } = menuItemsWithPrices;
        const combinations = [];
    
        // Generate all possible combinations of menu items
        function generateCombinations(index, currentCombination, remainingBudget) {
            // Terminate the recursion if we've iterated through all items
            if (index === menuItems.length) {
                return;
            }
    
            // Include the current item in the combination if the remaining budget is enough
            if (prices[index] <= remainingBudget) {
                currentCombination.push(menuItems[index]);
                const newRemainingBudget = remainingBudget - prices[index];
                combinations.push([...currentCombination]); // Add the combination to the list
                generateCombinations(index, currentCombination, newRemainingBudget); // Recur with the same item
                currentCombination.pop(); // Backtrack
            }
    
            // Move to the next item
            generateCombinations(index + 1, currentCombination, remainingBudget);
        }
    
        // Start generating combinations from the first item
        generateCombinations(0, [], totalAmount);
    
        return combinations;
    }   
} 

async function fetchMenuItemsWithPrices() {
    try {
        console.log('Fetching menu items with prices from the database...');
        // Your database querying code here
        const menuData = await Hotel.find({}, { menuItems: 1, prices: 1 });
        console.log('Menu data fetched successfully:', menuData);
        return menuData[0]; // Assuming there's only one document containing menu data
    } catch (error) {
        console.error("Error fetching menu items from the database:", error);
        return { menuItems: [], prices: [] }; // Return empty arrays in case of error
    }
}


async function fetchHotelsData() {
    try {
        // Fetch hotels data from the database
        const hotelsData = await Hotel.find({}, { menuItems: 1, prices: 1 });

        // Process the fetched data as needed
        return hotelsData;
    } catch (error) {
        console.error("Error fetching hotels data from the database:", error);
        return []; // Return empty array in case of error
    }
}

module.exports = router;

const express = require('express');
const mongoose = require('mongoose');
const hotelRouter = require('./controllers/hotelRouter');
const userRouter = require('./controllers/userRouter');
const user = require('./controllers/userprofRouter');
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json());
mongoose.connect('mongodb+srv://anex:anex123@cluster0.bgkikbl.mongodb.net/flavorDb?retryWrites=true&w=majority', { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Failed to connect to MongoDB', err));
app.use("/api/hotels",hotelRouter);
app.use("/api/user",userRouter);
app.use("/api",user);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

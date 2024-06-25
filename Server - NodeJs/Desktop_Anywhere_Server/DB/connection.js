
import mongoose from 'mongoose'

const connectDB = ()=>{
    return mongoose.connect(process.env.MOOD == "DEV" ? process.env.DB_LOCAL : process.env.DB_HOST)
    .then(result => {console.log(`DB connected successfully ............`)})
    .catch(err => {console.log(`Fail to connect on DB .............. ${err}`)})
}

export default connectDB;
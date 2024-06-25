import { Schema, model } from "mongoose";
import mongoose from 'mongoose'

const turnSchema = new Schema({

    url: {
        type: String,
        required: true,
    },
    username: {
        type: String,
        required: true,
    },
    credential: {
        type: String,
        required: true,
    },
    company: {
        type: String,
        required: true,
    },

}, {
    timestamps: true,
});


const turnModel = mongoose.models.Turn || model('Turn', turnSchema);

export default turnModel;
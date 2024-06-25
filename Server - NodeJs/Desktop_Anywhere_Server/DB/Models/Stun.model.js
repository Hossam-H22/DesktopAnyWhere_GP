import { Schema, model } from "mongoose";
import mongoose from 'mongoose'

const stunSchema = new Schema({

    url: {
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


const stunModel = mongoose.models.Stun || model('Stun', stunSchema);

export default stunModel;
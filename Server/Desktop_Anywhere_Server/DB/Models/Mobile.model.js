import { Schema, model } from "mongoose";
import mongoose from 'mongoose'

const mobileSchema = new Schema({
    name: {
        type: String,
        required: true,
    },
    model: {
        type: String,
        required: true,
    },
    version_number: {
        type: String,
        required: true,
    },
    // mac_address: {
    //     type: String,
    //     required: true,
    // },
}, {
    timestamps: true,
});


const mobileModel = mongoose.models.Mobile || model('Mobile', mobileSchema);

export default mobileModel;
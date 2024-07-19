import { Schema, Types, model } from "mongoose";
import mongoose from 'mongoose'

const connectionSchema = new Schema({
    desktop_mac: {
        type: String,
        required: true,
    },
    mobile_id: {
        type: Types.ObjectId,
        required: true,
    }
}, {
    timestamps: true,
});


const connectionModel = mongoose.models.Connection || model('Connection', connectionSchema);

export default connectionModel;
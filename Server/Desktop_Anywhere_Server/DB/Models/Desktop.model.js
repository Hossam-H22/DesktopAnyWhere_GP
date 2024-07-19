import { Schema, model } from "mongoose";
import mongoose from 'mongoose'

const desktopSchema = new Schema({
    public_ip: {
        type: String,
        required: true,
    },
    private_ip: {
        type: String,
        required: true,
    },
    mac_address: {
        type: String,
        required: true,
    },
}, {
    timestamps: true,
});


const desktopModel = mongoose.models.Desktop || model('Desktop', desktopSchema);

export default desktopModel;
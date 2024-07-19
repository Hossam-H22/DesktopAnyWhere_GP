import { Schema, Types, model } from "mongoose";
import mongoose from 'mongoose'

const mediaSchema = new Schema({
    createdBy: { 
        type: Types.ObjectId, 
        ref:'Mobile', 
        required: true, 
    },
    secure_url: { 
        type: String, 
        required: true, 
    },
    file_name: { 
        type: String, 
        required: true, 
    },
    mimetype: { 
        type: String, 
        required: true, 
    },
    size: { 
        type: Number, 
        required: true, 
    },
}, {
    timestamps: true,
});


const mediaModel = mongoose.models.Media || model('Media', mediaSchema);

export default mediaModel;
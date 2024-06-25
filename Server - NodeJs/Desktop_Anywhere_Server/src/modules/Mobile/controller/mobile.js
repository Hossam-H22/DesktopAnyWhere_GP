import { asyncHandler } from './../../../utils/errorHandling.js';
import mobileModel from './../../../../DB/Models/Mobile.model.js';



export const getAll = asyncHandler(async (req, res, next) => {
    const devices = await mobileModel.find();
    return res.status(200).json({ message: "Done", devices });
})


export const get = asyncHandler(async (req, res, next) => {
    const device = await mobileModel.findById(req.params.id);
    return device ? res.status(200).json({ message: "Done", device }) : next(new Error(`Not Found device with this id ${req.params.id}`, { case: 404 }));
})

export const add = asyncHandler(async (req, res, next) => {
    var mobile = await mobileModel.create({
        name: req.body.name,
        model: req.body.model,
        version_number: req.body.version_number,
    });
    return mobile? res.status(201).json({ message: "Done", mobile }) : next(new Error(`Found Error`, { case: 400 }));
})

export const deleteOne = asyncHandler(async (req, res, next) => {
    const device = await mobileModel.findByIdAndDelete(req.params.id);
    return device ? res.status(200).json({ message: "Done"}) 
                    : next(new Error(`In-valid or Not Found Id: ${req.params.id}`, {cause: 404}));
})


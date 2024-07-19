import stunModel from './../../../../DB/Models/Stun.model.js';
import { asyncHandler } from './../../../utils/errorHandling.js';



export const getAll = asyncHandler(async (req, res, next) => {
    const stun = await stunModel.find();
    return stun ? res.status(200).json({ message: "Done", stun }) : next(new Error(`Not Found stun for this id ${req.params.id}`, { case: 404 }));
})

export const getOne = asyncHandler(async (req, res, next) => {
    
    const stun = await stunModel.findById(req.params.id);
    return stun ? res.status(200).json({ message: "Done", stun }) : next(new Error(`Not Found stun for this id ${req.params.id}`, { case: 404 }));
})


export const add = asyncHandler(async (req, res, next) => {
    const stun = await stunModel.create(req.body);
    return stun ? res.status(201).json({ message: "Done", stun }) : next(new Error(`Found Error`, { case: 400 }));
})



export const deleteOne = asyncHandler(async (req, res, next) => {
    const stun = await stunModel.findByIdAndDelete(req.params.id);
    return stun ? res.status(200).json({ message: "Done"}) 
                    : next(new Error(`In-valid or Not Found Id: ${req.params.id}`, {cause: 404}));
})


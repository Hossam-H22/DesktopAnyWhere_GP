import turnModel from './../../../../DB/Models/Turn.model.js';
import { asyncHandler } from './../../../utils/errorHandling.js';



export const getAll = asyncHandler(async (req, res, next) => {
    const turn = await turnModel.find();
    return turn ? res.status(200).json({ message: "Done", turn }) : next(new Error(`Not Found turn for this id ${req.params.id}`, { case: 404 }));
})

export const getOne = asyncHandler(async (req, res, next) => {
    const turn = await turnModel.findById(req.params.id);
    return turn ? res.status(200).json({ message: "Done", turn }) : next(new Error(`Not Found turn for this id ${req.params.id}`, { case: 404 }));
})


export const add = asyncHandler(async (req, res, next) => {
    const turn = await turnModel.create(req.body);
    return turn ? res.status(201).json({ message: "Done", turn }) : next(new Error(`Found Error`, { case: 400 }));
})



export const deleteOne = asyncHandler(async (req, res, next) => {
    const turn = await turnModel.findByIdAndDelete(req.params.id);
    return turn ? res.status(200).json({ message: "Done"}) 
                    : next(new Error(`In-valid or Not Found Id: ${req.params.id}`, {cause: 404}));
})


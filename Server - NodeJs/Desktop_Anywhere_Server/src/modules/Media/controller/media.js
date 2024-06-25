import { asyncHandler } from './../../../utils/errorHandling.js';
import mediaModel from './../../../../DB/Models/Media.model.js';
import { fileURLToPath } from 'url'
import fs from "fs"
import path from 'path'


const __dirname = path.dirname(fileURLToPath(import.meta.url));


export const getAllFilesData = asyncHandler(async (req, res, next) => {
    const files = await mediaModel.find();
    return res.status(200).json({ message: "Done", files });
})


export const getOne = asyncHandler(async (req, res, next) => {
    const mobile_Id = req.params.mobile_Id;
    const file = await mediaModel.findOne({ createdBy: mobile_Id });
    if (file) {
        // Check if the file exists
        if(! await fileExists(file.secure_url)){
            console.log('File does not exist');
            await mediaModel.deleteMany({ createdBy: mobile_Id });
            return next(new Error(`No files found for this Id: ${mobile_Id}`, { cause: 404 }));
        }
    }
    return file? res.status(200).json({ message: "Done", file }) : next(new Error(`In-valid or Not Found Id or No files for this Id: ${mobile_Id}`, { cause: 404 }));
})



export const add = asyncHandler(async (req, res, next) => {
    const mobile_Id = req.body.mobile_Id;
    var media = await mediaModel.find({ createdBy: mobile_Id });
    if (media.length > 0) {
        media.forEach(element => {
            deleteFile(element.secure_url);
        });
        await mediaModel.deleteMany({ createdBy: mobile_Id });
    }

    media = await mediaModel.create({
        createdBy: mobile_Id,
        secure_url: req.file.dest,
        file_name: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
    });

    return res.status(201).json({ message: "Done", media });
})


export const deleteOne = asyncHandler(async (req, res, next) => {
    const mobile_Id = req.params.mobile_Id
    var media = await mediaModel.find({ createdBy: mobile_Id });
    media.forEach(async (element) => {
        if(await fileExists(element.secure_url)){
            deleteFile(element.secure_url);
        }
    });
    media = await mediaModel.deleteMany({ createdBy: mobile_Id });

    return media.deletedCount > 0 ? res.status(200).json({ message: "Done" })
        : next(new Error(`In-valid or Not Found Id or No files found for this Id: ${req.params.mobile_Id} `, { cause: 404 }));
})


export function deleteFile(url) {
    const fullPath = path.join(__dirname, `./../../../${url}`)
    try {
        fs.unlinkSync(fullPath);
    }
    catch (error) {
        console.log(error);
    }
}


export function fileExists(url) {
    const filePath = path.join(__dirname, `./../../../${url}`);
    return new Promise((resolve, reject) => {
        fs.access(filePath, fs.constants.F_OK, (err) => {
            if (err) {
                // File does not exist or cannot be accessed
                resolve(false);
            } else {
                // File exists
                resolve(true);
            }
        });
    });
}

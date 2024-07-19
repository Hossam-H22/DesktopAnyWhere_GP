
import desktopModel from '../../../../DB/Models/Desktop.model.js';
import mobileModel from '../../../../DB/Models/Mobile.model.js';
import { refreshDevicesConnection } from '../../../socket.js';
import connectionModel from './../../../../DB/Models/Connection.model.js';
import { asyncHandler } from './../../../utils/errorHandling.js';



export const getAll = asyncHandler(async (req, res, next) => {
    const connections = await connectionModel.find();
    return res.status(200).json({ message: "Done", connections });
})


export const getDesktopConnections = asyncHandler(async (req, res, next) => {
    const mobiles = await connectionModel.find({ 'desktop_mac': req.params.desktop_mac });

    var mobileIds = [];
    mobiles.forEach(element => {
        mobileIds.push(element.mobile_id);
    });
    const mobilesData = await mobileModel.find({ '_id': mobileIds });

    var data = [];
    mobilesData.forEach(element => {
        for(var i=0; i<mobiles.length; i++){
            if(`${element._id}` == `${mobiles[i].mobile_id}`){
                data.push({
                    ...element.toObject(),
                    connectionId: mobiles[i]._id
                });
                break;
            }
        }
    });
    console.log(data);
    return res.status(200).json({ message: "Done", mobiles: data });
})


export const getMobileConnections = asyncHandler(async (req, res, next) => {
    const desktops = await connectionModel.find({ 'mobile_id': req.params.mobile_id });
    return res.status(200).json({ message: "Done", desktops });
})


export const addConnection = asyncHandler(async (req, res, next) => {
    const { desktop_mac, mobile_id } = req.body;
    var connection = await connectionModel.findOne({ 'desktop_mac': desktop_mac, 'mobile_id': mobile_id, });
    if(connection){
        return res.status(200).json({ message: "Done", connection });
    }else {
        connection = await connectionModel.create({
            'desktop_mac': desktop_mac,
            'mobile_id': mobile_id,
        });

        const {public_ip} = await desktopModel.findOne({"mac_address": connection.desktop_mac});
        refreshDevicesConnection(public_ip);
    }
    return connection? res.status(200).json({ message: "Done", connection }) : next(new Error(`Found Error`, { case: 404 }));
})


export const deleteConnection = asyncHandler(async (req, res, next) => {
    const connection = await connectionModel.findOneAndDelete({ '_id': req.params.id });
    if(connection==null){
        next(new Error(`In-valid or Not Found ID: ${req.params.id}`, {cause: 404}))
    }
    const {public_ip} = await desktopModel.findOne({"mac_address": connection.desktop_mac});
    refreshDevicesConnection(public_ip);

    return public_ip ? res.status(200).json({ message: "Done"}) 
                    : next(new Error(`In-valid or Not Found ID: ${req.params.id}`, {cause: 404}));
})



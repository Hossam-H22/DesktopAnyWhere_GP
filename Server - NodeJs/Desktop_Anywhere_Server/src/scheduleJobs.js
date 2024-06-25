
import schedule from "node-schedule";
import axios from "axios"
import mediaModel from "../DB/Models/Media.model.js";
import { deleteFile, fileExists } from "./modules/Media/controller/media.js";



export function compareDate(date, hoursValue) {
    const now = new Date();
    const specificDate = new Date(date);
    const diffInMilliseconds = Math.abs(now - specificDate);
    const hoursValueInMilliseconds = hoursValue * 60 * 60 * 1000;
    return diffInMilliseconds >= hoursValueInMilliseconds;
}




const initSchedule = () => {

    const url = "https://desktopanywhere.onrender.com"


    const refreshServer = schedule.scheduleJob('1 */10 * * * *', () => {
        axios.get(`${url}/welcome`).then(response => {
            console.log(`Refresh Server From Schedule => "${response.data.message}"`);
        }).catch(error => {
            console.log(`Error when refresh server from schedule: ${error}`);
        });
    });


    const deleteExpiredFiles = schedule.scheduleJob('20 */30 * * * *', async () => {
        const expireTimeInHours = 1
        const files = await mediaModel.find();
        if (files.length > 0) {
            const deletedFilesIds = [];
            files.forEach(async fileData => {
                if (compareDate(fileData.createdAt, expireTimeInHours)) {
                    deletedFilesIds.push(fileData.createdBy);
                    if (await fileExists(fileData.secure_url)) {
                        deleteFile(fileData.secure_url);
                    }
                }
            });
            await mediaModel.deleteMany({ createdBy: deletedFilesIds });
        }
        console.log(`Delete files that were uploaded for more than ${expireTimeInHours} Hours, From Schedule`);
    });



}

export default initSchedule;

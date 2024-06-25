

import { asyncHandler, globalErrorHandling } from "./utils/errorHandling.js";
import connectionRouter from "./modules/Connection/connection.router.js"
import desktopRouter from "./modules/Desktop/desktop.router.js"
import mobileRouter from "./modules/Mobile/mobile.router.js"
import mediaRouter from "./modules/Media/media.router.js"
import stunRouter from "./modules/Stun/stun.router.js"
import trunRouter from "./modules/Turn/turn.router.js"
import stunModel from "./../DB/Models/Stun.model.js"
import turnModel from "./../DB/Models/Turn.model.js"
import connectDB from './../DB/connection.js';
import serveIndex from "serve-index"
import { fileURLToPath } from 'url'
import morgan from "morgan"
import cors from 'cors'
import path from 'path'




const __dirname = path.dirname(fileURLToPath(import.meta.url));

const initApp = (app, express) => {


    // allow acces from anyWare
    app.use(cors({})); 


    // to calculate request time
    if (process.env.MOOD == "DEV") {
        app.use(morgan("dev"));
    }
    else {
        app.use(morgan("common"));
    }


    // convert Buffer Data
    app.use((req, res, next) => {
        if (req.originalUrl == '/media') next();
        else express.json({})(req, res, next);
    });
    // app.use(express.json({}));



    // Media Routing
    const fullPath = path.join(__dirname, './uploads')
    app.use("/uploads", express.static(fullPath), serveIndex(fullPath, { icons: true }));




    // App Routing
    app.use(express.static("public"));
    app.get("/", (req, res) => res.sendFile(__dirname + "/public/index.html") );
    app.get('/welcome', (req, res) => res.status(200).json({ message: "Welcome to Desktop Anywhere Server" }));
    app.use("/connection", connectionRouter);
    app.use("/stun", stunRouter);
    app.use("/turn", trunRouter);
    app.use("/desktop", desktopRouter);
    app.use("/mobile", mobileRouter);
    app.use("/media", mediaRouter);
    app.get("/confegration", asyncHandler(async (req, res, next) => {
        const stun = await stunModel.find();
        var newStun = []
        stun?.forEach(element => newStun.push(element.url));

        const turn = await turnModel.find();
        var newTurn = []
        turn?.forEach(element =>
            newTurn.push({
                "urls": element.url,
                "username": element.username,
                "credential": element.credential,
            })
        )
        var configuration = {
            "iceServers": [
                {
                    'urls': newStun
                },
                ...newTurn,
            ]
        }
        return res.status(200).json({ message: "Done", configuration })
    }));

    app.all("*", (req, res, next) => {
        return res.status(404).json({ message: "In-valid routing" });
    });



    // Error handling middleware
    app.use(globalErrorHandling);

    // Connection DB
    connectDB();

}

export default initApp
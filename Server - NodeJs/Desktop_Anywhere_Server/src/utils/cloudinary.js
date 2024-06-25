
import cloudinary from 'cloudinary'
import { fileURLToPath } from 'url'
import * as dotenv from 'dotenv'
import path from 'path'

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({path: path.join(__dirname, './../../.env')});



// Configuration 
cloudinary.v2.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.CLOUD_API_KEY,
  api_secret: process.env.CLOUD_API_SECRET,
  secure: true
});


export default cloudinary.v2

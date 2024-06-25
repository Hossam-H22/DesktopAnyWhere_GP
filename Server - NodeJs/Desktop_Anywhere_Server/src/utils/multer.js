
import { fileURLToPath } from 'url'
import { nanoid } from 'nanoid'
import multer from 'multer'
import path from 'path'
import fs from 'fs'

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const fileValidation = {
    image: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg'],
    file: ['application/pdf', 'application/msword'],
}

export function fileUpload(customPath = 'general', customValidation = []) {
    
    const fullPath = path.join(__dirname, `./../uploads/${customPath}/`);

    if(!fs.existsSync(fullPath)) {
        fs.mkdirSync(fullPath, { recursive: true });
    }
    const storage = multer.diskStorage({
        destination: (req, file, cb) => {
            cb(null, fullPath);
        },
        filename: (req, file, cb) => {
            const suffixName = nanoid()+"_"+file.originalname;
            file.dest = `uploads/${customPath}/${suffixName}`;
            cb(null, suffixName);
        },
    });

    function fileFilter(req, file, cb) {
        if(customValidation.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb('In-valid format', false);
        }
    }

    const upload = multer({ dest: 'uploads', /*fileFilter,*/ storage });
    return upload;

}

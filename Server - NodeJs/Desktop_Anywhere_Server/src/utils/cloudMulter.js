
import multer from 'multer'


export const fileValidation = {
    image: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg'],
    file: ['application/pdf', 'application/msword'],
}

export function fileUpload(customValidation = []) {
    
    const storage = multer.diskStorage({});

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

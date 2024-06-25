
import { Router } from 'express'
import * as mobileController from './controller/mobile.js';


const router = Router();

router.get("/", mobileController.getAll);
router.get("/:id", mobileController.get);
router.post("/", mobileController.add);
router.delete("/:id", mobileController.deleteOne);



export default router;
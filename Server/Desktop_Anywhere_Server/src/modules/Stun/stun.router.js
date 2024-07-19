
import { Router } from 'express'
import * as stunController from './controller/stun.js';


const router = Router();

router.get("/", stunController.getAll);
router.get("/:id", stunController.getOne);
router.post("/", stunController.add);
router.delete("/:id", stunController.deleteOne);



export default router;
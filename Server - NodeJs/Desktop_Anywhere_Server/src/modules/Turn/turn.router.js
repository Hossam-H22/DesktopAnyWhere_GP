
import { Router } from 'express'
import * as turnController from './controller/turn.js';


const router = Router();

router.get("/", turnController.getAll);
router.get("/:id", turnController.getOne);
router.post("/", turnController.add);
router.delete("/:id", turnController.deleteOne);



export default router;
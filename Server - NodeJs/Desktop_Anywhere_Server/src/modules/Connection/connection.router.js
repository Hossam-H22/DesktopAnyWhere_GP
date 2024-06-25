
import { Router } from 'express'
import * as connectionController from './controller/connection.js';


const router = Router();

router.get("/", connectionController.getAll);
router.get("/desktop/:desktop_mac", connectionController.getDesktopConnections);
router.get("/mobile/:mobile_id", connectionController.getMobileConnections);
router.post("/", connectionController.addConnection);
router.delete("/:id", connectionController.deleteConnection);

export default router;
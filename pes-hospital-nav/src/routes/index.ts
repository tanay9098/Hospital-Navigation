import { Router } from "express";
import health from "./health";
import departmentRoutes from "./departments";

const router = Router();

router.use("/health", health);
router.use("/api", departmentRoutes);

export default router;
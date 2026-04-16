import { Router } from "express";
import health from "./health";
import departmentRoutes from "./departments";
import navigationRoutes from "./navigation";
import ivrsRoutes from "./ivrs";


const router = Router();

router.use("/health", health);
router.use("/api", departmentRoutes);
router.use("/api", navigationRoutes);
router.use("/api", ivrsRoutes);

export default router;
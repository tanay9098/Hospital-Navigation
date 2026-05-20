import { Router } from "express";
import health from "./health";
import ivrsRoutes from "./ivrs";

const router = Router();

router.use("/health", health);
router.use("/ivrs", ivrsRoutes);

export default router;

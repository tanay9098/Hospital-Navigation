import { Router } from "express";
import NavigationService from "../services/NavigationService";

const router = Router();

router.post("/navigate", (req, res) => {

  const { start_node_id, dest_dept_id, wheelchair_mode, language_code } = req.body;

  try {

    const result = NavigationService.navigate(
      start_node_id,
      dest_dept_id,
      wheelchair_mode,
      language_code
    );

    res.json(result);

  } catch (err:any) {

    res.status(500).json({ error: err.message });

  }

});

export default router;
import { Router } from "express";
import DepartmentService from "../services/DepartmentService";

const router = Router();

/* GET /api/floors */
router.get("/floors", (req, res) => {
  const isActive = req.query.is_active
    ? Number(req.query.is_active)
    : undefined;

  const floors = DepartmentService.getFloors(isActive);
  res.json(floors);
});

/* GET /api/floors/:id/departments */
router.get("/floors/:id/departments", (req, res) => {
  const data = DepartmentService.getDepartmentsByFloor(req.params.id);
  res.json(data);
});

/* GET /api/departments */
router.get("/departments", (req, res) => {
  const departments = DepartmentService.getDepartments(req.query);
  res.json(departments);
});

/* GET /api/departments/:id */
router.get("/departments/:id", (req, res) => {
  const dept = DepartmentService.getDepartmentById(req.params.id);

  if (!dept) {
    return res.status(404).json({ error: "Department not found" });
  }

  res.json(dept);
});

/* GET /api/departments/ivrs/:shortcode */
router.get("/departments/ivrs/:shortcode", (req, res) => {
  const dept = DepartmentService.getDepartmentByIvrs(req.params.shortcode);

  if (!dept) {
    return res.status(404).json({ error: "Department not found" });
  }

  res.json(dept);
});

export default router;
const router = require('express').Router();
const ctrl   = require('../controllers/departmentController');

router.get('/search',       ctrl.searchDepartments);
router.get('/floor/:floor', ctrl.getDepartmentsByFloor);
router.get('/:id',          ctrl.getDepartmentById);
router.get('/',             ctrl.getAllDepartments);
router.post('/',            ctrl.createDepartment);
router.patch('/:id',        ctrl.updateDepartment);

module.exports = router;

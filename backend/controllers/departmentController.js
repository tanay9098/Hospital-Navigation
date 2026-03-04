const Department = require('../models/Department');
const Location   = require('../models/Location');

// GET /api/v1/departments
exports.getAllDepartments = async (req, res, next) => {
  try {
    const { floor, search } = req.query;
    const filter = { isActive: true };
    if (floor !== undefined) filter.floor = parseInt(floor, 10);

    let query = Department.find(filter).sort({ floor: 1, name: 1 });

    if (search) {
      query = Department.find(
        { ...filter, $text: { $search: search } },
        { score: { $meta: 'textScore' } }
      ).sort({ score: { $meta: 'textScore' } });
    }

    const departments = await query.lean();
    res.json({ success: true, count: departments.length, data: departments });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/departments/:id
exports.getDepartmentById = async (req, res, next) => {
  try {
    const dept = await Department.findById(req.params.id).lean();
    if (!dept || !dept.isActive) {
      return res.status(404).json({ success: false, message: 'Department not found.' });
    }

    // Attach location details
    const location = await Location.findOne({ code: dept.locationCode }, '-connections').lean();
    res.json({ success: true, data: { ...dept, location } });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/departments/floor/:floor
exports.getDepartmentsByFloor = async (req, res, next) => {
  try {
    const floor = parseInt(req.params.floor, 10);
    if (isNaN(floor) || floor < 0 || floor > 8) {
      return res.status(400).json({ success: false, message: 'Floor must be 0–8.' });
    }

    const departments = await Department.find({ floor, isActive: true })
      .sort({ name: 1 })
      .lean();

    res.json({ success: true, floor, count: departments.length, data: departments });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/departments/search?q=cardio
exports.searchDepartments = async (req, res, next) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, message: 'Search query must be at least 2 characters.' });
    }

    const departments = await Department.find(
      { isActive: true, $text: { $search: q.trim() } },
      { score: { $meta: 'textScore' } }
    )
      .sort({ score: { $meta: 'textScore' } })
      .limit(15)
      .lean();

    res.json({ success: true, count: departments.length, data: departments });
  } catch (err) {
    next(err);
  }
};

// POST /api/v1/departments
exports.createDepartment = async (req, res, next) => {
  try {
    const dept = await Department.create(req.body);
    res.status(201).json({ success: true, data: dept });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/v1/departments/:id
exports.updateDepartment = async (req, res, next) => {
  try {
    const dept = await Department.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!dept) {
      return res.status(404).json({ success: false, message: 'Department not found.' });
    }

    res.json({ success: true, data: dept });
  } catch (err) {
    next(err);
  }
};

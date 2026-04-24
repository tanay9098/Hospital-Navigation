import db from "../db/db";

class DepartmentService {

  static getFloors(isActive?: number) {
    let query = `
      SELECT 
        f.id,
        f.floor_number,
        f.label,
        f.is_active,
        COUNT(z.id) as zone_count
      FROM FLOOR f
      LEFT JOIN ZONE z ON z.floor_id = f.id
    `;

    const params: any[] = [];

    if (isActive !== undefined) {
      query += " WHERE f.is_active = ?";
      params.push(isActive);
    }

    query += `
      GROUP BY f.id
      ORDER BY f.floor_number
    `;

    return db.prepare(query).all(...params);
  }

  static getDepartmentsByFloor(floorId: string) {
    const query = `
      SELECT 
        d.id,
        d.code,
        d.name,
        d.short_name,
        d.category,
        d.room_number,
        d.contact_ext,
        z.name as zone_name,
        f.floor_number
      FROM DEPARTMENT d
      JOIN ZONE z ON d.zone_id = z.id
      JOIN FLOOR f ON z.floor_id = f.id
      WHERE f.id = ?
      ORDER BY d.name
    `;

    return db.prepare(query).all(floorId);
  }

  static getDepartments(filters: any) {
    let query = `
      SELECT 
        d.id,
        d.code,
        d.name,
        d.short_name,
        d.category,
        d.room_number,
        d.floor_number,
        d.ivrs_shortcode
      FROM DEPARTMENT d
      JOIN ZONE z ON d.zone_id = z.id
      JOIN FLOOR f ON z.floor_id = f.id
      WHERE 1=1
    `;

    const params: any[] = [];

    if (filters.search) {
      query += ` AND (d.name LIKE ? OR d.short_name LIKE ?)`;
      params.push(`%${filters.search}%`, `%${filters.search}%`);
    }

    if (filters.category) {
      query += ` AND d.category = ?`;
      params.push(filters.category);
    }

    if (filters.floor !== undefined && filters.floor !== '') {
      query += ` AND f.floor_number = ?`;
      params.push(Number(filters.floor));
    }

    query += " ORDER BY d.name";

    return db.prepare(query).all(...params);
  }

  static getDepartmentById(id: string) {
    const query = `
      SELECT 
        d.*,
        z.name as zone_name,
        f.id as floor_id,
        f.floor_number,
        f.label as floor_label
      FROM DEPARTMENT d
      JOIN ZONE z ON d.zone_id = z.id
      JOIN FLOOR f ON z.floor_id = f.id
      WHERE d.id = ?
    `;

    return db.prepare(query).get(id);
  }

  static getDepartmentByIvrs(shortcode: string) {
    const query = `
      SELECT 
        d.id,
        d.name,
        d.short_name,
        d.floor_number,
        d.room_number,
        d.contact_ext
      FROM DEPARTMENT d
      WHERE d.ivrs_shortcode = ?
    `;

    return db.prepare(query).get(shortcode);
  }
}

export default DepartmentService;
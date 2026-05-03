# pes-hospital-nav

Backend API for the **PES Hospital Electronic City Indoor Navigation System**.

This service provides REST API endpoints to support patients, visitors, and staff in navigating the hospital campus — locating departments, wards, OPDs, labs, and amenities using an interactive indoor map.

---

## Tech Stack

| Layer        | Technology                  |
|--------------|-----------------------------|
| Runtime      | Node.js                     |
| Framework    | Express 4                   |
| Language     | TypeScript 5                |
| Database     | SQLite (via better-sqlite3) |
| Config       | dotenv                      |
| Linting      | ESLint + TypeScript plugin  |
| Formatting   | Prettier                    |

---

## Project Structure

```
pes-hospital-nav/
├── src/
│   ├── config/        # Environment config and app-level settings
│   ├── middleware/    # Express middleware (error handler, 404, etc.)
│   ├── models/        # Data models and type definitions
│   ├── routes/        # Express route handlers
│   ├── services/      # Business logic layer
│   ├── app.ts         # Express app setup
│   └── index.ts       # Server entry point
├── .env.example       # Environment variable template
├── .eslintrc.json     # ESLint configuration
├── .prettierrc        # Prettier configuration
├── tsconfig.json      # TypeScript configuration
└── package.json
```

---

## Getting Started

### Prerequisites

- Node.js >= 18
- npm >= 9

### Installation

```bash
cd pes-hospital-nav
npm install
```

### Environment Setup

```bash
cp .env.example .env
# Edit .env as needed
```

### Development

```bash
npm run dev
```

### Build

```bash
npm run build
npm start
```

### Linting & Formatting

```bash
npm run lint         # Check for lint errors
npm run lint:fix     # Auto-fix lint errors
npm run format       # Format all source files
npm run format:check # Check formatting without writing
```

---

## API

Base URL: `http://localhost:{PORT}`

All endpoints are prefixed with `/api/v1`.

### Health

| Method | Endpoint        | Description  |
|--------|-----------------|--------------|
| GET    | /api/v1/health  | Health check |

### Floors

| Method | Endpoint                          | Description                          |
|--------|-----------------------------------|--------------------------------------|
| GET    | /api/v1/api/floors                | Get all floors                       |
| GET    | /api/v1/api/floors?is_active=1    | Get only active floors               |
| GET    | /api/v1/api/floors/:id/departments | Get all departments on a floor (by floor ID e.g. `F0`) |

### Departments

| Method | Endpoint                              | Description                              |
|--------|---------------------------------------|------------------------------------------|
| GET    | /api/v1/api/departments               | Get all departments                      |
| GET    | /api/v1/api/departments?search=       | Search departments by name or short name |
| GET    | /api/v1/api/departments?category=     | Filter departments by category           |
| GET    | /api/v1/api/departments?floor=        | Filter departments by floor number (e.g. `0` for ground floor) |
| GET    | /api/v1/api/departments/:id           | Get department by ID                     |
| GET    | /api/v1/api/departments/ivrs/:shortcode | Get department by IVRS shortcode       |

### Navigation

`POST /api/v1/api/navigate`

Request body:
```json
{
  "start_node_id": "N1",
  "dest_dept_id": "D41",
  "wheelchair_mode": false,
  "language_code": "en"
}
```

### IVRS

| Method | Endpoint                                  | Description               |
|--------|-------------------------------------------|---------------------------|
| POST   | /api/v1/api/ivrs/call/start               | Start an IVRS call        |
| POST   | /api/v1/api/ivrs/call/:call_id/interact   | Log a DTMF/speech interaction |
| POST   | /api/v1/api/ivrs/call/:call_id/end        | End an IVRS call          |
| GET    | /api/v1/api/ivrs/menu                     | Get IVRS menu options     |

---

## Environment Variables

| Variable   | Default                   | Description              |
|------------|---------------------------|--------------------------|
| NODE_ENV   | development               | Runtime environment      |
| PORT       | 3000                      | HTTP server port         |
| DB_PATH    | ./data/hospital-nav.db    | Path to SQLite database  |

---

## License

MIT — PES Hospital IT Dept

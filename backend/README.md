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

| Method | Endpoint          | Description        |
|--------|-------------------|--------------------|
| GET    | /api/v1/health    | Health check       |

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

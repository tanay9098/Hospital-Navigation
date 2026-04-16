# PES Hospital Indoor Navigation Backend

Backend API for the **PES Hospital Electronic City Indoor Navigation System**.
This service powers indoor navigation, department lookup, and IVRS-based guidance for patients and visitors.

The system exposes REST APIs that allow clients (mobile apps, web dashboards, kiosks, and IVRS systems) to navigate the hospital building and locate departments, services, and facilities.

---

# Tech Stack

| Layer       | Technology              |
| ----------- | ----------------------- |
| Runtime     | Node.js                 |
| Framework   | Express.js              |
| Language    | TypeScript              |
| Database    | SQLite (better-sqlite3) |
| Environment | dotenv                  |
| Dev Tools   | ESLint, Prettier        |
| Dev Server  | ts-node-dev             |

---

# Project Structure

```
pes-hospital-nav
│
├── src
│   ├── config          # Environment configuration
│   ├── db
│   │   ├── migrations  # SQL migration files
│   │   ├── seeds       # Initial seed data
│   │   ├── db.ts       # Database connection
│   │   └── migrate.ts  # Migration runner
│   │
│   ├── routes          # Express route handlers
│   ├── services        # Business logic layer
│   ├── middlewares     # Express middleware
│   ├── models          # Domain models (if required)
│   │
│   ├── app.ts          # Express app setup
│   └── index.ts        # Server entry point
│
├── data                # SQLite database location
├── package.json
├── tsconfig.json
└── README.md
```

---

# Features

### Hospital Structure

* Buildings
* Floors
* Zones
* Departments
* Department translations

### Navigation System

* Indoor navigation graph
* Dijkstra pathfinding
* Accessibility-aware routing (wheelchair mode)
* Multi-floor navigation

### IVRS Integration

* Call session tracking
* Voice prompts
* Department shortcode directory
* DTMF / speech interaction logging

### Multilingual Support

* English
* Kannada
* Hindi
* Tamil

### User Sessions

* Navigation sessions
* Step-by-step instructions
* Journey tracking

---

# Prerequisites

Ensure the following are installed:

* Node.js >= 18
* npm >= 9

Check versions:

```
node -v
npm -v
```

---

# Installation

Clone the repository:

```
git clone <repository-url>
cd pes-hospital-nav
```

Install dependencies:

```
npm install
```

---

# Environment Setup

Create an environment file:

```
cp .env.example .env
```

If `.env.example` does not exist, create `.env` manually:

```
PORT=3000
NODE_ENV=development
DB_PATH=./data/hospital.db
```

---

# Database Setup

Run migrations to create database tables:

```
npm run migrate
```

---

# Seed Initial Data

Seed the database with hospital structure and navigation data:

```
ts-node src/db/seeds/01_hospital_structure.ts
ts-node src/db/seeds/02_navigation_ground_floor.ts
ts-node src/db/seeds/03_languages_voice_prompts.ts
```

This will populate:

* Buildings
* Floors
* Departments
* Navigation nodes
* Navigation edges
* Landmarks
* Languages
* Voice prompts

---

# Running the Server

Start development server:

```
npm run dev
```

Server runs at:

```
http://localhost:3000
```

---

# Production Build

Compile TypeScript:

```
npm run build
```

Start compiled server:

```
npm start
```

---

# API Endpoints

### Health

```
GET /api/v1/health
```

---

### Floors

```
GET /api/floors
GET /api/floors?is_active=1
GET /api/floors/:id/departments
```

---

### Departments

```
GET /api/departments
GET /api/departments?search=
GET /api/departments?category=
GET /api/departments?floor=
GET /api/departments/:id
GET /api/departments/ivrs/:shortcode
```

---

### Navigation

```
POST /api/navigate
```

Body:

```
{
  "start_node_id": "N1",
  "dest_dept_id": "D41",
  "wheelchair_mode": false,
  "channel": "APP",
  "language_code": "en"
}
```

Response:

```
{
  "session_id": "...",
  "total_steps": 5,
  "total_distance_m": 42,
  "steps": []
}
```

---

### IVRS

Start call:

```
POST /api/ivrs/call/start
```

Interact with IVR:

```
POST /api/ivrs/call/:call_id/interact
```

End call:

```
POST /api/ivrs/call/:call_id/end
```

Department directory:

```
GET /api/ivrs/menu
```

---

# Development Workflow

### Run migrations

```
npm run migrate
```

### Start dev server

```
npm run dev
```

Server automatically reloads when files change.

---

# Branching Strategy

This repository uses the following branches:

### main

Production-ready code.

### development

Active development branch where new features are merged before release.

---

# How to Contribute

1. Create a new branch from **development**

```
git checkout development
git pull origin development
git checkout -b feature/<feature-name>
```

Example:

```
git checkout -b feature/navigation-routing
```

---

2. Make your changes and commit

```
git add .
git commit -m "feat(api): implement navigation routing service"
```

---

3. Push to development branch

```
git push origin feature/<feature-name>
```

Create a Pull Request to **development**.

---

# Commit Message Format

Follow Conventional Commits:

```
feat: new feature
fix: bug fix
chore: configuration change
docs: documentation
refactor: code improvement
```

Example:

```
feat(db): add navigation graph schema
```

---



# Maintainers

Tanay Dwivedi, Arnab, Basvaraj, Chandan, Shweta, Niteesh

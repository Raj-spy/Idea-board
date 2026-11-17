# IdeaBoard Platform

IdeaBoard is a focused idea-sharing application: users can submit ideas and retrieve the persisted board. This phase implements the React frontend and FastAPI backend backed by PostgreSQL.

## Architecture

- **Frontend:** React 18, Vite, JavaScript, and Tailwind CSS. The UI calls the REST API through a small, separate API client.
- **Backend:** Python 3.12+, FastAPI, Pydantic, SQLAlchemy 2, and psycopg 3.
- **Database:** PostgreSQL. SQLAlchemy creates the `ideas` table through an explicit initialization command; the API does not perform schema changes on startup.
- **Runtime:** Environment-based configuration, configurable browser origins, health checks, and no cloud-specific application dependencies.

## Repository structure

```text
backend/
  app/
    api/routes/       # Idea and health endpoints
    config.py         # Environment-backed settings
    database.py       # SQLAlchemy engine and session dependency
    init_db.py        # Explicit schema initialization
    models.py         # SQLAlchemy models
    schemas.py        # Pydantic request/response schemas
    main.py           # FastAPI application
  tests/              # Pytest API tests (SQLite test database)
  requirements.txt
frontend/
  src/
    api/              # HTTP client
    App.jsx           # Idea board UI
    styles.css
  package.json
  vite.config.js
.env.example
```

## Prerequisites

- Python 3.12 or newer
- Node.js 20 or newer and npm
- PostgreSQL 14 or newer, running locally or reachable over the network

## Environment configuration

Copy `.env.example` to `.env` in the repository root and set the PostgreSQL values. `.env` is ignored by Git.

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `POSTGRES_HOST` | No | `localhost` | PostgreSQL server host |
| `POSTGRES_PORT` | No | `5432` | PostgreSQL server port |
| `POSTGRES_DB` | No | `ideaboard` | Database name |
| `POSTGRES_USER` | No | `ideaboard` | Database user |
| `POSTGRES_PASSWORD` | Yes | — | Database password |
| `CORS_ORIGINS` | No | `http://localhost:5173` | Comma-separated allowed browser origins |
| `VITE_API_BASE_URL` | No | Empty | Frontend API origin; empty uses the Vite proxy in development |

Create the PostgreSQL database and user before initializing the schema. For example, from a PostgreSQL administrator session:

```sql
CREATE USER ideaboard WITH PASSWORD 'replace-with-a-local-password';
CREATE DATABASE ideaboard OWNER ideaboard;
```

## Local development

From the repository root, create and activate a virtual environment, then install backend dependencies:

```powershell
py -3.12 -m venv backend\.venv
backend\.venv\Scripts\Activate.ps1
python -m pip install -r backend\requirements.txt
```

Initialize the database and start the API:

```powershell
$env:PYTHONPATH = "backend"
python -m app.init_db
python -m uvicorn app.main:app --app-dir backend --reload
```

In another terminal, install frontend dependencies and start Vite:

```powershell
Set-Location frontend
npm install
npm run dev
```

Open <http://localhost:5173>. The Vite development server proxies `/api` and `/health` requests to `http://localhost:8000`. Configure `VITE_API_BASE_URL` at frontend build time to use another API origin.

## API

Interactive OpenAPI documentation is available at <http://localhost:8000/docs>.

| Method | Endpoint | Behavior |
| --- | --- | --- |
| `GET` | `/api/ideas` | Returns ideas, newest first |
| `POST` | `/api/ideas` | Creates an idea; returns `201 Created` |
| `GET` | `/health` | Checks database connectivity; returns `503` if unavailable |

Idea content is trimmed, must not be blank, and is limited to 1000 characters. Example:

```powershell
Invoke-RestMethod -Method Post `
  -Uri http://localhost:8000/api/ideas `
  -ContentType 'application/json' `
  -Body '{"content":"Make it easier to share ideas"}'

Invoke-RestMethod -Method Get -Uri http://localhost:8000/api/ideas
```

## Testing and build

Run backend tests from the repository root:

```powershell
$env:PYTHONPATH = "backend"
python -m pytest backend\tests
```

Build the frontend:

```powershell
Set-Location frontend
npm run build
```

Backend tests use an isolated in-memory SQLite database and do not require a running PostgreSQL server. The PostgreSQL health check and live API/database behavior require a configured PostgreSQL instance.

## Implementation status

Implemented: idea creation and listing, input validation, PostgreSQL persistence, database connectivity health check, configurable CORS/API URL, structured backend logs, API documentation, frontend loading/empty/error/success states, and backend API tests.

Not implemented in this phase: Dockerfiles/Compose, Kubernetes, Helm, Terraform, CI/CD, AI deployment risk analysis, monitoring integrations, authentication, and automated database migrations.

## Next planned engineering phase

Add Dockerfiles and a Docker Compose setup for the frontend, API, and persistent PostgreSQL service, with health-based service readiness. No infrastructure or deployment resources are included in this application-foundation phase.

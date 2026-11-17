# IdeaBoard Platform

IdeaBoard is a focused idea-sharing application: users can submit ideas and retrieve the persisted board. The application foundation and a Docker Compose deployment are implemented with a React frontend, FastAPI backend, and PostgreSQL.

## Architecture

- **Frontend:** React 18, Vite, JavaScript, and Tailwind CSS. The UI calls the REST API through a small, separate API client.
- **Backend:** Python 3.12+, FastAPI, Pydantic, SQLAlchemy 2, and psycopg 3.
- **Database:** PostgreSQL. SQLAlchemy creates the `ideas` table through an explicit initialization command; the API does not perform schema changes on startup.
- **Runtime:** Environment-based configuration, configurable browser origins, health checks, and no cloud-specific application dependencies.
- **Container deployment:** Multi-stage frontend/backend image builds, an unprivileged Nginx reverse proxy, a one-shot database initializer, private service networks, and a persistent PostgreSQL volume.

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
  Dockerfile          # Vite build and unprivileged Nginx runtime
  nginx.conf          # Static hosting and API reverse proxy
  src/
    api/              # HTTP client
    App.jsx           # Idea board UI
    styles.css
  package.json
  package-lock.json
  vite.config.js
compose.yaml
.env.example
```

## Prerequisites

- Python 3.12 or newer
- Node.js 20 or newer and npm
- PostgreSQL 14 or newer for host-based development (Compose provides PostgreSQL)
- Docker Desktop or Docker Engine with the Compose v2 plugin (for containerized operation)

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
| `APP_PORT` | No | `8080` | Host loopback port for the Compose frontend |

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

## Docker Compose

Docker Compose runs PostgreSQL, the API, a one-shot schema initializer, and the Nginx-served frontend. Only the frontend is published to the host, bound to loopback; the API and database have no host port mappings. The frontend reverse-proxies `/api/`, `/health`, `/docs`, and `/openapi.json` to the backend over a private application network. PostgreSQL is reachable only from the backend over a separate private network.

1. Copy `.env.example` to `.env` in the repository root and replace `POSTGRES_PASSWORD` with a strong local password. Do not commit `.env`.
2. From the repository root, build and start the services:

   ```powershell
   docker compose up --build -d
   docker compose ps
   ```

   Compose waits for PostgreSQL to become healthy, runs the existing `python -m app.init_db` process once, and waits for the backend health check before starting the frontend.
3. Open <http://localhost:8080>. The port is bound to `127.0.0.1`; set `APP_PORT` in `.env` to choose another local port.

Compose overrides `POSTGRES_HOST` and `POSTGRES_PORT` for the application containers to use the private `db:5432` address. If a password contains a dollar sign, quote its value with single quotes in `.env` so Compose treats it literally.

Use the same REST API through the reverse proxy:

```powershell
Invoke-RestMethod -Method Post `
  -Uri http://localhost:8080/api/ideas `
  -ContentType 'application/json' `
  -Body '{"content":"Make it easier to share ideas"}'

Invoke-RestMethod -Method Get -Uri http://localhost:8080/api/ideas
Invoke-RestMethod -Method Get -Uri http://localhost:8080/health
```

Inspect service logs with `docker compose logs -f`. Stop the services with `docker compose down`; the named `postgres-data` volume is retained across container recreation. **This volume contains persisted ideas.** Remove it only when intentionally deleting local data with `docker compose down --volumes`.

The backend and frontend images run as non-root users. The backend has a read-only root filesystem and dropped Linux capabilities; the frontend uses the unprivileged Nginx image. Container health checks gate service startup. To apply a changed application schema in this phase, update the existing SQLAlchemy models and initializer; this setup does not add a separate migration framework.

## API

Interactive OpenAPI documentation is available at <http://localhost:8080/docs> with Compose, or <http://localhost:8000/docs> when running the backend directly.

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

Implemented: idea creation and listing, input validation, PostgreSQL persistence, database connectivity health check, configurable CORS/API URL, structured backend logs, API documentation, frontend loading/empty/error/success states, backend API tests, multi-stage Dockerfiles, unprivileged Nginx reverse proxy, Compose health checks, and persistent database storage.

Not implemented: Kubernetes, Helm, Terraform, CI/CD, AI deployment risk analysis, monitoring integrations, authentication, and automated database migrations.

## Next planned engineering phase

Add automated CI/CD and container image vulnerability scanning. Kubernetes, Helm, Terraform, and cloud deployment remain separate future phases.

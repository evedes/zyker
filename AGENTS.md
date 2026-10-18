# zyker

Phoenix 1.8 app (`Zyker` / `ZykerWeb`) backed by PostgreSQL and SeaweedFS (S3 API).
Everything runs in containers for development; there is no host-side Elixir setup.

## Guidelines

Before writing Elixir, Phoenix, LiveView, Ecto or HEEx code, read
[PHOENIX_GUIDELINES.md](PHOENIX_GUIDELINES.md). This file wins where the two disagree.

## Dev environment

- `cp .env.example .env` once. `.env` is gitignored; `.env.example` is the committed template.
  Add any new compose variable to both.
- `bin/dev` wraps `docker compose -f docker-compose-dev.yaml` and refuses to run without `.env`:
  `bin/dev up -d --build`, `bin/dev logs -f app`, `bin/dev down`.
- Run Mix inside the app container, not on the host: `bin/dev exec app mix <task>`.
  Source is bind-mounted, so edits reload live; `deps` and `_build` live in named volumes.

| Service     | In the compose network     | From the host                                   |
|-------------|----------------------------|-------------------------------------------------|
| `app`       | `app:4000`                 | `127.0.0.1:$APP_PORT`                           |
| `db`        | `db:5432`                  | `127.0.0.1:$DB_PORT`                            |
| `seaweedfs` | `http://seaweedfs:8333` (S3) | `127.0.0.1:$S3_PORT`, master/filer UIs on their ports |

The app reads its DB settings from `DATABASE_*` and S3 settings from `S3_*` env vars
(see `docker-compose-dev.yaml`). No S3 client library is wired in yet.

## Before committing

Run `bin/dev exec app mix precommit` (warnings as errors, unused deps, format, tests)
and fix anything it reports.

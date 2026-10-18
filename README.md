# zyker

Phoenix app with PostgreSQL and SeaweedFS, all containerized for development.

## Dev

    cp .env.example .env   # once; adapt ports/credentials to your environment
    bin/dev up -d --build

`bin/dev` wraps `docker compose -f docker-compose-dev.yaml` and stops early if
`.env` is missing. Any compose arguments work: `bin/dev logs -f app`, `bin/dev down`.

| Service   | Host address (default ports)     | Configured by                                  |
|-----------|----------------------------------|------------------------------------------------|
| app       | http://127.0.0.1:4000            | `APP_PORT`                                     |
| db        | 127.0.0.1:5439                   | `DB_PORT`, `POSTGRES_*`                        |
| seaweedfs | http://127.0.0.1:8333 (S3 API)   | `S3_PORT`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY` |
|           | http://127.0.0.1:9333, :8888     | `SEAWEEDFS_MASTER_PORT`, `SEAWEEDFS_FILER_PORT` |

Source is bind-mounted into the app container; `deps` and `_build` live in named volumes.

Run tests inside the container:

    bin/dev exec -e MIX_ENV=test app mix test

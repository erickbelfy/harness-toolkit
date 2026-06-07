# Python Backend Project Layout

A conventional `src/` layout for a FastAPI service. Adapt names to the project.

```
myservice/
├── pyproject.toml          # deps, tool config (ruff, mypy, pytest)
├── uv.lock                 # or poetry.lock — pinned, committed
├── README.md
├── src/
│   └── myservice/
│       ├── __init__.py
│       ├── main.py         # app factory / ASGI entrypoint
│       ├── api/            # routers (HTTP boundary)
│       │   └── v1/
│       ├── schemas/        # pydantic request/response models (API contracts)
│       ├── models/         # ORM models (persistence) — kept separate from schemas
│       ├── services/       # business logic (framework-free)
│       ├── repositories/   # data access
│       ├── core/           # config, logging, security, dependencies
│       └── db/             # session, migrations (alembic/)
└── tests/
    ├── conftest.py         # fixtures (client, db, factories)
    ├── unit/
    └── integration/
```

## Principles
- **Boundary vs core**: `api/` and `db/` are edges; `services/` holds
  framework-free policy. Dependencies point inward.
- **Schemas ≠ models**: API contracts (`schemas/`) are separate from ORM
  (`models/`) so persistence changes don't leak into the API.
- **Config in `core/`**: a single typed settings object (pydantic-settings)
  reading from the environment; no scattered `os.environ` access.
- **Tests mirror src**: unit tests for services, integration tests through the
  HTTP/repository boundary with real or containerized dependencies.

## pyproject.toml essentials
```toml
[tool.ruff]
line-length = 100
[tool.mypy]
strict = true
[tool.pytest.ini_options]
addopts = "-q"
testpaths = ["tests"]
```

---
name: backend-python
description: Build production-quality Python backends. Use when writing or modifying Python services, APIs, data access, or background jobs. Covers project layout, typing, async, API design, data/transactions, error handling, security, testing, and performance for Python server code.
license: MIT
metadata:
  discipline: backend
  language: python
  reference: addyosmani/agent-skills/source-driven-development,test-driven-development,security-and-hardening
---
# Backend Engineering (Python)

Write Python services that are typed, tested, observable, and secure. Prefer the
standard, boring tools and let types and tests carry the correctness load.

## When to use
- Building or changing Python APIs, services, workers, or data access.
- Designing request/response models, persistence, or background jobs.
- Hardening, testing, or profiling Python server code.

## Core practices

### Project & tooling
- Use a `src/` layout, `pyproject.toml`, and a single resolver/runner (uv or
  Poetry). Pin dependencies; separate dev/prod extras. Layout: `references/project-layout.md`.
- Format/lint/type with **ruff** + **mypy** (or pyright) in strict mode; wire
  them into CI and pre-commit.
- Target a current Python (3.11+); use `from __future__ import annotations` only
  when needed.

### Typing & modeling
- Type all public functions and data boundaries; avoid `Any`.
- Use **pydantic** (or dataclasses) for validated request/response and config
  models; keep ORM models separate from API schemas (input/output separation).
- Make illegal states unrepresentable with enums and discriminated unions.

### API design
- Prefer **FastAPI** for new HTTP services; declare explicit response models and
  status codes. Validate input at the boundary; never trust client data.
- Consistent error envelope and status-code mapping across endpoints.
- Version the API; extend with optional fields rather than breaking changes.

### Async & concurrency
- Don't block the event loop — no sync IO in async paths; use async drivers or a
  thread/executor for unavoidable blocking calls.
- Bound concurrency (semaphores, pools); set timeouts on every network call.
- Make handlers idempotent where retries are possible.

### Data & transactions
- Keep transactions short; one unit of work per request. Use explicit isolation
  where it matters. Migrations are forward-only and reviewed (Alembic).
- Never build SQL by string concatenation — parameterize or use the ORM.
- Avoid N+1 queries; load what you need explicitly.

### Errors, logging, observability
- Raise specific exceptions; map them to responses at the edge. Don't swallow.
- Structured logging (JSON) with correlation/request ids; no secrets in logs.
- Add metrics and traces for hot paths and external calls.

### Security
- Validate and normalize all external input; enforce authz on every endpoint.
- Secrets from environment/secret manager, never in code or logs.
- Hash passwords with a strong KDF; use parameterized queries; set timeouts and
  size limits to resist abuse.

### Testing
- **TDD** for logic and bug fixes (red-green-refactor; reproduce bugs first).
- pytest with fixtures; test at the boundary (HTTP/repository), mock only true
  externals. Keep the suite fast and deterministic.

### Performance
- Measure before optimizing (profile, don't guess). Cache deliberately with clear
  invalidation. Use connection pooling; batch IO.

## Red flags
- Untyped boundaries or pervasive `Any`; ORM models reused as API schemas.
- Blocking calls in async code; missing timeouts; unbounded concurrency.
- String-built SQL; secrets in code/logs; endpoints without authz.
- Broad `except:` that swallows errors; no tests for new logic.

## Verification checklist
- [ ] ruff + mypy (strict) clean; formatted.
- [ ] Public boundaries typed; input validated with pydantic models.
- [ ] Endpoints have explicit response models, status codes, and authz.
- [ ] No blocking IO in async paths; all network calls have timeouts.
- [ ] SQL parameterized; transactions short; migrations forward-only.
- [ ] Tests cover new logic and reproduce fixed bugs; suite is fast.
- [ ] No secrets in code/logs; structured logging in place.

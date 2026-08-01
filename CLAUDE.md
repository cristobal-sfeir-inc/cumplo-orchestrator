# cumplo-orchestrator

## Overview
FastAPI service that acts as the central coordination hub for the Cumplo API. Receives Pub/Sub
messages with available funding requests and fans them out to each user's configured notification
channels by publishing per-user events downstream.

Deployed as a Cloud Run service. Consumed by downstream services (herald, spotter, tailor) via
Pub/Sub. Depends on `cumplo-common` for shared domain models, Firestore client, and Pub/Sub
middleware.

## Build & Run
- Install deps: `poetry install`
- Start locally: `make start` (docker-compose)
- Stop: `make down`
- Build image: `make build`

Python 3.13, FastAPI, Gunicorn + Uvicorn workers, Poetry 2.4.x.

## Code Quality
- Auto-fix lint + format: `make format`
- Verify (CI gate): `make lint`

Both commands run inside the Poetry virtualenv. `make lint` runs four checks in sequence:
`ruff check`, `ruff format --check`, `basedpyright`, `docformatter --check`. A failure in any
step exits non-zero and blocks the PR.

`make format` is auto-fix only — run it before committing. After format, run `make lint` to
confirm the CI gate passes cleanly before pushing.

## Tooling Config (pyproject.toml)
- **Ruff** `select = ["ALL"]` with line length 120, target Python 3.13, preview mode.
  FAST002 and B008 are ignored (FastAPI `Depends()` patterns).
- **basedpyright** `typeCheckingMode = "standard"`, Python 3.13.
- **docformatter** wraps summaries and descriptions at 120 chars; `pre-summary-newline = true`.

## GitHub Actions
`.github/workflows/lint.yml` runs `make lint` on every PR. The job authenticates to Artifact
Registry with WIF (`vars.WIF_PROVIDER` + `vars.READER_SA` set at org level) so that
`poetry install` can pull `cumplo-common` from the private registry.

## Gotchas
- **`cumplo-common` blast radius.** This service depends on every release of `cumplo-common`.
  A breaking change there breaks this service. After updating `cumplo-common`, run
  `make update_common` to refresh the lock and venv, then retest.
- **Async exception handlers.** FastAPI exception handlers must be `async` even if they don't
  await anything. The `# noqa: RUF029` on `_validation_error_handler` suppresses the
  "unnecessary async" rule intentionally.
- **No tests yet.** Test coverage is thin. Add tests alongside any logic changes.

## Before Committing
- [ ] Run `make format`, then `make lint` — confirm it passes with zero violations.
- [ ] No secrets or credential files committed.
- [ ] If touching `cumplo-common` version, bump pyproject.toml and run `make update_common`.

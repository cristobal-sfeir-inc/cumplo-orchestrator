# cumplo-orchestrator

## Overview
Centralized coordination service that fans out available funding requests to all registered
users via Pub/Sub. Receives a Pub/Sub-wrapped payload from `cumplo-spotter`, iterates over
users stored in Firestore, and publishes a per-user `FUNDING_REQUEST_FILTER` event so
downstream services (herald, tailor, …) can act on it.

## Build & Run
- Install deps: `poetry install`
- Start locally: `make start` (Docker Compose)
- Build image: `make build`

## Code Quality
- Auto-fix lint + format: `make format`
- Verify code quality (CI gate): `make lint`

Python 3.13, Poetry. The lint gate runs Ruff, basedpyright, and docformatter — all must pass
clean before opening a PR.

## CI/CD
`.github/workflows/lint.yml` runs `make lint` on every PR and push to `master`. Cloud Build
deploys to Cloud Run on merge to `master` (no test step in Cloud Build — lint is the gate).

## Git workflow
- Branch prefixes: `feat/`, `fix/`, `chore/`, `ci/`. Conventional-commit subjects.
- `master` is protected: every change requires a PR + code-owner review (`@cnsfeir-reviewer`).
  **Never push directly to `master`.**

## Architecture notes
- Pub/Sub messages are unwrapped by `PubSubMiddleware` (from `cumplo-common`) before reaching
  the router; the handler receives the decoded payload directly.
- `firestore.client.users.list()` returns all users; users with no channels are skipped.
- `CloudPubSub.publish` fans out one message per user.

## Gotchas
- **`cumplo-common` blast radius.** This service depends on `cumplo-common`. Any breaking
  change there requires a coordinated bump here.
- **`IS_TESTING` flag.** Set `IS_TESTING=1` in the environment to use `basicConfig` logging
  instead of Cloud Logging (avoids needing GCP credentials locally).
- **`cumplo-pypi-credentials.json`** is gitignored; required only for local `make build` to
  pull the private package. CI uses Workload Identity Federation instead.

## Before committing
- [ ] Run `make format`, then `make lint` and ensure it passes.
- [ ] No secrets or credential files committed.

# Contributing to English Brain

Thanks for your interest in English Brain! This is a self-hosted, privacy-first
project, so contributions that keep it **local, robust and offline-capable** are
especially welcome.

## Ground rules

- Be respectful — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
- **Never commit secrets.** No real domains, API keys, internal IPs, SSH targets
  or `.env` files. Every script and compose file reads its values from
  environment variables with placeholder defaults (`TU_NAS_IP`,
  `ingles.tudominio.dev`, `CHANGE_ME_api_key`). Keep it that way.
- Keep the three blocks decoupled: `app/` (Flutter), `backend/` (FastAPI) and
  `nas/` (infrastructure) should not leak into each other.

## Getting set up

1. Fork and clone the repo.
2. Backend: `pip install -r backend/requirements.txt` then `pytest backend/tests -v`.
3. App: `cd app && flutter pub get && flutter run -d chrome`.
4. Full stack: copy `nas/.env.example` to `nas/.env`, fill in your own values,
   and `docker compose up -d` from `nas/`.

## Workflow

1. Create a branch: `git checkout -b feat/short-description`.
2. Make focused commits with clear messages.
3. Run the checks before opening a PR:
   - `make test` (backend + app), or `pytest backend/tests -v` and `cd app && flutter test`.
   - `cd app && dart analyze` — no new analyzer warnings.
4. Open a Pull Request describing **what** changed and **why**. Link any issue.

## Coding style

- **Dart / Flutter:** follow `flutter_lints`; keep widgets small and features
  under `app/lib/features/<feature>/`. State via Riverpod, persistence via Drift.
- **Python / FastAPI:** type hints, small routers under `backend/app/routers/`,
  providers under `backend/app/providers/`. New AI calls go through the provider
  router so graceful degradation keeps working.
- Add or update tests for behavior changes.
- Add or update the relevant doc under `docs/` when you change architecture.

## Reporting bugs & ideas

Open an issue with steps to reproduce (and platform: Android / Web / Windows).
For anything security-related, follow [SECURITY.md](SECURITY.md) instead of a
public issue.

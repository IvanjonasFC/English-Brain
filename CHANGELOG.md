# Changelog

All notable changes to English Brain are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the app follows
`versionName+versionCode` from `pubspec.yaml`.

## [Unreleased]

### Added
- Open-source governance: `LICENSE` (MIT), `CONTRIBUTING.md`, `SECURITY.md`,
  `CODE_OF_CONDUCT.md`, `NOTICE` and this changelog.
- Rewritten, badge-rich English `README.md` with architecture diagram and
  cover art.

### Changed
- **Repository sanitized for public release.** All scripts, `docker-compose.yml`
  and docs now read `BASE_URL`, `API_KEY`, `JWT_SECRET`, IPs and SSH targets from
  environment variables with placeholder defaults — no real domain, key or
  internal IP is committed.
- OTA flow now documented and run through the `shorebird` CLI (via `make
  shorebird-patch` / `make shorebird-release`) instead of Windows `.bat` wrappers.

### Removed
- **Repo trimmed to what's reproducible.** Dropped personal/host-specific helper
  scripts (`sync_nas.ps1`, `chequeo_65.bat`, `precarga_nas.*`, `build_apk.*`,
  `dev_run.bat`, `shorebird_*.bat`, `gestor_contenido.bat`, `_clean_empty.bat`),
  internal working notes (handoff/audit/review docs), personal tooling
  (`project-ai.json`, `Ingles.code-workspace`) and duplicates (root `Caddyfile`
  and `SHOREBIRD.md`; `app/shorebird_patch.bat`). The self-hosted stack lives in
  `nas/`, the GPU workers in `Portatil/`, and the content tooling in
  `cargar contenido/`.

## [1.0.1+4] — 2026-09

### Added
- **Streaming Free Talk.** New voice-first home: a single calm orb, tap-to-talk,
  live token-by-token replies over Server-Sent Events, with Kokoro TTS playback.
  Additive and bulletproofed with automatic fallback to the non-streaming path.
- SSE streaming endpoint on the backend (`/api/ai/free-talk/stream`) with a
  concurrency semaphore for multi-user safety.
- Caddy `flush_interval -1` so streamed responses reach the client immediately.

### Fixed
- Mobile audio capture: recorded audio is now read and sent correctly on Android
  (previously the send path dropped the file on device).

## [1.0.0] — 2026

### Added
- First self-hosted release: Flutter client (Android · Web · Windows), FastAPI
  orchestrator, Ollama + Speaches (Whisper/Kokoro) AI services on Docker.
- Spaced repetition with `py-fsrs`, offline seed content, pronunciation scoring
  (wav2vec2 + MFA), and Shorebird over-the-air updates.

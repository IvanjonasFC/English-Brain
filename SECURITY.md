# Security Policy

English Brain is a self-hosted application: you run the backend and AI services
on your own hardware, and you control exposure. Still, the code should never make
that harder. This policy covers the repository itself.

## Supported versions

The latest release on the `main` branch is the only supported version.

## What this repo guarantees

- **No secrets in the tree.** Scripts, `docker-compose.yml` and the Flutter build
  read `BASE_URL`, `API_KEY`, `JWT_SECRET`, IPs and SSH targets from environment
  variables with **placeholder** defaults. No real domain, key or internal IP is
  committed. `.env` is git-ignored; only `.env.example` (placeholders) ships.
- **Hardened edge (when deployed).** The bundled Caddy config sets HSTS,
  `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff` and a strict
  referrer policy. Remote access can be restricted to WireGuard.

## Hardening checklist for your own deployment

- Change **every** default: `API_KEY`, `JWT_SECRET`, and any sample credentials.
- Keep the AI box (Ollama / Speaches) on your LAN or VPN, not the public internet.
- Terminate TLS at Caddy; don't expose the FastAPI port directly.
- Rotate `API_KEY` if it was ever built into a distributed APK.

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Instead, report privately via GitHub Security Advisories
("Report a vulnerability" on the repo's **Security** tab), or contact the
maintainer through the profile at <https://github.com/IvanjonasFC>.

You'll get an acknowledgement as soon as possible, and credit in the release
notes once a fix ships (unless you prefer to stay anonymous).

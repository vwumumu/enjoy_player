# ADR-0026: Local production diagnostics (Phase 1)

## Status

Accepted

## Context

Release GUI builds (especially Windows) have no visible console. Support issues such as YouTube WebView stalls required custom debug builds. We need production-safe diagnostics without exposing Developer settings or uploading data by default.

## Decision

1. **Always-on local file sink** — redacted rotating logs under application support for all native builds.
2. **Opt-in verbose tier** — allowlisted loggers only (`YouTube*`, `sync`, `api`, `auth`, `update`); default off.
3. **User-initiated export** — Settings → About zip export (logs + manifest); no remote upload in Phase 1.
4. **Default-tier YouTube stall WARNING** — 30s after `load_stop` without `first_playing`.

## Consequences

- Support can ask users to export a zip instead of finding `%APPDATA%` paths.
- Redaction is mandatory at the file sink; call sites must still avoid logging secrets.
- Phase 2 may add optional upload to Enjoy API; this ADR does not commit to that design.

## Supersedes

None.

## Superseded by

None.

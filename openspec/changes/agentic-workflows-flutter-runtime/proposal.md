## Why

GitHub Agentic Workflows (`gh-aw`) in this repo cannot reliably run Flutter/Dart commands (`flutter analyze`, `flutter test`, `dart run build_runner build`) because the shared runtime component declares a non-functional `runtimes.flutter` entry that gh-aw ignores, and no deterministic setup steps install the SDK before the agent runs. Workflows like Test Improver and Repo Assist are therefore blocked from validating code the same way CI does, reducing the value of automation and causing failed or incomplete agent runs on the self-hosted `agentic` runner.

## What Changes

- Replace the ineffective `runtimes.flutter` block in `.github/workflows/shared/runtime.md` with **`pre-agent-steps`** that reuse existing CI tooling (`ensure_linux_tooling.sh`, `./.github/actions/setup-flutter`, `flutter pub get`).
- Add **`dart`** to merged network allowlists so agents can fetch packages from `pub.dev` / Flutter storage during runs.
- Add a **prompt body** to `shared/runtime.md` (via `runtime-import`) documenting CI-parity Flutter commands and project constraints from `AGENTS.md`.
- Ensure **all eight agentic workflows** import `shared/runtime.md` (five already do; add to `issue-triage`, `update-docs`, and `agentic-wiki-writer` for consistent runner setup and network baseline—even when Flutter is not invoked, setup is idempotent).
- **Recompile** all affected `.lock.yml` files with `gh aw compile --validate` and align gh-aw compiler version with repo lock metadata where practical.
- Document the **`agentic` self-hosted runner** checklist in `docs/ci-self-hosted-runners.md` (labels, Flutter pin, optional pre-install vs on-job setup).

## Capabilities

### New Capabilities

- `agentic-workflows-runtime`: Shared gh-aw runtime setup, network permissions, and agent prompt guidance so Flutter/Dart tooling is available and CI-equivalent commands work on the Linux `agentic` runner before agent execution.

### Modified Capabilities

<!-- None: no existing OpenSpec specs define gh-aw or CI agent behavior. -->

## Impact

- **Workflow sources**: `.github/workflows/shared/runtime.md`; imports in `issue-triage.md`, `update-docs.md`, `agentic-wiki-writer.md` (and verification of existing imports).
- **Generated lock files**: all `.github/workflows/*.lock.yml` touched by compile (test-improver, repo-assist, perf-improver, duplicate-code-detector, large-file-simplifier, issue-triage, update-docs, agentic-wiki-writer, plus maintenance/commands if regenerated).
- **Docs**: `docs/ci-self-hosted-runners.md` — new agentic runner section.
- **Infrastructure**: self-hosted Linux runner labeled `self-hosted`, `linux`, `agentic` (may share machine with CI `Linux` runner).
- **Out of scope**: macOS/Windows agentic jobs (unsupported by AWF); Android release builds inside agent sandbox; changing upstream `githubnext/agentics` workflow logic beyond local imports and shared components.

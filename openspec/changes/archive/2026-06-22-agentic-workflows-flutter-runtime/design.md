## Context

Enjoy Player uses **GitHub Agentic Workflows** (`gh-aw` v0.77.x lock files) on a **self-hosted Linux runner** tagged `[self-hosted, linux, agentic]`. Eight markdown workflows drive automation (test-improver, repo-assist, perf-improver, duplicate-code-detector, large-file-simplifier, issue-triage, update-docs, agentic-wiki-writer).

Deterministic CI ([`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml)) already installs Flutter via [`.github/actions/setup-flutter`](../../../.github/actions/setup-flutter) (pinned by [`.github/flutter-version`](../../../.github/flutter-version)) and Linux packages via [`ensure_linux_tooling.sh`](../../../.github/scripts/ensure_linux_tooling.sh).

The shared gh-aw component [`.github/workflows/shared/runtime.md`](../../../.github/workflows/shared/runtime.md) currently declares:

```yaml
runtimes:
  flutter:
    action-repo: "flutter-actions/setup-flutter"
```

**gh-aw does not support arbitrary `runtimes.*` IDs.** Only known runtimes (node, python, go, …) are compiled into setup steps. Unknown IDs—even with `action-repo`—are skipped. Compiled `.lock.yml` files contain no Flutter setup. Agents that run `flutter test` therefore depend on accidental runner state or fail.

Agent execution runs inside the **Agent Workflow Firewall (AWF)** sandbox on Linux only; host `PATH` (including Flutter from pre-agent steps) is forwarded into the container.

## Goals / Non-Goals

**Goals:**

- Every agentic workflow job MUST have Flutter/Dart available on the `agentic` runner before the AI engine starts, using the same pin and setup action as CI.
- Shared configuration MUST live in one importable component (`shared/runtime.md`) to avoid drift across eight workflows.
- Network egress MUST allow Dart/Flutter package fetches (`dart` ecosystem identifier).
- Agent prompts MUST document CI-parity commands and hard rules from `AGENTS.md`.
- Recompiled lock files MUST pass `gh aw compile --validate`.

**Non-Goals:**

- Adding Flutter to macOS/Windows agentic jobs (AWF does not support those runners).
- Running Android/iOS release or signing inside agent workflows.
- Upstreaming changes to `githubnext/agentics` template repos (local `imports` and shared components only).
- Pre-installing Flutter on the runner *instead of* job setup (optional optimization documented, not required).

## Decisions

### 1. Use `pre-agent-steps`, not `runtimes.flutter`

**Decision:** Remove `runtimes.flutter` and install Flutter via `pre-agent-steps` in `shared/runtime.md`.

**Rationale:** gh-aw’s compiler only emits setup steps for [known runtime IDs](https://github.github.com/gh-aw/reference/frontmatter/). `pre-agent-steps` run on the host runner after checkout, outside AWF, and can invoke the repo’s composite action.

**Alternatives considered:**

| Alternative | Rejected because |
|-------------|------------------|
| Keep `runtimes.flutter` + external action | Compiler ignores unknown runtime IDs; wrong action repo |
| Pre-install Flutter only on runner | Version pin drift when `.github/flutter-version` bumps; harder to reproduce |
| `steps:` in pre-activation job | Runs before agent checkout context; wrong lifecycle |
| `pre-steps:` at job start | Runs before checkout; cannot read `.github/flutter-version` from repo |

**Steps (merged via import):**

```yaml
pre-agent-steps:
  - name: Ensure Linux tooling
    run: bash .github/scripts/ensure_linux_tooling.sh
  - uses: ./.github/actions/setup-flutter
  - name: Flutter pub get
    run: flutter pub get
  - name: Verify Flutter toolchain
    run: flutter --version && dart --version
```

### 2. Centralize in `shared/runtime.md` + universal import

**Decision:** All eight agentic workflows import `shared/runtime.md` (add to the three that currently only import `engine-minimax.md`).

**Rationale:** Import merge applies `pre-agent-steps`, `network`, and prompt injection consistently. Setup is idempotent; cost on non-Flutter workflows (issue-triage) is acceptable (~1–2 min amortized on warm runners).

**Alternative:** Import runtime only on Flutter-heavy workflows → rejected to keep one runner baseline and simplify ops docs.

### 3. Network: add `dart` ecosystem

**Decision:** Add `dart` under `network.allowed` in `shared/runtime.md` (merged into workflows that declare broader allowlists).

**Rationale:** [gh-aw network docs](https://github.github.com/gh-aw/reference/network/) map `dart` to `pub.dev` and `storage.googleapis.com` (Flutter SDK/archives). Without it, `flutter pub get` fails in AWF.

Workflows with explicit multi-ecosystem lists (test-improver, repo-assist, etc.) inherit merged `dart` from the import; no per-workflow duplication required unless they override `network` entirely (they use list merge via imports).

### 4. Agent prompt body in `runtime.md`

**Decision:** Add markdown after frontmatter documenting:

- Commands mirroring CI: `flutter analyze`, `flutter test`, `dart format`, `dart run build_runner build`
- Read `AGENTS.md`; no web target; single `media_kit` player rule
- Flutter version source: `.github/flutter-version`

**Rationale:** `{{#runtime-import shared/runtime.md}}` injects body into compiled prompts; frontmatter alone does not guide the agent.

### 5. Lock file regeneration

**Decision:** Run `gh aw compile --validate` for all workflow `.md` sources and commit updated `.lock.yml` files.

**Rationale:** gh-aw requires lock files for execution; frontmatter-only edits have no effect until compile.

**Note:** Local CLI may be newer than embedded compiler version in locks (v0.77.5 → v0.79.x); compile may bump metadata—acceptable if validation passes.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Pre-agent Flutter setup adds ~1–3 min per run on cold runners | Runner disk cache via `setup-flutter` (same as CI); document optional pre-install |
| `flutter pub get` fails offline / firewall | Ensure `dart` in network; verify with `gh aw audit` on a test run |
| Import merge order places steps incorrectly | gh-aw merges imported `pre-agent-steps` before workflow-local steps; keep all setup in shared file |
| Workflows without runtime import still broken | Add import to issue-triage, update-docs, agentic-wiki-writer |
| gh-aw upgrade changes pre-agent ordering | Pin compile in CI/docs; re-run compile after gh-aw bumps |
| Agent runs Android/desktop builds | Document in prompt: Linux analyze/test only |

## Migration Plan

1. Update `shared/runtime.md` (frontmatter + body).
2. Add `imports: - shared/runtime.md` to three workflows missing it.
3. Run `gh aw compile --validate` locally.
4. Smoke-test: `gh aw run test-improver --ref main` (or branch) and confirm pre-agent steps show Flutter setup in logs.
5. Update `docs/ci-self-hosted-runners.md` with agentic runner section.
6. Rollback: revert `runtime.md`, imports, and lock files; no app code changes.

## Open Questions

- **Single runner vs dedicated `agentic` machine:** Proposal assumes same Linux host can carry both `Linux` and `agentic` labels; if isolated, duplicate Flutter install path is fine (tool cache per user).
- **gh-aw version bump:** Whether to run `gh aw fix --write` in same change or follow-up PR—implementation can decide based on diff size.

## 1. Shared runtime component

- [x] 1.1 Replace `runtimes.flutter` in `.github/workflows/shared/runtime.md` with `pre-agent-steps` (ensure_linux_tooling → setup-flutter → flutter pub get → verify)
- [x] 1.2 Add `network.allowed` including `dart` in `shared/runtime.md` frontmatter (preserve merge with workflow-specific network lists)
- [x] 1.3 Add markdown body to `shared/runtime.md` with CI-parity Flutter/Dart commands and pointers to `AGENTS.md` / `.github/flutter-version`

## 2. Workflow imports

- [x] 2.1 Add `shared/runtime.md` to `imports` in `.github/workflows/issue-triage.md`
- [x] 2.2 Add `shared/runtime.md` to `imports` in `.github/workflows/update-docs.md`
- [x] 2.3 Add `shared/runtime.md` to `imports` in `.github/workflows/agentic-wiki-writer.md`
- [x] 2.4 Confirm five existing workflows (test-improver, repo-assist, perf-improver, duplicate-code-detector, large-file-simplifier) still import `shared/runtime.md` with no duplicate local Flutter setup

## 3. Compile and validate lock files

- [x] 3.1 Run `gh aw compile --validate` for all agentic workflow sources
- [x] 3.2 Inspect generated `.lock.yml` files for pre-agent Flutter setup steps and `dart` in firewall allowlists where applicable
- [ ] 3.3 Commit updated `.lock.yml` files (and `.github/aw/actions-lock.json` if compile updates it)

## 4. Documentation and runner ops

- [x] 4.1 Extend `docs/ci-self-hosted-runners.md` with an **Agentic workflows** section (`agentic` label, Flutter pin, relationship to CI Linux runner)
- [x] 4.2 Note in docs that agentic Flutter scope is Linux analyze/test only (no AWF on macOS/Windows)

## 5. Verification

- [ ] 5.1 Trigger a smoke run: `gh aw run test-improver --ref <branch>` and confirm pre-agent steps succeed in Actions logs
- [ ] 5.2 Confirm agent can run `flutter analyze` / `flutter test` (or that pre-agent `flutter pub get` completes without network blocks via `gh aw audit` if run fails)

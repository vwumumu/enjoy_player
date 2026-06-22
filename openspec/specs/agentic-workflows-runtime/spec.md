# agentic-workflows-runtime Specification

## Purpose
TBD - created by archiving change agentic-workflows-flutter-runtime. Update Purpose after archive.
## Requirements
### Requirement: Shared Flutter pre-agent setup

The repository SHALL define Flutter/Dart toolchain installation for gh-aw agent jobs in `.github/workflows/shared/runtime.md` using `pre-agent-steps` that invoke `.github/scripts/ensure_linux_tooling.sh`, `.github/actions/setup-flutter`, and `flutter pub get`, matching the Flutter version pin in `.github/flutter-version`.

#### Scenario: Agent job starts on Linux agentic runner

- **WHEN** any agentic workflow that imports `shared/runtime.md` reaches the agent job
- **THEN** the compiled lock file MUST include pre-agent steps that install Linux build packages (if missing), install the pinned Flutter SDK, and run `flutter pub get` before the AI engine executes

#### Scenario: Flutter version pin changes

- **WHEN** `.github/flutter-version` is updated on the default branch
- **THEN** the next agentic workflow run MUST install the new pinned version via `setup-flutter` without editing individual workflow markdown files

### Requirement: Dart network access for agentic workflows

Shared runtime configuration SHALL allow the gh-aw `dart` network ecosystem identifier so agents can reach `pub.dev` and Flutter storage endpoints during package resolution.

#### Scenario: Agent runs flutter pub get inside AWF

- **WHEN** an agent or pre-agent step runs `flutter pub get` during a workflow with merged `network.allowed` including `dart`
- **THEN** network requests to Dart/Flutter package hosts MUST NOT be blocked by the Agent Workflow Firewall

### Requirement: Agent prompt documents CI-parity Flutter commands

The markdown body of `shared/runtime.md` SHALL document the canonical verification commands used in CI (`flutter analyze`, `flutter test`, `dart format`, `dart run build_runner build` when applicable) and reference project agent rules in `AGENTS.md`.

#### Scenario: Test-oriented agent selects verification commands

- **WHEN** an agentic workflow such as test-improver or repo-assist validates code changes
- **THEN** the compiled agent prompt MUST include instructions to use the same Flutter/Dart commands as `.github/workflows/ci.yml` rather than inventing alternate commands

### Requirement: All agentic workflows import shared runtime

Every gh-aw workflow markdown file under `.github/workflows/` that sets `runs-on` to include the `agentic` runner label SHALL import `shared/runtime.md` in its frontmatter `imports` list.

#### Scenario: Issue triage workflow runs

- **WHEN** the issue-triage agentic workflow is compiled and executed
- **THEN** it MUST merge `pre-agent-steps` and network settings from `shared/runtime.md` alongside its existing imports

#### Scenario: Workflows already importing runtime

- **WHEN** test-improver, repo-assist, perf-improver, duplicate-code-detector, or large-file-simplifier are recompiled after shared runtime changes
- **THEN** their lock files MUST reflect the updated shared pre-agent steps without requiring duplicate Flutter setup in each workflow file

### Requirement: Lock files regenerated after runtime changes

After modifying agentic workflow sources or `shared/runtime.md`, maintainers SHALL run `gh aw compile --validate` and commit the resulting `.lock.yml` updates before merging.

#### Scenario: Pull request changes shared runtime

- **WHEN** a pull request modifies `.github/workflows/shared/runtime.md` or agentic workflow imports
- **THEN** the pull request MUST include corresponding updates to generated `.lock.yml` files that pass gh-aw validation

### Requirement: Agentic runner documentation

Project documentation SHALL describe self-hosted runner requirements for the `agentic` label, including relationship to the CI Linux runner, Flutter pin file, and optional pre-installed SDK.

#### Scenario: Operator registers agentic runner

- **WHEN** a maintainer follows `docs/ci-self-hosted-runners.md` to configure runners
- **THEN** the document MUST explain labels `self-hosted`, `linux`, and `agentic` and how Flutter setup occurs during agentic jobs


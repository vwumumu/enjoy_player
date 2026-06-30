# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Dart ^3.12, Flutter stable 3.x or NEEDS CLARIFICATION]

**Primary Dependencies**: [e.g., Riverpod, Drift, media_kit, flutter_inappwebview or NEEDS CLARIFICATION]

**Storage**: [if applicable, e.g., Drift AppDatabase, secure storage, local files or N/A]

**Testing**: [e.g., flutter test, widget tests, integration harness or NEEDS CLARIFICATION]

**Target Platform**: [Android, iOS, macOS, Windows; no Flutter web unless ADR-approved]

**Project Type**: Flutter native mobile/desktop app

**Performance Goals**: [domain-specific, e.g., smooth 60 fps scrolling, no playback stalls, bounded import time or NEEDS CLARIFICATION]

**Constraints**: [domain-specific, e.g., local-first, no UI-isolate heavy work, offline-capable or NEEDS CLARIFICATION]

**Scale/Scope**: [domain-specific, e.g., library size, transcript length, recording count, platform count or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Architecture and Code Quality

- Confirm affected code stays in `lib/features/<feature>/{application,data,domain,presentation}`,
  `lib/core`, or `lib/data` as appropriate.
- Confirm domain models remain UI-free and persistence flows through Drift DAOs.
- Confirm Riverpod is used for app state and no new mutable global singleton is introduced.
- Confirm no `print()` calls and no direct `media_kit` `Player()` outside the player engine/controller.

### II. Testing Defines the Contract

- List automated tests required for changed behavior, including unit, widget, integration,
  repository, DAO, parser, or notifier coverage as applicable.
- If a relevant behavior cannot be automated, document the manual verification and the reason.
- Include `dart run build_runner build` when Drift or Riverpod annotations change.

### III. User Experience Consistency

- Confirm user-facing strings use ARB localization.
- Confirm tappable controls, haptics, tooltips, and keyboard affordances follow shared UI patterns.
- Identify the `docs/features/` page that will be updated for user-visible behavior.

### IV. Performance Is a Requirement

- State the performance budget or expected evidence for playback, startup, scrolling,
  transcript rendering, sync, media import, or any other affected user-visible flow.
- Confirm expensive file, image, database, transcript, or audio work is cached, streamed,
  paged, debounced, or moved off the main isolate where needed.

### V. Documentation and Traceability

- Identify required ADR, feature documentation, runbook, or agent guidance updates.
- Record any constitution exception with principle, reason, risk, and follow-up owner.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
lib/
├── features/[feature]/
│   ├── application/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── core/
└── data/

test/
├── features/[feature]/
├── data/
└── widget_test.dart

integration_test/
└── [feature]_test.dart

docs/
├── features/[feature].md
└── decisions/[ADR-number]-[short-title].md
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-frontend-phase-directories
closure_kind: completed
input_sha256: e23b2077fe751df03284d9a6bfda44b7185e927c0365db5d1ec232581a942ff6
captured_at: 2026-09-12T04:48:10+00:00
---

# Terminal workflow evaluation

## Lifecycle

- Created from the approved `frontend-layout` draft.
- Moved reconstructed frontend leaves into `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}/`, aligned implementation stems with headers, rewrote live includes, and retargeted live path citations.
- `as_dependency_graph.*` was unlisted in the original folder-map and placed in `Compile/` (`Naming assumed`).

## Verification

- Task 1.1 GREEN: Harness `ue.build` `AngelscriptProjectEditor` RunId `196f9e5ffcc74c4fa21bfb1e0c2495e1` (exit 0). Cases 1–5 held on the tree; `asCParser` / `asCSema` names unchanged.
- Task 1.2 GREEN: `openspec.validate angelscript/refactor-frontend-phase-directories --type change --strict --json` Succeeded (Harness runId `06bfdf05739443e69502e531669ecdd8`). Live knowledge cites `#include "frontend/<Phase>/as_*.h"`.
- Strict change validation still Succeeded after spec sync and knowledge promotion (Harness runId `933af044a1bd4061b32ce0a29d981bdc`).
- Affected current spec `angelscript/language/ast/core` still fails strict validation on unspecified scenarios (four-space indent findings). Those are pre-existing baseline formatting failures; the synced scenario "Include the reconstructed language headers" has no spec-validator errors. This Change does not migrate the rest of that record.

## Material friction and corrective action

- An empty untracked leftover tree `openspec/changes/angelscript/test-lexer-isolated-coverage-candidate` blocked `openspec.validate` with 11 `OS-UNREGISTERED-DOMAIN` errors. It contained 0 files and was removed so `load_strict` could run.

## Spec and knowledge disposition

Durable include-path delta was merged into `openspec/specs/angelscript/language/ast/core/spec.md`. Change-local `frontend-phase-directories.md` and `impl-stem-matches-header.md` are promoted to `openspec/specs/angelscript/language/ast/core/knowledges/`. `first-party-sdk-root.md` was updated in place to the phased include contract.

## Scope boundary and provenance

Harness Quick, Performance, Integration, and Automation suites were omitted: include-path and layout change only. Raw Unreal runs remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`. This Change ID is not a reusable Harness gate default fixture.

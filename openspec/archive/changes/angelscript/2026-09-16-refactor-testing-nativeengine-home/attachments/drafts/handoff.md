# Handoff

Source identity: angelscript/newversion-retirement, selected design nativeengine-test-home. Approved 2026-09-15. This English export is the curated handoff, not the discussion transcript.

## Problem

`NewVersion/` is a temporary physical shell that still holds four tenants: NativeEngine, Bindings, Framework, and Baseline. Lexer already lives at `AngelscriptTest/NativeEngine/Lexer/`. Most public identities are flat, so Harness cannot select one proof layer. There is no Parser unit tree. The language execution matrix (operators, `+=`, omitted for clauses, `N::F()`, inherited dispatch) is thin. The accepted work retires the shell, recuts by theme/layer, and completes that coverage.

## Success Criteria

1. `NewVersion/` is no longer a source root.
2. The four tenants have module-root homes; NativeEngine folders and TestDir tokens match.
3. `ue.test Angelscript.UnitTest.NativeEngine.<Layer>` runs only that layer.
4. Parser's three classes run independently; every matrix axis has positive, boundary, and rejection cases; positive expressions use runtime inputs.
5. Bindings, Framework, and Baseline public prefixes stay unchanged; the legacy gate stays off.

## Evidence

Inventory and tenant map: [current-layout.md](findings/current-layout.md). Gaps: [coverage-gaps.md](findings/coverage-gaps.md). Target folders: [target-taxonomy.md](findings/target-taxonomy.md). Durable baseline already allows module-root `NativeEngine/` and forbids `NewVersion` in public names (`openspec/specs/angelscript/testing/baseline`).

## Scope and Exclusions

In: relocate, recut, nest identities, rewrite includes/skill/spec paths, Parser unit tree, language core matrix through VM.

Out: production frontend, implementing the unified-framework Change, TestCode corpus rewrites, Bindings expansion, JIT, Legacy mapping, productizing foreach, per-opcode source suites.

## Constraints

Replacement gate on, legacy gate off. CQTest forbids `Layer.Layer`. One Change; the Task DAG runs phase 1 before phase 2. Axes outside the table require a design update first.

## Options

Retirement: whole shell / NativeEngine only / dump everything under NativeEngine. Coverage: relocate only / one thin area / layer+matrix / Legacy parity. Identity: nest all / keep flat / nest new layers only. Packaging: two Changes / one Change / direct edits.

## Decision and Rationale

Retire the whole shell. Recut NativeEngine by proof layer using production-aligned tokens; Preprocessor joins Lexer; source-to-VM is SourceExecution. Nest all identities. Gate tests live under Basic with class Foundation. One Change moves first, then covers. The matrix is design section 4 in full.

The shell is not NativeEngine-only. Nested names make layer prefixes selectable. The matrix is the accepted meaning of complete coverage. One Change is the confirmed packaging.

## Flip Condition

Reopen identity if an external dashboard is locked to the old flat names. Reopen the retired-syntax axis if foreach becomes a supported product; tasks must not change that product rule.

## Architecture, Components, and Data Flow

```text
Phase 1 relocate files and TestDir tokens
 └─[then] Phase 2 Parser unit tree
    └─[then] SourceExecution matrix groups (operators, control flow, calls, objects, rejections)
```

CQTest TestDir is `Angelscript.UnitTest.NativeEngine.<Layer>`. Class tokens are not the Layer name. Framework includes become `Framework/...`. Fixtures still own source locally and never take an ambient Engine.

## Failures and Edge Cases

Class equals Layer → rename the class or the theme (Basic.Foundation is the settled case). An empty Parser prefix after phase 1 is expected. Overlap with existing VMSource/Bodies methods is marked, not copied. Generated TestCode still includes Framework and must move in phase 1 or the build breaks.

## Verification

Phase 1: `ue.build`; Fast smoke on Basic, Lexer, VM, Framework, RuntimeBindings, Baseline; close-out shows zero retired flat names. Phase 2: per-group exact prefixes RED/GREEN; Lexer and VM non-regression.

## OpenSpec Handoff

- Change ID: `angelscript/refactor-testing-nativeengine-home`
- Type: refactor (directory and identity structure); coverage is the second half of the same Task DAG
- Capabilities: `angelscript/testing/baseline` (paths and identities). Ensure plan decides whether authoring/coverage deltas are required.
- Artifacts: proposal, design, spec deltas, Task DAG with phase-1 edges into phase 2
- Task boundaries: phase 1 is verifiable per tenant/layer; phase 2 is one proving prefix per matrix group

## Exploration Carryover

Confirmed 2026-09-15. Talks T1–T6 and knowledge K1–K3 are materialized beside this file. Discarded: Gates naming detours, the two-Change recommendation, round navigation.

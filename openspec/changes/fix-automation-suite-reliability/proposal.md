## Why

The 2026-07-22 `All` automation-suite run exposed a mixture of deterministic
regressions, stale test assumptions, and one non-deterministic Debugger timeout.
Twenty-two tests failed and four suite entries found no matching tests. The
recent UHT single-file Runtime binding work is not implicated: its three focused
tests and the Engine-level single-generated-file assertion passed.

The StaticJIT AOT tests are especially fragile because they require a local,
ignored fixture cache whose build identifier can become stale after a schema or
configuration change. A clean or long-lived development workspace should not
determine whether the normal test suite can execute its AOT verification.

## What Changes

- Repair the AngelScript builder's enum-description cleanup so post-build test
  diagnostics cannot traverse deleted global-variable descriptions.
- Make the Editor module register Angelscript Project Settings deterministically
  when its startup module runs, rather than silently skipping registration when
  the Settings module is not already loaded.
- Give tests that intentionally exercise the no-current-engine branch a
  test-only scoped engine-resolution suppression, preserving the production
  subsystem fallback semantics.
- Correct stale expected script stack source coordinates in the Widget and
  World function-library binding tests.
- Replace obsolete `ClassGenerator` and `ScriptClass` suite prefixes with one
  non-duplicating `Generator` entry that matches the current automation IDs.
- Make the StaticJIT AOT fixture cache a test-owned, self-provisioned artifact
  under `Saved/StaticJIT/AOT/`; keep generated C++ source checked in and
  independently verified, but never require a cache in the source tree.
- Harden Debugger TCP envelope intake against fragmented header/payload reads
  and add coverage for incremental frame assembly. The one observed suite
  timeout was not reproducible in focused reruns, so this is a robustness fix,
  not a claim of a proven single root cause.

## Capabilities

### New Capabilities

- `automation-suite-reliability`: The automation suite reports current test
  groups accurately and its regression fixtures do not rely on stale ambient
  state or locally pre-generated binary input.

### Modified Capabilities

- `as-static-jit-aot-test`: StaticJIT AOT runtime tests provision and validate
  their local cache for the current build instead of requiring a manually
  generated source-tree cache.
- `debugger-protocol-v2`: The debug server accepts a valid TCP debug envelope
  even when its header or payload arrives in multiple socket reads.

## Impact

- **Plugin runtime:** `AngelscriptEngine`, AngelScript third-party builder
  cleanup, and Debug Server receive state.
- **Plugin editor:** deterministic `ISettingsModule` acquisition during module
  startup.
- **Plugin tests:** StaticJIT AOT fixture/generation tests, no-engine lifecycle
  tests, builder regression coverage, source-coordinate assertions, and Debugger
  transport tests.
- **Host tooling:** `Tools/Shared/TestSuiteDefinitions.ps1` suite prefix
  definitions.
- **OpenSpec:** this change adds the reliability specification and updates the
  StaticJIT AOT and Debugger protocol requirements.

**BREAKING:** None. The test-only StaticJIT cache moves from an ignored file
under the source tree to `Saved/`; no consumer-facing runtime cache format or
plugin API changes.

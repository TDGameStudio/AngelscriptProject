# NativeEngine replacement-test isolation

## Reusable Insight

A replacement CQTest remains isolated when CQTest is treated only as an explicitly included UE test library and every AngelScript-specific fixture is owned by `NewVersion/NativeEngine`, rather than inherited from the quarantined force include and engine pool.

## Evidence

The current build rules couple CQTest to the legacy branch, but the existing replacement baseline demonstrates that new test translation units can compile and register independently. The archived startup measurement also shows that a fresh UE process dominates a logic-only test: approximately 26.8 seconds of process time versus roughly 0.13 seconds in test bodies.

## Boundaries

- Applies to reconstructed ThirdParty frontend tests.
- Does not authorize legacy source discovery, `ASTEST_*`, `FAngelscriptEngine`, or ambient `asCScriptEngine` use.
- Does not make the temporary `NewVersion` path part of public identity.
- Does not establish a portable startup-time threshold.
- Does not replace Harness process, report, timeout, or workspace validation.

## Application

Use one CQTest class per coherent frontend area, keep scenario intent in `TEST_METHOD`, include matchers explicitly, and own all inputs/results locally. Build after source changes, then execute the narrowest complete area prefix once with Harness `ue.test` and `Fast = $true`.

## Sources

- `openspec/specs/angelscript/testing/baseline/spec.md`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
- `openspec/archive/changes/angelscript/2026-09-04-refactor-legacy-runtime-tests-quarantine/attachments/data/test-startup-timing.md`

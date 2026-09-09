# Final-content baseline and NativeEngine verification

## Final build identity

Harness build run `e92df87572ff4714897bfdde26777720` succeeded for `AngelscriptProjectEditor`, Development, Win64. The tested binaries are:

| Binary | SHA-256 |
|---|---|
| `UnrealEditor-AngelscriptRuntime.dll` | `49D8614FE6F33E366427D1C8F2B200118310455BD28D288B4ECD345E87710A6F` |
| `UnrealEditor-AngelscriptTest.dll` | `711E160A4B2DD08B1CEC888B929047FB0EEF231742C7D3B146D6838679C2D933` |

## Task 8.3: dormant baseline

Harness run `d15830d3e8734ffeb6b2a298d92fb8ac` executed the exact `Angelscript.UnitTest.Baseline` selector and completed all three public replacement cases with process exit 0, 0 failures, 0 skipped, and 0 not-run:

- `Angelscript.UnitTest.Baseline.LegacySuiteExcludedByDefault`
- `Angelscript.UnitTest.Baseline.OptionalIntegrationsDormantByDefault`
- `Angelscript.UnitTest.Baseline.RuntimeDormantByDefault`

The cases prove the default subsystem remains engine-free and non-ticking, explicit binding creation does not publish an ambient owner, optional JIT/debug/cache services stay dormant, old namespaces are absent, and public replacement identities do not expose the physical `NewVersion` directory.

The report outcome is `PassedWithWarnings`: 2 cases succeeded normally and `LegacySuiteExcludedByDefault` succeeded with 2,436 warnings. Every warning is unrelated UE 5.8 MetaSound automation-tag discovery output emitted while that test enumerates the complete Automation registry; there are no AngelScript warnings or errors. This known engine discovery noise does not weaken any baseline assertion.

## Task 8.4: shared frontend, metadata, and VM regression

Harness run `14bd04f964ad43b1914bbc4737df7180` executed the exact `Angelscript.UnitTest.NativeEngine.` selector against the same binaries. Its complete validated Automation report contains 1,080 discovered cases: 1,080 succeeded, 0 failed, 0 skipped, 0 not-run, 0 warnings, and 0 errors, with process exit 0.

This selection directly covers the shared declaration identities, syntax and parser behavior, metadata images and freezing, type layouts, template materialization, native call ABI, callable lifetime, preprocessing, and VM behavior affected by the Runtime binding reconstruction.

## Related final-content proof

Harness run `d189352e8d104a1ab4af72b644cdca9b` passed all 312 `Angelscript.UnitTest.RuntimeBindings.` cases on these binaries with no failures, skips, warnings, or errors. Detailed full publication, provider reconciliation, representative execution, and deterministic manifest evidence is retained in `verification-full-runtime.md`.

Heavier Performance, Integration, packaging, JIT execution, and dormant legacy suites were omitted because this closure changes neither their contracts nor their enabled configuration. The exact baseline, complete RuntimeBindings, and complete NativeEngine selections cover the demonstrated impact.

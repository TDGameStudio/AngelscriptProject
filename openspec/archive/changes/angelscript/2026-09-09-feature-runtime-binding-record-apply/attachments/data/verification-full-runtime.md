# Task 8.2 full Runtime publication and accounting verification

## Outcome

The full registered provider collection now records, validates, installs, and publishes independently owned Runtime Engines. The exact coverage fixture proves two-owner isolation, exact provider identity reconciliation, representative installed execution, atomic failure, full-manifest acceptance, and deterministic export. No legacy `Register*` callback is replayed during installation.

The captured Windows Editor/Development policy is `editor=true`, `shipping=false`, `logging=true`, `scriptFloatIsFloat64=true`, and `platform=Windows`. The full snapshot contains 267 providers: 258 recorded under this policy and 9 excluded by their actual conditions. Of the recorded providers, 240 contribute types, members, effects, primitives, or native maps and 18 are the explicitly enumerated intentional-no-output set. The installed inspection contains 19,126 type identities, 18,573 members, and 22,881 reflected native identities.

## Failure and repair evidence

The prepared full-runtime group initially exposed missing full-factory publication and then successively reached mixed detached/legacy infrastructure branches. `implementation/issue-20260909-full-capture-engine-state.md` records the root cause and repairs. After full publication, run `3559e6aeec5a4c6092fbcef323c077ce` exposed a repeat-capture crash. The first apparent stale-pointer projection was made pointer-safe, but run `bc05dcbe1a984c00ab9156ac64fa0467` demonstrated the first bad boundary earlier: `FullOwnerExecutesVectorStringContainerAndReflectedCalls` explicitly destroyed an `FScriptArray` placement-constructed inside an already constructed stack object, and scope exit destroyed it again. The following reflection capture surfaced the resulting heap corruption. The test now uses aligned raw storage, matching the construction/destruction API contract.

## Exact GREEN and repeatability

Build run `43d3df1f233f4edf9918378b67e18c6c` succeeded for `AngelscriptProjectEditor`, Development, Win64. Exact Harness runs `05205d5fade149d2addde33559ecf196` and `914625e880234063b4878417fba543cb` each completed all six cases with 6 succeeded, 0 failed, 0 skipped, 0 warnings, and process exit 0:

- `ExactReconciliationRejectsBalancedMissingAndUnknownIdentities`
- `FactoryPublishesTwoIndependentCompleteOwners`
- `FinalizationAndNativeFailuresPublishNoOwnerWithSourceDiagnostic`
- `FullOwnerExecutesVectorStringContainerAndReflectedCalls`
- `FullRuntimeManifestIsValidatedAndWrittenFromInstalledSnapshot`
- `RuntimeCollectionAndInstalledSnapshotHaveExactProviderAccounting`

The two independently generated exports are byte-identical for all nine artifacts. SHA-256 values are:

| Artifact | SHA-256 |
|---|---|
| `manifest.json` | `CE113A720E605E2DC4E1245A68FDC1DE2C137406538C522BE6DE230FFAFBB053` |
| `classes.csv` | `E47E2FBB79BCE1660CA1105016AE1D0D6CE267400681BE632A8E2B9F9B083E9E` |
| `exclusions.csv` | `F7927C24AB42B152CF162CFB5EBB519BECF98876B16BD5F9A5105C337C6CDE0F` |
| `globals.csv` | `DCCB59971E2C84324D89FCD627A3E64E09672E3BAEC225E77052C57B6E7CDD3B` |
| `members.csv` | `32A0ED273D7696ED246AB334C22F7FA0DA6BE3315D33159E4F44DF12AE42DD04` |
| `providers.csv` | `2DB0BC8ED62FD1DF6BF5C67CC336DDC6674949207DA10F298C33CB97C3FA33F9` |
| `reflection.csv` | `2DC11A8F90BC2F3D853F0D3FACAB53009CA1C3BEEE85C2DC2AFBEACE8882EC32` |
| `summary.csv` | `CAB5079FAD6E6996DA6C433DF2EC8A00CEDA2F74CD1DBE0C720DE0812244050E` |
| `types.csv` | `D22956CA34FB0702D70B568CCC0A8A5E0B8918BD8A1DACA55C790DFEF2BD49E6` |

Independent standard-library commands both returned exit 0 with `valid=true` and no diagnostics:

```text
python Plugins/Angelscript/Tools/BindingInspection/validate_bindings.py Saved/Harness/RuntimeBindings/FullRuntime/CaptureA/manifest.json --expect openspec/changes/angelscript/feature-runtime-binding-record-apply/attachments/data/full-runtime-expectations.json --report Saved/Harness/RuntimeBindings/FullRuntime/validate-a.json
python Plugins/Angelscript/Tools/BindingInspection/validate_bindings.py Saved/Harness/RuntimeBindings/FullRuntime/CaptureB/manifest.json --expect openspec/changes/angelscript/feature-runtime-binding-record-apply/attachments/data/full-runtime-expectations.json --report Saved/Harness/RuntimeBindings/FullRuntime/validate-b.json
```

The semantic comparison also returned exit 0 with `equal=true`, `compatible=true`, and no changes:

```text
python Plugins/Angelscript/Tools/BindingInspection/diff_bindings.py Saved/Harness/RuntimeBindings/FullRuntime/CaptureA/manifest.json Saved/Harness/RuntimeBindings/FullRuntime/CaptureB/manifest.json --report Saved/Harness/RuntimeBindings/FullRuntime/diff-a-b.json
```

## Final identities

| Input | SHA-256 |
|---|---|
| `AngelscriptTypeBindInfoInspection.cpp` | `A67DE029B6D0629DCE6D41BC7FD1E93BEC6599DF22BEB18D3EC6FF75E5D3C7FB` |
| `AngelscriptTypeBindInfoApply.cpp` | `4CF6C9078150C5E0C9F1B601075B0B0915EAC70A0CF4DE4D9AD7C971C483BCC2` |
| `RuntimeBindingFullRuntimeTests.cpp` | `DC30514810F55E30B1D1D944ECA5ADF0B0958C90115A07E31C8778B3BD8CC428` |
| `full-runtime-expectations.json` | `8DA60D41037804E9E539F4973B99D1808E796AC1926663AA45460ED69E7029B3` |
| `UnrealEditor-AngelscriptRuntime.dll` | `49D8614FE6F33E366427D1C8F2B200118310455BD28D288B4ECD345E87710A6F` |
| `RuntimeBindingManifestTests.cpp` | `AADD9765C39D26FC57F1A1DE51E7CFB8C9250B5C086A03C446FEB1C0EAB77078` |
| `UnrealEditor-AngelscriptTest.dll` | `711E160A4B2DD08B1CEC888B929047FB0EEF231742C7D3B146D6838679C2D933` |

After the deterministic capture proof, the broader run `7b18742a129e459d9ac3615233d6c08c` found one obsolete selected-family fixture identity: `SemanticMutationsChangeOnlyRelevantManifestFacts` still searched for `Test` after namespaces acquired their collision-free `namespace:Test` identity. Build run `e92df87572ff4714897bfdde26777720` compiled the corrected expectation. Focused run `dfcfdd467b464a9795683aff081982ff` then passed all 10 manifest cases, and final-content run `d189352e8d104a1ab4af72b644cdca9b` passed all 312 discovered `Angelscript.UnitTest.RuntimeBindings.` cases with 312 succeeded, 0 failed, 0 skipped, 0 warnings, and process exit 0. That shared final run includes and passes all six task 8.2 cases on the final test binary.

# Verification Evidence

## Static contract checks

| Check | Result |
|---|---|
| `openspec validate feature-unreal-angelscript-product-version --strict --json` | PASS: one valid change, zero issues |
| `Plugins/Angelscript/Tools/ValidateVersion.ps1` | PASS: `Unreal AngelScript 1.0.0`, encoded `10000`, header and descriptor agree |
| Validator with temporary descriptor `VersionName=1.0.1` | Expected rejection: exit 1 with the exact mismatched field |
| Native coverage catalog validation | PASS: 320 products, 46,164 unique expected IDs, 46,018 CurrentFork IDs, 65 FutureDisabled IDs |
| Remaining 2.33 inventory | PASS: remaining occurrences are lineage, historical/audit context, or explicit old-header rejection evidence |

## Build

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
	-Label unreal-angelscript-version `
	-TimeoutMs 1800000 `
	-NoXGE
```

Result:

- PASS, `Result: Succeeded`.
- 94/94 build actions completed.
- UBT execution time: 101.61 seconds.
- No source fix/rebuild cycle was required.
- Evidence: `Saved/Build/unreal-angelscript-version/20260730_013430_085_6bee0761/`.

## Focused tests

| Prefix | Result | Evidence |
|---|---:|---|
| `Angelscript.TestModule.AngelScriptSDK.Engine.Version` | 8/8 PASS | `Saved/Tests/unreal-angelscript-version-native/20260730_013625_490_f88b7f6e/` |
| `Angelscript.TestModule.Engine.HeaderShim` | 1/1 PASS | `Saved/Tests/unreal-angelscript-version-header/20260730_013716_161_227c6e5e/` |
| `Angelscript.TestModule.Functional.Upgrade` | 7/7 PASS | `Saved/Tests/unreal-angelscript-version-upgrade/20260730_013756_214_ff32c403/` |
| `Angelscript.TestModule.Functional.Core` | 11/11 PASS | `Saved/Tests/unreal-angelscript-version-core/20260730_013849_293_a0c48c08/` |

Focused aggregate: 27/27 PASS, zero failed, zero skipped/not-run, all process/final exits zero, no crash or timeout.

## NativeCore

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 `
	-Suite NativeCore `
	-LabelPrefix unreal-angelscript-version-nativecore `
	-TimeoutMs 600000 `
	-ContinueOnFail
```

Result:

- 691/691 PASS, up from the preceding 683 baseline by the eight new version scenarios.
- Zero failed and zero not-run.
- Normal process/final exit, no crash or timeout.
- Evidence: `Saved/Tests/unreal-angelscript-version-nativecore_01_AngelScriptSDK/20260730_014007_843_ba7b8b64/`.

## Full plugin suite

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 `
	-Suite All `
	-LabelPrefix unreal-angelscript-version-all `
	-TimeoutMs 900000 `
	-ContinueOnFail
```

Result:

- 35/35 configured prefixes produced reports.
- 2,404/2,404 PASS.
- Zero failed, zero skipped/not-run, zero missing reports, zero process/final exit failures, and zero timed-out prefixes.
- No residual UnrealEditor or CrashReportClient process remained.
- Runner exit code 0; wall time 2,590.3 seconds.
- Evidence roots: `Saved/Tests/unreal-angelscript-version-all_01_Editor/` through `Saved/Tests/unreal-angelscript-version-all_35_WorldSubsystem/`.

The report aggregation reads `ProcessExitCode`, `ExitCode`, and `TimedOut` from each `RunMetadata.json`; `ExitCode` is the current metadata field name for the final runner result.

After final test-code review added failure-path RAII cleanup, an incremental build completed 4/4 actions with `Result: Succeeded` and both exit codes zero in `Saved/Build/unreal-angelscript-version-final/20260730_023506_407_8156365a/`. The refreshed version prefix then completed 8/8 PASS with zero failed/skipped and both exit codes zero in `Saved/Tests/unreal-angelscript-version-native-final/20260730_023528_044_2d492782/`. Production code did not change after the full 2,404-test run.

## Final static closure

After the build and all runtime tests:

- Version validator: PASS.
- Coverage catalog: 320 products / 46,164 unique IDs / zero incomplete products.
- Source reconciliation: 319 implemented + 1 DisabledImplemented; 705 methods, 315 product owners, 64 product parts, 326 explicit non-products, zero unresolved.
- Public API audit: 365 rows; 357 directly observed, 1 contract-covered, 7 explicitly deferred, zero missing direct-or-contract rows.
- Raw SDK boundary audit: zero violations.
- Inline source audit: 306/306 conforming ordinary sources, two registered escaped inputs, zero violations.
- Planning record audit: zero violations.
- `feature-unreal-angelscript-product-version` and the updated `improve-as-standalone-release-evidence` change both pass strict OpenSpec validation.

## Commits

- Plugin implementation: `dc99986` (`[Angelscript] Feat: establish Unreal AngelScript 1.0.0 version contract`).
- The parent commit records this OpenSpec, scoped parent documentation, native coverage ownership, and the updated plugin gitlink.

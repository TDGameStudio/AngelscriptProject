# Readable entry names and complete run-local exports

## Context

The user requested readable camel-style entry names without underscores, all individual .as files beside the test log, and one unit test per generator. They also asked to confirm implementation ownership.

## Evidence

Harness Private/Run.ps1 Get-UnrealRunPaths sets Unreal.log inside Saved/Harness/Unreal/Runs/<RunId>. Private/Operations.ps1 passes -ABSLOG. UE 5.8 FGenericPlatformOutputDevices::GetAbsoluteLogFilename honors that argument. The existing generator is owned by Framework/Generate and its tests by FrameworkTests. FFileHelper supports explicit UTF-8 without BOM.

## Options

Keeping uppercase underscored entries conflicts with the user's readability request. Exporting only an aggregate or selected examples omits requested individual cases. A fixed project export directory loses the association with the exact test run. The selected approach uses PascalCase names and complete product-specific exports beside the resolved active log.

## Settled Decision

Retain stable CaseIds; canonical names use Entry plus PascalCaseId. One GeneratesAndExportsAllCases method per generator exports every canonical cell and index.json, then reports assertions and accumulated failures. Production source generation stays in Framework/Generate with no I/O; a small FrameworkTests helper owns file operations. Gold is independent, bounded checked-in evidence; complete exports are ignored run artifacts.

## Consequences

ForLoop's original five methods are consolidated without losing their assertions, and its gold adopts new names. All product proving selectors target the one method. The shared data/export helper belongs to task 1.1, so existing prerequisites remain sufficient. No new Harness route or runtime executor is needed.

## Flip Condition

Evidence that the platform cannot resolve the actual log path or that a accepted canonical ID set collides under the selected spelling requires a focused correction. Do not silently omit files, rename collisions with arbitrary suffixes or export beside a different run.

## Sources

[Current design](../../design.md), [task plan](../../tasks.md), [complete inventory](../data/product-inventory.md), and the user's explicit naming, export and directory instructions in the current session.

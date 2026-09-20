# UCLASS reload and transient Blueprint first

## Context

The old HotReload suite is large and isolated. The user asked to look at it, then narrowed the first proof.

## Evidence

AskQuestion follow-up after the Legacy survey. Draft log R8.

## Options

Port the 32-file Legacy suite; prove only `PerformHotReload` file watch; or prove UCLASS SoftReload plus some Blueprint create with new NativeEngine tests.

## Settled Decision

Get UCLASS SoftReload and a transient Blueprint child through first. Reorganize tests later. Do not port Legacy files.

## Consequences

Phase 1 borrows `SoftReloadUpdatesMemberFunctionBody` and `SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody`. PIE, rename, LevelBP stay out.

## Flip Condition

Reopen if the isolation contract is lifted and Legacy files must compile again.

## Sources

[legacy-reload-slice](../drafts/findings/legacy-reload-slice.md). Provenance: draft log R8.

# SourceManager source-content identity repair — 2026-08-23

## Problem

`asCSourceManager::RemapLogical()` previously reused an existing snapshot-local
`asASTFileID` solely from `(logicalKey, origin)`.  The caller could therefore
restore changed source bytes, or the same bytes under a changed line offset,
and silently receive the old buffer and line table.  Any AST range subsequently
using that FileID described stale source.

This is especially unsafe for Cache/public AST source remapping: logical source
identity is stable across snapshots, but a FileID and its coordinates are local
to one concrete source snapshot.

## Contract

Within one `asCSourceManager`, an existing `(logicalKey, origin)` may be reused
only if all of the following agree:

1. source byte length;
2. every source byte;
3. line offset.

A mismatch returns invalid FileID `0`; it neither mutates the existing section
nor creates a second ambiguous section with the same logical identity.  A
caller that intends changed source must construct a new AST/source snapshot.

## TDD evidence

New test:

`RemapRejectsChangedContentForExistingLogicalSource`

in `AngelscriptNativeSourceManagerTests.cpp` creates a processed source at a
logical path, then separately attempts a changed line offset and changed
source bytes.  It requires invalid FileID, one retained section, and unchanged
original bytes/line mapping.

| Stage | Command / label | Result |
| --- | --- | --- |
| Red | `RunBuild.ps1 -NoXGE` `cta-source-manager-remap-red-build` | success |
| Red | SourceManager prefix `cta-source-manager-remap-red` | **3/4 pass, 1/4 fail**; remap returned the old ID |
| Green build | `RunBuild.ps1 -NoXGE` `cta-source-manager-remap-green-build` | success |
| Green | SourceManager prefix `cta-source-manager-remap-green` | **4/4 pass, 0 fail, 0 skip** |

Saved reports:

- `Saved/Tests/cta-source-manager-remap-red/20260823_071055_219_54afecd3`
- `Saved/Tests/cta-source-manager-remap-green/20260823_071238_063_e96c9844`

## Scope and non-claims

This is a bounded part of task **2.2**, not its closure.  It makes the
SourceManager's own restore/remap operation content truthful.  It does **not**
yet route legacy Parser/Builder/`asCCompiler` diagnostics through
`asCSourceLocation/asCSourceRange`, and it does not make Cache sidecars persist
the full source model.  Task 2.2 remains unchecked until those authority paths
are implemented and regression-tested.

## Context

`New-UnrealRunRequest` already writes a `label` field, and each single-operation route supplies a derived value. The legacy wrapper exposed a caller `-Label`, while the Harness route signatures and observation projections do not. Run directories, leases, and the newly repaired UBT correlation contract are deliberately keyed by generated RunId and contained paths.

## Goals / Non-Goals

**Goals:**

- Restore caller-defined semantic labels for build, generic UBT, test, and commandlet runs.
- Preserve useful route-derived defaults and expose the effective label in planning and observation.
- Accept readable Unicode labels while preventing terminal/control-character injection and unbounded metadata.
- Preserve compatibility with existing RunId-only artifact paths and old retained run records.

**Non-Goals:**

- Rename run directories or introduce label aliases on disk.
- Use labels as identity, authorization, correlation, concurrency, or executor input.
- Change suite-entry identity, request/run schema names, or Unreal product behavior.

## Decisions

### Keep RunId canonical and labels display-only

Every run remains rooted at `Saved/Harness/Unreal/Runs/<RunId>`. A label is repeatable human context and therefore cannot safely replace or modify the unique RunId. It is not appended to UBT or editor arguments.

### Normalize once at request construction

A shared resolver trims a supplied label, falls back to the existing route-derived value for omitted or whitespace-only input, limits the effective value to 128 UTF-16 code units, and rejects control characters. Spaces, punctuation, and Unicode remain valid because the label never becomes a path segment or command-line argument. `New-UnrealRunRequest` applies the final defensive validation so internal callers cannot bypass the contract.

### Persist the label in request and metadata

`Request.json` remains the request source of truth. New `RunMetadata.json` records copy the effective label so status can report it without adding a new dependency on reparsing request data during every lifecycle query. Status tolerates historical metadata without the property by reading and validating the contained request label as a compatibility fallback.

### Project the label at each observation boundary

Plan objects expose `Label`; `ue.run.status` exposes the persisted/fallback label; recognized UBT build process views expose the validated request label. Unrecognized machine processes retain an empty label and cannot inject display metadata into trusted observations.

## Risks / Trade-offs

- Two evidence files contain the same label for new runs. Tests require equality at creation, and request data remains authoritative for process correlation.
- Historical runs may lack metadata labels. The bounded contained-request fallback preserves their existing automatically derived label where valid.
- The 128-code-unit limit is intentionally a metadata/terminal bound rather than a filesystem bound; labels can remain readable in Chinese and other scripts.

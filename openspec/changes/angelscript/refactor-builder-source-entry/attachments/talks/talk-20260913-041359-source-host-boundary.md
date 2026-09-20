# Shared Source and Host Boundary

Provenance: accepted builder-source-entry design, confirmed 2026-09-13; curated for implementation and maintenance.

## Context

UE owns source acquisition and preparation. The SDK needs ready bytes and logical identity, while existing host consumers still need provenance fields.

## Evidence

[Storage evidence](../drafts/findings/builder-source-storage-evidence.md) identifies the host fields and AddFile body copy. The character stream already accepts bounded byte views.

## Options

The meaningful ownership choice is whether compiler ingestion copies caller text or retains an immutable source version. Shared version ownership fits the existing byte-view consumers and makes retention explicit without relocating host loading policy.

## Settled Decision

Keep one FAngelscriptSource, its host fields, and one moved FUtf8String body. Submit shared-const references after preparation. SDK owns reference/index organization and rejects unprepared input without reading a file. Exact logical paths identify modules; the host controls normalization.

## Consequences and Flip Condition

The host must stop mutating published aliases; the interface does not enforce freezing. Existing host factories need bounded encoding/move compatibility. Reconsider only if enforced publication, filesystem services, or a different encoding becomes an explicit requirement.

## Sources

[Accepted design](../drafts/design.md), [storage evidence](../drafts/findings/builder-source-storage-evidence.md).

# Stable Declarations and Callback Lifecycle

Provenance: accepted builder-source-entry design, confirmed 2026-09-13; curated final rationale only.

## Context

The host needs declaration facts early enough to prepare its own types, while compilation can still fail later. Declaration publication and successful runtime replacement are different events.

## Evidence

[Lifecycle evidence](../drafts/findings/builder-source-lifecycle-evidence.md) identifies the rich per-fragment projection, the later simplified overwrite, existing stable-key lookups, and the session's definition borrow.

## Options

Repeatedly rebuilding outward descriptions from later products changes their meaning and lifetime. A single resolved declaration publication instead separates stable facts from final executable success; definition association remains available by stable key.

## Settled Decision

Publish a validated whole-batch, deep-read-only per-module description set once after DeclarationsResolved. Later stages refresh diagnostics, not descriptions. Keep runtime pointers unmaterialized; use stable keys to query separately owned definitions.

Ordinary hooks short-circuit on failure. Final notification reaches every valid registered object once, including objects skipped earlier. It is synchronous notification, not a veto or UObject rollback. Take is unavailable until terminal execution and all callbacks return; definition transfer additionally requires success.

## Consequences and Flip Condition

Early descriptions cannot authorize a hot-reload commit. Host cleanup tolerates partial preparation, and abandoned builders remain host-managed. Reconsider for explicit bidirectional compiler/host semantic feedback or a changed publication transaction, not for an additional typed output field.

## Sources

[Accepted design](../drafts/design.md), [lifecycle evidence](../drafts/findings/builder-source-lifecycle-evidence.md).

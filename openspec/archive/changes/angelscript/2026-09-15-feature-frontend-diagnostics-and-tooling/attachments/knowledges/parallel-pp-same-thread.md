# parallel pp same thread

Status: candidate. Confirmed carryover on 2026-09-14 (Q18); not product-verified or promoted.

## Reusable Insight

A completed file can run preprocessing on its lexical worker when all PP prerequisites are file-local or frozen; per-file failure facts must be separate from global compile status.

## Evidence

The [English source finding](../drafts/findings/parallel-pp-same-thread.md) preserves inspected source rationale and accepted boundaries with original topic provenance. Creation does not claim execution evidence.

## Boundaries

This candidate explains decisions; canonical requirements and task completion remain in specs and tasks. Do not infer unimplemented APIs are present or transfer dormant-runtime behavior to the maintained frontend.

## Application

Apply to stage integration, result alignment and failed-compilation inspection. Do not bypass later declaration/publication barriers or execute PP twice.

## Sources

[Source finding](../drafts/findings/parallel-pp-same-thread.md) and [selected handoff](../drafts/handoff.md).

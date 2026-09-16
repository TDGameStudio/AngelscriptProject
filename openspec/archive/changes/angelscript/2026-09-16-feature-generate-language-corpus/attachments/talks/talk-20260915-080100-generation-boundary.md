# Make generator completion precise

## Context

The user wants the full source corpus while the reconstructed language runtime remains unavailable to these tests.

## Evidence

The product cards require generator-only tests; the current check found host, lifecycle and approximate numeric observations.

## Options

The selected approach is stated below. The earlier first-batch-only or generic/execution-coupled interpretations are not the current scope.

## Settled Decision

Verify source generation for all cells and preserve each observation boundary; do not claim generated-AS execution.

## Consequences

Normal, reject and fault fixtures all remain in scope. Host-dependent modules declare their needs and lifecycle fixtures retain their source-variant limits.

## Flip Condition

The user explicitly requests executing the generated language corpus or evidence invalidates a source contract.

## Sources

[Accepted handoff](../drafts/handoff.md), [design](../drafts/design.md), [creation check](../drafts/findings/design-check.md). Original discussion rounds are textual provenance above; the transcript stays local.

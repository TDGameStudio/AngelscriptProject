# Keep specialized directly constructed subclasses

## Context

The exploration considered registered lambdas and a generic recipe layer before selecting product subclasses.

## Evidence

Q17 and Q99, plus the inspected FForLoopGenerator and empty FCodeGenerator.

## Options

The selected approach is stated below. The earlier first-batch-only or generic/execution-coupled interpretations are not the current scope.

## Settled Decision

Keep algorithms, axes and typed parameters in each generator; no registry, Get<T>() or abstract iteration API in the base.

## Consequences

Products can grow without premature shared abstractions. Common helpers may be factored only when concrete evidence supports identical behavior.

## Flip Condition

Several implementations demonstrate a shared contract whose extraction is required and verified.

## Sources

[Accepted handoff](../drafts/handoff.md), [design](../drafts/design.md), [creation check](../drafts/findings/design-check.md). Original discussion rounds are textual provenance above; the transcript stays local.

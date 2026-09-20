# Choose the UFUNCTION reflection layer

## Context

Builder already emits bytecode. A raw Engine already Executes `Identity()`. ClassGen already materializes UserData. The remaining compiler join had three layers.

## Evidence

AskQuestion Q1 = U. Draft log R2. Finding [ufunction-join](../drafts/findings/ufunction-join.md).

## Options

- H: host Context.Prepare after CompileModules, no UFUNCTION.
- U: UFUNCTION → UASFunction → ProcessEvent.
- L: compile and execute admitted Language corpus files.

## Settled Decision

U. Acceptance is a UE reflection call, not a bare script Context and not Language admission.

## Consequences

ClassGen must see host Methods and bind ScriptFunction. Language corpus and Context.Prepare-only proof stay out.

## Flip Condition

Reopen if ProcessEvent cannot be the first host proof and a bare Prepare is the only callable surface.

## Sources

[handoff](../drafts/handoff.md), [design](../drafts/design.md). Provenance: draft log R2.

---
name: openspec-sync-specs
description: Merge an active change's durable delta specs into current OpenSpec specs. The CLI never performs this merge; use before completed archive or whenever current contracts should advance.
---

# Sync Delta Specs

Load the [Specification and Scenario Card contract](../openspec/references/specs.md) for authoring and ownership boundaries.

1. Read each concrete change `specs/**/spec.md` and its current target before writing.
2. Create a missing current capability through `openspec.domain/spec`, never by fabricating manifests.
3. Merge idempotently:
   - `ADDED` adds or reconciles the complete Requirement and complete Scenario Cards, including every clause-owned detail block beneath its exact behavior item.
   - In `MODIFIED`, a same-name scenario uses the delta's complete Scenario Card with all clause-local prose, lists, examples, and tables as its replacement, while a new scenario name appends its complete card.
   - Preserve unspecified scenarios and their complete clause-owned detail blocks. Change the requirement body only when the delta explicitly provides its replacement.
   - `REMOVED` deletes only the named Requirement block, and `RENAMED` applies only the explicit `FROM` / `TO` mapping.
4. Remove delta-operation headers from current specs and preserve every ordinary Markdown detail line inside the synchronized cards.
5. Run `openspec.validate --specs --strict --json` and record which capabilities changed or why sync is not applicable.

```text
delta + current -> semantic merge -> current spec -> strict spec validation
```

Never overwrite a current spec with a delta file. Retiring the last requirement of a capability is a product-scope decision and requires matching authority.

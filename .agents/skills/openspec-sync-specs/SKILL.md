---
name: openspec-sync-specs
description: Merge an active change's durable delta specs into current OpenSpec specs. The CLI never performs this merge; use before completed archive or whenever current contracts should advance.
---

# Sync Delta Specs

Load the [Specification and Scenario Card contract](../openspec/references/specs.md) for authoring and ownership boundaries.

1. Read each concrete change `specs/**/spec.md` and its current target before writing. Validate existing affected targets first and distinguish baseline failures from delta errors. If preserved content is already invalid, use an explicitly authorized, exact-record formatting correction or report the unresolved boundary; do not silently widen the migration, delete preserved content, or count the target as passing. For each new or modified behavior clause, actively evaluate whether synchronization preserves the useful information in its clause-owned detail block, including useful prose, lists, examples, or tables; a form may be absent when it adds no durable information.
2. Create a missing current capability through `openspec.domain/spec`, never by fabricating manifests.
3. Merge idempotently:
   - `ADDED` adds or reconciles the complete Requirement and complete Scenario Cards, including every clause-owned detail block beneath its exact behavior item.
   - In `MODIFIED`, a same-name scenario uses the delta's complete Scenario Card with all clause-local prose, lists, examples, and tables as its replacement, while a new scenario name appends its complete card.
   - Preserve unspecified scenarios and their complete clause-owned detail blocks, except an explicitly scoped formatting correction established in step 1 that retains text and parentage. Change the requirement body only when the delta explicitly provides its replacement.
   - `REMOVED` deletes only the named Requirement block, and `RENAMED` applies only the explicit `FROM` / `TO` mapping.
4. Remove delta-operation headers from current specs and preserve every ordinary Markdown detail line inside the synchronized cards.
5. Through Harness, run `openspec.validate <capability-id> --type spec --strict --json` for each affected current capability, and strict validation for the owning Change. Record the exact IDs, results and any resolved baseline failures. Use all-spec validation only when the impact policy or user request justifies that broader scope; report unrelated baseline failures separately without relabeling a failing affected target as successful.

```text
delta + current -> semantic merge -> current spec -> strict spec validation
```

Never overwrite a current spec with a delta file. Retiring the last requirement of a capability is a product-scope decision and requires matching authority.

Rich Markdown ownership is part of the authoring contract: direct Task and behavior-clause detail uses four spaces, nested blocks keep their own container, and useful information may be extensive. Preserve complete clauses with their headings, code, tables, lists, quotes, links and images; never flatten a card to its main sentence. Judge literal cases, actual interfaces and observable acceptance decisions, not section presence or word count.

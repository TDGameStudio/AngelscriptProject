---
name: openspec-sync-specs
description: Merge an active change's durable delta specs into current OpenSpec specs. The CLI never performs this merge; use before completed archive or whenever current contracts should advance.
---

# Sync Delta Specs

1. Read each concrete change `specs/**/spec.md` and its current target before writing.
2. Create a missing current capability through `openspec.domain/spec`, never by fabricating manifests.
3. Merge idempotently: ADDED adds or reconciles, MODIFIED changes only named behavior, REMOVED deletes the named block, RENAMED applies FROM/TO. Preserve all unrelated current content.
4. Remove delta-operation headers from current specs.
5. Run `openspec.validate --specs --strict --json` and record which capabilities changed or why sync is not applicable.

```text
delta + current -> semantic merge -> current spec -> strict spec validation
```

Never overwrite a current spec with a delta file. Retiring the last requirement of a capability is a product-scope decision and requires matching authority.

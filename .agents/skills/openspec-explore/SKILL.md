---
name: openspec-explore
description: Investigate an unclear idea, failure, or design choice before changing OpenSpec records or implementation. Use for evidence gathering and option analysis; do not use when an approved plan is already implementation-ready.
---

# Explore an OpenSpec Change

- Read the relevant code, current artifacts, and `attachments/INDEX.md`; do not bulk-load attachments or replan history.
- Separate facts that can be investigated from decisions that genuinely require user authority.
- Compare only the smallest viable approaches. Lead with the evidence, the recommended in-scope choice, and the assumption that would change it.
- Stay read-only. When a conclusion must become current truth, hand it to `openspec-update-change`; implementation belongs to `openspec-apply-change`.

```text
unclear request or divergence
  -> inspect evidence
  -> identify requirements and constraints
  -> compare viable options
  -> settle the smallest coherent design
  -> update artifacts or start implementation
```

In Goal mode, investigate and choose the best in-scope technical solution autonomously. Stop only for a true authorization boundary: new permissions, destructive user-data impact, merge/push/publish, missing credentials, or irreconcilable explicit instructions. In Current/interactive mode, use concise questions only when the missing choice would materially change the result and cannot be inferred safely.

Do not create an OpenSpec record just because exploration occurred. If the user asks to preserve the result, route requirements to specs, architecture decisions to design, scope to proposal, and executable work to tasks.

# Harness Evolution

## Knowledge levels

1. **Change evidence** — Reviews, implementation issues, Replans, talks, and trimmed data preserve what happened in one fixed snapshot.
2. **Capability knowledge** — `openspec/specs/hardness/core/knowledges/` keeps concise reusable guidance for future harness changes.
3. **Project instructions** — AGENTS guidance contains only invariants that apply across capabilities and materially affect every agent.

Load only the level needed by the current task. Do not bulk-load historical attachments or duplicate the same rule at every level.

## Plan the live surface once

Begin a broad harness Change with one compact map of the complete live surface: public entrypoints, current specs and metadata, publication and ignore rules, coupled contract tests, and explicitly deferred owners. Use that map to bound Task Cards before implementation. This avoids repeated replans caused by discovering one coupled file at a time while keeping cards free to include only useful local detail.

## Promotion gate

Promote a learning only when all are true:

- Evidence reproduces the behavior or an independent Review confirms it.
- The repair and its regression test pass.
- The rule applies to future changes, not only one machine, path, hash, or release.
- The rule changes an agent decision that is not already obvious from code or a lower-level contract.
- The promoted text can omit chronology, logs, and implementation trivia.

Archive never promotes knowledge automatically. Closure names the source attachment, target capability knowledge, and verification that still passes after promotion.

Raw `hardness.observe` records stay ignored under `Saved/Hardness/` and are not capability knowledge. Before completed closure, summarize only reusable timing, friction, repairs, deferred work, and raw-data provenance in one compact tracked workflow evaluation. Promote an invariant from that evaluation only through the same evidence and verification gate above.

## Evolution loop

```text
change evidence -> repair -> verification -> re-review
        |                               |
        +------ reusable invariant -----+
                        |
              explicit promotion
                        |
          next change loads on demand
```

When durable knowledge becomes false, update it through a later change and keep provenance. Do not accumulate exceptions in the Hardness entry Skill; route conditional detail to the focused reference or capability knowledge.

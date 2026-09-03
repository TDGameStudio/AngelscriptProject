# Harness Evolution

## Knowledge levels

1. **Change evidence** — Reviews, implementation issues, Replans, talks, and trimmed data preserve what happened in one fixed snapshot.
2. **Capability knowledge** — `openspec/specs/harness/core/knowledges/` keeps concise reusable guidance for future harness changes.
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

Raw `harness.observe` records stay ignored under `Saved/Harness/` and are not capability knowledge. Before closure, summarize only reusable timing, friction, repairs, transferred owners, and raw-data provenance in one indexed `harness-workflow-evaluation-v1` record. Promote an invariant from that evaluation only through the same evidence and verification gate above.

If self-hosting exposes a repeatable safety, correctness, lifecycle, evidence, or high-friction gap, admit it to one exact active Change as an indexed `openspec-material-issue-v2` record. An admitted issue cannot remain in conversation, raw observations, or a handoff: resolve or reject it with exact evidence, or supersede it with an exact existing v2 owner. When the source Change has already moved to the immutable archive, use a suitable active owner or create a successor rather than rewriting history. Admission alone starts neither Review nor Replan.

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

When durable knowledge becomes false, update it through a later change and keep provenance. Do not accumulate exceptions in the Harness entry Skill; route conditional detail to the focused reference or capability knowledge.

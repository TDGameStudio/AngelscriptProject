# Harness Evolution

## Knowledge levels

1. **Change evidence** — Reviews, implementation issues, Replans, talks, and trimmed data preserve what happened in one fixed snapshot.
2. **Capability knowledge** — `openspec/specs/harness/core/knowledges/` keeps concise reusable guidance for future harness changes.
3. **Project instructions** — AGENTS guidance contains only invariants that apply across capabilities and materially affect every agent.

Load only the level needed by the current task. Do not bulk-load historical attachments or duplicate the same rule at every level.

## Plan the live surface once

Begin a broad harness Change with one compact map of the complete live surface: public entrypoints, current specs and metadata, publication and ignore rules, coupled contract tests, and explicitly deferred owners. Use that map to bound Task Cards before implementation. This avoids repeated replans caused by discovering one coupled file at a time while keeping cards free to include only useful local detail.

## Admission and explanation feedback

Read the owning source, current specification and capability knowledge INDEX before explaining a mechanism. “I did not understand” establishes a question about the explanation, not a proven defect. Use a concrete state transition to explain the missing distinction, then distinguish a method gap, ambiguous intended behavior, missing knowledge, missed retrieval or an unproven cause. Ask only a consequential unresolved question; understanding is not approval of a pending lifecycle action.

Capture the actual source in the existing topic draft through `harness.observe`, with its known owner and scope. A Harness-upgrade topic uses the ordinary draft modes. New feedback does not need a Saved ledger, separate Skill or formal Change. Historical Saved observations remain readable; preserve them in place. A draft archive preserves unresolved questions rather than declaring them repaired.

Select improvement scope from actual authority. Source, current contract and a representative example can justify an authorized factual knowledge addition. A repair-derived learning also needs the selected repair and appropriate regression proof. An unclear desired behavior needs explained Grill and applicable planning authority. Ordinary unfamiliarity does not require a fabricated RED/GREEN test, duplicate article or unrelated prompt edit.

In either admission path, the learning must apply beyond one task, retain source and application boundaries, and omit transient machine details. Index it once and verify a later explanation actually reads the INDEX/entry and uses its model. A label saying “reused” is insufficient. Archive never promotes knowledge automatically; closure identifies admitted targets and their evidence. Change-specific evidence stays in its original attachments.

Before closure, summarize relevant friction, repairs, factual additions, unresolved owners and proof limits in one indexed `harness-workflow-evaluation-v1` record. The evaluation is durable evidence, not a second feedback inbox.

If self-hosting exposes a repeatable safety, correctness, lifecycle, evidence or friction gap, automatically collect it and show a batch for user scope selection. Repair already authorized problems within their scope; admit material in-scope issues to an indexed `openspec-material-issue-v2` owner without treating collection as authority to change unrelated Skills. An admitted issue cannot remain in conversation, raw observations, or a handoff: resolve or reject it with exact evidence, or supersede it with an exact existing v2 owner. When the source Change has moved to the immutable archive, collect the new finding and present the repair scope to the user. Preserve history; do not automatically create a successor. A selected repair uses the normal direct-work or user-led handoff route. Admission alone starts neither Review nor Replan.

## Evolution loop

```text
understanding feedback -> better current explanation -> resume original work
        |
        +-> sourced question in existing topic draft
             -> selected factual addition or verified repair
             -> owning knowledge + INDEX + provenance
             -> later explanation reads and applies it
```

When durable knowledge becomes false, update it through a later change and keep provenance. Do not accumulate exceptions in the Harness entry Skill; route conditional detail to the focused reference or capability knowledge.

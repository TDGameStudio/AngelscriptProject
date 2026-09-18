## Public naming decisions

- Load when design introduces a public name or implementation discovers one not listed in its plan.
- Public names include types, modules, namespaces, source/header files, public functions, Automation identities, Harness routes, capabilities and Skills. Private helpers and local variables do not require naming rounds.
- Naming choices belong to the concept's responsibility, scope and users. Explain the role before asking the user to compare labels.
- A name explicitly chosen by the user is settled. Do not re-ask it because a template expects a naming round.

## Inspect the neighbours

- Inspect sibling identifiers, prefixes/suffixes, shared vocabulary and relevant engine/library conventions.
- State what the name must communicate: operation or entity, ownership, lifetime, scope and abstraction level where those distinguish candidates.
- Derive a convention-backed recommendation and meaningful alternatives. Avoid replacing a precise responsibility with a fashionable generic word.
- Check collisions and misleading similarity in the repository, relevant engine/library APIs and existing routes. Search external naming guidance only when useful or requested; naming advice does not override local semantics.
- Prefer consistent familiar terms over clever abbreviations. Check how the name reads in a real caller, path, command or sentence.

## Ask with a more-names path

- Track required names in the owning design. Related independent names may share a round; names depending on an unsettled responsibility wait.
- Send the [Grill explanation](../../grill/references/brief.md) first: the role, current relevant architecture/terms, conventions, candidates and consequences.
- Every naming question includes an explicit “Provide more names” choice. This is an actionable alternative, not approval of the recommendation.
- Selecting it writes or expands `research/naming-<subject>.md` in the current draft. If the discussion has no draft, use the caller's authorized research owner rather than inventing a new lifecycle.
- Organize additional candidates by useful semantic direction, with meaning, fit, ambiguity, collision checks and reasons to prefer/reject them. Do not dump synonyms or impose a candidate-count quota.
- Link the candidate file and explain the meaningful differences in conversation, then return to a naming choice. The name stays unconfirmed until an actual answer chooses it.
- Respect form limits: a recommendation, a meaningful alternative and “Provide more names” can be the visible choices, with the larger comparison in Markdown.

```text
N1 — Name of the store that owns <data> for <lifetime>

A. <convention-backed name> — Communicates <responsibility> consistently with <neighbour>.
B. <meaningful alternative> — Emphasizes <different aspect>; risks <ambiguity>.
C. Provide more names — Expand research/naming-<subject>.md and continue comparing.
Recommendation: A, because <role and convention evidence>.
```

## Preserve vocabulary and apply it

- Record selected names, responsibility, useful rejected alternatives, reason and answer source in the design's Vocabulary and Naming section. CONTEXT retains the key decision and link.
- Keep legacy glossary records readable in place; do not create a separate glossary solely for the new contract.
- After a naming answer, show the relevant architecture with the chosen terms, mapping former to new terms where needed. Update related explanations and interfaces consistently.
- Every task's **Interfaces** lists new public names it introduces, with its design/decision source.

## Names discovered during implementation

- A clear authorized in-scope implementation need not stop for an omitted minor name. Derive the convention-backed name and record `Naming assumed: <name> — <reason>` in Evidence for later visibility.
- A public rename or newly surfaced product/architecture choice can invalidate accepted planning truth; follow Harness's Replan discussion and Gate.
- Do not treat the naming-more-options requirement as a new approval ceremony for every local implementation identifier.
- Frequent assumed public names signal missing design detail; improve future planning rather than interrupting every task.

## External reference directions

- [Epic C++ Coding Standard](https://dev.epicgames.com/documentation/unreal-engine/epic-cplusplus-coding-standard-for-unreal-engine) is the engine-specific source for C++ identifier conventions. Inspect neighbouring project code before applying a rule; a correct prefix does not explain a type's responsibility.
- [Epic asset naming guidance](https://dev.epicgames.com/documentation/unreal-engine/recommended-asset-naming-conventions-in-unreal-engine-projects) applies to content assets. Do not transfer asset prefixes mechanically to C++ classes, Harness routes or Skills.
- [Code Clarity](https://github.com/Lakr233/code-clarity) is an external Skill with naming and repository-convention methods. Its useful direction is to inspect local examples and communicate intent. Its cross-language examples and broader refactoring preferences are not this repository's policy; no installation is required for the naming round.

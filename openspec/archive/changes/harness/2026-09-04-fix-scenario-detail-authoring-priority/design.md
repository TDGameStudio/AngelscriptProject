## Context

Scenario Cards already support clause-owned quoted labels, prose, ordered and unordered lists, examples, and tables. The portable validator intentionally treats those forms as ordinary Markdown. The observed regression is an authoring-policy problem: both the workflow prompt and the live `openspec/config.yaml` rule say rich detail is mainly for a complex clause and separately emphasize compactness, while the regression suite verifies only that the vocabulary is mentioned. Recent agents consequently produced structurally valid but under-explained cards.

## Goals / Non-Goals

**Goals:**

- Make active, clause-by-clause evaluation of useful detail the default authoring behavior.
- Cover the complete Markdown palette instead of equating progressive detail with blockquotes.
- Preserve the ability to omit detail when it adds no durable information.
- Keep detail attached to the exact clause through authoring, update, verification, and synchronization.
- Repair the current durable copies of recently introduced Scenario Cards without rewriting immutable archives.

**Non-Goals:**

- Add parser fields, a rigid label matrix, or a minimum detail count.
- Change `record-v1`, `requirements-v1`, Task DAG semantics, or the portable CLI.
- Require every clause to contain a blockquote, list, example, or table.
- Store transient test output or implementation steps in specifications.

## Decisions

### Use a preference rule with an explicit omission test

Every new or modified behavior clause is actively evaluated. The author should retain the smallest useful combination of supported forms, and may omit a form only when it adds no durable information. This raises the priority without making optional prose machine-required. Empty placeholders and content that merely repeats the clause remain prohibited.

### Treat all clause-owned Markdown forms as peers

The guidance presents quoted labels, short prose, ordered lists, unordered lists, examples, and tables as one palette. A blockquote is useful for concise semantic labels, but it is not the canonical or exclusive form. The selected form follows the information shape: sequence or precedence uses an ordered list, a rule set or examples may use an unordered list, and repeated-field comparison may use a table.

### Test the decision contract, not a detail quota

The static regression test will verify that every maintained authoring entry—including the live generated-instruction configuration and overview mirrors—carries the active-evaluation, smallest-useful-combination, optionality, complete-palette, and exact-clause-ownership decisions. It will reject the two phrases that caused the regression. Representative current cards will prove that `WHEN` and `THEN` details stay clause-owned and that non-blockquote forms are exercised. It will not impose a count on arbitrary Scenario Cards.

### Repair current truth, preserve archived evidence

The current durable requirements introduced by the recent guidance, reconstruction, and Unreal execution Changes receive meaningful detail. The prior archive directories remain unchanged because they are historical evidence of what those Changes contained when closed.

## Risks / Trade-offs

- Richer cards consume more text. The smallest-useful-combination rule and explicit no-boilerplate boundary limit growth.
- Static wording tests can become brittle. Assertions target the policy concepts and known regressive phrases rather than one complete sentence.
- Adding details can accidentally introduce implementation instructions. Verification keeps the existing ownership table and checks that examples describe durable behavior or proof boundaries rather than source-edit sequences.

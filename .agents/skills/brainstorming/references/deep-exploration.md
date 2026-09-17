# Scoped Handoff

- Load before handing an approved scope to `openspec-create-change`; explicit direct work needs no Change handoff.
- Write the selected `designs/<scope>/handoff.md` in the user's draft language. Cover the problem, success criteria, evidence, scope/exclusions, constraints, chosen approach/rationale, meaningful alternatives and flip conditions, architecture/data flow, failure cases and verification.
- Resolve blocking decisions first. Keep accepted nonblocking assumptions and excluded work explicit. Confirm names and the exact target Change; do not manufacture alternatives or ask settled questions again.

## OpenSpec Handoff

- Use these exact identity labels; values identify this scoped handoff, not the topic's current focus:

```markdown
## OpenSpec Handoff

- Scope: <scope>
- Target Change: <domain>/<type>-<scope>-<outcome>
```

- Add affected capabilities, required artifacts and reviewable task boundaries as needed.
- In the selected README, set `design: <scope>`, `status: designed`, and `approval_round: R<n>` referencing the actual recorded approval. An incidental round mention is insufficient.

## Exploration Carryover

- Confirm the required copies, necessary cited findings, decision rationale (talks) and reusable insights (knowledge). Every row needs an exact source, Change-relative target and reason.
- Sources are paths relative to the selected design, optionally with log round anchors. Targets below are examples; use the confirmed names and timestamp for the actual handoff.

```markdown
## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| not-applicable | attachments/drafts/glossary.md | No naming decisions apply |
| ../../findings/example.md | attachments/drafts/findings/example.md | Required implementation evidence |
| ../../log.md#r8 | attachments/talks/talk-20260917-120000-example.md | Confirmed decision rationale |
| ../../findings/example.md | attachments/knowledges/example.md | Confirmed reusable insight |
```

- Replace `not-applicable` with the relevant glossary source when names exist. It is allowed only for the glossary. Include transitive research dependencies needed to make the export self-contained.
- Omit unused example rows. Keep the full transcript, unconfirmed candidates and unrelated sibling research local.
- `harness.change.create` freezes this expected export list in its schema 2 origin marker. Export English copies with provenance; `harness.change.seed.verify` checks every expected file, indexing exactly once and local link closure before Ensure plan.
- Preserve existing schema 1 Change origins. For an older draft, add explicit fields/table only to the selected handoff using actual approval evidence; never bulk-migrate records or repeat approval already given.

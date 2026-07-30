# Requirements Traceability

Captured: 2026-07-25

This table maps every requirement in the five capability specs to implementation-plan tasks and verification evidence. Task numbers refer to `implementation-plan.md`; checklist groups refer to `tasks.md`.

## `wiki-content-architecture`

| Requirement | Implementation plan | Checklist | Primary evidence |
|---|---|---|---|
| ordered topic architecture | Task 3 | 3.1–3.5 | source contract + Docs directory browser test |
| progressive depth vocabulary | Tasks 3 and 5 | 3.3–3.5, 5.1–5.5 | metadata validation + ordering/browser review |
| Unreal AngelScript language features | Task 5 | 5.1–5.2 | exact skeleton/catalog assertions |
| source-backed implementation-principle track | Task 5; source support Task 7 | 5.1–5.5, 8.1–8.7 | internals metadata/evidence + source registry |
| hot reload/live iteration | Task 5 | 5.1, 5.3–5.5 | exact skeleton/pipeline assertions |
| core vs special topics/integrations | Task 5 | 6.1–6.4 | integration kind/dependency contract |
| AngelscriptUHTTool subchapter sequence | Task 5 | 5.6–5.7 | exact four keys/depths + three binding paths + layout/RPC invariants |
| revisioned Hazelight comparison | Task 5 | 5.6, 5.8–5.10 | seven keys, evidence schema, pinned baselines, report/private-source/staleness tests |
| informative landings/placeholders | Tasks 2, 3, and 5 | 2.5–2.6, 3.3–3.4, 5.2–5.3 | required-section contract + visual state |
| migration-compatible entry points | Tasks 3 and 4 | 3.6–3.8, 4.4–4.5 | compatibility allowlist + deep-link tests |

## `wiki-bilingual-document-lifecycle`

| Requirement | Implementation plan | Checklist | Primary evidence |
|---|---|---|---|
| paired physical pages/one logical key | Task 2 | 2.3–2.4 | pair uniqueness contract |
| Chinese reviewed before English | Task 2 | 2.3–2.4 | Chinese-first source validation |
| locale resolution then Chinese fallback | Task 4 | 4.1–4.5 | macro/runtime and Playwright tests |
| stale English via translation revision | Tasks 2 and 4 | 2.3–2.4, 4.3–4.5 | revision contract + stale notice |
| locale-aware navigation/search | Tasks 3, 4, and 8 | 3.5, 4.4–4.5, 9.1–9.2 | directory/link/browser tests and author guide |
| UI fallback distinct from article fallback | Tasks 1 and 4 | 1.2, 4.1–4.5 | reconciliation with multilingual tests |

## `wiki-document-taxonomy`

| Requirement | Implementation plan | Checklist | Primary evidence |
|---|---|---|---|
| formal metadata contract | Task 2 | 2.1–2.10 | fixture and repository/catalog validation |
| native tag hierarchy | Task 3 | 3.1–3.5 | tag source/runtime query |
| orthogonal state in fields | Tasks 2, 3, and 5 | 2.5–2.6, 3.2–3.7, 5.4 | deny redundant tags; field filters |
| legacy classification tags retired | Task 3 | 3.6–3.8 | denylist + zero shipped uses |
| restrained topic-color ownership | Tasks 2 and 3 | 2.5–2.6, 3.1–3.2 | no initial color; eligibility contract |
| stable source keys/revisioned inventory | Tasks 2 and 7 | 2.7–2.8, 8.1–8.7 | source-key and corpus validation |
| integration packaging semantics | Task 5 | 6.1–6.4 | exact kind/dependency contract |

## `wiki-showcase-system`

| Requirement | Implementation plan | Checklist | Primary evidence |
|---|---|---|---|
| three explicit stability tiers | Task 6 | 7.1–7.2, 7.6 | tier tag/field contract and directory |
| Base stable-surface catalog | Task 6 | 7.1–7.4, 7.6–7.9 | B01–B15, including native TW/HTML/embed contracts and focused browser coverage |
| Pattern composition catalog | Task 6 | 7.1–7.3, 7.6, 7.10 | P01–P16 and containment/accessibility/author contracts |
| Lab experiment isolation | Task 6 | 7.1–7.3, 7.6, 7.10 | L01–L11, label/load safety and embed-security graduation boundary |
| verification follows stability | Tasks 6 and 8 | 7.6, 10.1–10.3 | tier-specific tests and artifact review |
| complete catalog without empty pages | Task 6 | 7.1–7.3 | exact 42 IDs; page existence not required |

## `wiki-source-reference-corpus`

| Requirement | Implementation plan | Checklist | Primary evidence |
|---|---|---|---|
| immutable/reproducible snapshots | Task 7 | 8.1–8.5 | exact commit/tree and isolated checkout tests |
| explicit sync absent from normal commands | Task 7 | 8.3–8.7 | network stubs + package command graph |
| private Hazelight source excluded/restricted | Tasks 5 and 7 | 5.8–5.10, 8.1–8.4 | restricted metadata-only keys + synchronizer rejection + rendered-output scan |
| license/provenance boundaries | Task 7 | 8.1–8.5 | notice/subtree classification tests and report |
| stable source-reference keys | Tasks 2 and 7 | 2.7–2.8, 8.1–8.6 | key registry and consumer validation |
| stale/broken reference detection | Task 7 | 8.1–8.6 | changed/moved/ambiguous/missing fixtures |
| raw source outside Wiki boot | Tasks 7 and 9 | 8.1–8.7, 10.3–10.4 | source-boundary/artifact/payload inspection |

## Cross-cutting completion

| Concern | Implementation plan | Checklist |
|---|---|---|
| Chinese author instructions precede English | Task 8 | 9.1–9.2 |
| exact source migration record | Task 8 | 9.3–9.4 |
| focused then complete verification | Task 9 | 10.1–10.4 |
| dirty-worktree preservation | Tasks 1 and 9 | 1.1–1.3, 10.5 |
| Wiki-first/parent-second commit boundary | Task 9 | 10.6 |

No spec requirement is intentionally left without an implementation task or verification surface.

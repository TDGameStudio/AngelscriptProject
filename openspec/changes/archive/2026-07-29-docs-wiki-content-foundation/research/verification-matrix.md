# Verification Matrix

Captured: 2026-07-25

This matrix maps every capability to source-level, runtime, and manual evidence. It prevents the later implementation from treating “the page renders” as sufficient proof of content architecture.

| Capability/contract | Node/source contract | TiddlyWiki runtime or Playwright | Manual review |
|---|---|---|---|
| Fifteen ordered topics | exact keys, unique integer orders, tag parent | directory order and localized captions | sensible grouping and scanability |
| Depth L0–L5 | enum; topic exposes only existing levels | lower depths appear before L4/L5 | beginner can stop before internals |
| Language-feature chapter | required catalog terms present in plan/landing | links and skeletons discoverable | scope matches current fork terminology |
| Hot-reload chapter | required pipeline/change terms present | practical and internals routes work | classification/recovery wording is honest |
| Internals track | `internals` only at L4/L5 unless explicitly waived; source keys required when reviewed | cross-topic directory retains topic/depth | behavior → pipeline → source → tests is understandable |
| UHT sequence | exact four keys/depths; all three binding paths; layout/RPC/source-engine invariants | sequence and cross-links render | function trace distinguishes generated and fallback paths |
| Hazelight comparison | exact nested tag/seven keys; relationship/confidence/revisions/evidence/version/consequence fields | baseline/evidence/stale/private-source labels visible | both architectures are represented without adoption pressure |
| Hazelight engine report | thirteen visible leaf paths; capture date; missing revisions; non-exhaustive marker | limitations remain adjacent to inventory | path/timestamp evidence is not mistaken for behavior proof |
| Hazelight restricted source | registry metadata allows no public excerpt/payload and no normal network command | restricted evidence never renders private text or inaccessible public link | paraphrase and attribution reveal no private implementation body |
| Hazelight performance claims | reviewed claim requires benchmark key/method/revisions | provisional estimate is visibly non-reviewed | method and applicability support the conclusion |
| Special topics | exact six slugs and integration kind; GAS dependency | labels visible | no domain topic is misrepresented as optional plugin |
| Formal metadata | all required fields and enums | caption/description/theme behavior | metadata is not visible noise |
| Topic tags | one primary topic; bounded secondary tags | native tag popup/filter behavior | hierarchy is usable at real volume |
| Legacy tag retirement | denylist and compatibility allowlist | old tags absent; old titles reachable | Home behaves as an entry, not a category |
| Chinese-first lifecycle | Chinese exists/reviewed before English; revision relation | locale resolution and notices | fallback is clear, not misleading |
| Placeholder honesty | status/revision/required sections; excluded from completed count | planned/unreviewed presentation | page is useful for implementers but not authoritative |
| Source provenance | source keys resolve in inventory/registry | evidence links render | claims match pinned current source |
| Source corpus pin | exact commit/tree/license/path policy | selected excerpt works offline | diff/report reviewed before update |
| Source corpus network boundary | normal command graph contains no sync/fetch | offline build succeeds without network | update command is clearly maintainer-only |
| Source reference staleness | anchor/hash validation and consumer list | stale status visible where rendered | moved candidate is not silently accepted |
| Showcase tier contract | exact tag/field/purpose and unique ID | tier indexes and warning | stability promise is intelligible |
| Base | B01–B15 catalog coverage | focused behavior/accessibility/containment tests | representative theme regression review |
| Native TW expressions | B13 parameter/default/quoting/scope/nesting/filter/transclusion inventory | deterministic procedure/function output; no durable writes | preferred form and legacy compatibility are clear |
| Trusted WikiText HTML | B14 semantic/ARIA/escaped-danger contract; deny live script/handlers | nested widgets, keyboard, print, narrow layout; no execution | trusted-author boundary is explicit |
| Web embedding | B15 title/loading/sandbox/referrer/fallback/offline contract | local deterministic case, denied/unavailable case, no unexpected external request | permissions/privacy/offline limitations are visible |
| Pattern | P01–P16 catalog coverage | render/discovery/reading order | composition solves a real document need |
| Lab | L01–L11 catalog coverage | load safety and experimental label | experiment does not masquerade as shipped behavior |
| Compatibility | exact-title allowlist only | old deep links work | body points to mapped topic |
| Raw source boot exclusion | raw path outside load roots and artifact scan | boot store has no raw tree | artifact/payload remains acceptable |

## Focused command set

Run from `Wiki/` after the corresponding implementation exists:

```powershell
pnpm run test:document-content
pnpm run test:source-corpus
pnpm run test:multilingual
pnpm run test:source-boundaries
pnpm run test:product-sources
pnpm run test:playwright -- --grep "document content foundation|Showcase"
```

## Full command set

```powershell
pnpm run check
pnpm run lint:all
pnpm run build:wiki
pnpm run verify
```

The Wiki-only foundation does not require Unreal Engine build or automation. A later article batch that changes plugin behavior or adds executable plugin fixtures must define its own UE verification.

## Required artifact inspection

The final offline artifact is inspected for:

- Home and directories;
- one low-depth and one internals page from both emphasized topics;
- the UHT overview-to-maintenance route and one generated/fallback trace;
- Hazelight baselines, report limitations, one architecture row, and one `future-candidate`;
- one optional-plugin and one engine-domain landing;
- Chinese fallback in English UI;
- stale-English presentation;
- a nonempty placeholder;
- Showcase root, Base, and Lab;
- B13–B15 catalog records and, after graduation, their deterministic native-TW/HTML/embed examples;
- one selected source excerpt;
- absence of the raw source tree from the boot store.

## Failure reporting expectations

Source validators must report:

- stable error code;
- repository-relative source path;
- tiddler title when parsed;
- field/tag/key involved;
- offending value;
- expected constraint.

They should collect independent errors and sort them deterministically. They should stop early only for unsafe filesystem boundaries, invalid snapshot identity, or a condition that makes further results misleading.

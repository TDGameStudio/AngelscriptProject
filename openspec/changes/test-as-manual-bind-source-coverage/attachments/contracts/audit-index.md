# TestSource Contract V2 plan audit index

Date: 2026-08-24  
Mode: OpenSpec plan-only; the audits are read-only evidence and do not prove source, compile, runtime, or external-oracle completion.

## Canonical denominator

The current `TestSource/Generation` V2 scanner is the only callable denominator used by this plan:

| Domain | Sources | Current owner-qualified callables | Source-only files |
|---|---:|---:|---:|
| Bindings | 576 | 2,556 | 0 |
| Containers | 186 | 481 | 14 |
| Debugger | 3 | 4 | 0 |
| Definitions | 519 | 2,073 | 84 |
| Feature | 367 | 1,946 | 56 |
| Gameplay | 262 | 1,463 | 5 |
| HotReload | 209 | 273 | 50 |
| Language | 642 | 2,221 | 33 |
| Optional | 116 | 382 | 0 |
| TestFramework | 38 | 212 | 0 |
| World | 123 | 376 | 7 |
| **Total** | **3,041** | **11,987** | **249** |

Source-only means the scanner finds no callable. It does not mean the file has no test contract: compile diagnostics, type/property declarations, and HotReload version state are represented by source-level assertions without fabricating a helper function.

## Formal audit evidence

| Scope | Sources | Audit-parser current callables | Proposed declarations | Formal attachment | SHA-256 |
|---|---:|---:|---:|---|---|
| Bindings excluding `Bindings/TArray`, Containers excluding `Containers/TArray`, Optional | 812 | 3,255 | 3,526 | `bindings-containers-optional-contract-audit.json` | `8D242BFD173C598E1FA2EFD9FF385F20BC2A9CF7CB2234ED42EC2275DB9BD5D7` |
| Language, Definitions, Feature | 1,528 | 6,248 | 6,248 current proposals plus 53 planned high-risk additions | `language-definitions-feature-contract-audit.json` | `62F433FCC9432DB913346C762ABBBCF8DE613E7E6FF2DAF8EE5B79FA5D1D32AD` |
| World, Gameplay | 385 | 1,839 | 1,839 current proposals plus explicit high-risk additions | `world-gameplay-contract-audit.json` | `80270A4F52A8B54D326A70CD0F1E6FF5F986E53F691C34688AAD6A648677704D` |
| HotReload, TestFramework, Debugger | 250 | 489 | 489 | `hotreload-framework-debugger-contract-audit.json` | `6CC245E0E1F987E3014241B72BF821FF4068B8478721224C3808F511BD7AE922` |
| Bindings/TArray | 8 | 45 | 68 | `../implementation/tarray-contract-v2-audit.md` | recorded by its audit |
| Containers/TArray | 58 | 98 | 145 | `containers-tarray-contract-audit.json` | `221679F35FD5E3362EB45722A3BCC12C35BC155A62C0AA0A8CC7F628346AC7C4` |

The Markdown companion reports carry the rationale and evidence maps. Their hashes are:

- Bindings/Containers/Optional: `0DD288B3D1D1857DA3ABB3E1A8B3D65CF79EEAEF9F3929A8DAED815CA8A0B5BD`.
- Language/Definitions/Feature: `C1A7EC9A16BB19E64912682BBCD4E4B1CD57413424107DA87716DF67DC0BAE2D`.
- World/Gameplay: `19B86188BC5BB4AD722ED70BAF5ABF78AF1A370E65BF48F36AEC465E8503EBED`.
- HotReload/TestFramework/Debugger: `48F4293B6D0F0C5A7897FC36ED2F7544728E1012CF9DD46D8E918666DB5D382E`.
- Containers/TArray: `8A4CBAC3AF103B02134704D522AE03931587668001B0F0F8296F24B56B711BCD`.

## Reconciliation result

The audit parser totals are evidence, not the canonical identity set. The main audit rows plus both TArray audits describe 11,974 legacy callable rows. The canonical scanner describes 11,987 current callable identities. `audit-coverage-reconciliation.json` closes the identity ledger:

- 3,041 / 3,041 source paths mapped;
- 11,987 / 11,987 current callables mapped to unique `sourcePath + owner + declaration + line` identities;
- 11,953 legacy audit rows matched one-to-one;
- 34 current callables missing from the prior audit parsers were added to the plan;
- 21 phantom audit rows were excluded with evidence;
- 16 owner-misattributed rows were repaired;
- zero duplicate current identities, duplicate exact audit rows, or zero-proposal current rows;
- embedded Draft 2020-12 schema validation passed.

Formal evidence:

- `audit-coverage-reconciliation.json`, SHA-256 `85795ED20A569017441ACBAAFDA5BFD9EE55A02DB570E6709D39BB4679F9B72C`;
- `audit-coverage-reconciliation.md`, SHA-256 `B5B00EB627E654045DACF6616E91ACC65E439579B37D434F0783B47BFD670114`.

Identity reconciliation is therefore complete. Declaration/vector/fixture/coverage/line-map review blockers remain separate and must be resolved or explicitly presented as non-executable review decisions in the normalized manifest.

## Plan-resolution supplements

The reconciliation ledger deliberately preserves raw audit candidates. The following supplemental files replace those candidates with owner-qualified review rows and explicit evidence blockers:

| Scope | Canonical current callables | Planned declarations/dispositions | Resolution artifact | SHA-256 | Current design boundary |
|---|---:|---:|---|---|---|
| Bindings excluding Bindings/TArray, Containers excluding Containers/TArray, Optional | 3,276 | 3,546 declarations + 1 explicit retirement | `bco-plan-resolution.json` | `53D3924C679768E7E243315939EF662879B1D6914A2AF7C539BB600F213A24C4` | 42 source-ready; 3,505 evidence-blocked; 30 rows in 13 real duplicate-proposal groups require explicit semantic choice |
| Language, Definitions, Feature | 6,240 | 6,240 final planned identities after 47 high-risk replacements and 6 one-to-one overlays are reconciled | `ldf-plan-resolution.json` | `EEE110C43AC3C034EDA395BEA204F490ED5E3B8F8661828D566F61715E3C22F1` | 5,351 rows have concrete/evidence-derived vectors; the remaining 889 are explicitly `vector-unresolved`; 11 scanner gaps, 2 UPROPERTY scanner artifacts, and 85 compile-failure files retain field-level blockers |
| World, Gameplay, HotReload, TestFramework, Debugger | 2,328 | 2,328 planned identities | `wghfd-plan-resolution.json` | `B45A50FF6A185846AE186C49654A80CE35EE85586CECAA047E677496FA57E096` | 2,049 exact review drafts and 279 evidence-blocked rows; all 1,128 anonymous intermediate outputs are semanticized, 49 DefaultComponent risks are recorded, and 209 HotReload files carry retained/replaced matrices |

The BCO supplement corrected 101 inferred signatures, improved 689 semantic names, removed generic numbered variants, adjudicated all 595 prior blockers/317 candidates/331 unmatched surfaces, and retained evidence blockers rather than fabricating arguments or diagnostics. The LDF and WGHFD rows follow the same rule: an exact candidate signature may be shown for review, but missing typed vector or diagnostic evidence makes the row non-executable.

## Normalized review projection

`attachments/contracts/normalized/manifest.json` deterministically projects all supplements and both TArray audits into the user-review surface:

- 3,041 source files and 11,987 current owner-qualified callable identities;
- 12,624 normalized plan rows: 12,327 proposed callable declarations, 48 explicit retirement tasks, and 249 source-only assertions;
- 7,494 review-ready rows and 5,130 design-blocked rows;
- 16,290 field-level blocker-resolution tasks, 3,041 per-file verification tasks, and 31,975 total checkboxes including 20 plan/protocol/full-corpus closure gates;
- manifest-content SHA-256 `5FB310CF3CA5C5EA470337A473382A42A350B76891EA3F177F7BABBA44F44203`;
- semantic-plan SHA-256 `83FD7412B22357904392335EE8E8082192E1BE5F8903F95987080404692AE914`;
- generated `tasks.md` SHA-256 `C43301111D37477FE30571AF97A2B1619AE756C6395CFDD297E740178E611D57`.

The 48 retirements and 47 new LDF high-risk replacement declarations are represented separately. In particular, a removed aggregate observer is never mistaken for the new raw-state/lifecycle phase that transfers its coverage.

## Status vocabulary

- `contract-review-ready`: declaration, comment, inputs/results/writebacks, vectors, fixture/cleanup, body constraints, coverage, and commands are exact; user/independent review is pending.
- `contract-reviewed`: the accepted normalized row hash, reviewer, and date are recorded; source implementation may start.
- `signature-unresolved`, `vector-unresolved`, `fixture-unresolved`, `coverage-unresolved`, `line-map-unresolved`, `compile-probe-required`: the row remains visible for review but is not executable.
- `runner-blocked`: the source design may be complete, but compile/runtime/external-oracle status remains blocked by an unavailable or out-of-scope driver.
- `existing-unaccepted-implementation-snapshot`: implementation and GREEN evidence exist, but independent/user acceptance has not completed; the task stays unchecked.

## Review gate

No `.as` source task may begin until all of the following are true:

1. Exactly 3,041 source records, 11,987 current callable identities, and 249 source-only records reconcile.
2. Every 1-to-N split is flattened into one proposed callable task per exact declaration.
3. Every proposed callable task includes its semantic name, exact declaration, adjacent English comment, typed vectors, fixture/cleanup, body constraints, status, blocker, and literal verification command.
4. No executable row contains `expand later`, `remaining`, ellipsis, placeholder type/output, generic diagnostic, or a hidden Expected parameter.
5. The normalized manifest and generated `tasks.md` are byte-identical on a second generation/check.
6. The user accepts the plan revision before any TestSource source implementation resumes.

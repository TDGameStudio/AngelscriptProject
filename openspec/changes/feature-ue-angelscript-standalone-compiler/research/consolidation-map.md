# Standalone OpenSpec Consolidation Map

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Decision

`feature-ue-angelscript-standalone-compiler` is the only standalone change lifecycle.

The six former child changes are not independent archive units. Their detailed designs, capability deltas, implementation tasks, and release gates are internal workstreams and phases of this change. The main change remains open through the complete Win64 first-release contract and is archived once.

## Source-to-Destination Map

| Former change | Detailed design destination | Capability destination | Task destination | Source task count |
|---|---|---|---|---:|
| `feature-as-standalone-native-runtime` | `workstreams/01-portable-core-and-native-runtime.md` | `specs/angelscript-standalone-native-runtime/spec.md` | Phase 1 | 29 |
| `feature-ue-as-offline-contract-export` | `workstreams/02-offline-contract-export.md` | `specs/ue-angelscript-offline-contract/spec.md` | Phase 2 | 22 |
| `feature-ue-as-standalone-analysis-core` | `workstreams/03-standalone-analysis-core.md` | `specs/ue-angelscript-standalone-analysis/spec.md` | Phase 3 | 31 |
| `feature-ue-as-standalone-template-adapters` | `workstreams/04-template-adapters.md` | `specs/ue-angelscript-standalone-analysis/spec.md` | Phase 4 | 25 |
| `feature-ue-as-offline-resource-validation` | `workstreams/05-resource-validation.md` | `specs/ue-angelscript-standalone-analysis/spec.md` | Phase 5 | 21 |
| `improve-as-standalone-release-evidence` | `workstreams/06-release-evidence.md` | native-runtime and UE-analysis specs | Phase 6 | 30 |

The former proposals are summarized by the main `proposal.md`; their scope exclusions and implementation boundaries remain in the corresponding workstream documents. The main `.openspec.yaml` is the only lifecycle metadata file.

## Capability Coverage

The six source changes originally contained 64 requirements and 114 scenarios. Subsequent approved planning added the shared LanguageCore capability and the default/project complete-snapshot contract. The current canonical record is:

| Canonical capability | Source requirements | Source scenarios | Current requirements | Current scenarios | Recorded evolution |
|---|---:|---:|---:|---:|---|
| `angelscript-standalone-native-runtime` | 14 | 23 | 14 | 26 | Output/publication, allocator accounting, and packaged default-bundle coverage |
| `ue-angelscript-offline-contract` | 12 | 26 | 13 | 33 | Canonical schemas plus default/project kinds and independent symbol/asset completeness |
| `ue-angelscript-standalone-analysis` | 38 | 65 | 39 | 73 | Hard non-execution plus deterministic default/explicit complete-bundle selection |
| `angelscript-language-core` | 0 | 0 | 8 | 15 | Post-consolidation shared frontend and current global-semantics boundary |
| **Total** | **64** | **114** | **74** | **147** | **10 requirements and 33 scenarios added or clarified after source consolidation** |

Four requirement titles were clarified during the move; their scenarios and intent remain mapped:

| Former title | Canonical title |
|---|---|
| `Unreal-independent standalone build` | `Unreal-independent native runtime build` |
| `Deterministic bundle publication` | `Deterministic offline bundle publication` |
| `Compatible bundle loading` | `Bundle-backed UE-AngelScript analysis and compatible loading` |
| `Initial support boundary` | `Phase-gated support boundary` |

The last rename removes the obsolete notion that adapters and resource validation remain permanently deferred after their own phases. It preserves the original pre-promotion behavior and makes final promotion evidence-dependent.

## Task Coverage

The six source task lists historically contained 158 implementation tasks. The current master task list is authoritative after LanguageCore integration, analysis-task consolidation, lifecycle additions, and the complete-snapshot rewrite: **180 tasks, 133 TDD and 47 non-TDD**.

The initial consolidation rewrote twelve verification/lifecycle descriptions because they formerly named a child change, child `verification.md`, or child archive action:

| Former task | Canonical task |
|---|---|
| native `2.7` | `1.11` |
| native `5.5` | `1.28` |
| native `5.6` | `1.29` |
| offline contract `6.1` | `2.19` |
| offline contract `6.4` | `2.22` |
| analysis core `6.4` | `3.30` |
| analysis core `6.5` | `3.31` |
| template adapters `6.2` | `4.23` |
| template adapters `6.4` | `4.25` |
| resource validation `5.4` | `5.21` |
| release evidence `6.5` | `6.29` |
| release evidence `6.6` | `6.30` |

Those rewrites retain the original commands and acceptance outcomes while targeting phase evidence and strict validation of the canonical change. Later rewrites may combine or expand implementation steps when the design changes; `tasks.md` and `openspec status` define the live inventory rather than the historical source count.

Current task distribution:

| Phase | Current tasks |
|---|---:|
| 0 feasibility | 10 |
| 1 portable core, LanguageCore, and native runtime | 42 |
| 2 offline contract | 22 |
| 3 analysis core | 27 |
| 4 template adapters | 25 |
| 5 resource validation | 21 |
| 6 release | 30 |
| 7 closure | 3 |
| **Total** | **180** |

## Verification Record Map

| Phase | Evidence record |
|---|---|
| 0 | `verification/phase-00-feasibility.md` |
| 1 | `verification/phase-01-portable-native.md` |
| 2 | `verification/phase-02-offline-contract.md` |
| 3 | `verification/phase-03-analysis-core.md` |
| 4 | `verification/phase-04-template-adapters.md` |
| 5 | `verification/phase-05-resource-validation.md` |
| 6 | `verification/phase-06-release.md` |

These files are created when their phase is executed. `verification/README.md` defines the required command, environment, result, count, artifact, disagreement, and follow-up fields.

## Removal Gate

The former child directories may be removed only after all of the following are true:

1. all six detailed designs exist under `workstreams/`;
2. the canonical specs retain the 64 source requirements/114 source scenarios and record the later LanguageCore and complete-snapshot additions, currently totaling 74 requirements/147 scenarios;
3. the current master task list is internally consistent and reported by `openspec status`, currently totaling 180 tasks;
4. Phase 0 and lifecycle closure are present;
5. `openspec validate feature-ue-angelscript-standalone-compiler --type change --strict --no-interactive` succeeds.

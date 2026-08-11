# Planned AS Corpus And Test Scale

This is a capacity estimate for the decision-complete plan, not a requirement to generate a fixed number of files mechanically. The coverage requirements and matrix scenarios are authoritative; implementation may merge naturally cohesive targets or split an oversized target only when it updates the owning matrix, catalogue, test prefix, and verification record at the same time.

## Unique Planned Target Count

The count below deduplicates every explicit `Script/**/*.as` target path in `matrices/*.md`.

| Wave | Themes | Corpus `.as` | Test `.as` | Theme total |
|---|---|---:|---:|---:|
| 1 | Language, Math, Containers, Text, Reflection | 54 | 57 | 111 |
| 2 | Objects, Interop, Inheritance, Interface, Delegates | 23 | 32 | 55 |
| 3 | Actor, Component, World, Subsystems, Timers | 29 | 29 | 58 |
| 4 | Input, Collision, UI, Animation, Assets, Diagnostics | 31 | 31 | 62 |
| 5 | Networking | 8 | 9 | 17 |
| Cross-cutting A | BlueprintLibraries | 19 | 19 | 38 |
| Cross-cutting B | Bindings | 17 | 17 | 34 |
| **Total** | 24 root themes | **181** | **194** | **375** |

The 375 targets are new theme paths, but they are not all greenfield authoring: many are migrations or focused splits of the 27 current example files and the useful roles of current direct test fixtures. BlueprintLibraries and Bindings are cross-cutting tracks whose cases must link existing domain owners and may not duplicate their complete bodies.

## Estimated Final Script Tree

The planned steady state is approximately:

| Category | Count |
|---|---:|
| Curated theme corpus | 181 |
| Themed reflected AS test files | 194 |
| Retained `Example_BehaviorTreeNodes.as` special-purpose sample | 1 |
| Retained reflected test-framework reference | 1 |
| Retained optional GameplayTags legacy fixture | 1 |
| Retained cooked `Script/Game/Example_Actor.as` fixture | 1 |
| **Estimated final `Script/**/*.as` total** | **379** |

The current tree has 37 `.as` files, so the path-level net increase is approximately 342 after obsolete sources are migrated or retired. `Test_ExampleActorFixture.as` is not retained separately after its hot-reload consumer moves to a meaningful themed source.

## Estimated Source Volume

| Source kind | Typical physical lines per file | Planned files | Estimated physical lines |
|---|---:|---:|---:|
| Corpus source card, evidence-bearing API table, and executable workflow | 100–180 | 181 | 18,100–32,580 |
| Reflected AS functional suite, fixtures, and assertions | 70–150 | 194 | 13,580–29,100 |
| **Total** | — | **375** | **31,680–61,680** |

The estimated executable function/test logic, excluding source cards, API-table comments, evidence, prerequisites, and limitations, is approximately 22,000–38,000 lines. The 194 test files are expected to expose roughly 550–950 independent `UFUNCTION(meta=(AngelscriptTest))` leaves because most files need positive, boundary, mutation/lifecycle, and cleanup cases.

These are planning ranges, not acceptance metrics. Passing a line-count or leaf-count threshold never substitutes for a matrix scenario with a real behavioral oracle.

## Scale Guardrails

- A corpus target is created only when it owns a coherent reader workflow and at least one matrix row; no empty theme scaffold is generated in advance.
- An AS test file is created only when its leaves execute a stable project-script behavior or characterize an explicit supported/unsupported boundary; C++ method counts are not mirrored one-to-one.
- Each wave must compile, pass its theme prefixes, pass corpus validation, update the README catalogue, and reconcile its matrix rows before the next wave is accepted.
- Naturally cohesive rows may share a file, but the source card, API table, and test names must make every owned row discoverable. A file may not become an indiscriminate API dump merely to reduce count.
- Oversized files are split by user workflow, not by arbitrary phases or numeric buckets.
- Every new test leaf needs an assertion oracle; logging volume, compilation success, or a constant-return helper does not count as coverage.
- Actual file, line, and test-leaf totals are recomputed after the initial bind/test audit and recorded in `implementation-baseline.md` and final `verification.md`.
- The 204 binding files, 87 Bindings tests, and 18 FunctionLibraries tests are audit inputs, not file-count quotas; one logical provider family may map to an existing domain file, a BlueprintLibraries/Bindings case, or an explicit non-corpus disposition.

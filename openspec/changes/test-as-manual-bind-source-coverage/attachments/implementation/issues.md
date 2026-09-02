# Implementation Review Issues

> Historical issue catalogue from the first 2026-08-21 review. The current recheck resolves the automated structural indicators for `MBSRC-REV-001` through `005`, `007`, `009`, and the source-contract portion of `010`. `MBSRC-REV-006` remains open for five high-impact files; `MBSRC-REV-008` remains pending the external C++ oracle. No Bind or TestFramework task is marked semantically accepted solely from this automated recheck. See `reviews/theme-expansion-recheck-2026-08-21.md`.

Review baseline: 2026-08-21. All issues are open. Exact per-file mappings live in `inventory/testsource-implementation-review.csv`.

## MBSRC-REV-001 — Runner-readable observation contract is undefined

- Severity: Blocking
- Scope: 576 / 576 Bind files; 2,420 / 2,420 `Observe_*` functions
- Evidence: every Bind observation is `void`, has no parameters, and has no reflected framework assertion channel.
- Impact: a future runner can invoke the function but cannot read its pass/fail result, actual result, mutated identity, or cleanup target.
- Required resolution: define an exact callable signature and one external observation channel for every planned symbol. A function-local value never satisfies this issue.
- Acceptance: `observation-contracts.csv` has one unique row per planned callable; the implemented signature matches it; C++-readable output/state/diagnostic is named.

## MBSRC-REV-002 — Observation results are calculated and discarded

- Severity: Blocking
- Scope: 552 Bind files contain detected local `b...Observation...`, `b...Hold...`, or `b...Returned...` variables.
- Evidence: values such as `bNumObservationsHold`, `bTruncToFloatObservationsHold`, and `bRequestExitReturned` are never returned, written out, asserted, or placed on host-visible state.
- Impact: meaningful comparisons exist but have no oracle effect; both true and false produce the same externally visible execution.
- Required resolution: return actual/expected status, write an out observation, or expose an identified state checked by C++.
- Acceptance: no planned scenario terminates with a local-only oracle; the review inventory names the external channel.

## MBSRC-REV-003 — Tautologies and permissive fixture-null success

- Severity: High
- Scope: 67 Bind files; 213 detected tautologies; 45 detected fixture-null success forms. Counts overlap where one expression matches both categories.
- Evidence: `b || !b`, `x == nullptr || x != nullptr`, `x == x`, `x != y || x == y`, and `Fixture == nullptr || Expected`.
- Impact: incorrect bindings and failed setup can pass.
- Required resolution: use deterministic fixtures and exact expected results. Setup failure must be reported separately from the behavior result.
- Acceptance: audit count is zero for known tautology/permissive forms and manual review finds no equivalent exhaustive condition.

## MBSRC-REV-004 — World/Actor/Component fixture contract is missing

- Severity: High
- Scope: World-, Actor-, Component-, collision-, asset-, subsystem-, and network-dependent Bind sources.
- Evidence: all `Observe_*` functions are no-argument; sources use ambient `GetCurrentWorld`/CDOs or self-spawned objects, sometimes accepting absence as success. `UWorld/Test_Behavior_01.as` dereferences the ambient World for `ServerTravel` without a runner-owned fixture contract.
- Impact: meaningful branches are not deterministic; headless/editor contexts can silently exercise only empty/null paths or fail before an observation is published.
- Required resolution: record runner-supplied inputs, setup preconditions, expected setup-failure disposition, and fixture ownership for every environment-dependent callable.
- Acceptance: the per-callable contract names the fixture producer and inputs; source never converts missing required setup into success.

## MBSRC-REV-005 — Lifecycle and cleanup ownership is incomplete

- Severity: High
- Scope: at least the four AActor Bind files with direct spawning; other timer/delegate/console/file/subsystem/global mutations require the same review.
- Evidence: 34 direct `SpawnActor`/`SpawnPersistentActor` call sites in Bind sources and zero actor-destruction call sites; deferred-spawn paths do not publish a finish/abort owner.
- Impact: repeated execution can leak actors, preserve registrations/timers/global state, or leave partial construction behind.
- Required resolution: prefer runner-owned fixtures; otherwise return the created identity and declare exact teardown. Restore all mutable external state.
- Acceptance: setup and cleanup ownership are explicit and every success, early-return, and expected-failure path is covered.

## MBSRC-REV-006 — High-impact host operations are unsafe for default execution

- Severity: High
- Scope: 17 direct calls in 5 files:
  - `TestSource/Bindings/FGenericPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as`;
  - `TestSource/Bindings/FPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as`;
  - `TestSource/Bindings/FPlatformApplicationMisc/Test_NamespaceAndGlobalFunctions_01.as`;
  - `TestSource/Bindings/FPlatformProcess/Test_NamespaceAndGlobalFunctions_01.as`;
  - `TestSource/Bindings/UWorld/Test_Behavior_01.as`.
- Evidence: `RequestExit`, clipboard mutation, `LaunchURL`, and `ServerTravel` are called directly.
- Impact: a generic runner could terminate the host, open an external handler, alter user clipboard contents, or change maps.
- Required resolution: assign `DefaultSafe`, `FixtureIsolated`, `SubprocessOnly`, `DiagnosticOnly`, or `CompileOnlyPendingHarness`; snapshot/restore mutable state where possible.
- Acceptance: none of the five sources is default-executable without the required isolation, and compile-only cases are not counted as functional coverage.

## MBSRC-REV-007 — Knowledge comments are not local enough for generic scenarios

- Severity: Medium
- Scope: 342 `Observe_SurfaceNNN_*` functions; no `Observe_*` declaration is immediately preceded by a scenario comment.
- Evidence: repeated file cards describe a broad group, but generic function names do not reveal the AS surface, chosen boundary, expected value, or ownership rule.
- Impact: review and maintenance require cross-reading the generated task/CSV for every generic symbol; formulaic “consumed” claims can hide discarded results.
- Required resolution: add natural comments beside ambiguous, generic, ownership-sensitive, negative, World, platform, or latent scenarios. Do not introduce a mandatory metadata template.
- Acceptance: a reviewer can understand each non-obvious scenario and its oracle from the source near that scenario.

## MBSRC-REV-008 — TestFramework corpus still needs an independent C++ oracle

- Severity: Pending external oracle
- Scope: 38 / 38 TestFramework files; 103 reflected test methods; 221 detected assertion calls.
- Evidence: all 38 files explicitly name a C++ oracle, but the current change has no driver that verifies discovery, counts, diagnostics, locations, phase order, identity, timeout, or cleanup.
- Impact: the AS unit-test framework would otherwise use itself to prove itself.
- Required resolution: preserve these sources as provisional payloads and implement the independent oracle in the later driver OpenSpec.
- Acceptance: C++ verifies the exact external outcomes required by each framework task. Source presence or internal assertions alone are insufficient.

## MBSRC-REV-009 — Structural plan drift guard

- Severity: Blocking when present; currently clear
- Scope: all 614 planned rows.
- Evidence: current baseline has 614 / 614 paths and no missing planned symbol.
- Impact: future rewrites could accidentally rename or remove a planned namespace/callable while correcting semantics.
- Required resolution: keep the audit check in every source-only rework batch.
- Acceptance: zero missing paths and zero missing planned symbols.

## MBSRC-REV-010 — Corpus status claims are stale

- Severity: Medium
- Scope: `TestSource/README.md` and the original plan-only wording in this OpenSpec.
- Evidence: the README says presence of declarations is the accepted bar and says all non-void/void effects are observed; the implementation review disproves the second claim and raises the semantic bar. The original design context says `TestSource/` is empty.
- Impact: reviewers can mistake structural materialization for functional test coverage.
- Required resolution: this OpenSpec records the corrected state immediately; update `TestSource/README.md` during the source rewrite, after its contract description matches reality.
- Acceptance: documentation distinguishes structural presence, source-semantic acceptance, compilation, execution, and external-oracle verification.

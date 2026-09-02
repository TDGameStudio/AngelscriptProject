# TestSource Implementation Review — 2026-08-21

## Review decision

The current implementation is **structurally complete but semantically not accepted**.

- All 614 planned `.as` paths exist and all planned namespace/callable names are present.
- None of the 576 Bind sources currently has a defined runner-readable observation contract.
- All 38 TestFramework sources are useful provisional payloads, but they remain pending the C++ external oracle already required by this change.
- No per-source implementation task is complete merely because its file and planned declarations exist. All existing checkboxes remain unchecked.

This review does not compile AngelScript and does not modify `TestSource/**`. It reviews the authored source against the OpenSpec contract and current C++ test evidence, then records the required rework in this change.

## Scope and reproducible evidence

The review covers:

- `TestSource/Bindings/**/*.as`: 576 files;
- `TestSource/TestFramework/**/*.as`: 38 files;
- all 614 rows in `inventory/planned-test-sources.csv`;
- representative current C++ tests for value/container behavior, World/Actor fixtures, collision queries, expected diagnostics, and reflected framework behavior.

Run the lexical audit from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec/changes/test-as-manual-bind-source-coverage/scripts/AuditTestSourceImplementation.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec/changes/test-as-manual-bind-source-coverage/scripts/AuditTestSourceImplementation.ps1 -Check
```

Generated evidence:

- `inventory/testsource-implementation-review.csv`: one disposition row for every planned `.as` file;
- `inventory/testsource-review-summary.json`: aggregate review counts;
- `attachments/implementation/issues.md`: issue definitions and affected areas;
- `attachments/implementation/progress.md`: current acceptance state.

The lexical counts are review signals, not a replacement for later parsing, compilation, or execution. A count can prove that a known bad form exists; absence from a regular-expression count does not prove semantic correctness.

## Scorecard

| Dimension | Evidence | Decision |
|---|---:|---|
| Planned paths present | 614 / 614 | Pass, structural only |
| Planned symbols present | 614 / 614 files | Pass, structural only |
| Bind sources | 576 | Reviewed |
| Bind `Observe_*` functions | 2,420 | Reviewed |
| Non-void Bind `Observe_*` functions | 0 | Blocking |
| Bind `Observe_*` functions with parameters | 0 | Blocking for fixture-driven scenarios |
| Void/no-argument Bind `Observe_*` functions | 2,420 / 2,420 | Blocking |
| Bind files with discarded local observation booleans | 552 / 576 | Blocking |
| Bind files with detected tautologies or permissive fixture success | 67 / 576 | High |
| Detected tautological expressions | 213 | High; conservative lexical count |
| Detected `fixture == nullptr || ...` success forms | 45 | High; not additive with tautology count |
| Bind `SpawnActor` / `SpawnPersistentActor` calls | 34 | Cleanup review required |
| Bind actor destruction calls | 0 | High |
| Direct high-impact host side-effect calls | 17 in 5 files | High / unsafe for default execution |
| Generic `Observe_SurfaceNNN_*` functions | 342 | Knowledge-comment review required |
| Generic/immediately documented `Observe_*` functions | 0 / 2,420 immediately preceded by a comment | Medium |
| TestFramework files | 38 | Provisional |
| TestFramework `meta=(AngelscriptTest)` methods | 103 | Positive structural evidence |
| Detected TestFramework assertion calls | 221 | Positive behavioral payload evidence |
| TestFramework files naming the C++ oracle | 38 / 38 | Positive, still pending execution |
| Accepted Bind files | 0 / 576 | Not accepted |
| Accepted TestFramework files | 0 / 38 | Pending external oracle |

## What is already good

The implementation has several useful foundations that should be preserved during rework:

1. Directory and task identity are exact. The 576 Bind paths and 38 framework paths match the plan without missing or duplicate target paths.
2. All planned namespace and callable names are materialized. The rework can proceed in place without another file-layout migration.
3. The boundary between ordinary Bind sources and framework-owned sources is respected. Bind files do not inherit `UAngelscriptTestSuite` or call `FAngelscriptTest`.
4. Many pure-value bodies calculate meaningful exact comparisons. For example, `FMath/Test_NamespaceAndGlobalFunctions_10.as` covers positive, negative, and zero rounding behavior, and `TArray/Test_Queries_01.as` checks empty/populated/container boundary cases. Their main defect is that the calculated result is discarded.
5. The TestFramework corpus is materially deeper than the Bind corpus: it declares real reflected tests, calls the exposed assertions, contains intentional failure leaves, and consistently states which result needs C++ verification.

These positives explain why the implementation should be repaired rather than discarded wholesale.

## Blocking finding: the observation oracle is lost

Every Bind observation has the same externally opaque shape:

```angelscript
void Observe_Something_Nominal()
{
    // Calls and comparisons...
    bool bSomethingObservationsHold = Actual == Expected;
}
```

The local Boolean is destroyed when the function returns. A future C++ runner can call the function, but it cannot determine whether the comparison was true. This is not merely a future-runner gap: the source itself has failed to publish the observation that the runner would need.

Representative cases:

- `TestSource/Bindings/TArray/Test_Queries_01.as`: the exact `Contains`, `Num`, capacity, allocation, and slack checks end in discarded local Booleans.
- `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_10.as`: detailed rounding expectations are calculated correctly but never returned or written out.
- `TestSource/Bindings/AActor/Test_Queries_01.as`: actor and component observations are local, while the created actor identity is not returned to a cleanup owner.
- `TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_01.as`: query results and out values are local and therefore unavailable to the C++ fixture/oracle.

Current C++ tests demonstrate the missing contract:

- `AngelscriptCoverageTArrayAdvancedTests.cpp` exposes AS results as object properties and checks every value through `VerifyByPath` (for example the `TArrayAppendAndMerge` checks around lines 878–884).
- `AngelscriptWorldCollisionBindingsTests.cpp` passes an actual query component into AS, returns an `int`, and checks that result in C++ (`VerifySyncQueryEntrypointSmoke` around lines 67–97 and 132–139).
- `AngelscriptActorComponentManagementTests.cpp` lets C++ own `FAngelscriptTestWorld`, spawn the actor, call the AS function, and verify root, attachment, registration, and ownership (`CreateSceneComponentsRegistersRootAndAttachment` around lines 88–157).

The corrected source contract must use at least one runner-readable channel per scenario:

- a non-void result checked by C++;
- out/inout observation values or an observation record checked by C++;
- host-visible state whose exact owner/identity is passed in or returned to C++;
- an expected diagnostic whose phase, message, count, and location are checked by C++.

A function-local Boolean, logging, or successful return from a `void` function is never an observation channel.

## High finding: tautologies and permissive setup failures create false positives

The audit finds 213 tautological expressions and 45 fixture-null success expressions across 67 Bind files. Examples include:

```angelscript
(bResult || !bResult)
(HitActor == nullptr || HitActor != nullptr)
(DistanceAfter != DistanceBefore || DistanceAfter == DistanceBefore)
OutHit.Distance == OutHit.Distance
Spawned == nullptr || bExpectedState
```

These forms only silence unused-variable concerns. They cannot distinguish a correct binding from a broken one. The last form is especially harmful: failure to create the fixture makes the test pass.

`TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_01.as` is a concentrated example. The query can hit or miss, its actor can be null or non-null, and its distance can change or stay unchanged; every possible result is accepted. The existing C++ collision reference instead constructs deterministic blocking components and requires all three operations and the overlap count to match a specific outcome.

Corrected rules:

- A fixture creation failure is a runner setup failure, never a successful observation.
- An API with multiple valid environmental outcomes must be given a deterministic fixture or explicitly classified as an environment probe; “either result is fine” does not provide functional coverage.
- Equality against self, Boolean complement disjunctions, and null/non-null exhaustions are prohibited as oracles.

## High finding: World, Actor, and host side effects lack ownership policy

The Bind corpus contains 34 direct actor-spawn calls and no actor-destruction call. The AActor sources also include deferred-spawn paths without a visible completion/teardown owner. If a later runner simply invokes these functions, repeated execution can leak actors or leave partially constructed objects in the test World.

Five files directly invoke high-impact host operations:

- `FGenericPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as`: `RequestExit`;
- `FPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as`: `RequestExit` variants;
- `FPlatformApplicationMisc/Test_NamespaceAndGlobalFunctions_01.as`: clipboard mutation/readback;
- `FPlatformProcess/Test_NamespaceAndGlobalFunctions_01.as`: `LaunchURL` variants;
- `UWorld/Test_Behavior_01.as`: `ServerTravel`.

These sources must not become default executable tests merely because a driver appears later. Every planned callable needs an execution policy:

- `DefaultSafe`: deterministic and process/editor-state neutral;
- `FixtureIsolated`: runner creates and owns a World/object/resource and guarantees cleanup;
- `SubprocessOnly`: may exit, travel, or otherwise invalidate the current host;
- `DiagnosticOnly`: expected failure path with a C++ diagnostic oracle;
- `CompileOnlyPendingHarness`: retained only when functional execution is unsafe until a dedicated harness exists; it must not be counted as functional coverage.

Clipboard tests require snapshot/restore. Actor creation requires a returned identity or runner-owned fixture plus teardown. Deferred spawn requires an explicit finish-or-abort rule. Timer, delegate, console, subsystem, global, file, and platform mutations need equivalent ownership recorded per applicable source.

## Medium finding: comments are broad but not sufficiently local

All Bind files use a repeated file-level comment card, even though the design intentionally avoided a mandatory metadata format. The card itself is not the defect; the problem is that 342 generic `Observe_SurfaceNNN_*` functions cannot be understood from their names and none of the 2,420 `Observe_*` declarations is immediately preceded by a scenario explanation.

The rework should not impose a larger ceremonial template. It should instead add natural, knowledge-oriented comments where the function name or behavior is not self-explanatory, especially for:

- `Observe_SurfaceNNN_*` symbols;
- out/inout append-versus-replace semantics;
- alias, identity, ownership, and nullability;
- World, latent, network, platform, and process-state behavior;
- expected diagnostics and deliberately unsupported boundaries.

Formulaic statements such as “the value is consumed” must describe an actual runner-readable result, not a discarded local variable.

## TestFramework disposition

The framework layer should not be grouped with the failed Bind observation shape. Its 38 files contain 103 reflected test methods, 221 detected assertion calls, and explicit C++ oracle notes in every file. Examples include:

- `Assertions/Test_EqualityAndOrderingAssertions.as`: passing overload coverage plus individually named intentional failures;
- `Commands/Test_DoThenFifo.as`: explicit FIFO assertions and an external order/diagnostic oracle;
- `World/Test_WorldActorComponentLifecycle.as`: World, actor, component, BeginPlay, tick, destroy, and cleanup assertions.

However, the framework is testing itself recursively. Until C++ independently checks discovered/pass/fail counts, diagnostics, source locations, phase order, instance identity, timeout behavior, and cleanup, these sources remain **provisional**, not accepted. This is the expected second half of the original design, not a reason to duplicate Bind rewrites inside the framework layer.

## Root cause

The failure is systemic and originates in an incomplete planning contract:

1. The OpenSpec required “observable behavior” conceptually but only planned callable names, not callable signatures or a runner-readable observation ABI.
2. Each generated task ended with an existence/declaration/framework-boundary verification line. That line did not require the result channel, fixture owner, expected value, cleanup owner, or execution policy to be inspectable.
3. Compilation and runner work were intentionally deferred, so there was no executable feedback to reveal that local oracle values disappeared at function return.
4. The implementation therefore optimized for the mechanically checkable parts: all paths, all symbols, all API calls, and broad comments. A `void Observe_*()` plus a local `b...ObservationsHold` satisfied the shallow gate while violating the intended semantic requirement.

The fix must start by strengthening the OpenSpec and task acceptance criteria. Rewriting individual expressions before defining the observation contract would reproduce the same problem in a different form.

## Required rework order

1. Add a per-callable observation-contract inventory keyed by `TaskId + PlannedSymbol`, including exact callable signature, runner inputs, expected output/effect, setup owner, cleanup owner, execution policy, and external oracle.
2. Repair a cross-section pilot covering pure values, containers, World/Actor fixtures, collision out values, one dangerous platform operation, expected diagnostics, and one framework external-oracle handshake.
3. Run the audit and manually review the pilot. No tautological or local-only oracle may remain.
4. Rewrite the remaining 576 Bind sources in the existing per-file task order, using the review CSV to surface file-specific risk flags.
5. Keep all 38 framework files provisional until the later driver change supplies the independent C++ oracle.
6. Update `TestSource/README.md` only after the corpus truth matches its claims; “presence of planned declarations” is no longer an accepted semantic bar.

The exact blocking tasks and acceptance gates are recorded at the start of `tasks.md`. The corresponding normative requirements are recorded in `specs/as-manual-bind-source-coverage/spec.md`.

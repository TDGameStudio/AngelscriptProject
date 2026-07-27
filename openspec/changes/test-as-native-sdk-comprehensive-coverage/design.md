## Context

The repository uses `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK` as the regression boundary for the vendored AngelScript core. The fork is based on 2.33 with selective 2.38 compatibility and deliberate divergences. The previous change reorganized this suite into nine domains and recorded ambitious depth requirements, but its final audit did not connect those requirements to source. A direct reconciliation found 197 of 222 exact minimum scenarios missing, including all 100 exact language scenarios, while native debug/introspection APIs remained largely untested.

This design retains the predecessor's useful domain structure and the methodological lessons from `openspec/changes/test-coverage`/`AngelscriptTest/Coverage`: source authority, scenario-level records, type/role separation, interaction coverage, assertion-layer review, and explicit unsupported boundaries. It strengthens them with stable combination IDs, exact expected-vs-implemented reconciliation, raw-SDK ownership, smaller semantic owners, current formatting rules, and direct native debug coverage.

Planning detail is distributed across:

- `background.md` for user intent, baseline evidence, predecessor findings, formatting/debug gaps, scale, and dirty-workspace preservation;
- `references/ue-as-coverage-lessons.md` for the concrete prior Coverage practices adopted and improved;
- `coverage/coverage-contract.md` for row schema, product policies, evidence, and audit closure;
- fourteen language-theme catalogs for syntax elements and dimensions;
- `coverage/native-debug.md` for callback/frame/local/nested-state/function metadata products;
- `coverage/cross-theme-interactions.md` and `coverage/native-domains.md` for interactions and non-language depth;
- `impact-map.md` for source/document/configuration effects;
- `tasks.md` for implementation order and exact verification commands.

## Goals / Non-Goals

**Goals:**

- Turn the raw native suite into a comprehensive, source-verifiable regression boundary for core syntax, compiler/runtime behavior, native interfaces, and fork-specific semantics.
- Define finite semantic dimensions and complete local Cartesian products wherever axes participate in the same decision.
- Make every implemented, excluded, deferred, or selected-2.38 cell independently identifiable and auditable.
- Close the predecessor's missing scenarios while allowing stronger combinations to supersede old method names.
- Add direct coverage of raw context callbacks, call stacks, source positions, locals, `this`, nested state, concrete stack frames, and function debug metadata.
- Enforce CQTest/raw-engine ownership and current inline-AS formatting, including explicit exact-layout exceptions.
- Scale by semantic products and independently verifiable cases, without a physical-line target or line count as an acceptance criterion.
- Minimize compile/test cycles by implementing coherent large batches, completing static reconciliation, then building and testing.

**Non-Goals:**

- Testing any AngelScript SDK add-on.
- Testing `FAngelscriptEngine`, UE reflection/bindings, Actors/Worlds, DebugServer/DAP, editor debugging, source navigation, or VS Code behavior inside this suite.
- Performing a wholesale 2.38 upgrade.
- Changing production fork semantics merely to make a desired future test pass.
- Declaring completeness from source size, method count, file count, or green subset totals.
- Rewriting the predecessor OpenSpec or presenting its structural results as nonexistent.

## Decisions

### 1. Create a new corrective change instead of editing the predecessor

`refactor-as-native-sdk-regression-suite` remains the immutable record of the structural implementation and verification that actually occurred. This change explicitly supersedes only its depth/completeness claims.

Alternative considered: reopen and rewrite predecessor tasks. Rejected because it would erase the evidence that its audit design permitted 197 missing scenarios to pass as complete.

### 2. Use stable coverage IDs as the completion key

Every planned cell receives a stable ID. Catalogs provide expected IDs; source annotations/declarations provide implemented IDs; test reports provide verified IDs. The complete audit performs set reconciliation and evidence checks.

Alternative considered: use exact `TEST_METHOD` names only. Rejected because one tightly related method may validly run many type cells, while renaming a method should not silently lose or create semantic coverage.

Alternative considered: aggregate method/file counts. Rejected by both predecessor failure evidence and the user's explicit coverage-depth requirement.

### 3. Apply complete products locally, not one unbounded global product

Axes are multiplied completely when they feed the same parse/resolution/ABI/lifetime/state decision. Large cross-theme spaces use named risk-bearing chains. Reduction is permitted only with recorded semantic-independence proof and retained boundaries.

This is not representative sampling by default. It is a decomposition technique: a large global product is partitioned into complete local contracts and explicit cross-contract chains so failures remain meaningful and implementation remains finite.

Alternative considered: multiply every value across all themes. Rejected because independent axes would generate enormous duplicate cases without increasing behavioral distinction, making review and runtime less reliable.

Alternative considered: pairwise-only coverage. Rejected as the default because the user requires complete combinations for many syntax elements and pairwise methods can miss higher-order overload/lifetime/state interactions.

### 4. Separate expected cells from execution grouping

A coverage cell is the smallest acceptance unit. It may be implemented by an independent `TEST_METHOD` or a tightly related batch. A batch must expose each ID, expected value, actual value, exact declaration, and failure independently; it cannot reduce results to an aggregate success count.

Unique invalid syntax, lifecycle, callback, exception, and state transitions generally receive independent methods. Repetitive primitive/type products may share a formatted AS fixture containing multiple entry functions and execute each by exact declaration.

Alternative considered: one test method per cell. Not mandated because it can create excessive registration/runtime overhead and duplicated setup, but it remains preferred where failure isolation or source shape is unique.

### 5. Prefer explicit formatted fixtures; use deterministic generation for proven finite products

Readable `ASTEST_AS_ANSI(R"AS(...)AS")` sources remain the default for singular scenarios. Repetitive finite products may define multiple explicit entry functions or use deterministic builders when checked-in inputs and expected results are readable, offline, independently identified, formatting-compliant, and source-auditable. Function-product implementation proved that builders materially reduce copied slot/signature mistakes while preserving per-cell evidence. Expression products also require builders because precedence, grouping, source shape, evaluation trace, and failure placement must be varied systematically. Invalid cases remain isolated even when their source is generated.

Every generated module version is printed before compilation with its stable ID, module name, explicit begin/end markers, and one-based numbered lines. Successful inputs, expected failures, provider/consumer pairs, and each rebuild/rebind version are all retained in the Automation log. The emitted source and expected result/parse/trace are derived through separate helpers or tables so a generator bug cannot make the same mistake in both sides of the assertion.

Alternative considered: use generation to control line count. Rejected because source size is not an acceptance criterion and opaque generation can hide semantics. Generation is selected only for an enumerated semantic product whose tables, legality rules, independent expectations, printed outputs, and reconciliation IDs remain reviewable.

### 6. Split source by semantic ownership

The final `Language` and `Runtime/Debug` trees use subdirectories and concrete micro-contract owners such as parameter directions, constructor failure cleanup, or local-variable inspection. Existing broad files are migrated and deleted only after reconciliation. The design avoids another 16,000-line single owner like the prior UE struct test while accepting that the total suite may be very large.

No arbitrary per-file line cap is an acceptance gate; reviewability, one failure domain, unity-build symbol hygiene, and clear automation prefixes determine splits.

### 7. Preserve the nine-domain architecture and add deeper sub-prefixes

The stable root remains `Angelscript.TestModule.AngelScriptSDK`. First-level domains remain Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, and Conformance. Language and Runtime Debug add descriptive lower-level prefixes. Existing broad IDs may be replaced after an explicit migration record; no legacy aliases are required.

### 8. Treat current fork, rejection, future 2.38, and absent API as different states

Enabled tests assert exactly one current result. Expressible future semantics compile as Disabled/tagged real tests. A future API whose symbol does not exist is recorded as `ApiDeferred`, not declared locally or mocked as if supported. Active fork rejections are enabled negative tests.

### 9. Native debug is raw context/function behavior only

The new Debug owners call `asIScriptContext`, exported `asCContext`, and `asIScriptFunction` directly. Case-owned callback recorders capture deterministic events. UE DebugServer/DAP remains in the existing `Debugger` layer and cannot satisfy these rows.

### 10. Formatting audit distinguishes ordinary scripts from exact-layout inputs

Ordinary compile/execute fixtures are reformatted. Tokenizer fragments and line/column tests are not blindly dedented: exact-layout cases use preserve-lines helpers, a reason, and expected offset evidence. The audit maintains an exception catalog so intentional layout cannot become an undocumented escape hatch.

### 11. Source-derived audits are executable acceptance tools

The change adds PowerShell audits under its own `scripts/` directory. Planned commands validate:

- catalog schema and unique IDs;
- inherited predecessor mapping;
- expected-to-source reconciliation;
- required API symbol calls;
- evidence declarations and exact owners;
- future-2.38 flags/tags;
- add-on/UE wrapper absence;
- test body gates and prefixes;
- inline-AS wrappers/indentation/braces/blank lines and exact-layout exceptions;
- counts and report consistency.

Static pattern checks cannot fully prove assertion semantics, so tasks also require assertion-layer review and focused runtime verification. The audit is a guardrail, not a substitute for test review.

### 12. Build and test only after large coherent implementation batches

Planning, catalogs, helpers, all language owners, debug owners, non-language closure, formatting migration, and static reconciliation are completed before the planned integration build. A narrowly justified structural characterization build is allowed only if a blocker would invalidate a large amount of subsequent code; it must be recorded. After the integration build, compile fixes are batched. Automation runs proceed from narrow affected prefixes to all nine domains, full SDK, `NativeCore`, and the full suite.

This implements the user's instruction to reduce compilation frequency while preserving a recovery path for genuine structural blockers.

### 13. Preserve dirty work and dual-repository commit order

Before implementation, capture parent and plugin status. Do not edit/stage unrelated files. Source changes are committed in `Plugins/Angelscript` first; parent OpenSpec/docs and the resulting gitlink are committed second. No worktree is created unless the user later requests it.

### 14. Split discovered production repairs from the coverage change

The coverage change owns expected products, regression witnesses, test support,
and audit closure. Production semantic fixes discovered by those witnesses are
owned by linked root-cause OpenSpecs and reconciled at hunk level through
`runtime-change-map.md`. The initial linked owners cover reference-bytecode
ownership/persistence, script-class restore/lifecycle, object-last native
calling convention, and deterministic engine-property defaults.

Alternative considered: retain all ThirdParty changes under this test OpenSpec.
Rejected because it obscures rollback boundaries, makes a green suite appear to
authorize unrelated runtime semantics, and prevents each defect from carrying
its own focused regression and impact analysis.

## Risks / Trade-offs

- **[Combinatorial explosion]** Complete products may produce hundreds of thousands of lines and long runtimes. → Partition into complete local contracts, use risk-bearing cross-theme chains, share setup/fixtures without aggregating results, and split execution prefixes.
- **[False completeness from catalogs]** A row can exist without real assertions. → Require evidence layers, source symbol checks, assertion-layer review, and runtime report reconciliation.
- **[Brittle diagnostic text]** Exact full messages can change for harmless reasons. → Assert result code, owning category, source location, and the smallest stable text fragment; never accept unrelated alternatives.
- **[Debug callback nondeterminism]** Optimization or VM implementation details can alter counts. → Separate contractual order/data from characterization-only details, test optimized/unoptimized modes explicitly, and avoid timing/thread assumptions.
- **[Crash-prone invalid debug access]** Internal frame pointers and reentrant callbacks can destabilize the process. → Start with narrow isolated cases, inspect only returned ranges, avoid arbitrary dereference, and do not batch hazardous cases.
- **[Compile time and memory]** A very large test module can strain unity builds. → Split translation units by semantic owner, keep symbols class-private, audit unity collisions, and use staged prefixes; do not create one giant generated unit.
- **[Test registration overhead]** One method per cell can make discovery and reports unwieldy. → Permit tightly related batches with per-cell IDs while keeping unique behavior in separate methods.
- **[Formatting changes alter line tests]** Dedenting can shift expected positions. → Use preserve-lines wrappers and verify exact offsets before changing expectations.
- **[Current-fork behavior is uncertain]** Old planning records may misclassify a feature as supported. → Add characterization tasks before enabling singular expected behavior; record future/unsupported states separately rather than forcing desired outcomes.
- **[Existing dirty changes overlap]** Coverage, Debugger, and runtime files are already modified. → Default additions to new owners, inspect overlaps before touching an existing file, and stop for user coordination if changes cannot be isolated.
- **[Implementation scale hides low-value duplication]** A physical-line target could incentivize padding. → Never use line count as a gate; require unique semantic IDs and reject duplicate-equivalent rows without a boundary rationale.

## Migration Plan

1. Freeze baseline inventories for current methods, predecessor requirements, public/internal APIs, implementation units, inline fixtures, automation IDs, and dirty files.
2. Materialize machine-readable expected coverage records from the approved catalogs; validate uniqueness/cardinality before test implementation.
3. Add narrow shared support for case IDs, raw fixtures, lifecycle probes, callbacks, diagnostics, and debug capture.
4. Implement all language-theme owners and cross-theme chains in coherent source batches without building per file; record any production defect in a linked root-cause change before repairing it.
5. Implement raw debug/introspection owners and hazardous cases as isolated methods.
6. Close non-language domain/API/implementation gaps and predecessor mappings.
7. Migrate existing broad tests, reformat ordinary fixtures, register exact-layout exceptions, then delete superseded sources only after reconciliation.
8. Run complete static audits; resolve every missing, duplicate, unknown, formatting, ownership, evidence, or boundary item.
9. Run the final integration build; batch compile fixes and rebuild only after a coherent fix set.
10. Run focused theme/domain prefixes, then the full SDK, `NativeCore`, and full suite; diagnose and batch repairs.
11. Update generated counts and documentation from verified reports, perform scoped diff/status review, commit the plugin, then commit parent artifacts/gitlink.

Rollback is source-level for the test expansion: individual new owners can be
reverted without migrating consumer data. Each linked runtime repair has its
own rollback and focused verification boundary, preventing coverage work from
silently changing the fork contract.

## Latest implementation slice — Function direction/default interaction

The current implementation adds one focused raw-SDK owner under
`Language/Functions`: `FFunctionDirectionDefaultTests` generates
11 primitive types × four parameter directions × four default/call states ×
three call targets (global, namespace global, and instance method), for 528
independently identified cells. Each cell has its own module name, source ID,
printed Allman-formatted source, compile/diagnostic branch, reflected
parameter metadata, exact entry declaration lookup, runtime transfer or
writeback observation, and discard/isolation check.

The expected-result function is deliberately fork-aware. By-value omission is
accepted; `&out` and `&inout` omission is rejected. For `&in`, the current fork
accepts omission only when the default literal already has the parameter's
primitive width/type (`int`, `float32`, `float64`, or `bool`); narrow and
unsigned integer cells remain enabled negative characterization cases. The
source uses explicit `float32`/`float64` spellings because bare `float` is
resolved by the fork's engine policy and would not independently characterize
the 32-bit family.

No production runtime, UE binding, add-on, or 2.38-only behavior is changed.
The only implementation file is in the AngelscriptTest submodule; catalog,
source-registry, coverage, task, issue, background, review, and verification
records are parent-repository OpenSpec artifacts. Initial integration compile
defects and the fork-specific default-argument observations are retained in
`issues.md` rather than hidden by weakening the owner.

## Open Questions

- Which old scenarios are genuinely invalid requirements rather than missing implementations? This is resolved during the baseline mapping task and requires a concrete source-backed disposition per row.
- Does the current fork expose every planned typedef/funcdef/try-catch form through the tokenizer/parser path? Characterization tasks decide CurrentFork, RejectByFork, Future238Disabled, or ApiDeferred before bulk implementation.
- Which debug callback counts/order are stable public/fork contracts versus implementation characterizations? The debug inventory marks the distinction before final assertions.
- Is deterministic fixture generation beneficial after the first explicit type products, or would it reduce reviewability? No generator is approved until the implementation review answers this with concrete repetition evidence.

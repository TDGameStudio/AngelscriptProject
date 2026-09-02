# Canonical compiler TDD execution cadence review — 2026-08-30

## User-raised execution problem and recorded decision

This review records the concern raised during CTA-S69 implementation: the
current workflow feels slow when every small correction is treated as a
separate TDD item, each assertion triggers another Unreal build/test host
cycle, and review findings are fixed one at a time instead of being examined
and closed as a coherent set.

The recorded decision is:

- keep test-first evidence for observable compiler behavior and bug fixes;
- stop using one UE RED/GREEN launch per assertion or per small internal edit;
- use static review first to discover the complete reachable problem set at a
  behavior boundary;
- group related findings into one risk cluster and generate several focused
  tests in the same fixture/prefix;
- authenticate one batched RED, fix the confirmed in-scope findings together,
  then authenticate one batched GREEN;
- run the broader Canonical regression gate once after the cluster, rather
  than after every small fix;
- record deferred, dormant and separately scoped findings instead of either
  silently fixing them or losing them.

This is the execution rule for the remaining non-Standalone work in this
change. It is an efficiency correction, not a relaxation of compiler
correctness, rollback, lifetime or semantic-authority evidence.

## Review verdict

The current slowdown is not caused by writing behavioral tests. It is caused
by applying the smallest possible RED/GREEN loop at the wrong execution
granularity for an Unreal Engine automation host. A single assertion is cheap;
repeated UBT invocation, Editor startup, plugin/module loading, discovery,
report export and shutdown are not.

For the remainder of
`refactor-as-canonical-typed-ast-compiler`, use **risk-clustered, batched TDD**:
review one coherent behavior boundary, add the complete high-risk test matrix,
run one class/prefix RED, implement all confirmed in-scope blockers in that
cluster, run one class/prefix GREEN, and then run the broader regression gate
once. Do not launch a fresh UE process for every assertion or mechanically
independent line edit.

This changes execution cadence, not the required evidence standard. Behavior
changes still need a failing test or equivalent compile-time RED before the
implementation is changed.

## Concrete cost observed in the current slice

The CTA-S69 AccessSpecifier publication slice provides a direct measurement:

- Incremental Runtime/Test build: `4/4` actions, **11.327 s** total.
  Evidence: `Saved/Build/build/20260830_000511_749_4dd1a207`.
- One ProductionCodeGen class-prefix run: **126** tests, **30.564 s** total.
  The new field-publication invariant was the only failure: **125 passed,
  1 failed, 0 skipped**.
  Evidence:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_000529_415_11532058/Report`.
- The RED proved the exact issue found by static review: a foreign Canonical
  field access edge is rejected, but `CompileClass()` has already called
  `AddPropertyToClass()`, leaving one Runtime property shell published.
- The matching GREEN completed with **126 passed, 0 failed, 0 skipped** after
  exact field access resolution was moved before Runtime property publication.
  Evidence:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_000751_322_3b0c3f0f/Report`.
- A second, review-derived behavior cluster covered two independent defects in
  one host cycle: AccessSpecifier definition inventory/order still followed
  retained native-node coordinates, and repeated wildcard permission entries
  overwrote rather than accumulated `readonly` / `editdefaults` traits. Its
  authenticated RED was **125 passed, 2 failed, 0 skipped** out of 127 tests.
  Evidence:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_000933_320_46d750e8/Report`.
- After one implementation pass, the same second cluster completed GREEN with
  **127 passed, 0 failed, 0 skipped** in **29.821 s**. Evidence:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_001239_795_80a3a439/Report`.
- A third review-derived Stage 2 integrity matrix added four tests in one host
  cycle. It produced **128 passed, 3 failed, 0 skipped** out of 131: dangling
  owner child, duplicate definition name and duplicate permission DeclId were
  the three intended failures; the foreign-method no-shell test was already
  GREEN. Evidence:
  `Saved/Tests/cta-s69-access-integrity-red/20260830_002146_141_804c4f0a/Report`.
- The corresponding repair completed **131/131 PASS**. Evidence:
  `Saved/Tests/cta-s69-access-integrity-green/20260830_002522_227_f50ffc24/Report`.
- Parser-side silent OOM was kept as a separate producer cluster. Its test-first
  build failed only because the intended deterministic append-seam API was
  absent. After checked growth and the test-only seam were implemented, the
  complete SemaAuthority class passed **423/423**. Evidence:
  `Saved/Build/cta-s69-access-parser-oom-red/20260830_002741_716_2727e0e2`
  and
  `Saved/Tests/cta-s69-access-parser-oom-green/20260830_002913_226_64ccab5a/Report`.
- A final review-derived mutation cluster added AccessSpecifier and permission
  embedded-self-ID cases together. Temporarily removing both production guards
  produced exactly those two failures: **131 passed, 2 failed, 0 skipped** out
  of 133. Restoring the guards closed the same class at **133/133 PASS**.
  Evidence:
  `Saved/Tests/cta-s69-access-self-id-mutation-red/20260830_004429_813_392a1f43/Report`
  and
  `Saved/Tests/cta-s69-access-self-id-green/20260830_004526_833_0fc2a58e/Report`.
- Independent final review then grouped owner, field and method indexed-object
  self-ID authentication into one three-test cluster. The shared RED produced
  exactly those three failures (**147 passed, 3 failed, 0 skipped**) out of
  150, and the one repair pass closed at **150/150 PASS**. Evidence:
  `Saved/Tests/cta-s69-owner-member-self-id-red/20260830_005837_195_de11d284/Report`
  and
  `Saved/Tests/cta-s69-owner-member-self-id-green/20260830_010025_366_326f33e8/Report`.

The failing assertion executes in milliseconds. Most of the wall time belongs
to host startup and orchestration. Repeating the same host cycle for several
closely related assertions would add latency without adding proportionate
confidence.

## Revised execution flow

### 1. Static review and risk clustering

Before changing production code, inspect the whole relevant boundary and
classify findings together:

- semantic authority and exact identity;
- transaction/publication atomicity;
- ownership, allocation and rollback;
- generation-local Runtime projection;
- LEGACY/reference compatibility;
- reachable production paths versus dormant historical branches.

The output of this phase is a small behavior matrix, not a sequence of isolated
implementation TODOs.

### 2. One test matrix per coherent risk cluster

Add multiple test cases or multiple assertions when they exercise independent
facets of the same public behavior. Prefer one test fixture and one UE class
prefix when setup is shared. Each test must still have a single readable
failure reason; batching does not justify combining unrelated behavior into a
monolithic test.

Examples for the current AccessSpecifier cluster are:

- exact Canonical declaration identity survives retained-source poisoning;
- Runtime-only access metadata is rejected before any member shell is
  published;
- a foreign exact field access edge is rejected before its property shell is
  published;
- ordinary method access attaches the exact generation-local Runtime DTO;
- definition projection is staged and owner mutation is atomic.

### 3. One RED for the cluster

Build once after the test matrix compiles, then run the narrowest UE class or
prefix that includes the full matrix. Record the report path and verify that
failures correspond to the intended missing behavior. Unexpected failures are
debugged before production changes.

A single-test run is reserved for diagnosis after a class RED, not used as the
default development cadence.

### 4. Implement all confirmed in-scope blockers

Once the cluster RED is authenticated, fix the complete set of closely related
production problems in one implementation pass. Directly fixing review
findings is appropriate when all of the following hold:

- the path is reachable in the supported product configuration;
- the change is within this OpenSpec's accepted architecture and user-defined
  boundaries;
- the behavior has a RED or the change is genuinely non-behavioral;
- the fix does not silently expand into a separate language feature or restore
  retired architecture;
- ownership and rollback consequences are understood.

No extra user confirmation is needed for these normal, reversible,
in-scope implementation steps.

### 5. One GREEN plus one broad regression gate

After the cluster implementation:

1. rebuild once;
2. rerun the same class/prefix and require every matrix case to pass;
3. run the broader CanonicalAST/Frontend/build boundary once;
4. run static source-boundary scans and `git diff --check` together;
5. record the final evidence in OpenSpec once.

If GREEN reveals a new independent behavior defect, create the next risk
cluster. Do not turn every internal correction into a full independent release
gate.

## What still requires TDD

TDD remains mandatory for changes that affect observable behavior, especially:

- parser/Sema acceptance, rejection or declaration identity;
- verifier admission and fail-closed behavior;
- Stage 2 Runtime shell publication and rollback;
- Bytecode/AOT lowering or execution;
- lifetime, cleanup, exception and partial-construction behavior;
- generation publication, Hot Reload and cache/sidecar restoration;
- any bug fix whose absence can be reproduced deterministically.

For these cases, the test may be one member of a batched matrix. “Batched” does
not mean implementation-first.

## What does not need a standalone micro RED/GREEN cycle

The following work normally does not justify a separate UE launch when it does
not change behavior:

- documentation and review attachments;
- comments and diagnostic wording that tests do not contractually match;
- formatting and mechanical renames with source/build validation;
- adding static scans or inventory notes;
- recording an unreachable or explicitly deferred legacy issue;
- moving already-covered code without changing its contract, followed by the
  existing relevant regression prefix;
- OpenSpec task/evidence synchronization.

If a supposedly mechanical edit changes behavior or exposes a regression, it
is reclassified and handled through the next test cluster.

## Review findings are not all automatic implementation scope

Review should find more issues than the current implementation pass fixes.
Every finding is classified as one of:

1. **blocking and reachable** — add it to the current matrix and fix it;
2. **correct but separately scoped** — record it with code evidence and leave
   implementation to the appropriate OpenSpec;
3. **dormant/unreachable** — record the condition that makes it unreachable;
4. **unproven suspicion** — retain as an audit question, not as a claimed bug;
5. **already covered** — cite the existing test/evidence and avoid duplicate
   work.

This prevents “fix everything found by review” from destabilizing the mainline.
For example, the current fork keeps the old shared-class validation branches,
but class/interface `shared` modifier parsing is commented out in both Parser
and Builder. The access-pointer comparison gap in `isExistingShared` is real at
the source level but is not a reachable CTA-S69 product path. It must be
recorded as dormant/deferred, not used to justify restoring shared language
semantics inside this change.

## Current CTA-S69 application

The revised cadence is now active:

- static review found the field-shell publication ordering defect, native-node
  definition inventory dependency and wildcard trait overwrite defect;
- the first 126-test class RED reproduced exactly the field-publication
  failure, and its matching GREEN passed 126/126;
- the next two findings were grouped into one 127-test class RED with exactly
  two failures, then closed by one 127/127 GREEN;
- the next Stage 2 integrity matrix grouped four negative cases into one
  131-test run, authenticated exactly three missing behaviors, and closed at
  131/131;
- the producer-side OOM question became a separate compile-time RED and closed
  with the full 423/423 SemaAuthority class rather than a nondeterministic
  process-global allocator override;
- the final two exact self-ID review questions were grouped into one mutation
  cycle with exactly two intended failures, then closed at 133/133;
- final independent review grouped owner/field/method self-ID into one
  three-failure 150-test cycle, then closed it at 150/150;
- exact field access is now resolved before `AddPropertyToClass()`, so failure
  leaves no Runtime property shell to roll back;
- access definition inventory and order now come directly from exact Canonical
  owner-child declaration identities rather than retained native access-node
  coordinates;
- wildcard permission traits accumulate with OR semantics, preserving the
  corresponding LEGACY Runtime metadata behavior;
- broader CanonicalAST regressions ran once after the final review repairs and
  are **436/436 SemaAuthority**, **631/631 Compiler** plus **175/175 Frontend**;
- the `AS_NO_COMPILER` reset/member guard mismatch was a mechanical
  configuration correction, so it was fixed by matching the existing compile
  guards and covered by the normal build/static review rather than inventing a
  source-grep test. A dedicated no-compiler/Standalone build remains deferred;
- review also found historical mixin-class source/name access lookup. Static
  reachability review classified it as dormant because the Parser accepts only
  free mixin functions, `RegisterMixinClass()` has no callers and `mixin class`
  syntax is currently rejected; it was recorded rather than expanding CTA-S69;
- Standalone remains explicitly deferred and is not part of the claim.

The review initially recorded Parser-side silent OOM, forged unsealed
access-child integrity and embedded-self-ID authentication as separate
questions. Static review then established reachable contracts and deterministic
seams, so they were promoted into batched risk clusters and fixed or
mutation-authenticated. Dormant shared/virtual-property paths, uniform
`asCString` copy-OOM handling and broader failed-candidate module lifecycle
remain separately scoped questions; their discovery still does not justify
unbounded implementation inside CTA-S69.

## Guardrails

- Product default remains LEGACY.
- The native AngelScript AST remains for LEGACY/reference/differential use.
- HIR does not return.
- CANONICAL does not gain silent LEGACY fallback or a production dual backend.
- Public AST V1 and durable pointer-free identity rules remain unchanged.
- This cadence review does not waive required final validation or authorize
  Standalone changes.

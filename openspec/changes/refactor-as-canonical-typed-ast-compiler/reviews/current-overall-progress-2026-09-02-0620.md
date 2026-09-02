# Current overall progress review — 2026-09-02 06:20 CST

## Executive result

- Authoritative OpenSpec checklist: **110/136 = 80.9%**.
- Unchecked rows: **26**.
- Calibrated engineering completion: **about 84.5%**, reasonable range
  **84–85%**.
- Default-CANONICAL cutover readiness: **about 71%**, reasonable range
  **70–72%**.
- If one rounded planning number is required, use **85%**.
- For auditable task reporting, use only **80.9%**.

The formal counter is unchanged because no additional OpenSpec umbrella row
has completed. The latest official StaticJIT Mode All run nevertheless moved
the CTA-S184a publication chain materially farther: baseline build, Generate,
generated-source build and Verify are all green and deterministic. The final
StaticJIT owner prefix is red and crash-aborted, so Task 15.8 cannot close.

This replaces the stale validation-stage table in the 05:46 review. It does
not rewrite that historical snapshot.

## Authoritative checklist state

- tasks.md: **110 checked / 26 unchecked / 136 total**.
- Parent HEAD: 84e1c0c41578.
- Plugin HEAD: 0816dd453e4a.
- Plugin worktree: 44 modified files, 4,449 insertions and 3,796 deletions.
  Most of the volume is deterministic generated-provider output.
- Parent OpenSpec/task/review edits remain uncommitted while this gate is red.
- Unrelated .claude/skills/openspec-design.md and list/ remain untouched.

Exact unchecked rows:

    0.2, 0.3,
    5.7, 5.8, 5.9,
    7.2, 7.4, 7.5,
    9.1, 9.5, 9.6, 9.7,
    10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9,
    12.2, 12.4,
    13.2, 13.6, 13.8, 13.12,
    15.8

Grouped remaining work:

| Theme | Open rows | Count |
|---|---|---:|
| AST-first cards and complete gate matrix | 0.2, 0.3 | 2 |
| Sema language/lifetime breadth | 5.7, 5.8, 5.9 | 3 |
| TypedASTJIT closure | 7.2, 7.4, 7.5 | 3 |
| Canonical Bytecode artifact/install/differential | 9.1, 9.5, 9.6, 9.7 | 4 |
| production selection, LEGACY isolation and cutover | 10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9 | 7 |
| final focused and All validation | 12.2, 12.4 | 2 |
| review-restored architectural blockers | 13.2, 13.6, 13.8, 13.12 | 4 |
| authenticated lifetime Provider consumer | 15.8 | 1 |

## Latest official StaticJIT Mode All chain

Official entry:

    Tools\RunStaticJITTests.ps1 -Mode All

| Stage | Result | Durable evidence |
|---|---:|---|
| baseline build | **PASS** | Saved/Build/staticjit-testjit_01_baseline_build/20260902_060226_109_50ed870c |
| Generate | **PASS** | Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/20260902_060255_390_335efd81 |
| generated-source build | **PASS** | Saved/Build/staticjit-testjit_03_generated_build/20260902_060709_047_68c9ea62 |
| Verify | **PASS** | Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_04_verify/20260902_060711_464_5f72657e |
| StaticJIT owner prefix | **FAIL / CRASH-ABORTED** | Saved/Tests/staticjit-testjit_05_tests/20260902_061127_197_1776782f |

The baseline build compiled 34 generated actions and linked
UnrealEditor-AngelscriptTestJIT.dll. Generate retained
Candidates=7, Captured=7, Skipped=0 throughout, reported every owned output
unchanged, and published:

    ProviderId =
      7dc70fd55a76cc55d726e32d5c2434713bd93755a32e4dd524a4b7c39c8b5d44
    ProviderGeneration =
      070722af0ec74504ef479e3308f74a584e81381bda674af636114a8d2a671865

The generated-source build was correctly up to date because baseline already
compiled the unchanged outputs. Verify reported the same Provider identity and
returned zero.

The owner run found 405 tests. Before the process crash:

- 39 tests completed Success;
- 3 tests completed Fail;
- 0 tests completed Skipped;
- the 43rd started test crashed with EXCEPTION_ACCESS_VIOLATION;
- the remaining 362 tests did not complete.

RunMetadata records ProcessExitCode 3 and wrapper ExitCode 1, without a
timeout. Summary.json exists only as a crash-degraded summary: the normal
total/pass/fail/skip fields are null and SummarySource is None. Therefore it
would be incorrect to report a complete 39/42 or a complete three-failure
suite result.

## Owner-gate findings and disposition

### 1. Installed Provider command diagnostic schema — small stale assertion

InstalledProviderGenerationDiagnosticsAppearInStableCommandJson still
expects generationDiagnostics.schemaRevision 1 at
AngelscriptStaticJITAotCommandDiagnosticsTests.cpp:36. The installed
diagnostic correctly reports revision 3 after the full-expression grammar and
forgery-firewall change.

Disposition: **OPEN / TEST EXPECTATION STALE**. Update the exact expectation
to revision 3; do not accept arbitrary schema versions. This is not a runtime
semantic defect.

### 2. Fresh Cache V2 route — deferred opt-in prototype failure

FreshCacheV2EnginePublishesAndExecutesCommittedProviderRoute reports 65/69
restored functions, eight compiled misses, four not-cacheable functions and
no exact module-set match.

Disposition: **DEFERRED / NON-GATING FOR THE PRODUCT RESTORE REDESIGN**. Per
the existing scope decision, this opt-in restore prototype failure does not
independently block 136/136. The Cache default-disabled lifecycle boundary is
still a final gate, and AST Body Sidecar remains in scope. It is not correct
to call all Cache work non-gating.

### 3. Differential 1-versus-61 result — oracle authenticity blocker

IsolatedNativeAndPrivateRoutesMatchFreshInterpreterState reaches the first
Bytecode Raw comparison with the two sides equal to 1 and 61. Independent
generated-code inspection shows that
DifferentialInlineBytecodeJIT.generated.cpp evaluates A=6, B=7, true, true to
61, and an independent production Typed-provider case also seals 61.

The current leading scope is therefore the so-called fresh-interpreter side:
CreateCompleteInterpreterFixtureEngineSession, ExecuteInterpreterInt,
generation-profile selection, argument mapping or route pollution. This must
be instrumented before assigning blame to production Bytecode or Typed
lowering.

The same 1-versus-61 result existed in the 2026-08-28
cta-s53-15-8-verify_02_tests evidence, while some older owner runs passed. It
is therefore a recurring, previously unledgered owner-oracle failure, not a
new CTA-S184a regression.

Disposition: **OPEN / HIGH / DIFFERENTIAL ORACLE NOT YET TRUSTWORTHY**. It
blocks Task 15.8 validation because backend parity cannot be claimed, but it
is not yet evidence that the generated Raw function computes the wrong value.

### 4. Object-lifetime generated route — real native access violation

NestedReferenceLifetimeAndRecursionMatchInterpreter completes the reference
case and then crashes in the object-lifetime case. The generated function
loads the string-literal global-storage address into void pointer v_TEMP_11,
but its copy constructor consumes:

    new (Object) FString((*(FString*)((&v_TEMP_11))));

That treats the address of the pointer slot as an FString instead of
dereferencing the FString address stored in the slot. The access violation is
at ASStaticJITAotFixture.c8f22911.EditorDevelopment.jit.cpp:2182, through its
VM entry at line 2349 and the owner helper at
AngelscriptStaticJITAotTests.cpp:5860.

Disposition: **OPEN / CRITICAL / AUTHENTIC GENERATED-CODE DEFECT**. The root
scope is BytecodeJIT indirect-reference system-call argument lowering
(address versus pointed value), not the now-closed copy-constructor dependency
publication defect. The generated manifest contains the copy-constructor and
string-literal reference slots; dependency presence does not make this operand
shape correct.

The automation log's original crash-snapshot directory was empty during the
read-only audit, but the UE crash package retained
`Saved/Crashes/UECC-Windows-79D8EF6D40334A17E423D984ADED1F54_0000/`
with `CrashContext.runtime-xml`, `AngelscriptCrashSnapshot.json`, the captured
automation log and the minidump. Those files, the owner run and generated
source form the durable crash evidence.

## CTA-S184a and Task 15.8

CTA-S184a's source-authentic lifetime summary, installed-provider
diagnostic/forgery firewall, exact copy-constructor dependency, complete
GenerationFacts capture, Generate, generated-source build and Verify have all
advanced to green.

Task 15.8 remains **OPEN** because:

- the final Provider/TypedASTJIT owner validation is not green;
- the differential oracle cannot currently prove interpreter parity;
- a generated object-lifetime route can crash the process;
- the crash aborted most of the 405-test owner matrix.

The Cache V2 opt-in failure is recorded but is not the reason 15.8 stays open.
Even after excluding that deferred item, the oracle blocker and native access
violation independently prevent closure.

## Permanent compound-assignment record

The += family remains exactly four resolved semantic defects:

1. **CTA-S146 — overloaded lvalue:** Object += 7 was represented as generic
   Assign instead of resolved opAddAssign Call.
2. **CTA-S157 — rvalue receiver:** Make() += 7 was rejected because one-time
   receiver materialization was confused with lvalue assignability.
3. **CTA-S177-ORDER — indexed sequencing:** receiver/index effects preceded
   the RHS (1,2,3) instead of required RHS-first order (3,1,2).
4. **CTA-S177-SCALAR-REF-SNAPSHOT — aliasing:** a scalar-reference RHS retained
   an address instead of freezing its pre-mutation value (21 instead of 11).

Tail += 100 remains **REDUCED / NOT REPRODUCIBLE**, not a fifth defect. Its
strengthened fresh/reused-context oracle remains **1/1 PASS** at:

    Saved/Tests/cta-s179-tail-declid-strengthened/
    20260902_011308_781_6e3217c8

None of the current StaticJIT owner failures changes the compound-assignment
issue count.

## Why the formal percentage remains flat

The OpenSpec rows are deliberately broad closure contracts. CTA-S184a gained
real implementation and publication evidence, but Task 15.8 requires the
consumer and owner gates as a whole. A green Generate/Verify chain is not
enough when the executable owner path still has an untrusted oracle and a
native access violation.

The three useful progress numbers are therefore:

- **80.9%** — exact auditable task completion;
- **about 84.5%** — calibrated engineering completion;
- **about 71%** — default-CANONICAL cutover readiness.

The engineering estimate stays near 85% because most structure and the
publication pipeline exist. Cutover readiness is lower because the remaining
work is concentrated in correctness-sensitive lifetime, Bytecode install,
snapshot transaction, differential, entry-point and final-gate umbrellas, and
because the latest executable owner run exposed a process crash.

## Recommended critical path

1. Add a focused RED for the object-lifetime indirect-reference operand shape,
   fix the address-versus-pointed-value lowering, and prove the crash case
   green.
2. Instrument the differential session with selected backend/profile, active
   function route and input/output facts; make the fresh interpreter oracle
   authentic before judging parity.
3. Synchronize the exact installed diagnostic schema assertion from 1 to 3.
4. Rerun the focused three findings, then the complete official StaticJIT
   Mode All chain. Do not report owner totals unless the 405-test run finishes.
5. Continue the planned scalar Return temporary and remaining lifetime matrix,
   then close TypedASTJIT, Bytecode artifact/install, snapshot transaction and
   cutover gates in dependency order.

## Bottom line

> **Formal 110/136 = 80.9%; engineering about 84.5% (round to 85% for
> planning); default cutover readiness about 71%.**

The latest run proves that generation and provider verification are now
substantially healthier than the prior snapshot. It also exposes one
high-priority oracle-authenticity blocker and one critical generated-code
access violation. Task 15.8 and the formal percentage must remain unchanged
until those owner-path failures are closed and the complete matrix runs.

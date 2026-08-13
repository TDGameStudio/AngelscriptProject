# Semantic AOT execution observability and control-flow contract

Date: 2026-08-13

Status: maintained-fork source audit and implementation constraints for
`feature-as-typed-semantic-aot`. This note is research attached to the change;
it is not a Runtime input, a serialized schema, or a claim that the Semantic
backend already implements these behaviors.

## 1. Executive conclusion

Generating readable C++ from typed HIR is only the middle of this change. The
generated body is correct only if it also preserves the maintained fork's
execution-control and observability contracts. The first implementation must
therefore treat the following as eligibility and routing requirements, not as
optional polish:

- script exception propagation and immediate effect suppression;
- bounded recursion before the native C++ stack overflows;
- current function/frame/file/line reporting;
- debugger breakpoint and step callbacks;
- CodeCoverage line hits;
- editor loop-timeout, abort, and suspend safe points;
- exact `for`/`while`/`do-while` continue destinations;
- exact nearest-legal `break`/`continue` ownership and transfer cleanup;
- `switch` selector/case/fallthrough/default/exhaustive-enum behavior;
- single-evaluation mutation plans for assignment, compound assignment, and
  prefix/postfix increment/decrement;
- compiler-selected power overload/conversion behavior rather than C++ `pow`
  guessed from source spelling.

The practical v1 policy is **instrument or route to VM**. A Semantic entry may
run only when its generated profile satisfies all execution capabilities
required by the current session. Otherwise that root and every direct internal
Semantic call that it can reach must use an instrumented Semantic closure or a
VM/approved bridge route. A root cannot be called “debuggable” or “covered”
while it directly calls an uninstrumented child.

This does not require Unreal Engine source changes. It does require integration
with plugin-owned execution state and routing because bytecode alone is not the
owner of debugger, coverage, timeout, or JIT frame behavior.

## 2. Maintained execution-stack evidence

### 2.1 JIT execution deliberately has no active VM context

`ThirdParty/angelscript/source/as_context.h:257-303` defines
`FScriptExecution`. Its constructors save the previous execution/context, set
`tld->activeExecution` to the new JIT execution, and set
`tld->activeContext = nullptr`. It carries the JIT engine/function/binding,
reference table, non-Shipping debug-callstack pointer, and
`bExceptionThrown`. Its destructor restores the previous execution and
context.

Consequences:

- Semantic generated code must participate in `FScriptExecution`; a separate
  unrelated thread-local frame model would make public execution queries and
  exception handling disagree.
- Code that assumes `asGetActiveContext()` is available while native JIT code
  runs is wrong. A bridge that temporarily enters VM must explicitly preserve
  and restore the linked JIT/VM execution chain.
- `FScriptExecution` by itself is not a debugger context. It has no VM stack
  frame/local-variable model and does not reproduce line callbacks.

### 2.2 Top-level and nested JIT calls create execution scopes

`asCContext::Execute()` in `as_context.cpp:906-1030` resolves virtual/imported
targets, acquires the current JIT binding, constructs `FScriptExecution`, sets
its JIT metadata, invokes `VMEntry`, and maps `bExceptionThrown` back to the
context status.

`asCContext::CallScriptFunction()` in `as_context.cpp:1473-1544` attempts the
nested JIT `VMEntry` first and creates another `FScriptExecution`. Only after no
JIT entry is available does it execute the VM recursion check and push a VM
call state.

The Semantic backend should distinguish two call shapes:

1. **entry/bridge call**: establishes or links the execution scope required by
   the existing entry contract;
2. **direct internal Semantic helper**: may share the current execution object
   for efficiency, but still enters a Semantic frame/depth RAII scope so
   recursion, current function, debug frames, and exception unwinding cannot be
   skipped.

Creating a fresh unrelated `FScriptExecution` for every internal helper would
fragment frame identity. Omitting a helper frame entirely would hide recursion
and callstack structure. The implementation needs one reviewed linked-frame
contract rather than choosing per emitter site.

### 2.3 Native JIT recursion is not protected by the VM guard

The top-level VM context checks `m_callStack.GetLength() > 20000` before entry.
The nested script-call path checks `m_callStack.GetLength() > 10000` only after
the JIT path is unavailable. A direct JIT-to-JIT recursive call does not grow
`m_callStack`, so those checks do not bound native recursion.

This is a correctness and crash-safety requirement, not merely a diagnostic:

- every generated Semantic frame, including internal non-root helpers and every
  member of a recursive SCC, must consume a bounded script recursion/frame
  budget before making deeper native calls;
- exhaustion must set the maintained script exception state and return before
  C++ stack exhaustion;
- the budget and exception text/shape must be reviewed against the existing VM
  policy; an arbitrary per-function counter is not sufficient;
- a recursion guard is part of the generated execution profile and must not be
  optimized away in Shipping unless another proven guard owns the contract.

Until this exists, recursive Semantic SCCs should report a stable eligibility
failure such as `UnsupportedExecutionControl` with detail
`RecursionGuardUnavailable`, or route through VM. `UnsupportedRecursionGuard`
may be used as a dedicated enum only if diagnostics need to aggregate it
independently; the design should avoid proliferating enums for every detail.

### 2.4 Current-function and `this` queries need an explicit JIT policy

`asGetActiveFunction()` returns `tld->activeFunction`. The current fork sets and
restores that value around system/native calls (including
`FScopeInformSystemFunction`), but `FScriptExecution` does not automatically set
it to its script `jitFunction`. Consequently, a Semantic root/helper must not
assume that setting `Execution.jitFunction` also makes
`asGetActiveFunction()` report the script body. Before changing this behavior,
add a characterization test for existing Legacy/VM/native callers and decide
whether a Semantic frame owns a scoped script active-function value or whether
public code must query the active execution's JIT function explicitly.

There is a similar asymmetry in the plugin API. `GetStackTrace()` traverses
`FScriptExecution` and its debug frames, including `ThisObject`, but
`FAngelscriptEngine::GetAngelscriptExecutionThisObject()` currently calls only
`asGetActiveContext()` and therefore returns null during JIT execution. The
debug-frame structure already contains linked `ThisObject` values, but a patch
must first define `StackFrame` traversal across nested debug frames, nested
`FScriptExecution` objects, and the previous VM context. Do not fix only frame
zero and leave mixed JIT→VM stacks inconsistent.

Add a table-driven public execution-query audit for file/line, formatted
position, callstack, `this`, and active function across VM, top-level JIT,
direct JIT helper, nested execution, system call, and JIT→VM bridge. This is
more robust than growing one-off query fixes as Semantic support expands.

## 3. Debug position is not debugger/coverage parity

### 3.1 What Legacy StaticJIT currently preserves

`StaticJITHeader.h:280-305` defines `FScopeJITDebugCallstack`. It links one
frame through `Execution.debugCallStack`, stores filename/function/`this`/line,
and restores the previous frame on destruction. The macros at
`StaticJITHeader.h:424-431` create a frame and update its line.

The Legacy generator emits the frame in the function prolog and line updates
when `bEmitDebugMetadataInOutput` is enabled
(`AngelscriptStaticJIT.cpp:551-562,593-600`). This is useful for exception and
public execution-position reporting. Semantic output should preserve the same
source metadata when that output profile requests it.

The profile cannot copy only the prolog. Direct internal Semantic helpers must
push/pop frames, and source-point updates must dominate all relevant exits so
an exception is attributed to the expression/statement that actually ran.

### 3.2 What the debug frame does not preserve

The VM handles `asBC_SUSPEND` in `as_context.cpp:2520-2549`. At these points it
can:

- invoke the configured line callback for always-on mode or modules with active
  breakpoints;
- expose current VM registers/frames to the callback;
- periodically invoke the loop-detection callback;
- stop when the callback changes execution status.

Configured contexts install `AngelscriptLineCallback` and
`AngelscriptLoopDetectionCallback` in `Core/AngelscriptEngine.cpp`. The line
callback drives DebugServer processing and `FAngelscriptCodeCoverage::HitLine`.
The loop callback enforces `EditorMaximumScriptExecutionTime` by setting a
script exception.

Legacy StaticJIT's `asBC_SUSPEND` implementation at
`StaticJIT/AngelscriptBytecodes.cpp:3871-3878` is a no-op. Therefore the
existence of `SCRIPT_DEBUG_CALLSTACK_LINE` does **not** prove any of the
following:

- source breakpoint behavior;
- single-step/step-over/step-out behavior;
- debugger local-variable inspection;
- coverage line-hit behavior;
- editor loop timeout;
- suspend/abort polling.

This distinction must remain visible in documentation and diagnostics. A
generated frame profile may be `PositionOnly`; it must not be labelled
`DebuggerInstrumented` or `CoverageInstrumented`.

### 3.3 Initial routing contract

The runtime route should evaluate an explicit execution-requirements snapshot
before selecting an entry. It need not create a second provider type. Useful
capability bits/fields include:

- `FramePosition` — JIT frame/function/file/line queries;
- `LineCallback` — source-line callback semantics;
- `DebuggerStep` — VM-like break/step control and inspectable locals;
- `Coverage` — line-hit reporting on the supported thread;
- `LoopTimeout` — periodic timeout check;
- `AbortOrSuspend` — cooperative execution-status polling;
- `RecursionBudget` — bounded direct native recursion.

The names are design vocabulary, not a frozen public ABI. The stable rule is:
all requirements must be satisfied by the selected function's reachable direct
Semantic closure. If any required capability is unavailable, the function
routes to VM/Legacy according to the approved fallback policy and diagnostics
report `UnsupportedExecutionObservability` or `UnsupportedExecutionControl`
with a deterministic detail token.

Recommended first-version behavior:

| Runtime condition | Semantic route |
| --- | --- |
| No debugger/coverage/timeout requirement, recursion guard present | uninstrumented or position-only Semantic is allowed |
| Exception/file/line reporting requested | require Semantic frame + source-point metadata |
| CodeCoverage recording | instrument exact approved hit points or route the complete direct-call closure to VM |
| Breakpoint or stepping active | route to VM initially |
| Debug locals inspection required | route to VM initially; optimized C++ temporaries are not a VM local frame |
| Editor loop timeout required | emit approved backedge safe points or route to VM |
| Abort/suspend can be requested | emit approved poll points or route to VM |
| Recursive helper/SCC without native frame budget | route to VM or reject Semantic eligibility |

`AngelscriptLineCallback` returns immediately off the game thread. A Semantic
instrumentation path must not call CodeCoverage or DebugServer directly from an
arbitrary thread to manufacture parity. It must use an approved thread-aware
hook or fall back.

Instrumentation capability affects generated content/profile identity and
invalidation. Instrumented and uninstrumented objects cannot share a content
identity merely because their HIR body is identical.

## 4. HIR source points and safe points

Source span alone is enough for diagnostics but not for runtime observation.
The HIR/lowering plan should preserve explicit source points and safe-point
roles at least at:

- function entry;
- effectful statement/expression boundaries that can throw;
- loop/body entry and each loop backedge;
- call boundaries;
- `continue` transfer points and their target phase;
- exception-producing switch default edge;
- returns and bridge transitions where the frame changes.

This metadata does not force v1 to instrument every point. It lets eligibility
determine whether a requested profile can be emitted without consulting
bytecode. The emitter must not reconstruct safe points from C++ text after
lowering.

Coverage and debugger line events need an explicit event-selection policy. The
same source line may contain multiple HIR nodes, and blindly hitting every node
would inflate coverage or step differently from VM `LineInstr`/
`asBC_SUSPEND`. The implementation should first capture/compare the compiler's
line-event authority, then either emit equivalent events or route to VM. “Every
HIR source span is a line callback” is rejected.

## 5. Structured control-flow semantics

### 5.1 Transfer nodes require explicit verified targets

`Break` and `Continue` cannot be represented only as `target=nearest`. The
meaning of “nearest” depends on lexical ownership and construct kind, and a
`switch` nested in a loop is the counterexample:

- `break` in the switch targets that switch;
- `continue` in the same switch targets the enclosing loop, never the switch.

Each HIR transfer node therefore records the stable target statement ID. HIR
verification builds the lexical parent map and proves that the target is the
nearest legal enclosing construct:

- `continue`: `For`, `While`, or `DoWhile`;
- `break`: `For`, `While`, `DoWhile`, or `Switch`.

A dangling, non-ancestor, wrong-kind, or skipped-nearer target fails with
`InvalidControlTarget` before eligibility/emission. The synthetic fixture
schema v3 now freezes this rule.

### 5.2 Loop phase order is part of the HIR contract

Maintained compiler evidence in `as_compiler.cpp:5711-6129` fixes the control
phases:

- `for`: initializer once, condition, body safe point/body, continue target,
  increment expression list, then condition;
- `while`: condition, body safe point/body, then condition; `continue` targets
  condition evaluation;
- `do-while`: body, continue target/safe point, trailing condition; `continue`
  evaluates the trailing condition rather than jumping directly to the body.

The HIR loop statement should store ordered phase children (`initializer`,
`condition`, `body`, `increment`) and the transfer target should identify the
loop statement. Lowering derives the target phase from loop kind. Alternatively
the HIR may store an explicit target-phase enum, but the verifier must reject a
phase inconsistent with the loop kind.

Tests must include side effects and exceptions in every phase. A result-only
loop test can pass even when `continue` skips an increment or evaluates a
condition twice.

### 5.3 Transfer cleanup is semantic, even when v1 scalar locals are trivial

`CompileBreakStatement()` and `CompileContinueStatement()` walk variable scopes
and emit destructors for values that leave scope before jumping
(`as_compiler.cpp:6132-6177`). The v1 scalar-only slice may have no managed
destructor, but the transfer edge still needs an explicit cleanup plan. The
verifier/eligibility layer should calculate the exited scopes and prove their
cleanup set is empty/trivial. A later object slice can then attach concrete
cleanup actions without redefining `break`/`continue`.

If an exited scope owns managed state and no exception-safe cleanup plan exists,
the root remains `UnsupportedLifetime`; emitting a C++ `break` and trusting
host RAII is not a demonstrated AngelScript lifetime equivalence.

### 5.4 `switch` is more constrained than C++ source spelling suggests

`CompileSwitchStatement()` establishes the maintained behavior:

- selector and case values must be integer/unsigned/enum-compatible;
- selector is currently converted to 32-bit (`TODO` remains for 64-bit);
- every case expression must be a compile-time constant;
- duplicates are rejected and optional enum case types are checked;
- empty switch is rejected;
- `default` must currently be last;
- bare declarations directly inside a case are rejected; an explicit nested
  block is required for such scope;
- case bodies preserve fallthrough, and nonempty implicit fallthrough warns
  unless explicit `fallthrough` syntax is present;
- an exhaustive enum switch without `default` routes an unexpected runtime
  enum representation to a generated exception edge whose message is
  `Invalid enum value passed to switch`.

Semantic HIR must retain selector normalization, ordered cases, constant values,
default/fallthrough disposition, case/body scope, and the exhaustive-enum
invalid-value edge. Emitting an ordinary C++ `switch` with no default would
silently continue instead of raising the maintained script exception. C++ enum
typing also must not replace the maintained 32-bit selector conversion.

## 6. Mutation and operator lowering

### 6.1 Assignment and compound assignment are mutation plans

`CompileAssignment()` compiles the right expression recursively before the
left target. Primitive compound math then deliberately merges RHS bytecode
before LHS bytecode (`as_compiler.cpp:16865-16875`). Ordinary eager binary
operators may use a different merge order.

A verified mutation HIR node should therefore contain at least:

- target/address expression and symbol/storage identity;
- old-value read, when required;
- RHS expression;
- authoritative evaluation sequence;
- selected operator and exact operand/result types;
- conversion plan;
- one final store;
- exception boundaries that suppress later evaluation/store.

The target must be evaluated exactly once. Generated `lhs op= rhs` is allowed
only when analysis proves C++ evaluation, conversion, overflow, and exception
behavior exactly match the recorded plan. Otherwise the emitter uses explicit
typed temporaries and a final store.

Property accessor get/compute/set and object overloads add receiver/index
evaluation, lifetimes, and calls. They remain outside the v1 scalar slice rather
than being misclassified as primitive compound assignment.

### 6.2 Prefix and postfix results differ

For primitive prefix `++/--`, the compiler requires a mutable assignable
lvalue/reference and mutates it; the result represents the same updated
reference/value semantics. For postfix `++/--`, it copies the old value to a
temporary before mutating through the retained reference and returns the old
value (`as_compiler.cpp:14982-15179`).

HIR must not encode both as a generic `Increment` node with a display flag.
Tests need to observe both returned value and final storage, including nesting
inside another effectful expression and the maintained warning/config policy
for complex increment/decrement expressions.

### 6.3 Power support is narrower than the token set

The maintained compiler selects integer power opcodes but reports
`Cannot pow on integer values`; integer power is therefore not a valid runtime
Semantic capability merely because Legacy bytecode classes exist. Constant
folding separately detects `TXT_POW_OVERFLOW`.

Valid primitive runtime shapes include float32 power, float64 power, and
float64 with a compiler-normalized 32-bit integer exponent (`POWdi`). The
emitter must consume the resolved operand types/conversion node. It must not
pass the original wide integer source value to a C++ overload after the
compiler already narrowed it.

The authoritative regression surface is
`AngelscriptNativePowerOperatorTests.cpp`; the implementation should reuse it.
The conservative v1 policy is to keep power unsupported until every claimed
float/double shape has VM/Legacy/Semantic differential coverage for conversion,
non-finite/overflow behavior, constant folding, and exception state. Integer
power must never be advertised as supported while the frontend rejects it.

## 7. Required implementation changes

### 7.1 HIR/compiler

- Add explicit target statement IDs to `Break`/`Continue` and verify the nearest
  legal lexical target.
- Preserve ordered loop phases and enough source/safe-point metadata for later
  instrumentation without bytecode inspection.
- Preserve switch selector normalization, case constants/order, fallthrough,
  default/exhaustive disposition, case scopes, and invalid-enum exception edge.
- Represent assignment/compound/prefix/postfix as exact single-evaluation
  mutation plans.
- Preserve compiler-selected power operand/result conversions.
- Calculate transfer cleanup sets; only empty/trivial sets are eligible in the
  initial scalar slice.

### 7.2 Semantic analyzer/emitter

- Accept an explicit execution profile/requirements snapshot.
- Compute capability closure over all direct internal Semantic helpers/SCCs.
- Reject or reroute when frame, recursion, safe-point, coverage, debugger, or
  timeout requirements cannot be satisfied.
- Emit frame/depth RAII for every entered Semantic function/helper.
- Check exception state after every safe operation boundary that may fail.
- Generate exact loop phase order and verified transfer targets.
- Emit the exhaustive-enum invalid-value exception edge.
- Materialize mutation targets/values exactly once and use scalar edge helpers
  rather than host undefined/implementation-defined behavior.

### 7.3 Runtime/provider routing

- Keep execution requirements separate from provider kind; route among entries
  already present.
- Treat capability/profile bits as content/route identity and invalidation
  input.
- Ensure a root cannot direct-call a child that lacks current-session required
  instrumentation.
- Route breakpoint/stepping/local-inspection sessions to VM in v1.
- Route coverage/timeout/abort sessions to VM unless the generated provider
  explicitly advertises an approved equivalent hook profile.
- Preserve the linked JIT/VM frame when a scalar bridge enters interpreter
  execution.

## 8. Verification matrix

| Area | Minimum proof |
| --- | --- |
| JIT execution position | live `FScriptExecution` + `FScopeJITDebugCallstack` queried through public API |
| Frame nesting | Semantic root → direct helper → bridge/VM → return restores each previous frame |
| Public execution queries | file/line, position, callstack, `this`, and active function agree for VM/JIT/mixed stacks |
| Recursion | self and mutual recursive SCC stop with script exception before native stack overflow |
| Debug route | active breakpoint/step requirement selects VM; no Semantic entry counter increment |
| Coverage route | recording session either receives matched lines from approved hooks or selects VM |
| Timeout | infinite `for`, `while`, and `do-while` stop through approved timeout route |
| Control targets | switch-in-loop and loop-in-switch prove nearest legal `break`/`continue` target |
| Loop phases | side effects/exceptions in condition, body, continue path, and increment preserve order |
| Switch | default-last compile rule, fallthrough, scoped declarations, duplicate case, exhaustive enum invalid value |
| Mutation | RHS-before-LHS assignment/compound order, one target evaluation, prefix updated result, postfix old result |
| Power | reuse native SDK matrix; unsupported integer power never enters Semantic |
| Closure | instrumented root with uninstrumented direct child is rejected/rerouted |
| Determinism | instrumentation profile changes content identity; identical profile/source is stable |

Existing test oracles to reuse instead of inventing parallel semantics:

- `AngelScriptSDK/Compiler/AngelscriptNativeNestedTargetTests.cpp`
- `AngelScriptSDK/Compiler/AngelscriptNativeSwitchTests.cpp`
- `AngelScriptSDK/Compiler/AngelscriptNativeForClauseTests.cpp`
- `AngelScriptSDK/Compiler/AngelscriptNativeAssignmentOperatorTests.cpp`
- `AngelScriptSDK/Compiler/AngelscriptNativeIncrementOperatorTests.cpp`
- `AngelScriptSDK/Compiler/AngelscriptNativePowerOperatorTests.cpp`
- `AngelScriptSDK/Compiler/AngelscriptNativeEagerExpressionOrderTests.cpp`
- `StaticJIT/AngelscriptStaticJITDebugCallstackTests.cpp`
- StaticJIT generated-output tests for frame/line macros.

## 9. Small test-first patch found during research

The public `FAngelscriptEngine::GetAngelscriptExecutionFileAndLine()` path was
characterized with a real active `FScriptExecution` and
`FScopeJITDebugCallstack`. The test exposed that the implementation entered the
debug-frame dereference branch only when the pointer was null. The minimal fix
changes the condition to `DebugStack != nullptr`.

This patch is useful independently of Semantic AOT: it closes the existing
public JIT execution-position path that Semantic will reuse. Its focused RED /
GREEN and broader StaticJIT debug-callstack results are recorded in
`research/patches/execution-observability-and-control-flow-test-first-patch.md`.

It does **not** add line callbacks, stepping, coverage, or timeout support to
Legacy/Semantic JIT. It validates only live top-frame filename/line reporting.

## 10. Stable failure vocabulary

Keep the fallback enum set small and use stable details:

- `InvalidControlTarget` — HIR verifier failure for dangling/wrong/non-nearest
  transfer targets;
- `UnsupportedExecutionObservability` — current execution requires debugger,
  coverage, or frame behavior not present in the selected generated profile;
- `UnsupportedExecutionControl` — recursion budget, timeout, suspend, abort, or
  safe-point behavior is unavailable;
- existing `UnsupportedLifetime` — transfer/exception cleanup cannot be proven;
- existing `SuspendOrExceptionState` — called/body behavior can suspend or has
  unsupported exception state.

Suggested deterministic details include `DebuggerStepUnavailable`,
`DebuggerLocalsUnavailable`, `CoverageHookUnavailable`,
`LoopTimeoutSafepointUnavailable`, `AbortPollUnavailable`,
`RecursionGuardUnavailable`, `DirectCalleeProfileMismatch`, and
`TransferCleanupUnavailable`. Diagnostics should include processed source
provenance and required/available capability sets without exposing pointer
identities.

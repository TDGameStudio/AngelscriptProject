# Test-first patch: JIT execution position and Semantic execution contracts

Date: 2026-08-13

Purpose: preserve an application-ready characterization patch found while
auditing `feature-as-typed-semantic-aot`, then turn the wider execution/control
findings into concrete future patch cells. This file is research guidance, not
an instruction to overwrite the current dirty workspace wholesale.

## 1. Landed local characterization patch

### 1.1 Bug contract

`FAngelscriptEngine::GetAngelscriptExecutionFileAndLine()` is the public query
used while JIT code owns `tld->activeExecution`. When a non-null
`FScopeJITDebugCallstack` frame exists, it must return the live top frame's
filename and line.

The previous branch condition entered the dereference body only when
`DebugStack == nullptr`. In practice the safe null case returned empty/-1 and
the live-frame case also returned empty/-1. Semantic AOT will reuse this
execution-position seam, so the defect was characterized independently before
adding any Semantic code.

### 1.2 RED test

File:

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITDebugCallstackTests.cpp`

Add CQTest class/prefix:

```cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptStaticJITExecutionPositionTests,
	"Angelscript.TestModule.StaticJIT.DebugCallstack.ExecutionPosition",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
```

The fixture creates/resets its engine through `BEFORE_ALL`/`AFTER_ALL`, enters
`FAngelscriptEngineScope`, constructs a real `FScriptExecution` over game-thread
TLD, pushes:

```cpp
FScopeJITDebugCallstack Frame(
	Execution,
	"ExecutionPosition.as",
	"ObservePosition",
	73,
	nullptr);
```

It calls the public query and asserts filename `ExecutionPosition.as` and line
`73`. It does not call a new `ForTesting` accessor and does not mock the debug
stack layout.

RED evidence:

- build log:
  `Saved/Build/build/20260813_093817_142_9b0a3b57/Build.log`;
- focused report:
  `Saved/Tests/semantic-aot-jit-position-red/20260813_093841_016_d1fe53c8/Report`;
- result: `0 succeeded / 1 failed`;
- failure: `JIT execution-position lookup should return the live top-frame filename`.

This is a meaningful RED: the real active execution and non-null frame are
present; the public query takes the wrong branch.

### 1.3 Minimal production patch

File:

`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`

Patch only the condition in
`FAngelscriptEngine::GetAngelscriptExecutionFileAndLine()`:

```diff
-       if (DebugStack == nullptr)
+       if (DebugStack != nullptr)
```

Do not copy the complete current file from this workspace: it contains
unrelated active provider/cache work. The one-line conditional hunk and the
focused test class are the complete patch owned by this research slice.

### 1.4 GREEN commands and evidence

The validation commands are:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunBuild.ps1 `
  -ExtraArgs -NoHotReloadFromIDE `
  -TimeoutMs 1800000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.DebugCallstack.ExecutionPosition" `
  -Label semantic-aot-jit-position-green `
  -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.DebugCallstack" `
  -Label semantic-aot-jit-debug-callstack-green `
  -TimeoutMs 600000
```

The first GREEN attempt correctly stopped because another authorized Shipping
package run owned the main-workspace build/test mutex. It was not killed or
bypassed. After that run released the mutex, the same commands produced:

- GREEN build: succeeded, 4 UBT actions;
  `Saved/Build/build/20260813_100618_182_f4d002a1/Build.log`;
- focused GREEN: `1/1 passed`, `0 failed/skipped`;
  `Saved/Tests/semantic-aot-jit-position-green/20260813_100645_232_42c3b971/Report`;
- broader debug-callstack GREEN: `2/2 passed`, `0 failed/skipped`;
  `Saved/Tests/semantic-aot-jit-debug-callstack-green/20260813_100748_444_bab852ec/Report`.

This completes the focused RED/GREEN proof for the one-line public execution-
position fix while preserving the existing scope push/pop regression.

### 1.5 Scope limit

This patch proves only live JIT top-frame filename/line reporting. It does not
add or prove:

- DebugServer breakpoints or stepping;
- inspectable locals;
- CodeCoverage hits;
- editor loop timeout;
- abort/suspend safe points;
- direct native recursion protection.

Those are separate execution capabilities below.

## 2. Future patch cell A — explicit HIR control targets

### RED

Extend `AngelscriptNativeTypedSemanticIRTests.cpp` with a nested shape:

```angelscript
for (int I = 0; I < 4; ++I)
{
	switch (I)
	{
	case 1:
		continue;
	case 2:
		break;
	default:
		break;
	}
}
```

Assert the continue HIR targets the `For` statement ID while both inner breaks
target the `Switch`. Mutate the continue target to the switch and require
`InvalidControlTarget`. Add dangling, sibling/non-ancestor, wrong-kind, and
skipped-nearer mutations.

The research-only equivalent already exists in schema-v3
`research/fixtures/semantic-aot-v1/loop-switch` and
`Test-ValidateFixtures.ps1`; it is a preflight oracle, not production coverage.

### GREEN implementation anchors

- `ThirdParty/angelscript/source/as_typed_semantic_ir.h/.cpp`: add
  `TargetStatementId` to transfer nodes and verifier parent/ancestor checks.
- `ThirdParty/angelscript/source/as_compiler.cpp`:
  `CompileBreakStatement`/`CompileContinueStatement` capture the same lexical
  construct identity that owns the compiler label stack.
- Do not store bytecode label numbers; they are not structured HIR identity.
- Normalized dump spells `target=T<n>` deterministically.

### Runtime/golden gate

Reuse `AngelscriptNativeNestedTargetTests.cpp` and add generated-output/runtime
counter cases for switch-in-loop and loop-in-switch. Result-only assertions are
insufficient; counters must show the intended phase/construct was exited.

## 3. Future patch cell B — exact loop phases and switch edge

### RED

Add one fixture per loop kind with visible effects in condition/body/increment
and an exception variant in each phase:

- `for continue` must execute increment then condition;
- `while continue` must execute condition;
- `do-while continue` must execute trailing condition.

Add exhaustive enum switch input created by an out-of-domain integer cast and
assert VM/Legacy report `Invalid enum value passed to switch`. Semantic must do
the same rather than fall out of a C++ switch.

Compile-time cases also cover non-integral/nonconstant/duplicate cases,
default-not-last, empty switch, bare case declaration versus declaration in a
block, explicit fallthrough, and nonempty implicit-fallthrough warning.

### GREEN implementation anchors

- HIR loop node fields: ordered init/condition/body/increment child IDs plus
  source/safe-point roles.
- HIR switch fields: selector conversion, ordered case constants/body/scope,
  fallthrough/default, exhaustive enum flag, invalid-value edge.
- Emitter uses structured C++ and verified transfer ownership, but emits an
  explicit invalid-value exception branch when HIR requires it.
- Analyzer calculates exited scopes and accepts only empty/trivial cleanup in
  v1; non-trivial cleanup remains `UnsupportedLifetime`.

## 4. Future patch cell C — single-evaluation mutation plan

### RED

Reuse the maintained assignment, increment, and eager-order test suites. Add
HIR assertions and generated counters for:

- assignment RHS effect/exception before target effect;
- compound RHS/target order and exactly one target evaluation;
- exactly one final store;
- prefix returns updated value and final storage is updated;
- postfix returns old value and final storage is updated;
- nested mutation as a call operand;
- target/RHS exception suppresses later phases/store.

Power uses `AngelscriptNativePowerOperatorTests.cpp`; integer power stays a
compile rejection, while every claimed float/double form must preserve the
compiler-selected conversion including the 32-bit exponent used by `POWdi`.

### GREEN implementation anchors

Define a mutation record rather than a generic binary operator:

```text
target/address -> optional old value -> RHS -> operator/conversions
               -> result -> one store -> expression result
```

The authoritative evaluation sequence is explicit. The emitter materializes
typed temporaries and may use C++ compound syntax only after a verifier/analyzer
proof that it is identical. Property getter/setter mutation remains outside
the first scalar slice.

## 5. Future patch cell D — frame/depth RAII and recursion budget

### RED

Add generated Semantic fixtures for:

- root → direct internal helper → return;
- root → direct helper → scalar VM bridge → return;
- helper exception with top position attributed to the helper source point;
- self recursion and mutual recursion beyond the configured script budget;
- every path restores the previous `debugCallStack` and execution frame.

The recursion test must run out-of-process or under the existing automation
crash-safety timeout so a missing guard cannot take down the validation driver.
The expected result is a script exception, not OS stack overflow, access
violation, or timeout.

### GREEN implementation sketch

Introduce a private generated-code helper owned by Runtime, conceptually:

```cpp
class FScopeSemanticExecutionFrame
{
public:
	FScopeSemanticExecutionFrame(
		FScriptExecution& Execution,
		asIScriptFunction* Function,
		const char* File,
		const char* Declaration,
		int32 Line,
		EAngelscriptSemanticInstrumentationProfile Profile);
	~FScopeSemanticExecutionFrame();

	bool Entered() const;
};
```

It links the existing debug position where enabled, publishes current function
metadata needed by approved public APIs, consumes a shared per-execution depth
budget, and sets the maintained script exception when the budget is exhausted.
Do not create an unrelated global/TLS recursion counter. Direct helpers must
construct this scope just like roots; call-site optimization cannot omit it.

The exact public/private location and fields should follow the provider
refactor's final entry ABI, but the behavior is independent and can be tested
first through a checked-in generated fixture.

## 6. Future patch cell E — instrument-or-VM routing

### RED

Add a fake/current execution-requirements snapshot and table-driven routing
tests:

| Required | Position-only entry | Instrumented entry | Expected |
| --- | --- | --- | --- |
| position | yes | yes | Semantic |
| breakpoint/step/locals | no | only after dedicated proof | VM initially |
| coverage | no | approved line hooks | instrumented Semantic or VM |
| loop timeout | no | approved backedge hooks | instrumented Semantic or VM |
| abort/suspend | no | approved poll hooks | instrumented Semantic or VM |
| recursion budget | only with frame guard | frame guard | Semantic or VM |

Repeat with an instrumented root that directly reaches a position-only child;
the closure must bridge/reroute or fail with `DirectCalleeProfileMismatch`.

### GREEN implementation anchors

- Define compact private capability/profile flags and an invocation
  requirements snapshot; do not introduce another provider namespace.
- Include the instrumentation profile in generated content/profile identity.
- Compute direct helper/SCC capability closure during Semantic analysis.
- UASFunction/provider routing checks the snapshot before selecting the
  Semantic entry.
- Initial breakpoint/step/local-inspection policy is VM.
- Coverage/timeout/abort/suspend are VM unless an approved hook implementation
  exists for every direct callee.
- Never call `AngelscriptLineCallback`/CodeCoverage directly off game thread.

## 7. Verification order

1. Run the network-free source probe and schema-v3 fixture validators.
2. Land/control-target HIR RED/GREEN while bytecode capture-on/off stays equal.
3. Land mutation and structured-control differential tests/emission.
4. Land frame/depth RAII and recursion protection before enabling recursive
   direct helpers.
5. Land execution requirements/profile routing before advertising debugger,
   coverage, timeout, abort, or suspend compatibility.
6. Rebuild checked-in AOT artifacts, then run compiler, StaticJIT, AOT,
   Standalone, and full-suite gates from `tasks.md`.

Before extending production routing, add one more characterization cell for
the public execution-query matrix. `asGetActiveFunction()` reads
`tld->activeFunction`, which is currently scoped around system calls but is not
set automatically by `FScriptExecution`. `GetAngelscriptExecutionThisObject()`
is currently VM-context-only even though JIT debug frames contain `ThisObject`.
Test VM, top-level JIT, nested JIT frames, nested `FScriptExecution`, system
call, and JIT→VM bridge behavior before deciding whether Semantic frame RAII
scopes active script function/`this` or the queries traverse JIT metadata. A
frame-zero-only `this` patch is insufficient because the public API accepts a
stack-frame index.

Network-free preflight:

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticExecutionSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/fixtures/semantic-aot-v1/Validate-Fixtures.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/fixtures/semantic-aot-v1/Test-ValidateFixtures.ps1
```

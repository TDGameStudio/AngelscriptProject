# Task 4.1 — Complete TypedASTJIT bytecode-isolation sentinel

## Scope

Task 4.1 requires more than a generated-text token scan. A TypedASTJIT
artifact can omit `GetByteCode` and `FAngelscriptBytecode` spellings while an
earlier eligibility, reference, or lowering stage still traverses VM
bytecode. The test therefore has to observe the production access boundaries
during a real eligible TypedASTJIT generation task.

The focused test lives separately from the large generated-output matrix:

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/BytecodeIsolation/AngelscriptTypedASTJITBytecodeIsolationTests.cpp`

## Audited production boundaries

The maintained source has four distinct bytecode-only boundaries:

1. `FAngelscriptBytecodeJIT::AnalyzeScriptFunction()` — BytecodeJIT analysis;
2. `CollectStableProviderStringLiteralReferences()` — the Provider bytecode
   reference scanner that reads the function's instruction array directly;
3. `FAngelscriptBytecodeJIT::GenerateCppCode()` immediately before
   `asIScriptFunction::GetByteCode()` — VM instruction-stream acquisition;
4. `FAngelscriptBytecode::GetBytecode()` — opcode implementation dispatch.

The test must first prove the sentinel is live by running the paired real
BytecodeJIT differential generation and observing every total counter above
zero. In the same fixture run, every production TypedASTJIT `Generate()` call
is enclosed by an audit scope. The corresponding four in-scope counters must
remain exactly zero while a real eligible TypedASTJIT differential symbol is
emitted.

The audit API is compiled only when `WITH_ANGELSCRIPT_UNITTESTS=1`; production
and Shipping builds retain no counter update or synchronization overhead.

## RED — missing real audit contract

The new focused CQTest was added first and includes the not-yet-implemented
Runtime audit contract. The official wrapper build failed only at that
missing header, establishing that the repository had no real bytecode-access
observation seam:

```text
Command:
powershell.exe -NoProfile -ExecutionPolicy Bypass \
  -File Tools\RunBuild.ps1 \
  -Label semantic-aot-task41-bytecode-isolation-red \
  -TimeoutMs 1800000 -NoXGE

Result: expected RED, FinalExitCode=1
Failure:
AngelscriptTypedASTJITBytecodeIsolationTests.cpp(4,1): fatal error C1083:
cannot open include file
`StaticJIT/AngelscriptStaticJITBytecodeAccessAudit.h`

Evidence:
Saved/Build/semantic-aot-task41-bytecode-isolation-red/
20260817_041958_371_34c69002/
```

No production code had been modified before this RED build.

## First runtime probe exposed an over-broad fixture dependency

The first GREEN candidate compiled, but the focused Automation case failed
before reaching its sentinel assertions because it called the complete AOT
`Run(Verify)` harness. That harness intentionally also requires the unfinished
task 4.4/4.5 exhaustive-enum control-flow fixture to emit through TypedASTJIT:

```text
Command:
powershell.exe -NoProfile -ExecutionPolicy Bypass \
  -File Tools\RunTests.ps1 \
  -TestPrefix "Angelscript.TestModule.StaticJIT.TypedASTJIT.BytecodeIsolation" \
  -Label semantic-aot-task41-bytecode-isolation-green \
  -TimeoutMs 600000

Result: 0/1 PASS, 1 FAIL
Failure before sentinel assertions:
TypedASTJIT exhaustive enum switch fixture unexpectedly fell back:
Reason=10 Detail=Expression kind is outside the scalar slice

Evidence:
Saved/Tests/semantic-aot-task41-bytecode-isolation-green/
20260817_042213_005_4b9388f9/
```

This is not evidence of a bytecode-isolation failure. It proves the initial
test seam was too broad: a task 4.1 sentinel must not require unfinished
task 4.4/4.5 control-flow support. The corrected seam will create the same
isolated production generation Engine and generation snapshot but generate
only the already-supported `DifferentialScalarValue` function once through
BytecodeJIT and once through TypedASTJIT. Existing exhaustive-enum assertions
remain unchanged and fail closed in their own control-flow task.

## Focused bytecode-isolation GREEN

The corrected production probe generates only the supported scalar pair while
retaining the real isolated Generation Engine, immutable snapshot, backend
router, and provider-generation path. The official wrapper evidence is:

```text
Build:
Saved/Build/semantic-aot-task41-bytecode-isolation-focused-build/
20260817_042423_124_19141411/
Result: PASS

Focused Automation:
Saved/Tests/semantic-aot-task41-bytecode-isolation-focused/
20260817_042444_784_58a41907/
Result: 1/1 PASS, zero failed/skipped/timeouts
```

The BytecodeJIT half proves every audited counter can observe real bytecode
work. The TypedASTJIT half emits an eligible symbol while all four
`DuringTypedAST` counters remain exactly zero.

## Compile-out generated-output fixture API correction

The first build of the newly partitioned `TypedASTJIT/CompileOut` golden test
failed before linking because the test used an obsolete guessed emitter call
shape (`FunctionName` and a two-argument `EmitTypedASTJITFunction`). The
current production API owns `SymbolName` in the function shape and requires
explicit emit options. This was a fixture-only error; no production behavior
was changed.

```text
Build:
Saved/Build/semantic-aot-task41-compileout-baseline-build/
20260817_043101_272_2a58bbc8/
Result: expected fixture RED, FinalExitCode=1
```

The corrected fixture then compiled and both independent output cases passed:

```text
Build:
Saved/Build/semantic-aot-task41-compileout-baseline-build2/
20260817_043211_620_ae620ec8/
Result: PASS

Focused Automation:
Saved/Tests/semantic-aot-task41-compileout-baseline/
20260817_043233_044_c3f5febe/
Result: 2/2 PASS
```

## Compile-out mutation sensitivity

To prove the new method-chain golden assertion protects the production branch,
the emitter was temporarily mutated so `CompileOutAsMethodChain` discarded its
retained receiver and emitted `(void)0`. The mutation compiled successfully;
the focused run then failed only the method-chain receiver assertion while the
entire/first-parameter rewrite case stayed GREEN:

```text
Mutation build:
Saved/Build/semantic-aot-task41-compileout-mutation-red-build/
20260817_043323_142_dd67b603/
Result: PASS

Mutation Automation:
Saved/Tests/semantic-aot-task41-compileout-mutation-red/
20260817_043337_151_ea79bdc7/
Result: expected RED, 1/2 PASS, 1/2 FAIL
Only failure: MethodChainReturnsOnlyTheRetainedReceiver
```

The mutation was immediately removed. The production emitter again retains
the one verified operand for both retained-value rewrite dispositions.

## Restored final GREEN and task audit

After restoring the retained-value emitter, the official wrapper build and
both partitioned compile-out tests were GREEN:

```text
Restored build:
Saved/Build/semantic-aot-task41-compileout-green-build/
20260817_043434_779_7e17de26/
Result: PASS

Restored CompileOut Automation:
Saved/Tests/semantic-aot-task41-compileout-green/
20260817_043455_542_e8c5b99c/
Result: 2/2 PASS, zero failed/skipped/timeouts
```

The complete existing TypedASTJIT generated-output owner was also rerun after
the new partitions landed. Its 25 cases cover typed locals, literal encoding,
explicit conversions, scalar unary/binary helpers, division failure,
one-target/one-store mutations, short circuiting, deterministic output, and
the forbidden generic execution-context spelling:

```text
Generated-output Automation:
Saved/Tests/semantic-aot-task41-generated-output-green/
20260817_043616_901_febe6916/
Result: 25/25 PASS, zero failed/skipped/timeouts
```

Together with the production-path bytecode sentinel `1/1 PASS`, this closes
every explicit task 4.1 acceptance clause. The tests are partitioned by
capability under `TypedASTJIT/CompileOut` and `TypedASTJIT/BytecodeIsolation`
instead of adding more responsibilities to the already-large golden owner.

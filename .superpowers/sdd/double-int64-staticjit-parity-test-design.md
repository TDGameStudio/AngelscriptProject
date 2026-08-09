# Double-to-Int64 StaticJIT Parity Regression Design

Date: 2026-07-27  
Mode: read-only design / plan-only deliverable  
Target OpenSpec: `fix-as-double-int64-bytecode-execution`

## Recommendation

Extend the existing `ASStaticJITAotFixture` with two parameterized global
functions and add one focused AOT test that executes those same functions first
through ordinary interpreter bytecode and then through attached generated
StaticJIT entries. Use exact in-range values beyond 32-bit range, inspect the
interpreter bytecode for `asBC_dTOi64` / `asBC_dTOu64`, and require generated
entry pointers plus one diagnostic entry hit per AOT function.

This is the smallest test that satisfies the existing OpenSpec. The current
`FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` should
remain an unrelated helper-level int32/uint32-to-double test and must no longer
be named as the double-to-int64 StaticJIT owner.

## Evidence and Current Gap

### Current “parity” test is not generated execution

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITPrimitiveConversionTests.cpp`
was inspected completely.

Its `BitCastAndNumericParity` method:

- creates a full `FAngelscriptEngine`;
- calls `ConvertPrimitiveValue<double, int>(-1)` directly;
- calls `ConvertPrimitiveValue<double, asDWORD>(0xFFFFFFFFu)` directly; and
- never compiles an AngelScript fixture, loads precompiled data, attaches a
  `jitFunction`, or calls a generated entry.

`StaticJITHeader.h` defines that helper as
`OutT ConvertPrimitiveValue(InT InValue)`, so the current test covers
signed/unsigned 32-bit integer **to double**, not double to int64/uint64.

### The real AOT path already exists

The existing AOT flow is suitable without a new harness:

1. `AngelscriptStaticJITAotFixture.cpp::GetScriptSource()` provides the
   deterministic AngelScript module.
2. `AngelscriptStaticJITAotGeneration.cpp` compiles the annotated module and
   calls `GenerateStaticJITAotArtifactsForDiagnostics`.
3. Generate mode writes the `.jit.hpp`, `.jit.cpp`, compiled-info source, and a
   paired local precompiled cache.
4. A second UBT build compiles the generated `.jit.cpp`.
5. `LoadAotFixtureFromPrecompiledData` loads the cache and attaches registered
   `jitFunction`, `jitFunction_Raw`, and `jitFunction_ParmsEntry` pointers.
6. `FStaticJITDiagnosticEntryMarkers` provides direct evidence that the
   generated function body ran.
7. `GeneratedOutputVerify` strictly compares regenerated source text and checks
   cache GUID/build/module/function semantics.

The canonical runner already enforces the required sequence:

```text
baseline build -> Generate commandlet -> generated-source build -> AOT tests
```

### Production paths under test

The interpreter handlers are:

- `as_context.cpp:3450-3452`, `asBC_dTOi64`; and
- `as_context.cpp:3460-3462`, `asBC_dTOu64`.

They read operand 1 and advance two words. The StaticJIT generators are:

- `AngelscriptBytecodes.cpp:5694-5704`, `asBC_dTOi64`; and
- `AngelscriptBytecodes.cpp:5718-5728`, `asBC_dTOu64`.

Both StaticJIT handlers use operand 1 and emit an `int64(...)` or `uint64(...)`
conversion into the operand-0 destination.

## Approaches Considered

### A. Extend the existing AOT fixture — recommended

Add two global functions to `ASStaticJITAotFixture`, regenerate the existing
artifacts, and add one interpreter-versus-AOT execution test.

Advantages:

- uses the repository’s only proven generated-source/runtime-registration
  pipeline;
- adds no new build rules, commandlet, cache type, or compiled-info package;
- can prove bytecode opcode shape, generated pointer attachment, generated
  execution, exact results, and cleanup in one scenario;
- stays under the established
  `Angelscript.TestModule.StaticJIT.AOT.*` prefix; and
- avoids the known `FStaticJITCompiledInfo` single-package/global-state risk.

Cost:

- the checked-in generated header and local ignored cache must be regenerated;
- the canonical AOT runner performs two builds.

### B. Create a dedicated conversion-only AOT fixture

Create a second script fixture, generated directory/cache, compiled-info unit,
and test prefix.

Advantages:

- isolates conversion changes from the general AOT fixture;
- produces a smaller generated header.

Disadvantages:

- duplicates the generator/cache workflow;
- introduces a second compiled-info package in a process where the current
  design assumes one active `FStaticJITCompiledInfo`;
- requires more source, diagnostics, setup instructions, and cleanup than the
  behavior being tested warrants.

This is disproportionate and riskier than reusing the current fixture.

### C. Hand-code or directly call a generated-looking conversion wrapper

Add a C++ function that calls `ConvertPrimitiveValue<int64, double>` /
`ConvertPrimitiveValue<uint64, double>` and invoke it from the primitive test.

Advantages:

- no regeneration;
- very small edit.

Disadvantages:

- does not compile AngelScript conversion bytecode;
- does not run `asBC_dTOi64` / `asBC_dTOu64` through the StaticJIT generator;
- does not prove precompiled attachment or generated entry execution; and
- repeats the exact category error in the current ownership record.

This approach must be rejected.

## Selected Test Contract

### AngelScript fixture functions

Add these two global functions to
`AngelscriptStaticJITAotFixture.cpp::GetScriptSource()`:

```angelscript
int64 DoubleToInt64ForAOT(double Value)
{
	return int64(Value);
}

uint64 DoubleToUint64ForAOT(double Value)
{
	return uint64(Value);
}
```

The values must be passed as runtime arguments. A constant-only return risks
compiler folding and would not reliably preserve the conversion opcode.

Add matching fixture declarations:

```text
int64 DoubleToInt64ForAOT(double)
uint64 DoubleToUint64ForAOT(double)
```

The lookup may continue to use the existing unique-name fallback, but the new
test must additionally assert:

- exactly one parameter;
- parameter type equal to
  `Engine.GetScriptEngine()->GetTypeIdByDecl("double")` (this fork names the
  primitive enum value `asTYPEID_FLOAT64`); and
- return type `asTYPEID_INT64` or `asTYPEID_UINT64`.

That prevents a name-only lookup from silently accepting the wrong signature.

### Representative exact values

| Case | Runtime input | Exact expected result | Reason |
|---|---:|---:|---|
| signed | `-4294967296.75` | `-4294967296` | Negative, exactly representable double, safely in int64 range, beyond int32, verifies truncation toward zero without boundary UB. |
| unsigned | `4294967296.75` | `4294967296` | Positive, exactly representable double, safely in uint64 and int64 range, beyond uint32, verifies a real 64-bit unsigned result. |

The unsigned input deliberately stays below `INT64_MAX` because the current
interpreter implementation converts through `asINT64` before storing the
`asQWORD`. This test is for operand layout and execution parity, not a new
out-of-range conversion-policy requirement.

### Interpreter phase

Create one isolated full engine with `CreateIsolatedFullEngine()`, enter an
`FAngelscriptEngineScope`, and compile the same fixture source with
`CompileAnnotatedModuleFromMemory`.

For each conversion function:

1. Resolve the unique function and assert the signature.
2. Assert `jitFunction == nullptr` so the phase cannot silently use the
   generated path.
3. Walk `asCScriptFunction::GetByteCode()` using
   `asBCTypeSize[asBCInfo[Opcode].type]`.
4. Require `asBC_dTOi64` in the signed function and `asBC_dTOu64` in the
   unsigned function.
5. Create a context, `Prepare`, `SetArgDouble(0, Input)`, and `Execute`.
6. Require `asEXECUTION_FINISHED`.
7. Read `GetReturnQWord()` and decode it as signed or unsigned.
8. Require the exact expected result.

Release each context on every exit path. Drain active modules before the engine
scope and isolated engine are destroyed.

### Generated StaticJIT phase

After the interpreter engine and its scope have been destroyed, create a
second isolated full engine and call the existing
`LoadAotFixtureFromPrecompiledData`.

For each conversion function:

1. Resolve and assert the same signature.
2. Use `RequireJitEntries` to require a function ID, registered generated C++,
   non-null `jitFunction`, non-null `jitFunction_Raw`, and non-null
   `jitFunction_ParmsEntry`.
3. Reset `FStaticJITDiagnostics` entry counters before either call.
4. Execute through a normal `asIScriptContext` with the same double input.
5. Require `asEXECUTION_FINISHED`.
6. Require the exact expected result.
7. Require equality with the interpreter result.
8. Require `GetEntryCount(FunctionId) == 1`.

The entry-count assertion is the decisive generated-execution proof. Merely
loading precompiled data or seeing a non-null pointer is insufficient.

Release contexts and drain the AOT module before destroying its scope and
engine. Run interpreter and AOT engines sequentially, not concurrently, to
avoid expanding the existing StaticJIT global-state surface.

### Generated-source visibility

Three existing mechanisms should be used together:

1. Add both conversion function names to
   `AngelscriptStaticJITAotGeneration.cpp::RequiredFunctions`, so cache
   verification compares their function metadata.
2. Keep `GeneratedOutputVerify` in the required AOT prefix; it strictly compares
   the regenerated `.jit.hpp` text and paired cache semantics.
3. Record an explicit generated-source scan showing the two function symbols,
   `dTOi64` / `dTOu64` opcode comments, and emitted `int64(...)` /
   `uint64(...)` lines.

This provides human-visible generated source while the entry counters prove the
compiled generated body actually executed.

## Exact File and Symbol Map

### Plugin source changes

1. `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotFixture.h`

   Add:

   - `GetDoubleToInt64Declaration()`;
   - `GetDoubleToUint64Declaration()`.

   Expected values can remain local `constexpr` values in the focused test;
   they do not need fixture-wide APIs.

2. `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotFixture.cpp`

   Modify `GetScriptSource()` to add the two parameterized conversion
   functions. Implement both declaration accessors.

3. `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`

   Add `DoubleToInt64ForAOT` and `DoubleToUint64ForAOT` to
   `VerifyPrecompiledCacheSemantics()`’s `RequiredFunctions` array.

4. `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITAotTests.cpp`

   Add:

   - include `AngelscriptTestEngineAcquisition.h`;
   - include `source/as_bytecode.h`;
   - class-private result struct
     `FDoubleInt64ConversionResults`;
   - narrow helper `DiscardActiveModules(FAngelscriptEngine&)`;
   - narrow helper
     `FunctionContainsOpcode(asCScriptFunction&, asEBCInstr)`;
   - narrow helper for preparing one function, passing one double, executing,
     and returning its raw qword while always releasing the context; and
   - `TEST_METHOD(DoubleInt64ConversionsMatchInterpreter)`.

   Keep the scenario’s compile/load/resolve/assert sequence directly inside
   `TEST_METHOD`. Do not add another file-level `Run...` wrapper. The helper
   functions should hide bytecode walking and context-release noise only.

   The full Automation ID becomes:

   ```text
   Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.DoubleInt64ConversionsMatchInterpreter
   ```

5. `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITPrimitiveConversionTests.cpp`

   No behavioral edit is required. Its current helper-level conversion test is
   orthogonal. Do not expand it into a second AOT harness.

   An optional later cleanup may rename `BitCastAndNumericParity` to a more
   precise int32/uint32-to-double name, but that rename is not required for this
   regression and would unnecessarily change an existing Automation ID.

### Generated artifacts

Run the generator; never hand-edit these:

- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp`
  — must change to contain and register both functions.
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitCode_0.jit.cpp`
  — generator rewrites/verifies it; it may remain text-identical because it
  includes the fixture header.
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitInfo.jit.cpp`
  — generator rewrites/verifies it; it may remain text-identical if the fixture
  GUID is intentionally retained.
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/StaticJITAotFixture.Cache`
  — must be regenerated locally, remains ignored and must not be committed.

No AOT GUID bump is required for this test-only fixture extension. The fixture
was previously expanded in commit `814501a` without changing this GUID; the
generate/rebuild/test workflow, function IDs, and semantic cache verifier
enforce the matched source/cache/binary set. Preserve that established package
identity and regenerate the pair.

### Documentation and OpenSpec changes

6. `Documents/Guides/TestCatalog.md`

   Extend the existing `Angelscript.TestModule.StaticJIT.AOT.*` description to
   mention interpreter/generated double-to-int64/uint64 parity. Do not add a new
   test layer or prefix.

7. `openspec/changes/fix-as-double-int64-bytecode-execution/background.md`

   Replace the false primitive-helper parity owner with:

   ```text
   FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter
   ```

   State explicitly that `BitCastAndNumericParity` is int32/uint32-to-double
   helper coverage and is not the owner.

8. `openspec/changes/fix-as-double-int64-bytecode-execution/proposal.md`

   Update the parity impact entry to the AOT method and generated fixture.

9. `openspec/changes/fix-as-double-int64-bytecode-execution/design.md`

   Record the two-engine sequence, exact values, opcode assertions, generated
   entry-counter proof, artifact regeneration requirement, and cleanup.

10. `openspec/changes/fix-as-double-int64-bytecode-execution/specs/as-double-int64-bytecode-execution/spec.md`

    Sharpen the StaticJIT scenario so a direct C++ conversion helper cannot
    satisfy it:

    - interpreter functions contain the exact conversion opcodes;
    - AOT functions have attached generated entries;
    - generated diagnostic entry counters increment; and
    - both paths return identical exact values.

11. `openspec/changes/fix-as-double-int64-bytecode-execution/tasks.md`

    Correct checked task 1.3 to name the real owner only after the record is
    updated. Add TDD tasks for:

    - focused red regression;
    - parameterized fixture functions and signature/opcode assertions;
    - generated artifact/cache regeneration;
    - interpreter/AOT exact-result and entry-counter green evidence; and
    - OpenSpec/catalog/verification closure.

    Replace the current primitive-prefix task 3.4 with the canonical AOT
    generation/build/test workflow.

12. `openspec/changes/fix-as-double-int64-bytecode-execution/issues.md`

    Record the confirmed gap and close it only after generated execution
    evidence exists.

13. `openspec/changes/fix-as-double-int64-bytecode-execution/verification.md`

    Replace the false parity gate with the canonical AOT runner, focused result,
    generated-source scan, exact results, entry counts, cleanup, and artifact
    status.

## Test-First Sequence and Red Expectation

The production fix predates this regression, so a new test on the current tree
may not naturally fail on conversion semantics. The plan must not pretend
otherwise.

Use this honest two-stage red:

1. Add the focused test and declaration accessors before adding the two
   functions to `GetScriptSource()`.
2. Build and run the focused method.
3. Expect a test failure resolving `DoubleToInt64ForAOT` /
   `DoubleToUint64ForAOT` from the interpreter fixture. This proves the new
   regression is active and not accidentally passing through the old direct
   helper.
4. Add the two script functions. Before regeneration, expect
   `GeneratedOutputVerify` to report stale generated output and/or the runtime
   AOT phase to fail because the old cache has no conversion functions.
5. Regenerate, rebuild generated code, and rerun. Require green exact results
   plus entry counts.

The semantic mutation oracle is:

- with the historical P091/P092 behavior restored in an isolated mutation
  experiment, the interpreter phase must fail to finish cleanly, return a wrong
  value, or misdispatch after the source operand; and
- the generated AOT phase should still return the expected value.

Do not revert P091/P092 in the shared dirty workspace merely to manufacture a
red run. Historical crash evidence already documents that defect. If mutation
testing is desired, it must be an explicitly authorized isolated follow-up.

## Ready-to-Execute Task Plan

### Task 1 — Add a focused active regression

Files:

- modify `AngelscriptStaticJITAotFixture.h/.cpp` with declaration accessors only;
- modify `AngelscriptStaticJITAotTests.cpp` with the new test and narrow
  helpers.

Steps:

1. Add the result struct, opcode scanner, context execution helper, and
   `DoubleInt64ConversionsMatchInterpreter`.
2. Use unique declarations/signature assertions and runtime inputs from the
   table above.
3. Compile the current fixture and assert the functions exist.
4. Run the focused test and record the expected missing-function red.

### Task 2 — Add the minimal fixture behavior

Files:

- modify `AngelscriptStaticJITAotFixture.cpp`;
- modify `AngelscriptStaticJITAotGeneration.cpp`.

Steps:

1. Add the two parameterized script functions.
2. Add both names to `RequiredFunctions`.
3. Rebuild the commandlet-bearing module.
4. Run before regeneration and record the expected stale-artifact/AOT-function
   red.

### Task 3 — Regenerate and compile the AOT pair

Files:

- regenerate the three tracked files under `AOT/Generated/`;
- regenerate the ignored local cache.

Steps:

1. Run the canonical `Tools\RunStaticJITTests.ps1 -AotOnly` workflow.
2. Confirm the commandlet reports four written paired artifacts.
3. Confirm the generated-source build compiles both new registrations.
4. Confirm the AOT prefix includes the focused method and
   `GeneratedOutputVerify`.
5. Confirm the ignored cache is not staged or committed.

### Task 4 — Record exact parity and closure

Files:

- modify the target OpenSpec records listed above;
- modify `Documents/Guides/TestCatalog.md`.

Steps:

1. Record signed/unsigned interpreter results and execution status.
2. Record signed/unsigned AOT results, function IDs, pointer attachment, and
   entry count `1`.
3. Record opcode and generated-source visibility.
4. Record module/context cleanup and normal process shutdown.
5. Run strict OpenSpec and whitespace checks.
6. Mark tasks complete only from fresh outputs.

## Focused Verification Commands

### Canonical generated AOT workflow

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -AotOnly -LabelPrefix fix-as-double-int64-staticjit-parity -BuildTimeoutMs 1800000 -CommandletTimeoutMs 600000 -TestTimeoutMs 600000
```

Expected terminal evidence:

- baseline build exit 0;
- Generate commandlet reports result 0 and four paired artifacts;
- generated-source build exit 0;
- `Angelscript.TestModule.StaticJIT.AOT` passes with the new method discovered;
- `GeneratedOutputVerify` passes;
- no crash or timeout.

### Focused method after the AOT pair is prepared

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.DoubleInt64ConversionsMatchInterpreter" -Label fix-as-double-int64-staticjit-parity-focused -TimeoutMs 600000
```

Expected:

- one discovered/passing focused test;
- interpreter signed `-4294967296`;
- interpreter unsigned `4294967296`;
- AOT values identical;
- both generated function entry counts equal `1`;
- contexts released, modules drained, normal shutdown.

This focused command is valid only after the canonical generation/rebuild
workflow has prepared the matching cache and DLL.

### Generated-source visibility

```powershell
rg -n "DoubleToInt64ForAOT|DoubleToUint64ForAOT|dTOi64|dTOu64|= int64\\(|= uint64\\(" Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp
```

Expected:

- one generated signed function and registration;
- one generated unsigned function and registration;
- a `dTOi64` opcode comment and emitted signed conversion;
- a `dTOu64` opcode comment and emitted unsigned conversion.

### Existing interpreter owners

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language.Constructors.Parameters" -Label fix-as-double-int64-staticjit-parity-parameters -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language.Conversions.Numeric" -Label fix-as-double-int64-staticjit-parity-numeric -TimeoutMs 1800000
```

### Record and whitespace validation

```powershell
openspec validate fix-as-double-int64-bytecode-execution --strict
git -C Plugins/Angelscript diff --check -- Source/AngelscriptTest/StaticJIT
git diff --check -- openspec/changes/fix-as-double-int64-bytecode-execution Documents/Guides/TestCatalog.md
```

## Risks and Guards

| Risk | Guard |
|---|---|
| Compiler folds a constant and omits `dTOi64` / `dTOu64`. | Accept a runtime `double` argument and scan interpreter bytecode for the exact opcode. |
| Test silently runs interpreter in the AOT phase. | Require all three JIT pointers and diagnostic entry count `1`. |
| Test silently runs generated code in the interpreter phase. | Compile normally in a separate engine and assert `jitFunction == nullptr`. |
| Name fallback resolves an unintended overload. | Use unique names and assert one double parameter plus exact signed/unsigned 64-bit return type. |
| Undefined or platform-sensitive floating conversion. | Use exact binary-representable fractional inputs safely inside the target ranges; avoid int64/uint64 extrema. |
| Old generated source and new cache are mixed. | Use only `RunStaticJITTests.ps1`, which enforces build → generate → rebuild → test. |
| A second AOT package conflicts with global compiled-info state. | Reuse the existing fixture and run interpreter/AOT engines sequentially. |
| Context or module survives an early assertion. | RAII-release every context and install module-drain cleanup immediately after each engine scope begins. |
| Entry counters retain earlier AOT activity. | Reset counters immediately before the two generated calls and assert each function ID independently. |
| Ignored binary cache is accidentally staged. | Confirm `git -C Plugins/Angelscript status --short` and `git check-ignore` before commit. |
| The old direct helper remains misdocumented as owner. | Update every OpenSpec reference to the new AOT method and explicitly classify the old method as unrelated helper coverage. |

## Definition of Done

The gap is closed only when all of the following are fresh and recorded:

- interpreter bytecode contains `asBC_dTOi64` and `asBC_dTOu64`;
- interpreter execution finishes and returns both exact values;
- the AOT fixture has matching regenerated tracked source and local cache;
- the generated conversion functions have attached VM/raw/params entries;
- AOT execution finishes and returns the same exact values;
- each generated function’s diagnostic entry count is exactly one;
- `GeneratedOutputVerify` passes;
- generated source visibly contains both opcode/conversion bodies;
- contexts and modules are cleaned up and the process shuts down normally;
- the two existing interpreter owner prefixes still pass;
- strict OpenSpec and scoped whitespace checks pass; and
- the OpenSpec no longer cites
  `FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` as
  the double-to-int64 parity owner.

## Review Boundary

No production source, test source, generated artifact, cache, OpenSpec record,
or catalog was modified while producing this design. No build, commandlet,
automation test, regeneration, or commit was run.

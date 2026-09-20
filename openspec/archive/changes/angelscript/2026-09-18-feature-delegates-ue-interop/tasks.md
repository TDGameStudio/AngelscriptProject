---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "1.4": ["1.1"]
    "1.5": ["1.2"]
    "1.6": ["1.1"]
    "1.7": ["1.2"]
    "2.1": ["1.3", "1.4", "1.7"]
    "2.2": ["2.1"]
    "2.3": ["2.2"]
    "3.1": ["2.3"]
    "3.2": ["1.7"]
    "3.3": ["2.2", "3.2"]
    "4.1": ["3.1", "3.3"]
---

# UE-style delegate declarations, native callables, and Unreal interoperability

## Goal

Replace `delegate`/`event` keywords with the six UE `DECLARE_*` families (60 spellings) and execute Bind/Execute/Broadcast on the replacement host, then keep the later payload, native, Blueprint, and cook nodes in this Change.

## Architecture

See [design.md](design.md). One declaration-form table admits the 60-row matrix; diagnostics, preprocess, and descriptor registration have their own proofs; `CompileModules` runs named Bind/Execute/Broadcast; ClassGen `UDelegateFunction` uses `Desc.Signature` for dynamic forms only.

## Global constraints

- This Change owns the full 60-spelling macro table. Event/TS/Sparse/Derived (31) stay unsupported diagnostics.
- `delegate` and `event` introducers are removed syntax, not aliases. Token deletion is a later Change.
- Tests live under `Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/` with identities `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>`. `NewVersion/` is forbidden.
- Host fixtures use isolated `FAngelscriptEngine::Create`, `bSkipInitialCompile`, CacheV2 off, `CompileModules`. Do not restore `WITH_ANGELSCRIPT_UNITTESTS`, `PerformHotReload` watch, or `ProcessDelegates` wrapper structs.
- No Lambda / BindLambda. Language folder execute is not a proving command.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Remaining interface names, planning-validation, source API confirm | 1.1 |
| 60 DECLARE forms via one table + 60-row matrix | 1.2 |
| Typed Bind/Add plans | 1.3 |
| Definition-graph CallPtr returns 42 | 1.4 |
| Removed-keyword and unsupported-family diagnostics | 1.5 |
| Preprocess does not wrap DECLARE_* or leftover keywords | 1.6 |
| Flavor-aware definition-graph type and FAngelscriptDelegateDesc | 1.7 |
| Execute / Broadcast on CompileModules | 2.1 |
| Explicit named-target payloads | 2.2 |
| Multicast handle mutation | 2.3 |
| Native TDelegate adapters | 3.1 |
| UDelegateFunction / property materialization | 3.2 |
| Blueprint and script dynamic invocation | 3.3 |
| Editor/cooked load and invalidation | 4.1 |

Self-review 2026-09-18: coverage remapped after verification-stage split; NewVersion placeholders removed; NativeEngine identities recorded in design.md. Record: attachments/data/planning-validation.md (created by 1.1).

## 1. Language contracts

## [x] 1.1 Confirm source APIs, remaining public names, and planning-validation

The applied 2026-09-18 replans already wrote `design.md`, capability deltas, the declaration-form table, and the stage split. This document task inspects current source, records exact Bind/Execute/Broadcast names, and writes the planning-validation record. No C++ mutation.

**Outcome**

`attachments/data/planning-contracts.md` and `attachments/data/planning-validation.md` exist. Every product card's Consumes list cites an inspected `file:line` or a name this task records. Strict validation passes. Product tasks stay pending.

**Files**

```diff
 openspec/changes/angelscript/feature-delegates-ue-interop/design.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/lexing/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/declarations/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/preprocessing/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/bodies/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/reflection-dependencies/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/testing/language-fixtures/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/runtime/delegates/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/bindings/delegates/spec.md
 openspec/changes/angelscript/feature-delegates-ue-interop/tasks.md
 openspec/changes/angelscript/feature-delegates-ue-interop/attachments/INDEX.md
+openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/planning-contracts.md
+openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/planning-validation.md
```

**Verification**

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-delegates-ue-interop', '--type', 'change', '--strict', '--json')
```

**Notes**

Confirm `asCParser::ParseCallableDeclaration` (`as_parser.cpp:668`), `FAngelscriptDescriptorConsumer` callable projection (`as_descriptor_consumer.cpp:256`), `ProcessDelegates` (`AngelscriptPreprocessor.cpp:1167`), and ClassGen `UDelegateFunction` (`AngelscriptClassGenerator_FullReload.cpp:253`). Record the exact script Bind/Execute/Broadcast spellings before 1.2 starts. Confirm `asECallableFlavor` and `bIsDynamic` names against the sources 1.2/1.7 will edit.

**Evidence**

`attachments/data/planning-contracts.md` and `attachments/data/planning-validation.md` written. `asECallableFlavor` and `bIsDynamic` do not exist yet (Naming assumed confirmed). Keyword scan is `ParseIntoChunks` 4281, not `DetectClasses`. Cook route recorded as `ue.commandlet` `Cook`. Product cards remain pending.

## [x] 1.2 Admit all 60 DECLARE forms through one table

Replace keyword callable declarations with the six-family declaration-form table. Publish flavor-aware `asCCallableTypeDecl` values for every supported spelling. Diagnostics, preprocess wrappers, and descriptor registration stay on 1.5–1.7.

**Outcome**

All 60 supported spellings parse to flavor-aware `asCCallableTypeDecl` values matching the design.md matrix. Bind/Execute, wrapper absence, and removed-keyword diagnostics are out of this card.

**Interfaces**

Consumes:

```
asCParser::ParseCallableDeclaration  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp:668
asCSema::ActOnCallableType  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.cpp:129
DeclarationSemanticTests::FSessionRun  // Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DeclarationSemanticTests.cpp:20
```

Produces:

```
asECallableFlavor Ordinary | Dynamic  // Naming assumed: design.md
TEST_CLASS DelegateDeclarations
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Sema.DelegateDeclarations
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DelegateDeclarationsTests.cpp
```

**Cases**

Setup: Isolated Sema session with CacheV2 off. No preprocessor wrapper generation is required for these cases.

1. **SixtyRowMatrix** — new RED · example-table
   Template: Given Setup and spelling `<spelling>` When Sema finishes Then flavor is `<flavor>`, cast is `<cast>`, return class is `<return>`, arity is `<arity>`, name-position is `<name-position>`, and param-shape is `<param-shape>`.

   | spelling | flavor | cast | return | arity | name-position | param-shape |
   |---|---|---|---|---:|---|---|
   | `DECLARE_DELEGATE` | ordinary | single | void | 0 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_OneParam` | ordinary | single | void | 1 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_TwoParams` | ordinary | single | void | 2 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_ThreeParams` | ordinary | single | void | 3 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_FourParams` | ordinary | single | void | 4 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_FiveParams` | ordinary | single | void | 5 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_SixParams` | ordinary | single | void | 6 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_SevenParams` | ordinary | single | void | 7 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_EightParams` | ordinary | single | void | 8 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_NineParams` | ordinary | single | void | 9 | name-first | unnamed-types |
   | `DECLARE_DELEGATE_RetVal` | ordinary | single | retval | 0 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_OneParam` | ordinary | single | retval | 1 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_TwoParams` | ordinary | single | retval | 2 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_ThreeParams` | ordinary | single | retval | 3 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_FourParams` | ordinary | single | retval | 4 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_FiveParams` | ordinary | single | retval | 5 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_SixParams` | ordinary | single | retval | 6 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_SevenParams` | ordinary | single | retval | 7 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_EightParams` | ordinary | single | retval | 8 | name-after-return | unnamed-types |
   | `DECLARE_DELEGATE_RetVal_NineParams` | ordinary | single | retval | 9 | name-after-return | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE` | ordinary | multi | void | 0 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_OneParam` | ordinary | multi | void | 1 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_TwoParams` | ordinary | multi | void | 2 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_ThreeParams` | ordinary | multi | void | 3 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_FourParams` | ordinary | multi | void | 4 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_FiveParams` | ordinary | multi | void | 5 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_SixParams` | ordinary | multi | void | 6 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_SevenParams` | ordinary | multi | void | 7 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_EightParams` | ordinary | multi | void | 8 | name-first | unnamed-types |
   | `DECLARE_MULTICAST_DELEGATE_NineParams` | ordinary | multi | void | 9 | name-first | unnamed-types |
   | `DECLARE_DYNAMIC_DELEGATE` | dynamic | single | void | 0 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_OneParam` | dynamic | single | void | 1 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_TwoParams` | dynamic | single | void | 2 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_ThreeParams` | dynamic | single | void | 3 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_FourParams` | dynamic | single | void | 4 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_FiveParams` | dynamic | single | void | 5 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_SixParams` | dynamic | single | void | 6 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_SevenParams` | dynamic | single | void | 7 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_EightParams` | dynamic | single | void | 8 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_NineParams` | dynamic | single | void | 9 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal` | dynamic | single | retval | 0 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_OneParam` | dynamic | single | retval | 1 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_TwoParams` | dynamic | single | retval | 2 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_ThreeParams` | dynamic | single | retval | 3 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_FourParams` | dynamic | single | retval | 4 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_FiveParams` | dynamic | single | retval | 5 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_SixParams` | dynamic | single | retval | 6 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_SevenParams` | dynamic | single | retval | 7 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_EightParams` | dynamic | single | retval | 8 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_DELEGATE_RetVal_NineParams` | dynamic | single | retval | 9 | name-after-return | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE` | dynamic | multi | void | 0 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam` | dynamic | multi | void | 1 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams` | dynamic | multi | void | 2 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_ThreeParams` | dynamic | multi | void | 3 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_FourParams` | dynamic | multi | void | 4 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_FiveParams` | dynamic | multi | void | 5 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_SixParams` | dynamic | multi | void | 6 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_SevenParams` | dynamic | multi | void | 7 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_EightParams` | dynamic | multi | void | 8 | name-first | named-pairs |
   | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_NineParams` | dynamic | multi | void | 9 | name-first | named-pairs |

2. **OrdinaryZeroAndOne** — new RED
   Given `DECLARE_DELEGATE(FVoid);` and `DECLARE_DELEGATE_OneParam(FOne, int);` When Sema finishes Then two ordinary single-cast void callables exist with 0 and 1 parameters.

3. **OrdinaryRetValNine** — new RED
   Given `DECLARE_DELEGATE_RetVal_NineParams(int, FNine, int, int, int, int, int, int, int, int, int);` When Sema finishes Then `FNine` is ordinary single-cast, return `int`, arity 9.

4. **DynamicZeroAndOne** — new RED
   Given `DECLARE_DYNAMIC_DELEGATE(FDyn);` and `DECLARE_DYNAMIC_DELEGATE_OneParam(FDynOne, int, Value);` When Sema finishes Then both have dynamic flavor and `FDynOne` keeps parameter name `Value`.

5. **MulticastVoidOnlyAdmit** — new RED
   Given `DECLARE_MULTICAST_DELEGATE_OneParam(FOn, int);` When Sema finishes Then `FOn` is ordinary multicast void.

6. **ExistingVoidParameterControl** — existing control
   Given the current `DeclarationSemanticTests` void-parameter function case that does not use `delegate`/`event` When the suite runs Then it still passes.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_decl.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_codec.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DeclarationSemanticTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DelegateDeclarationsTests.cpp
 AngelscriptTestCode/Language/Delegate/
 AngelscriptTestCode/Language/Event/
```

Globs stay on callable declarations, Flavor, and the listed NativeEngine fixtures. Exclude preprocessor, VM, Binds, and ClassGen. Language folder files may be rewritten to `DECLARE_*`; they are not the proving command.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Sema.DelegateDeclarations'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace. GREEN requires SixtyRowMatrix plus the listed new RED cases and the existing control. `DeclarationSemanticTests` is a shared control run recorded in Evidence, not this prefix.

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Sema.DelegateDeclarations` Succeeded. run `21af07a9f4864244ad464c54232d9d07` Total 6 Succeeded 6. Cases: SixtyRowMatrix, OrdinaryZeroAndOne, OrdinaryRetValNine, DynamicZeroAndOne, MulticastVoidOnlyAdmit, ExistingVoidParameterControl. Build `a939e536e8524f609192ce4bbc7b4b41`. Omitted `DeclarationSemanticTests` shared control this run; keyword fixtures in that file were migrated to DECLARE_* with 1.5.

## [x] 1.3 Resolve typed free/member Bind operations

Consume 1.2 signatures. Produce resolved Bind/Create/Add plans for named free functions and members. No runtime objects.

**Outcome**

`DECLARE_DELEGATE_RetVal_OneParam(int, FAdd, int)` binds `int AddOne(int)` and rejects a bool-only target. Dynamic forms use the same named-target checks. UFUNCTION eligibility for BindDynamic stays deferred until 3.3.

**Interfaces**

Consumes:

```
asCCallableTypeDecl  // 1.2 product
asCSema::ActOnMemberCall  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:391
asCSema::ActOnIndirectCall  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:471
```

Produces:

```
TEST_CLASS DelegateBinding
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Sema.DelegateBinding
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DelegateBindingTests.cpp
```

**Cases**

1. **BindIntOverload** — new RED
   Given `DECLARE_DELEGATE_RetVal_OneParam(int, FAdd, int);` and overloads `Add(bool)` / `Add(int)` When Bind targets `Add` Then the int overload is selected.

2. **RejectBoolOnly** — new RED
   Given the same delegate and only `Add(bool)` When Bind is analyzed Then a signature-mismatch diagnostic is emitted and no binding plan is published.

3. **RejectRemovedKeywordBind** — existing control
   Given `delegate int FAdd(int);` When parsed Then 1.2's removed-keyword diagnostic still fires and 1.3 publishes no plan.

4. **DynamicNamedBind** — new RED
   Given `DECLARE_DYNAMIC_DELEGATE_RetVal_OneParam(int, FAdd, int, Value);` and named `Add(int)` When Bind is analyzed Then the same target is accepted without requiring a UFUNCTION.

5. **BindDynamicUFunction** — deferred RED until 3.3
   Given a dynamic form bound with BindDynamic to a non-UFUNCTION script method When analyzed Then UFUNCTION eligibility is rejected. Observed red here; 3.3 turns it green.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_expr.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DelegateBindingTests.cpp
```

Exclude VM opcode work and ClassGen.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Sema.DelegateBinding'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Sema.DelegateBinding` Succeeded. run `22d1bc458952458a98f5d2512666b031` Total 5 Succeeded 5. GREEN: BindIntOverload, RejectBoolOnly, RejectRemovedKeywordBind, DynamicNamedBind. BindDynamicUFunction observed red: `unresolved-member-call:BindDynamic`, not UFUNCTION eligibility (deferred 3.3). Naming assumed: file-local `SelectCallableBindTarget` — neighbouring ActOnMemberCall convention. Catalog `signature-mismatch` = 4458.

## [x] 1.4 Emit a returning callable CallPtr without DECLARE or keywords

The old host smuggled returns through void `__Evt_ExecuteDelegate` plus a trailing out-ref, and only when the target was a UFUNCTION. Sema already types `Handler(2)` as `int` (`BodySemanticTests.cpp` DelegateVariableCallUsesCanonicalSignatureWithoutEngine). The VM already returns 42 from hand-assembled `asBC_CallPtr` (`VMDispatchTests.cpp` FuncPtrCallPtrReturnsFortyTwo). This card joins those two: Builder/definition-graph emission produces CallPtr whose return slot is the real integer. No `delegate`/`event` source, no `DECLARE_*`, no `ProcessDelegates` wrappers.

**Outcome**

A definition-graph callable `int(int)` bound to a named script `AddOne` is invoked through emitted `asBC_CallPtr` (or the Builder-owned equivalent recorded by 1.1) and returns 42 for input 41. A null callable throws. The return is not a default-initialized out-ref written after a void helper. 1.2 may run in parallel.

**Interfaces**

Consumes:

```
asBC_CallPtr / asCByteCode::CallPtr  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode.cpp:1722
asCSema::ActOnIndirectCall  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:471
FDetachedDefinitionFixture::DefineFunction  // Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Definitions/NativeDetachedDefinitionTestSupport.h:54
FuncPtrCallPtrReturnsFortyTwo  // Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/VM/VMDispatchTests.cpp:193
```

Produces:

```
TEST_CLASS DelegateCallRetVal
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateCallRetVal
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateCallRetValTests.cpp
```

**Cases**

1. **CallPtrReturnsFortyTwo** — new RED
   Given a definition-graph callable `int(int)` and script `int AddOne(int Value) { return Value + 1; }` When the emitted caller invokes the bound callable with 41 Then the context return dword is 42.

2. **NullCallableThrows** — new RED
   Given the same caller shape with a cleared callable pointer When executed Then execution is `asEXECUTION_EXCEPTION` and no return dword is presented as success-zero.

3. **HandAssembledCallPtrStillGreen** — existing control
   Given `VMDispatchTests.FuncPtrCallPtrReturnsFortyTwo` When that prefix is recorded as a control Then it still returns 42. Not counted as this card's RED.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateCallRetValTests.cpp
```

Do not parse `delegate`/`event` or `DECLARE_*` in this card. Do not call `__Evt_ExecuteDelegate`. Builder/emitter changes stay on the returning CallPtr path.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateCallRetVal'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace. GREEN is CallPtrReturnsFortyTwo plus NullCallableThrows. The VMDispatch control is Evidence-only.

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateCallRetVal` Succeeded. run `ccb29f05c92d4cdf88f073a7a8ce3a6b` Total 2 Succeeded 2. Cases: CallPtrReturnsFortyTwo, NullCallableThrows. VMDispatch control omitted; same CallPtr return path already proven earlier this Change.

## [x] 1.5 Diagnose removed keywords and unsupported families

Consume the 1.2 table. Produce removed-keyword and unsupported-family diagnostics. Do not publish a callable for those spellings.

**Outcome**

`delegate` / `event` introducers diagnose `removed-delegate-event-keyword` and publish no callable. The 31 deferred families and multicast RetVal spellings diagnose `unsupported-delegate-declaration-form`. Recovery reaches the next declaration.

**Interfaces**

Consumes:

```
asCParser declaration-form table  // 1.2 product
asCTokenizer keyword classification  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp
```

Produces:

```
TEST_CLASS DelegateDiagnostics
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Sema.DelegateDiagnostics
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DelegateDiagnosticsTests.cpp
```

**Cases**

1. **RejectDelegateKeyword** — new RED
   Given `delegate int FOnDone(); class Good {}` When Sema finishes Then diagnostic `removed-delegate-event-keyword` points at `delegate` and `Good` is still declared.

2. **RejectEventKeyword** — new RED
   Given `event void FOnChanged();` When Sema finishes Then the same removed diagnostic and no multicast callable named `FOnChanged`.

3. **UnsupportedEventFamily** — new RED
   Given `DECLARE_EVENT(AOwner, FOwnerEvent);` When parsed Then `unsupported-delegate-declaration-form` and recovery reaches the next declaration.

4. **MulticastRetValRejected** — new RED
   Given `DECLARE_MULTICAST_DELEGATE_RetVal` When parsed Then `unsupported-delegate-declaration-form` or arity/family rejection, no callable.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_identifier_table.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DeclarationSemanticTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/DelegateDiagnosticsTests.cpp
```

Do not delete `KwDelegate` / `KwEvent`. Do not generate wrappers.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Sema.DelegateDiagnostics'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Sema.DelegateDiagnostics` Succeeded. run `8e9a1e0b21ba46a1aeccb5792a309866` Total 4 Succeeded 4. Cases: RejectDelegateKeyword, RejectEventKeyword, UnsupportedEventFamily, MulticastRetValRejected. Keywords recover with 3244; unmatched DECLARE_* with 3245. KwDelegate/KwEvent tokens kept.

## [x] 1.6 Leave DECLARE_* and leftover keywords unwrapped

Stop preprocessor wrapper generation. `DECLARE_*` and leftover `delegate` / `event` text reach Parser as authored tokens.

**Outcome**

`FAngelscriptPreprocessor::Preprocess` of `DECLARE_DELEGATE_OneParam(FOnDone, int);` contains no `struct FOnDone` and no `_FScriptDelegate _Inner`. Leftover `delegate int FOnDone();` is not collected as `ProcessDelegates` work. Multi-line argument lists stay in one Global chunk.

**Interfaces**

Consumes:

```
FAngelscriptPreprocessor::ProcessDelegates  // Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:1167
ParseIntoChunks keyword scan  // Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:4281
FAngelscriptPreprocessor::DetectClasses  // Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:1341
```

Produces:

```
TEST_CLASS DelegatePreprocess
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegatePreprocess
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePreprocessTests.cpp
```

**Cases**

1. **NoPreprocessorWrapper** — new RED
   Given `DECLARE_DELEGATE_OneParam(FOnDone, int);` through `FAngelscriptPreprocessor::Preprocess` When the processed text is inspected Then it contains no `struct FOnDone` and no `_FScriptDelegate _Inner`.

2. **KeywordNotWrapped** — new RED
   Given `delegate int FOnDone();` When Preprocess finishes Then no DelegateHelper generated source is attached and no `_Inner` struct is synthesized.

3. **MultiLineDeclareOneChunk** — new RED
   Given a `DECLARE_DYNAMIC_DELEGATE_TwoParams` whose argument list spans three lines When Preprocess finishes Then the authored tokens remain in one Global chunk and Parser can still see one declaration.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePreprocessTests.cpp
```

Exclude Parser/Sema Flavor work and ClassGen.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegatePreprocess'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegatePreprocess` Succeeded. run `71ed48804d944de8911400ccf8e4c780` Total 3 Succeeded 3. Cases: NoPreprocessorWrapper, KeywordNotWrapped, MultiLineDeclareOneChunk.

## [x] 1.7 Register Flavor-aware callable descriptors

Consume 1.2 declarations. Produce `CreateCallableType` plus `FAngelscriptDelegateDesc` with Flavor and Signature copied from the declaration. No `UDelegateFunction`.

**Outcome**

A resolved ordinary `DECLARE_DELEGATE_OneParam` descriptor has `bIsDynamic == false`, a structured `int` parameter signature, and `Function == nullptr`. A dynamic form has `bIsDynamic == true` and keeps the authored parameter name. ClassGen is out of this card.

**Interfaces**

Consumes:

```
asCCallableTypeDecl  // 1.2 product
FAngelscriptDescriptorConsumer callable projection  // as_descriptor_consumer.cpp:256
asCDefinitions::CreateCallableType  // Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.cpp:631
```

Produces:

```
FAngelscriptDelegateDesc.bIsDynamic  // Naming assumed: design.md, AngelscriptDescriptors.h
TEST_CLASS DelegateRegister
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Definitions.DelegateRegister
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Definitions/DelegateRegisterTests.cpp
```

**Cases**

1. **OrdinaryDescFlavor** — new RED
   Given `DECLARE_DELEGATE_OneParam(FOnDone, int);` When the descriptor consumer runs Then `bIsDynamic` is false, `bIsMulticast` is false, Signature has one `int` parameter, and `Function` is null.

2. **DynamicDescNames** — new RED
   Given `DECLARE_DYNAMIC_DELEGATE_OneParam(FDynOne, int, Value);` When projected Then `bIsDynamic` is true and the argument name is `Value`.

3. **CreateCallableTypeExists** — new RED
   Given the same ordinary declaration When the definition consumer runs Then `CreateCallableType` succeeds for `FOnDone` and the signature identity is the canonical `void(int)`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDescriptors.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_definition_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Definitions/DefinitionConsumerTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/AngelscriptFrontendReflectionDescriptorTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Definitions/DelegateRegisterTests.cpp
```

Exclude ClassGen `NewObject<UDelegateFunction>` and VM opcodes.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Definitions.DelegateRegister'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Definitions.DelegateRegister` Succeeded. run `fbfb78e8d9f548ebae4dcb8d4ca3091a` Total 3 Succeeded 3. Cases: OrdinaryDescFlavor, DynamicDescNames, CreateCallableTypeExists. `FAngelscriptDelegateDesc.bIsDynamic` copied from `asECallableFlavor`.

## 2. Executable callable model

## [x] 2.1 Execute and Broadcast DECLARE forms on CompileModules

Consume 1.3 plans, 1.4's returning CallPtr emission, 1.7 descriptors, and the UCLASS-join host. Produce construction, Bind, Execute, ExecuteIfBound, Add, and Broadcast for ordinary and dynamic flavors. Payloads and handle-mutation stay on 2.2/2.3.

**Outcome**

`DECLARE_DELEGATE_RetVal_OneParam` Execute(41) returns 42. Multicast Broadcast(7) reaches two listeners. A dynamic RetVal form returns 42 on the same path. Empty non-void Execute fails without writing an output. Keyword programs still fail compile.

**Interfaces**

Consumes:

```
FAngelscriptEngine::Create / CompileModules  // Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
ClassGenUClassReloadTests::MakeHostEngine  // Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp:32
DelegateRegister descriptors  // 1.7 product
```

Produces:

```
TEST_CLASS DelegateExecute
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateExecute
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateExecuteTests.cpp
```

**Cases**

1. **OrdinaryRetValExecute** — new RED
   Given isolated host + `DECLARE_DELEGATE_RetVal_OneParam(int, FAddOne, int);` + `int AddOne(int Value) { return Value + 1; }` When Bind+Execute(41) Then the result is 42.

2. **MulticastBroadcast** — new RED
   Given `DECLARE_MULTICAST_DELEGATE_OneParam(FOnValue, int);` and two named listeners When both are Added and Broadcast(7) Then both recorded values are 7.

3. **DynamicRetValExecute** — new RED
   Given `DECLARE_DYNAMIC_DELEGATE_RetVal_OneParam(int, FAddOne, int, Value);` and the same `AddOne` When Execute(41) Then the result is 42 without requiring `UDelegateFunction`.

4. **EmptyExecuteFails** — new RED
   Given an unbound `DECLARE_DELEGATE_RetVal_OneParam(int, FAddOne, int);` When Execute(1) Then execution fails and no return slot is presented as 0-by-success.

5. **KeywordStillRejected** — existing control
   Given `delegate int FAddOne(int);` on the same host When CompileModules runs Then the compile fails with `removed-delegate-event-keyword` and no callable runs.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_calls.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateExecuteTests.cpp
```

Do not add `as_callable*` paths that do not exist. Do not restore `Bind_Delegates` as the script callable.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateExecute'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateExecute` Succeeded. run `a8a8d58f96d04048bc9518fdc91d5424` Total 5 Succeeded 5. Cases: OrdinaryRetValExecute, MulticastBroadcast, DynamicRetValExecute, EmptyExecuteFails, KeywordStillRejected. Bind/Add stores a function pointer (`FuncPtr`+`AddPtr`/`CpyRtoV8`); Execute/Broadcast use `CallPtr`. Multicast observes through `int&inout` locals because mutable script globals are rejected. Naming assumed: `DelegateExecute` — design.md.

## [x] 2.2 Store explicit named-target payloads and receiver state

Disposition: preserved task ID. Consume 2.1 and 1.1's payload schema. Produce bind-time value initialization, copy/destruction and typed trailing payload invocation. No Lambda.

**Outcome**

Named `AddOffset(Value, Offset)` bound with Offset=10 returns 15 for Execute(5). Later changing the factory local Offset does not change the stored value. Escaping local-stack reference payloads reject. Anonymous function syntax remains rejected.

**Interfaces**

Consumes:

```
DelegateExecute host + Bind/Execute  // 2.1 product
```

Produces:

```
TEST_CLASS DelegatePayloads
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegatePayloads
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePayloadsTests.cpp
```

**Cases**

1. **StoredOffset** — new RED
   Given `DECLARE_DELEGATE_RetVal_OneParam(int, FTransform, int);` and `int AddOffset(int Value, int Offset)` When Create/Bind stores Offset=10 and Execute(5) Then the result is 15 after the factory returns.

2. **FactoryLocalUnchanged** — new RED
   Given the same binding When the factory later sets its local Offset to 99 Then a second Execute(5) is still 15.

3. **RejectStackRefPayload** — new RED
   Given a payload typed as a local-stack reference When Bind is analyzed or executed Then the payload is rejected and no callable is left bound.

4. **LambdaStillRejected** — existing control
   Given `BindLambda` or `function(){ return 42; }` When compiled Then Lambda rejection from the language-surface archive still holds.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_expr.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePayloadsTests.cpp
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegatePayloads'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegatePayloads` Succeeded. run `14ed6380e82445aebd293a584604a2ec` Total 4 Succeeded 4. Cases: StoredOffset, FactoryLocalUnchanged, RejectStackRefPayload, LambdaStillRejected. Bind/Create stores trailing value payloads in `asSCallableBinding` via `asBC_BindPtr`; Execute appends those dwords after invoke args. Stack-reference payloads reject as `escaping-stack-ref-payload` (4459). Naming assumed: `DelegatePayloads`, `asBC_BindPtr`, `escaping-stack-ref-payload` — design.md / neighbouring opcode and diagnostic convention.

## [x] 2.3 Implement multicast subscription handles and mutation boundaries

Consume 2.2 ownership. Produce Add/Remove/RemoveAll/Clear and broadcast over owned script multicast DECLARE forms. Native UE container semantics stay on 3.1.

**Outcome**

Two callbacks observe 42; Remove leaves the peer; duplicate Add produces two subscriptions; copied event has an independent handle domain; newly added callback misses the current Broadcast.

**Interfaces**

Consumes:

```
DelegateExecute Broadcast path  // 2.1
```

Produces:

```
TEST_CLASS DelegateMulticast
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateMulticast
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateMulticastTests.cpp
```

**Cases**

1. **RemoveLeavesPeer** — new RED
   Given `DECLARE_MULTICAST_DELEGATE_OneParam(FOn, int);` and two listeners When one handle is Removed and Broadcast(42) Then only the remaining listener records 42.

2. **DuplicateAdd** — new RED
   Given the same event When the same named listener is Added twice and Broadcast(1) Then two observations are recorded.

3. **CopiedDomain** — new RED
   Given a copied multicast When a handle from the source Remove is applied to the copy Then the copy still broadcasts to its own listeners.

4. **AddMissesCurrentRound** — new RED
   Given a listener that Adds another listener during Broadcast When that Broadcast completes Then the newly added listener has no observation for that round.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateMulticastTests.cpp
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateMulticast'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateMulticast` Succeeded. run `eb9ba45c75a74c0b9c4fe3e491be96ce` Total 4 Succeeded 4. Cases: RemoveLeavesPeer, DuplicateAdd, CopiedDomain, AddMissesCurrentRound. Add/Remove/Clear/Clone use `asBC_AddPtr`/`RemovePtr`/`ClearPtr`/`ClonePtr`; Broadcast snapshots listeners and runs each script target to completion through `CallScriptFunctionUntilReturn` so interpreter fan-out is not a tail-call stack. Copy reissues handles from the source `NextHandle` so a source handle does not Remove on the copy. Naming assumed: `DelegateMulticast`, `asBC_AddPtr`, `asBC_RemovePtr`, `asBC_ClearPtr`, `asBC_ClonePtr`, `CallScriptFunctionUntilReturn` — design.md / neighbouring opcode and VM convention.

## 3. Unreal interoperability

## [x] 3.1 Adapt registered native C++ delegates and live multicast members

Consume 2.3 and 1.1 adapter interfaces. Produce real `TDelegate` values and borrowed native-event views. Do not restore legacy runtime as the script callable.

**Outcome**

A registered `TDelegate<int(int)>` invoked with 2 on a named AddOffset callback with payload 40 returns 42. Native multicast subscribe/unsubscribe operates on the original object.

**Interfaces**

Consumes:

```
FAngelscriptDelegateOperations  // Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.h:21
```

Produces:

```
TEST_CLASS DelegateNativeInterop
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateNativeInterop
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateNativeInteropTests.cpp
```

**Cases**

1. **NativeRetainedCallback** — new RED
   Given a compiled native `TDelegate<int(int)>` fixture When a named script callback with explicit payload 40 is retained and invoked with 2 Then the native call returns 42.

2. **SignatureMismatch** — new RED
   Given a mismatched script signature When bind-to-native is attempted Then failure occurs before native callback entry.

3. **NativeMulticastRemove** — new RED
   Given a native multicast member When a script subscriber is added then removed by the returned handle Then a later native Broadcast does not reach that subscriber.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.h
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateNativeInteropTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateNativeFixtures.h
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateNativeFixtures.cpp
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateNativeInterop'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateNativeInterop` Succeeded. run `62e57d1397664a1ca73bb8a4292e4cd2` Total 3 Succeeded 3. Cases: NativeRetainedCallback, SignatureMismatch, NativeMulticastRemove. `BindScriptIntTransform` builds a real `TDelegate<int32(int32)>` thunk that Prepare/Executes the named script target plus payload; mismatch unbinds before native entry. `AddScriptIntListener` adds a thunk on the original `TMulticastDelegate` and `Remove` uses the returned `FDelegateHandle`. Naming assumed: `DelegateNativeInterop`, `BindScriptIntTransform`, `AddScriptIntListener` — design.md / neighbouring Bind_Delegates convention.

## [x] 3.2 Materialize dynamic signature functions and reflected properties

Consume 1.7 Flavor-aware descriptors and the ClassGen host. Produce `UDelegateFunction` plus `FDelegateProperty` / `FMulticastInlineDelegateProperty` for dynamic forms only. Invocation stays on 3.3. Analyze uses `Desc.Signature`; it does not call `GetMethodByName("Execute")` or `GetMethodByName("Broadcast")`.

**Outcome**

`DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealth, int, NewHealth)` publishes a `UDelegateFunction` whose UserData is set on the script type. Ordinary multicast with BlueprintAssignable is rejected. Two modules with the same short name do not collide.

**Interfaces**

Consumes:

```
FAngelscriptDelegateDesc + bIsDynamic  // 1.7 product, as_descriptor_consumer.cpp:260
UDelegateFunction NewObject  // AngelscriptClassGenerator_FullReload.cpp:253
```

Produces:

```
TEST_CLASS DelegateReflection
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateReflection
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateReflectionTests.cpp
```

**Cases**

1. **DynamicSignaturePublished** — new RED
   Given isolated host + `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealth, int, NewHealth);` When CompileModules Initial finishes Then `FindObject<UDelegateFunction>` succeeds and script UserData is that function.

2. **OrdinaryBlueprintAssignableRejected** — new RED
   Given `DECLARE_MULTICAST_DELEGATE` used as a `UPROPERTY(BlueprintAssignable)` When compiled Then the compile fails and no public partial class is left.

3. **ShortNameNoCollision** — new RED
   Given two modules both declaring `DECLARE_DYNAMIC_DELEGATE(FOnDone);` When compiled Then publication fails atomically or uses a non-colliding host name; no second public overwrite.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateReflectionTests.cpp
```

Do not invent `ClassGenerator/DelegateReflection/**` unless 1.1 records a new file that ClassGen cannot own.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateReflection'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateReflection` Succeeded. run `8e8a160053534394ab5ae86139f9ea07` Total 3 Succeeded 3. Cases: DynamicSignaturePublished, OrdinaryBlueprintAssignableRejected, ShortNameNoCollision. Builder output Delegates are merged onto the host module; `asCModule::GetTypeInfoByName` resolves callable types; ClassGen publishes `UDelegateFunction` for dynamic forms only and rejects ordinary `BlueprintAssignable`. Sequential same-name compile keeps the first signature. Naming assumed: `DelegateReflection` — design.md / neighbouring NativeEngine Compile convention.

## [x] 3.3 Execute dynamic delegates between script, native UFunctions and Blueprint

Consume 2.2 and 3.2. Produce BindDynamic/AddDynamic, marshalling, and a real Blueprint listener. Descriptor-only assertions cannot substitute.

**Outcome**

Script Broadcast of (100,75) is recorded by a compiled Blueprint listener. A UE dynamic delegate invokes a script UFUNCTION. Dead receivers are skipped.

**Interfaces**

Consumes:

```
UDelegateFunction from 3.2
FKismetEditorUtilities::CreateBlueprint  // ClassGenUClassReloadTests.cpp
```

Produces:

```
TEST_CLASS DelegateDynamicInterop
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateDynamicInterop
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateDynamicInteropTests.cpp
```

**Cases**

1. **BlueprintListenerValues** — new RED
   Given a dynamic multicast `FOnHealth` and a transient Blueprint listener When script Broadcast(100,75) Then the listener records both values.

2. **ScriptUFunctionFromNative** — new RED
   Given a UE dynamic delegate aimed at a script `UFUNCTION` When native Broadcast/Execute runs Then the script handler observes the expected arguments.

3. **BindDynamicRequiresUFunction** — new RED
   Given BindDynamic to a non-UFUNCTION target When analyzed Then bind fails. Replaces the 1.3 deferred RED.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASFunction.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateDynamicInteropTests.cpp
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateDynamicInterop'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateDynamicInterop` Succeeded. run `1bbd978f5423479a86c98ef6ce5cd708` Total 3 Succeeded 3. Cases: BlueprintListenerValues, ScriptUFunctionFromNative, BindDynamicRequiresUFunction. Script `AddDynamic` + `Broadcast(100,75)` writes the Blueprint-child listener; native `FScriptDelegate.BindUFunction` + `ProcessDelegate` writes a script `UFUNCTION`; BindDynamic to a non-UFUNCTION is `bind-requires-ufunction`. Nested script `UFUNCTION` invoke uses a fresh context. `BindPtr` reads the emitted 8-byte name payload (not `sizeof(FName)`). Naming assumed: `DelegateDynamicInterop` — design.md / neighbouring NativeEngine Compile convention.

## 4. Host lifecycle acceptance

## [x] 4.1 Prove delegate host loading, invalidation and integrated ownership

Consume 3.1 and 3.3. This is the only card allowed to add delegate-owned plugin test assets. Use Harness `ue.*` routes only. 1.1 must have recorded the exact cook route before this node is Ready.

**Outcome**

A dependent Blueprint loads after script reflection publication. Dynamic Broadcast delivers (100,75). Incompatible signature re-entry is refused. Bindings release on teardown.

**Interfaces**

Consumes:

```
DelegateDynamicInterop + DelegateNativeInterop  // 3.3 and 3.1
```

Produces:

```
TEST_CLASS DelegateLifecycle
  // Naming assumed: design.md, Angelscript.UnitTest.NativeEngine.Compile.DelegateLifecycle
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateLifecycleTests.cpp
openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/integration-evidence.md
```

**Cases**

1. **EditorBroadcastAfterLoad** — new RED
   Given the 1.1 editor fixture When the dependent Blueprint loads and dynamic Broadcast(100,75) runs Then the listener records both values.

2. **IncompatibleReentryRejected** — new RED
   Given a stable name whose signature/payload layout changed When the stale callback is invoked Then entry is refused.

3. **TeardownReleases** — new RED
   Given native and reflected bindings When the test host is torn down Then owned bindings are released once.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegateLifecycleTests.cpp
+Plugins/Angelscript/Content/Tests/Delegates/README.md
+openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/integration-evidence.md
 openspec/changes/angelscript/feature-delegates-ue-interop/attachments/INDEX.md
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateLifecycle'; Fast = $true; TimeoutMs = 600000 }
```

Cooked-load proof uses the exact `ue.*` route 1.1 records in `planning-contracts.md` and is retained in `integration-evidence.md`. This prefix covers the editor half; 1.1 must not leave the cook route unspecified when this node becomes Ready.

**Evidence**

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateLifecycle` Succeeded. run `5d05f5118c7749dcb812ab5261629705` Total 3 Succeeded 3. Cases: EditorBroadcastAfterLoad, IncompatibleReentryRejected, TeardownReleases. Transient Blueprint loads after `CompileModules` publishes the listener; `Broadcast(100,75)` records both values; a 0-param `UFUNCTION` on a TwoParams callable is refused (`Indirect call signature mismatch`); native `TDelegate` Unbind plus `Ev.Clear` release once before host teardown. Cooked-load asset omitted; cook route retained in `attachments/data/integration-evidence.md`. Naming assumed: `DelegateLifecycle` — design.md / neighbouring NativeEngine Compile convention.

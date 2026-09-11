---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["1.1"]
    "4.1": ["1.1", "3.1"]
    "5.1": ["2.1", "4.1"]
    "5.2": ["5.1"]
---

# Retire MetadataImage for engine-free compile and batch registration

## Goal

Replace Image-owned script TypeInfo with per-unit `asCModuleDefinitionSet`, two Builder products, Function-hung bytecode, and one Engine Install+Link after the compile DAG.

## Architecture

Snapshot `asCBuilder` has no Engine. Script TypeInfo live on a takeable `asCModuleDefinitionSet` until `asCEngineCompileRegistration` Install+Link. `asCCompileOutput` is diagnostics plus `FAngelscript*Desc` with empty `ScriptType`. Stable bytecode is Emit onto `asCScriptFunction`; runtime bytecode is written only at Registration. Image remains BindInfo-only. See `design.md`.

## Global constraints

- The user requested Change creation. These nodes stay unchecked until a later apply authorization. Planning does not authorize applying tasks, UE execution, spec synchronization, archive, or Git.
- Binding Draft/Apply keep constructing `asCMetadataImage` and `RegisterMetadataImage`. Do not delete `as_metadata_image.*` in this Change.
- Do not implement host `CompileModules` / ClassGen UClass, a module-wave thread pool, `asSStableKey` rename, or a replacement bytecode persist codec.
- New tests use `WITH_ANGELSCRIPT_TESTS`, TestDir `Angelscript.UnitTest.NativeEngine`, class `CompileLifecycle`. Identity `Angelscript.UnitTest.<Area>.<Scenario>`.
- Transitional `TakeDefinitions()` that wraps a Taken set into Image is allowed only until 5.1 removes it. New tests call `TakeModuleDefinitionSet`.
- Public `asCByteCodeImage` / snapshot types stay until 5.2 retargets hand-authored VM tests. 5.1 does not delete those headers.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/
+  as_module_definition_set.h  # · 1.1
+  as_module_definition_set.cpp  # · 1.1
+  as_compile_output.h  # · 2.1
+  as_compile_output.cpp  # · 2.1
+  as_engine_compile_registration.h  # · 4.1
+  as_engine_compile_registration.cpp  # · 4.1
   as_builder.h  # · 1.1, 2.1, 3.1
   as_builder_frontend.cpp  # · 1.1, 2.1, 3.1
   frontend/as_builder_stages.h  # · 1.1, 3.1
   frontend/as_definition_consumer.h  # · 1.1
   frontend/as_definition_consumer.cpp  # · 1.1
   as_bytecode_emitter.h  # · 3.1
   as_bytecode_emitter.cpp  # · 3.1
   as_scriptfunction.h  # · 1.1, 3.1, 4.1
   as_context.h  # · 4.1
   as_scriptengine.h  # · 4.1
   as_scriptengine_metadata.cpp  # · 4.1
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/CompileLifecycleTests.cpp  # · 1.1, 2.1, 3.1, 4.1
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/  # · 5.1
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Registration/  # · 5.1
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/  # · 5.1
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/  # · 5.1, 5.2
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Independent typed compilation stages (engine-free TypeInfo on a set) | 1.1 |
| Builder yields two takeable products | 1.1, 2.1 |
| Default RunThrough emits stable bytecode | 3.1 |
| Script compile transfers TypeInfo through a definition set | 4.1 |
| Script TypeInfo lives on a module definition set until batch Engine transfer | 1.1, 4.1 |
| Transactional single-engine definition binding (script Registration) | 4.1 |
| Stable bytecode hangs on the function without an Engine | 3.1 |
| Registration is the only runtime bytecode writer | 4.1 |
| Source emission consumes frozen definitions | 3.1, 4.1 |
| Executable verification precedes publication | 3.1, 4.1 |
| Stable symbol linking is transactional | 4.1 |
| Source definition placement preserves private ownership | 4.1 |
| Prepare reads Function runtime bytecode | 4.1 |
| Image-as-product tests follow the new products | 5.1 |
| Public ByteCodeImage / snapshot types leave the VM path | 5.2 |
| Acceptance: Taken set has null Engine and TypeId -1 | 1.1 |
| Acceptance: later unit compiles against a Taken set | 1.1 |
| Acceptance: CompileOutput `ScriptType` stays empty | 2.1 |
| Acceptance: one Registration then Prepare; Prepare before that is `asNO_FUNCTION` | 4.1 |
| Acceptance: Image-as-product tests rewritten; Binding may stay commented | 5.1 |
| Acceptance: public ByteCodeImage / ExecutableSnapshot gone from script/VM path | 5.2 |

Self-review 2026-09-11: coverage complete; no placeholder phrases; symbols match `design.md` and `attachments/drafts/glossary.md` (`asCModuleDefinitionSet`, `asCCompileOutput`, `asCEngineCompileRegistration`, `TakeModuleDefinitionSet`, `HostImages` leftover). Record: `attachments/data/planning-validation.md`.

## 1. Definition set

## [ ] 1.1 Own script TypeInfo on a takeable module definition set

Builder today owns a `TUniquePtr<asCMetadataImage>` and `Options.Dependencies` is `TArray<asCMetadataImage*>`. After this task the script product is `asCModuleDefinitionSet`; snapshot compile still has no Engine. BindInfo Image constructors stay. `TakeDefinitions()` may wrap a Taken set into Image so existing `RegisterMetadataImage` tests still compile; new tests do not wrap.

**Outcome**

A successful freeze yields a Taken `asCModuleDefinitionSet` whose TypeInfo have null Engine and TypeId -1. A second Builder can compile against that set without Registration. Destroying the set without Registration deletes the objects. Excluded: Emit, Registration.Link, CompileOutput payload, deleting Image, host CompileModules.

**Interfaces**

Consumes (existing, `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h:22-32`, `frontend/as_builder_stages.h:21-28`, `frontend/as_definition_consumer.h:31-32`, `as_typeinfo.h:78` and `:96`):

```cpp
asCBuilder(TSharedRef<asCSourceSnapshot, ESPMode::ThreadSafe> Snapshot,
    asCDiagnosticsEngine& Diagnostics, const asSBuilderOptions& Options);
bool RunThrough(asEBuilderStage Stage = asEBuilderStage::DefinitionsFrozen);
TUniquePtr<asCMetadataImage> TakeDefinitions();
TArray<asCMetadataImage*> asSBuilderOptions::Dependencies;
asIScriptEngine* asCTypeInfo::GetEngine() const;
int asCTypeInfo::GetTypeId() const;
```

Produces (glossary `asCModuleDefinitionSet`, `TakeModuleDefinitionSet`; `HostImages` leftover from `design.md` BindInfo exception; `ByteCodeEmitted` later in 3.1):

```cpp
class asCModuleDefinitionSet {
public:
    TConstArrayView<asCTypeInfo*> GetTypes() const;
    TConstArrayView<asCScriptFunction*> GetFunctions() const;
    TConstArrayView<asCGlobalProperty*> GetGlobalProperties() const;
    TConstArrayView<asCModuleDefinitionSet*> GetDependencies() const;
    asCTypeInfo* FindType(const char* Name) const;
    asCTypeInfo* FindType(const asSStableKey& Key) const;
    asCScriptFunction* FindFunction(const asSStableKey& Key) const;
    bool IsImmutable() const;
};
TUniquePtr<asCModuleDefinitionSet> asCBuilder::TakeModuleDefinitionSet();
const asCModuleDefinitionSet* asCBuilder::GetModuleDefinitionSet() const;
TArray<asCModuleDefinitionSet*> asSBuilderOptions::Dependencies;
TArray<asCMetadataImage*> asSBuilderOptions::HostImages;
asSDefinitionConsumerResult::Definitions; // TUniquePtr<asCModuleDefinitionSet>
TEST_CLASS_WITH_FLAGS(CompileLifecycle, "Angelscript.UnitTest.NativeEngine", flags);
```

**Cases**

Setup: each case constructs snapshot `asCBuilder` with `asSBuilderOptions.TypeContext` set, `StableScope` `compile-lifecycle`, and UTF-8 source added then frozen. No `asCreateScriptEngine` unless a case names one.

1. **TakeSetReportsNullEngine** — new RED
   Given source `class Unit { int32 Value; void Set(int32 V) { Value = V; } }` When `RunThrough(DefinitionsFrozen)` succeeds and `TakeModuleDefinitionSet()` When inspecting `FindType("Unit")` Then `GetEngine()` is null and `GetTypeId()` equals -1.
2. **TakeSetMovesUniquePtr** — new RED
   Given the same successful freeze When `TakeModuleDefinitionSet()` Then the UniquePtr is non-null and `GetModuleDefinitionSet()` is null and a second Take returns null.
3. **TakeSetSecondBuilderResolvesFirst** — new RED
   Given Taken set from `class First { int32 Value; }` When a second Builder compiles `class Second { First Field; }` with `Options.Dependencies` holding that set pointer Then RunThrough succeeds and the second Taken set `FindType("Second")` is non-null while `FindType("First")` is null on the second set.
4. **TakeSetDestroyDeletesTypes** — new RED
   Given Taken set from `class Gone { }` with `asCTypeInfo* Raw = Set->FindType("Gone")` When the UniquePtr is reset Then `Raw` is not a live TypeInfo (subsequent use is not required; the observable is that a new compile of the same source yields a different pointer and the destroyed set cannot be used as `Dependencies`).
5. **TakeSetFailedRunThroughYieldsNothing** — boundary
   Given source `class {` (syntax error) When RunThrough fails Then `TakeModuleDefinitionSet()` returns null.
6. **TakeSetMutableDependencyRejected** — new RED
   Given a Builder that has collected declarations but not frozen When a second Builder lists that unfinished set in `Dependencies` Then the second RunThrough fails and publishes no Taken set.
7. **HostImagesStillAcceptFrozenImage** — existing control
   Given FrozenHostSemanticTests still pass a frozen BindInfo Image through `Options.HostImages` Then that host graph remains visible to script compile without Registration.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_frontend.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_builder_stages.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_definition_consumer.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_definition_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_objecttype.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_typeinfo.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_property.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/FrozenHostSemanticTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/GenericDefinitionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/ListInitializerDefinitionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/DefinitionConsumerTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/CompileLifecycleTests.cpp
```

UBT picks up the new cpp through the existing AngelscriptRuntime / AngelscriptTest globs. `as_metadata_image.*` is not deleted.

**Verification**

Run from the selected workspace root after a successful `ue.build`. Cases 1–6 are `CompileLifecycle` methods whose names start with `Take`. Case 7 is `Angelscript.UnitTest.NativeEngine` FrozenHost methods already in `FrozenHostSemanticTests.cpp`; include them in this run.

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($build.status -ne 'Succeeded') { throw '1.1 build failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.CompileLifecycle.Take+Angelscript.UnitTest.NativeEngine.FrozenHostSemantics'; Fast = $true; TimeoutMs = 600000 }
if ($result.status -ne 'Succeeded') { throw '1.1 tests failed' }
```

All Take cases discovered and passed. FrozenHost host-image compile still discovered and passed. Omitted: full NativeEngine, Binding, host CompileModules.

**Notes**

Keep Image constructors used by BindInfo. If `TakeDefinitions` remains, implement it as a wrap of TakeModuleDefinitionSet so Compiler tests that still `RegisterMetadataImage(TakeDefinitions())` compile until 5.1.

## 2. CompileOutput

## [ ] 2.1 Project ClassGen descriptors without filling ScriptType

`FAngelscriptDescriptorConsumer` already projects `FAngelscriptModuleDesc`. After this task that bag is reachable from `asCCompileOutput` on the snapshot Builder. TypeInfo stay on the definition set. `ScriptType` / `ScriptFunction` stay null.

**Outcome**

`GetCompileOutput` / `TakeCompileOutput` return diagnostics plus `asCDefinitionCompileOutput` whose modules reuse `FAngelscriptModuleDesc` / `ClassDesc`. `ScriptType` is null. CompileOutput does not own TypeInfo. Excluded: ClassGen UClass, filling ScriptType after Registration, Binding.

**Interfaces**

Consumes (existing, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDescriptors.h:197-216` and `:336-368`, `frontend/as_descriptor_consumer.h:26-36`):

```cpp
struct FAngelscriptClassDesc { asITypeInfo* ScriptType = nullptr; FString ClassName; };
struct FAngelscriptModuleDesc { TArray<TSharedRef<FAngelscriptClassDesc>> Classes; };
class FAngelscriptDescriptorConsumer { bool Project(...) const; };
```

Produces (glossary `asCCompileOutput`, `asCDefinitionCompileOutput`):

```cpp
class asCDefinitionCompileOutput {
public:
    TConstArrayView<TSharedRef<FAngelscriptModuleDesc>> GetModules() const;
};
class asCCompileOutput {
public:
    TConstArrayView<asSDiagnosticRecord> GetDiagnostics() const;
    const asCDefinitionCompileOutput& GetDefinitionOutput() const;
};
const asCCompileOutput* asCBuilder::GetCompileOutput() const;
TUniquePtr<asCCompileOutput> asCBuilder::TakeCompileOutput();
```

**Cases**

1. **CompileOutputReportsClassName** — new RED
   Given source `class Widget { int32 A; }` When RunThrough succeeds and `GetCompileOutput()` Then the first module contains a class whose `ClassName` is `Widget`.
2. **CompileOutputLeavesScriptTypeNull** — new RED
   Given the same compile When reading that `FAngelscriptClassDesc` Then `ScriptType` is null and each method `ScriptFunction` is null.
3. **CompileOutputHasNoTypeInfo** — new RED
   Given the same compile When inspecting `asCCompileOutput` Then it has no TypeInfo pointer API and `TakeModuleDefinitionSet()->FindType("Widget")` is the live TypeInfo.
4. **CompileOutputTakeMovesBag** — new RED
   Given a successful compile When `TakeCompileOutput()` Then the UniquePtr is non-null and `GetCompileOutput()` is null.
5. **CompileOutputFailedKeepsDiagnostics** — boundary
   Given source `class {` When RunThrough fails Then `GetCompileOutput()->GetDiagnostics()` is non-empty and `TakeModuleDefinitionSet()` is null.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_frontend.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_descriptor_consumer.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_descriptor_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/CompileLifecycleTests.cpp
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($build.status -ne 'Succeeded') { throw '2.1 build failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.CompileLifecycle.CompileOutput'; Fast = $true; TimeoutMs = 600000 }
if ($result.status -ne 'Succeeded') { throw '2.1 tests failed' }
```

All CompileOutput cases discovered and passed. Omitted: host ClassGen, Binding.

## 3. Emit

## [ ] 3.1 Hang stable bytecode on the function and stop producing ByteCodeImage

`asCByteCodeEmitter::Emit` currently returns `TUniquePtr<asCByteCodeImage>`. After this task Emit writes stable bytecode onto each script `asCScriptFunction`. Default `RunThrough` stop is `ByteCodeEmitted`. The public emitter remains. `asCByteCodeImage` may still exist for BindInfo-unrelated leftover tests until 5.1 deletes it from the script/VM path.

**Outcome**

Default RunThrough emits. `GetStableByteCode()` on a script function is non-empty without an Engine. Native system functions keep an empty stable body. Public Emit no longer returns `asCByteCodeImage` as the script product. Excluded: writing runtime bytecode, Prepare, deleting Image, persist codec.

**Interfaces**

Consumes (existing, `as_bytecode_emitter.h:53-59`, `as_scriptfunction.h:278`, `as_builder.h:25`):

```cpp
class asCByteCodeEmitter {
    static asSByteCodeEmissionResult Emit(const asCCompilationSession*, const asCMetadataImage*, const asSByteCodeEmissionOptions&);
    static asSByteCodeEmissionResult Emit(asCBuilder& Builder, asCScriptFunction& Function);
};
asDWORD* asCScriptFunction::GetByteCode(asUINT* length = 0);
bool asCBuilder::RunThrough(asEBuilderStage Stage = asEBuilderStage::DefinitionsFrozen);
```

Produces (glossary: hang both on Function; `asCByteCodeEmitter` stays public; `ByteCodeEmitted` from existing `asEBuilderStage` convention in `as_builder_stages.h:16-19`):

```cpp
enum class asEBuilderStage : uint8 { ..., DefinitionsFrozen, ByteCodeEmitted, Failed };
bool asCBuilder::RunThrough(asEBuilderStage Stage = asEBuilderStage::ByteCodeEmitted);
TConstArrayView<asDWORD> asCScriptFunction::GetStableByteCode() const;
struct asSByteCodeEmissionResult {
    asEByteCodeEmissionStatus EmissionStatus;
    asSByteCodeEmissionFailure Failure;
};
static asSByteCodeEmissionResult asCByteCodeEmitter::Emit(asCBuilder& Builder);
static asSByteCodeEmissionResult asCByteCodeEmitter::Emit(
    const asCCompilationSession* Session,
    const asCModuleDefinitionSet* FrozenDefinitions,
    const asSByteCodeEmissionOptions& Options);
```

**Cases**

1. **EmitWritesStableOnFunction** — new RED
   Given source `int32 Identity(int32 V) { return V; }` When RunThrough reaches `ByteCodeEmitted` Then the Taken set's Identity function `GetStableByteCode().Num()` is greater than 0.
2. **RunThroughDefaultEmits** — new RED
   Given the same source When calling `RunThrough()` with no stage argument Then `GetStage()` is `ByteCodeEmitted` (or the run succeeded through Emit) and stable bytecode is present.
3. **EmitWithoutEngine** — new RED
   Given the same compile When inspecting the function Then `GetEngine()` is still null and stable bytecode contains no requirement that an Engine exist.
4. **EmitNativeSystemEmptyStable** — boundary
   Given a host Image system function still constructed as `asFUNC_SYSTEM` When that function is not a script body Then `GetStableByteCode()` is empty.
5. **EmitStopAtFrozenSkipsStable** — existing control
   Given `RunThrough(DefinitionsFrozen)` When inspecting the Taken script function Then stable bytecode may be empty and the run still succeeded.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_frontend.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_builder_stages.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/CompileLifecycleTests.cpp
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($build.status -ne 'Succeeded') { throw '3.1 build failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.CompileLifecycle.Emit'; Fast = $true; TimeoutMs = 600000 }
if ($result.status -ne 'Succeeded') { throw '3.1 tests failed' }
```

All Emit cases discovered and passed. Omitted: VM Execute, persist codec, deleting `as_bytecode_image.*` in this node.

## 4. Registration

## [ ] 4.1 Install+Link in one Registration and Prepare from Function runtime bytecode

`RegisterMetadataImage` plus `asLinkByteCodeImage` currently publish `asCExecutableSnapshot`. After this task script compile uses `asCEngineCompileRegistration::Register` which Installs the UniquePtr sets then writes runtime bytecode onto the same functions. `Prepare` of a script function without that stream returns `asNO_FUNCTION`. BindInfo still calls `RegisterMetadataImage`.

**Outcome**

One success Installs types (Engine pointer and TypeId assigned) and writes runtime bytecode. Prepare after that succeeds. Prepare before that returns `asNO_FUNCTION`. A failed list is all-or-nothing. `$obj` / `$func` are created on Engine construction without Image. Excluded: BindInfo Apply rewrite, generating runtime bytecode at first Prepare, public snapshot types remaining until 5.1 test rewrite.

**Interfaces**

Consumes (existing, `as_scriptengine.h:311-323`, `as_bytecode_linker.h:10-13`, `as_context.h:112-113`, `as_scriptengine_metadata.cpp` `InitializeMetadataBuiltins`):

```cpp
asEMetadataRegistrationResult asCScriptEngine::RegisterMetadataImage(TUniquePtr<asCMetadataImage>);
asEByteCodeLinkStatus asLinkByteCodeImage(asCScriptEngine&, const asCByteCodeImage&, asCExecutableSnapshot*&);
int asIScriptContext::Prepare(asIScriptFunction* func);
int asIScriptContext::Prepare(asCExecutableSnapshot* Snapshot, const asSStableKey& Key);
```

Produces (glossary `asCEngineCompileRegistration`):

```cpp
class asCEngineCompileRegistration {
public:
    explicit asCEngineCompileRegistration(asCScriptEngine& Engine);
    asEMetadataRegistrationResult Register(TArray<TUniquePtr<asCModuleDefinitionSet>> Sets);
};
int asIScriptContext::Prepare(asIScriptFunction* func); // reads Function.runtime only
```

**Cases**

1. **RegisterInstallsEngineAndTypeId** — new RED
   Given Taken set from `class Unit { int32 Value; int32 Get() { return Value; } }` When `asCEngineCompileRegistration(Engine).Register({MoveTemp(Set)})` succeeds Then `FindType("Unit")->GetEngine()` equals that Engine and `GetTypeId()` is greater than `asTYPEID_LAST_PRIMITIVE`.
2. **RegisterWritesRuntimeBytecode** — new RED
   Given the same Registration When inspecting Unit.Get Then `GetByteCode` length is greater than 0 (runtime stream).
3. **PrepareBeforeRegisterReturnsNoFunction** — new RED
   Given a Taken set with stable bytecode and an Engine that has not Registered it When `CreateContext()->Prepare(GetFunction)` Then the return is `asNO_FUNCTION`.
4. **PrepareAfterRegisterExecutes** — new RED
   Given Registration of `int32 Identity(int32 V) { return V; }` When Prepare+SetArgDWord(0, 7)+Execute Then GetReturnDWord equals 7.
5. **RegisterAllOrNothing** — new RED
   Given two sets where the second duplicates the first's type name When Register({First, Second}) Then the result is a failure status, Identity from the submitted list is not Prepare-able, and types that existed on the Engine before the call remain.
6. **RegisterDoesNotUseImage** — new RED
   Given the successful path When searching the Registration call Then it does not require `asCMetadataImage` or `asCByteCodeImage` as inputs.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_engine_compile_registration.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_engine_compile_registration.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_metadata.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/CompileLifecycleTests.cpp
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($build.status -ne 'Succeeded') { throw '4.1 build failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.CompileLifecycle.Register'; Fast = $true; TimeoutMs = 600000 }
if ($result.status -ne 'Succeeded') { throw '4.1 tests failed' }
```

All Register cases discovered and passed. Omitted: Binding Apply GREEN, deleting `RegisterMetadataImage`, full NativeEngine.

## 5. Tests

## [ ] 5.1 Retarget Image-as-compile-product tests and remove TakeDefinitions

Image-named compile tests still Create/Take Image and `RegisterMetadataImage` for script TypeInfo. After this task those tests use DefinitionSet + Registration. `TakeDefinitions` is removed. Hand-authored VM tests may still mention `asCByteCodeImage` until 5.2. BindInfo files still compile against Image. Comment a Binding test only when it fails to compile solely because BindInfo still needs Image; do not treat Binding GREEN as a gate.

**Outcome**

`MetadataImage`, `DefinitionConsumer`, `EngineRegistration`, `TypeOwnership.Image`, and `VMDetachedMetadata` prove DefinitionSet ownership. Compiler and LanguageSurface tests call `TakeModuleDefinitionSet` then Registration. `NativeDetachedDefinitionTestSupport.h` no longer uses Image as the script compile product. Excluded: deleting `as_bytecode_image.*`, rewriting BindInfo Draft/Apply, host CompileModules, Binding GREEN.

**Interfaces**

Consumes (existing test identities, `MetadataImageTests.cpp:19`, `DefinitionConsumerTests.cpp:15`, `EngineRegistrationTests.cpp:11`, `TypeOwnershipImageTests.cpp:10`, `VMDetachedMetadataTests.cpp:9`, BindInfo `AngelscriptTypeBindInfoDraft.cpp:49`, `AngelscriptTypeBindInfoApply.cpp` `RegisterMetadataImage`):

```cpp
TEST_CLASS_WITH_FLAGS(MetadataImage, "Angelscript.UnitTest.NativeEngine", flags);
TEST_CLASS_WITH_FLAGS(DefinitionConsumer, "Angelscript.UnitTest.NativeEngine", flags);
TEST_CLASS_WITH_FLAGS(EngineRegistration, "Angelscript.UnitTest.NativeEngine", flags);
TEST_CLASS_WITH_FLAGS(Image, "Angelscript.UnitTest.NativeEngine.TypeOwnership", flags);
TEST_CLASS_WITH_FLAGS(VMDetachedMetadata, "Angelscript.UnitTest.NativeEngine", flags);
TUniquePtr<asCMetadataImage> asCMetadataImage::Create();
asEMetadataRegistrationResult asCScriptEngine::RegisterMetadataImage(TUniquePtr<asCMetadataImage>);
```

Produces: no new public SDK names. Test helpers consume `asCModuleDefinitionSet` and `asCEngineCompileRegistration` from 1.1/4.1.

**Cases**

1. **MetadataImageTestsUseDefinitionSet** — new RED
   Given `MetadataImage.ActualTypesAndMethodsNeedNoEngineOrNumericIds` When run after the rewrite Then it asserts TypeInfo on a Taken set (null Engine, TypeId -1) rather than `asCMetadataImage::Create` as the script product.
2. **EngineRegistrationUsesCompileRegistration** — new RED
   Given `EngineRegistration` When registering compiled script types Then it calls `asCEngineCompileRegistration::Register` and no longer `RegisterMetadataImage` for that script path.
3. **TakeDefinitionsRemoved** — new RED
   Given `as_builder.h` When compiled Then `TakeDefinitions` is absent and Compiler tests that used `RegisterMetadataImage(Builder.TakeDefinitions())` call Registration on `TakeModuleDefinitionSet()`.
4. **DetachedFixtureOwnsSet** — new RED
   Given `NativeDetachedDefinitionTestSupport.h` After this task Then it uniquely owns an `asCModuleDefinitionSet`, not `TUniquePtr<asCMetadataImage> Image` as the script product.
5. **BindInfoStillCompilesWithImage** — existing control
   Given `AngelscriptTypeBindInfoDraft.cpp` still assigns `Draft->Image = asCMetadataImage::Create()` When the runtime module compiles Then BindInfo is not rewritten. Binding tests stay enabled unless a named file fails to compile; a failure is recorded by commenting that test file with a one-line reason pointing at BindInfo Image.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/CompileLifecycleTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/MetadataImageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/DefinitionConsumerTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/NativeDetachedDefinitionTestSupport.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/VMDetachedMetadataTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Registration/EngineRegistrationTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipImageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipTestSupport.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/NativeSourceExecutionTestSupport.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceAdmissionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceCacheContractsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceCallContractsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceCallsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceControlFlowTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceExpressionsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceIntegrationTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceNumericTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceObjectsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceScopeCleanupTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceUnwindTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LanguageSurface/LambdaTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LanguageSurface/SDKTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LanguageSurface/SyntaxTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipBaselineTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipPrivateTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp
```

Compiler and LanguageSurface files are mechanical `TakeModuleDefinitionSet` + Registration replacements, not ClassGen work. BindInfo cpp files stay Image-backed; they are listed so the node does not delete Image out from under them. `as_bytecode_image.*` stays until 5.2.

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($build.status -ne 'Succeeded') { throw '5.1 build failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.MetadataImage+Angelscript.UnitTest.NativeEngine.DefinitionConsumer+Angelscript.UnitTest.NativeEngine.EngineRegistration+Angelscript.UnitTest.NativeEngine.TypeOwnership.Image+Angelscript.UnitTest.NativeEngine.VMDetachedMetadata+Angelscript.UnitTest.NativeEngine.CompileLifecycle'; Fast = $true; TimeoutMs = 600000 }
if ($result.status -ne 'Succeeded') { throw '5.1 tests failed' }
```

The listed classes are discovered and passed on the new products. Binding is omitted unless a BindInfo compile break forced a commented test, in which case Evidence names the file. Omitted: Quick, Integration, host CompileModules, `Angelscript.UnitTest.RuntimeBindings` as a pass gate, deleting ByteCodeImage headers.

## [ ] 5.2 Remove public ByteCodeImage and snapshot types from the VM path

Hand-authored VM tests still build `asCByteCodeImage` and `asLinkByteCodeImage` into `asCExecutableSnapshot`. After this task those tests Prepare Function runtime bytecode (source compile via Builder+Registration, or Emit onto a function then Registration). Public `asCByteCodeImage`, `asCExecutableFunction`, and `asCExecutableSnapshot` are gone. `Prepare(asCExecutableSnapshot*)` is gone. BindInfo does not use those types.

**Outcome**

NativeEngine VM tests execute through Function runtime bytecode. The listed public image/snapshot types and `as_bytecode_image_codec` are not SDK products. `Prepare` snapshot overload is absent. Excluded: a replacement persist codec, BindInfo rewrite, host CompileModules.

**Interfaces**

Consumes (existing, `as_bytecode_image.h` `class asCByteCodeImage`, `as_execution_snapshot.h:33` and `:51`, `as_bytecode_linker.h:10`, `as_context.h:113`, `NativeVMTestSupport.h` image builder helpers):

```cpp
class asCByteCodeImage;
class asCExecutableFunction;
class asCExecutableSnapshot;
asEByteCodeLinkStatus asLinkByteCodeImage(asCScriptEngine&, const asCByteCodeImage&, asCExecutableSnapshot*&);
int asIScriptContext::Prepare(asCExecutableSnapshot* Snapshot, const asSStableKey& Key);
```

Produces: no new public names. VM tests consume `asCEngineCompileRegistration` and `asCScriptFunction::GetByteCode` from 3.1/4.1.

**Cases**

1. **VMLinkingPreparesFunctionRuntime** — new RED
   Given `VMLinking.LinkResolvesOriginalFunctionPointers` When rewritten Then Prepare uses the registered function runtime bytecode and does not mention `asCExecutableSnapshot`.
2. **VMByteCodeImageTestsUseFunctionStream** — new RED
   Given `VMByteCodeImage` When run after the rewrite Then it asserts stable or runtime bytes on `asCScriptFunction`, not `TUniquePtr<asCByteCodeImage>`.
3. **PrepareSnapshotOverloadGone** — new RED
   Given `as_context.h` When compiled Then `Prepare(asCExecutableSnapshot*, const asSStableKey&)` is absent and VM context tests call `Prepare(asIScriptFunction*)`.
4. **PublicImageHeadersRemoved** — new RED
   Given AngelscriptRuntime public headers After this task Then `as_bytecode_image.h`, `as_bytecode_image_builder.h`, `as_bytecode_image_codec.h`, and `as_execution_snapshot.h` are not part of the public script/VM product (files deleted or no longer exported).
5. **VMScalarStillExecutes** — existing control
   Given `VMScalar` primitive execution tests When run after the rewrite Then they still return the same numeric results through Prepare+Execute of registered functions.

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_image.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_image.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_image_builder.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_image_builder.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_image_codec.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_image_codec.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_execution_snapshot.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_execution_snapshot.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/NativeVMTestSupport.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMByteCodeImageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMByteCodeVerifierTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMImageContractsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMLinkingTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMScalarTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMCacheTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMContextsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMWireFormatTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/
```

Every other `NativeEngine/VM/*Tests.cpp` that includes the deleted headers is updated in this node so `ue.build` succeeds. The listed files are the proving sample; the directory prefix `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/` is in the plan File map.

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($build.status -ne 'Succeeded') { throw '5.2 build failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMLinking+Angelscript.UnitTest.NativeEngine.VMByteCodeImage+Angelscript.UnitTest.NativeEngine.VMImageContracts+Angelscript.UnitTest.NativeEngine.VMScalar'; Fast = $true; TimeoutMs = 600000 }
if ($result.status -ne 'Succeeded') { throw '5.2 tests failed' }
```

The four classes are discovered and passed without snapshot/image products. `ue.build` succeeding is the oracle that remaining VM files no longer include the deleted headers. Omitted: full `Angelscript.UnitTest.NativeEngine.VM` prefix as a daily gate, persist codec, Binding.


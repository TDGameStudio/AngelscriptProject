# FAngelscriptType Correctness Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` (recommended) or
> `superpowers:executing-plans` to implement this plan task-by-task. Every
> behavior repair follows TDD and all build/test execution goes through the
> repository wrappers.

**Goal:** Repair the confirmed `FAngelscriptType` correctness and lifetime
defects without starting the later semantic-type or interface refactor.

**Architecture:** Preserve `FAngelscriptType` as the runtime interop adapter,
`FAngelscriptTypeUsage` as the concrete runtime usage, and one
`FAngelscriptTypeDatabase` per engine. Add deterministic initialization,
transactional finder commit, a closed database-explicit conversion path,
fail-closed byte-enum validation, and owned type-info slots for container
operations.

**Tech Stack:** Unreal Engine 5.7 C++, AngelScript 2.33 WIP fork, UE Reflection,
CQTest, `FAngelscriptTestEngine`, PowerShell repository build/test wrappers,
OpenSpec.

## Global Constraints

- Work in the current main checkout; do not create a worktree unless the user
  explicitly requests one.
- `Plugins/Angelscript` is a git submodule. Commit plugin source/tests inside the
  submodule first, then record the final gitlink with parent OpenSpec/docs.
- Do not change the `FAngelscriptTypeUsage` field order, size, alignment, or
  replace its union in this change.
- Do not redesign alias resolution, nominal type identity, hot-reload equality,
  or the `FAngelscriptType` virtual interface.
- Do not change AngelScript enum bytecode/storage ABI. Unsupported wide native
  enums fail closed; supporting them is a separate feature.
- Do not use type-info user-data slot `0` for owned container operations.
- Keep ambient APIs as checked-current-engine compatibility wrappers; all new
  logic lives in database-explicit implementations.
- New C++ test files start with `Angelscript` and use the existing CQTest and
  `FAngelscriptTestEngine` helpers.
- Build and tests run only through `Tools\RunBuild.ps1`,
  `Tools\RunTests.ps1`, or `Tools\RunTestSuite.ps1`.

## File Map

**Runtime core and reflected-signature routing:**

- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h`:
  deterministic constructor and database/script-engine-explicit overloads.
- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp`:
  transactional finder resolution and explicit conversion implementations.
- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h`:
  stop discarding explicit databases and route property/name lookups explicitly.

**Enum boundary:**

- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp`:
  byte-representability validation, byte-only property finder, and diagnostics.
- Inspect but do not widen
  `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum_Type.cpp`:
  retain its one-byte operations and remove no behavior required by byte-safe
  enums.

**Container operation ownership:**

- Create
  `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/ContainerOperationsUserData.h`:
  internal family slots plus development-automation cleanup observations.
- Create
  `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/ContainerOperationsUserData.cpp`:
  unique slot storage and thread-safe test observations.
- Modify `Bind_TArray.cpp`, `Bind_TMap.cpp`, `Bind_TSet.cpp`, and
  `Bind_TOptional.cpp` in the same directory: use dedicated slots, register
  typed cleanup callbacks, and record allocation/release observations in
  development automation builds.

**Tests:**

- Modify `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeUsageTests.cpp`.
- Modify `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeDatabaseTests.cpp`.
- Modify `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptDirectBindFluentTests.cpp`.
- Modify `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptUhtCoverageTestTypes.h` and `.cpp`.
- Create `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEnumTypeSafetyTests.cpp`.
- Create `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTemplateTypeUserDataLifetimeTests.cpp`.

**Documentation and record:**

- Modify `Documents/Knowledges/ZH/Type_Core.md`.
- Keep this change's `proposal.md`, `design.md`, delta specs, and `tasks.md` in
  sync with implementation discoveries.

---

## 1. Deterministic Type Usage And Transactional Finders

<!-- TDD -->

**Interfaces produced:**

```cpp
explicit FAngelscriptTypeUsage(TSharedPtr<FAngelscriptType> InType);
FAngelscriptTypeUsage FAngelscriptTypeUsage::FromProperty(
    FAngelscriptTypeDatabase& Database,
    FProperty* Property);
```

- [ ] 1.1 In `AngelscriptTypeUsageTests.cpp`, add
  `AdapterConstructorInitializesPayloadAndComparesDeterministically`: placement-
  construct two usages from the same minimal test adapter into aligned byte
  buffers prefilled with different nonzero patterns, assert
  `ScriptClass == nullptr`, empty subtypes, false qualifiers, deterministic
  `operator==`, and deterministic `EqualsUnqualified`; explicitly destruct both
  placement objects. Separately populate an ordinary usage, call `Reset()`, and
  assert the full empty invariant again. Prefilling makes the regression fail
  deterministically instead of depending on the test stack happening to be zero.

  The core assertions must include:

  ```cpp
  alignas(FAngelscriptTypeUsage) uint8 StorageA[sizeof(FAngelscriptTypeUsage)];
  alignas(FAngelscriptTypeUsage) uint8 StorageB[sizeof(FAngelscriptTypeUsage)];
  FMemory::Memset(StorageA, 0xA5, sizeof(StorageA));
  FMemory::Memset(StorageB, 0x5A, sizeof(StorageB));
  auto* UsageA = new (StorageA) FAngelscriptTypeUsage(ProbeType);
  auto* UsageB = new (StorageB) FAngelscriptTypeUsage(ProbeType);
  ASSERT_THAT(IsNull(UsageA->ScriptClass, TEXT("Adapter construction must zero the payload")));
  ASSERT_THAT(IsTrue(*UsageA == *UsageB, TEXT("Fresh usages of one adapter must compare deterministically")));
  UsageB->~FAngelscriptTypeUsage();
  UsageA->~FAngelscriptTypeUsage();
  ```

- [ ] 1.2 Run the TypeUsage owner before the repair:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeUsage" -Label type-usage-red -TimeoutMs 600000
  ```

  Expected: the new constructor test fails because the nonzero prefill remains
  in the payload union after the adapter constructor returns.

- [ ] 1.3 In `AngelscriptTypeDatabaseTests.cpp`, add
  `FailedFinderMutationsNeverEscape`: register a first finder that writes a
  marker adapter, subtype, qualifier, and non-null payload then returns `false`;
  register a second finder that asserts it receives a fresh usage and returns a
  different valid adapter; assert only the second result plus property-derived
  qualifiers are returned.

- [ ] 1.4 In the same file, add `SuccessfulFinderRequiresValidType`: make a
  finder return `true` with no type, then prove the next valid finder or ordinary
  `MatchesProperty` fallback supplies the result. Before invoking resolution,
  register exactly one expected diagnostic with:

  ```cpp
  TestRunner->AddExpectedError(
      TEXT("A successful AngelScript type finder must return a valid type"),
      EAutomationExpectedErrorFlags::Contains,
      1);
  ```

- [ ] 1.5 Run the TypeDatabase owner before the finder repair:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeDatabase" -Label type-database-red -TimeoutMs 600000
  ```

  Expected: `FailedFinderMutationsNeverEscape` resolves the rejected marker or
  exposes its payload; `SuccessfulFinderRequiresValidType` demonstrates the
  missing finder contract diagnostic.

- [ ] 1.6 Update the adapter constructor in `AngelscriptType.h` to move the
  adapter and initialize `ScriptClass(nullptr)`; keep the default constructor and
  `Reset()` invariant identical. Do not add, remove, reorder, or replace any
  `FAngelscriptTypeUsage` field.

  Minimal production change:

  ```cpp
  explicit FAngelscriptTypeUsage(TSharedPtr<FAngelscriptType> InType)
      : Type(MoveTemp(InType))
      , ScriptClass(nullptr)
  {
  }
  ```

- [ ] 1.7 Rewrite the finder loop in `AngelscriptType.cpp` to allocate one fresh
  candidate per finder, commit only `true + valid Type`, ensure on `true +
  invalid Type`, and run the existing fallback only when no candidate was
  committed. Apply reflected const/reference flags after candidate/fallback
  resolution.

- [ ] 1.8 Re-run both focused owners together:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeUsage+Angelscript.TestModule.Engine.TypeDatabase" -Label type-core-green -TimeoutMs 600000
  ```

  Expected: zero failures, skips, timeouts, crashes, and unexpected ensures.

- [ ] 1.9 Commit the plugin repair and regressions inside
  `Plugins/Angelscript`:

  ```powershell
  git add Source/AngelscriptRuntime/Core/AngelscriptType.h Source/AngelscriptRuntime/Core/AngelscriptType.cpp Source/AngelscriptTest/Core/AngelscriptTypeUsageTests.cpp Source/AngelscriptTest/Core/AngelscriptTypeDatabaseTests.cpp
  git commit -m "[Angelscript] Fix: harden runtime type usage resolution"
  ```

## 2. Database-Explicit Type Conversion And Function Signatures

<!-- TDD -->

**Interfaces produced:**

```cpp
static FAngelscriptTypeUsage FromTypeId(
    FAngelscriptTypeDatabase& Database,
    asIScriptEngine* ScriptEngine,
    int32 TypeId);
static FAngelscriptTypeUsage FromDataType(
    FAngelscriptTypeDatabase& Database,
    asIScriptEngine* ScriptEngine,
    const asCDataType& DataType);
static FAngelscriptTypeUsage FromProperty(
    FAngelscriptTypeDatabase& Database,
    asITypeInfo* ScriptType,
    int32 PropertyIndex);
static FAngelscriptTypeUsage FromReturn(
    FAngelscriptTypeDatabase& Database,
    asIScriptFunction* Function);
static FAngelscriptTypeUsage FromParam(
    FAngelscriptTypeDatabase& Database,
    asIScriptFunction* Function,
    int32 ParamIndex);
```

- [ ] 2.1 Strengthen the existing
  `FunctionSignatureUsesExplicitTypeDatabaseOutsideTargetScope` test in
  `AngelscriptDirectBindFluentTests.cpp`: retain the database-A/ambient-engine-B
  case, add a case with
  `FScopedAngelscriptEngineResolutionSuppressionForTesting`, and assert both the
  constructor and `InitFromDB` select database A's marker for every parameter
  and return slot.

- [ ] 2.2 Add
  `FunctionSignatureUsesExplicitTypeDatabaseOnWorkerThread` to the same owner.
  Construct the signature through `Async(EAsyncExecution::ThreadPool, ...)`,
  create `FScopedAngelscriptEngineResolutionSuppressionForTesting` inside the
  worker lambda, return only copied declarations/adapter identity booleans, and
  assert the result on the game thread. Do not mutate reflection or either
  database inside the worker.

- [ ] 2.3 In `AngelscriptTypeUsageTests.cpp`, add
  `ExplicitTypeIdAndDataTypeResolutionIgnoreAmbientEngine`: create engines A and
  B, give their databases distinguishable marker mappings, resolve a primitive
  and one template subtype with database A plus engine A while engine B is
  ambient, and assert all recursive usages come from database A.

- [ ] 2.4 Run the existing/expanded explicit-signature owner before production
  edits:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture.Fluent" -Label explicit-type-routing-red -TimeoutMs 600000
  ```

  Expected: the existing wrong-ambient case or new suppressed/worker case fails
  because `Helper_FunctionSignature.h` discards `TypeDatabase`.

- [ ] 2.5 Add the database/script-engine-explicit overload declarations to
  `AngelscriptType.h`; implement them in `AngelscriptType.cpp` so primitive name
  lookup, script type-info lookup, script-object/enum selection, and every
  recursive template subtype use the supplied database and script engine.

- [ ] 2.6 Reduce every ambient compatibility overload to a checked-current-
  engine delegator. For example, the ambient TypeId path must have this shape:

  ```cpp
  FAngelscriptTypeUsage FAngelscriptTypeUsage::FromTypeId(int32 TypeId)
  {
      FAngelscriptEngine& Engine = FAngelscriptEngine::Get();
      return FromTypeId(*Engine.GetTypeDatabase(), Engine.GetScriptEngine(), TypeId);
  }
  ```

  Do not retain a second switch, template recursion loop, or name lookup in the
  ambient overload.

- [ ] 2.7 Update explicit `InitFromFunction` and `InitFromDB` in
  `Helper_FunctionSignature.h`: remove `(void)TypeDatabase`, call
  `FromProperty(TypeDatabase, Property)`, and route mixin/name resolution through
  `GetByAngelscriptTypeName(TypeDatabase, Name)`. Leave the overloads without a
  database as compatibility paths.

- [ ] 2.8 Search the explicit implementation bodies for accidental ambient
  access:

  ```powershell
  rg -n "\(void\)TypeDatabase|FAngelscriptEngine::Get\(\)|GetTypeDatabase\(\)|FromProperty\(Property\)|GetByAngelscriptTypeName\([^,]+\)" Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h
  ```

  Expected: no discarded database parameter; ambient calls appear only in the
  named compatibility wrappers, not explicit overload bodies.

- [ ] 2.9 Run explicit routing and engine isolation owners:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture.Fluent+Angelscript.TestModule.Engine.Isolation+Angelscript.TestModule.Engine.TypeUsage" -Label explicit-type-routing-green -TimeoutMs 600000
  ```

  Expected: zero failures, including the no-ambient and worker-thread cases.

- [ ] 2.10 Commit the plugin routing batch:

  ```powershell
  git add Source/AngelscriptRuntime/Core/AngelscriptType.h Source/AngelscriptRuntime/Core/AngelscriptType.cpp Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h Source/AngelscriptTest/Core/AngelscriptDirectBindFluentTests.cpp Source/AngelscriptTest/Core/AngelscriptTypeUsageTests.cpp
  git commit -m "[Angelscript] Fix: honor explicit runtime type databases"
  ```

## 3. Byte-Enum Representation Boundary

<!-- TDD -->

**Fixture types produced in `AngelscriptUhtCoverageTestTypes.h`:**

```cpp
UENUM()
enum class EAngelscriptByteEnumProbe : uint8
{
    Zero = 0,
    Maximum = 255,
};

UENUM()
enum class EAngelscriptWideStorageEnumProbe : uint16
{
    Zero = 0,
    One = 1,
};

UENUM()
enum class EAngelscriptOutOfRangeEnumProbe : uint16
{
    Zero = 0,
    BeyondByte = 512,
};
```

The owning UCLASS contains one non-Blueprint `UPROPERTY()` for each enum so UHT
emits real `FEnumProperty` instances and underlying numeric properties.

- [ ] 3.1 Add the three UENUM probes and their property-owning UObject to
  `AngelscriptUhtCoverageTestTypes.h/.cpp`, following the existing export and
  `GENERATED_BODY()` conventions in those files.

- [ ] 3.2 Create `AngelscriptEnumTypeSafetyTests.cpp` with automation prefix
  `Angelscript.TestModule.Engine.TypeCorrectness.Enum`. Add
  `ByteBackedEnumResolvesWithOneByteOperations`: resolve the byte property
  through the engine database and assert valid usage, `GetValueSize() == 1`,
  successful copy/compare/hash, and the unchanged enum declaration.

- [ ] 3.3 Add `WideUnderlyingPropertyFailsClosed`: resolve the uint16 property,
  assert invalid usage, then install a later marker finder and prove the rejected
  enum candidate does not contaminate that marker result.

- [ ] 3.4 Add `OutOfRangeEnumIsNotPublishedAsByteBacked`: assert
  `GetByData(Database, StaticEnum<EAngelscriptOutOfRangeEnumProbe>())` is null
  after binding and capture the stable unsupported-enum diagnostic through the
  existing expected-error mechanism.

- [ ] 3.5 Run the new owner before enum production changes:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeCorrectness.Enum" -Label enum-type-safety-red -TimeoutMs 600000
  ```

  Expected: the wide property resolves through the current enum finder and/or
  the out-of-range enum is published despite the byte-only adapter.

- [ ] 3.6 In `Bind_UEnum.cpp`, add one internal byte-representability predicate
  that iterates published enum values and accepts only `0..255`; use it before
  native enum registration and emit one stable diagnostic containing the full
  UEnum path and offending value.

- [ ] 3.7 Make the enum property finder accept only `FByteProperty` and
  `FEnumProperty` with `FByteProperty` underlying storage. Remove the
  `FIntProperty -> TypeIndex = 4` success branch. On unsupported storage, return
  `false` without leaving any state in the caller-visible usage; transactionality
  from Task 1 provides the final containment.

- [ ] 3.8 Audit `Bind_UEnum_Type.cpp` and document in code that its one-byte
  size/copy/call/hash/debug behavior is protected by the finder/registration
  predicate. Do not add `TypeIndex` branches that would disagree with VM enum
  storage.

- [ ] 3.9 Run the new owner plus existing enum coverage and binding tests:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeCorrectness.Enum+Angelscript.TestModule.Coverage.UEnum+Angelscript.TestModule.Bindings.Enum" -Label enum-type-safety-green -TimeoutMs 600000
  ```

  Expected: byte-backed coverage remains green; wide storage and out-of-range
  values fail closed with the expected diagnostic and no truncation.

- [ ] 3.10 Commit the plugin enum batch:

  ```powershell
  git add Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp Source/AngelscriptRuntime/Binds/Bind_UEnum_Type.cpp Source/AngelscriptTest/Core/AngelscriptUhtCoverageTestTypes.h Source/AngelscriptTest/Core/AngelscriptUhtCoverageTestTypes.cpp Source/AngelscriptTest/Core/AngelscriptEnumTypeSafetyTests.cpp
  git commit -m "[Angelscript] Fix: reject unsafe native enum representations"
  ```

## 4. Container Template Operations Ownership

<!-- TDD -->

**Internal helper produced:**

```cpp
enum class EAngelscriptContainerOperationsFamily : uint8
{
    Array,
    Map,
    Set,
    Optional,
};

ANGELSCRIPTRUNTIME_API asPWORD GetAngelscriptContainerOperationsUserDataSlot(
    EAngelscriptContainerOperationsFamily Family);
```

Under `WITH_DEV_AUTOMATION_TESTS`, the helper also exposes reset/snapshot
functions for per-family allocation and release counts. In non-automation builds
the observation calls compile to no-ops and no test state is exported.

- [ ] 4.1 Create `ContainerOperationsUserData.h/.cpp` with four private static
  tag bytes, return each tag address as a unique nonzero `asPWORD`, and add
  thread-safe per-family allocation/release observations guarded by
  `WITH_DEV_AUTOMATION_TESTS`.

- [ ] 4.2 Create `AngelscriptTemplateTypeUserDataLifetimeTests.cpp` with prefix
  `Angelscript.TestModule.Engine.TypeCorrectness.TemplateOperations`. Add one
  table-driven test that creates an isolated engine, resets observations,
  instantiates valid `TArray<int>`, `TMap<int,int>`, `TSet<int>`, and
  `TOptional<int>` type infos, repeats each validation to prove cache reuse,
  destroys the engine, and expects for every family:

  ```text
  allocations = 1
  releases    = 1
  ```

- [ ] 4.3 Add a validation-failure case using a deliberately unsupported probe
  subtype for each reachable container callback; assert the callback rejects
  the type, then engine teardown balances every allocation with one release.
  Where a family rejects before allocation by design, assert `0/0` rather than
  forcing a new allocation.

- [ ] 4.4 Add `DefaultTypeInfoUserDataRemainsBorrowed`: attach a borrowed sentinel
  to slot `0` on a test type, attach an owned probe to a container-family slot,
  destroy the type/module, and assert only the registered family cleanup count
  changes; the test itself retains and owns the slot-0 sentinel.

- [ ] 4.5 Run the new lifetime owner before production cleanup registration:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeCorrectness.TemplateOperations" -Label template-operations-red -TimeoutMs 600000
  ```

  Expected: allocations are observed without matching type-info releases, or
  the new dedicated slots/callbacks are absent.

- [ ] 4.6 In each of `Bind_TArray.cpp`, `Bind_TMap.cpp`, `Bind_TSet.cpp`, and
  `Bind_TOptional.cpp`, register a cleanup callback on the target script engine
  during type infrastructure setup, before its template callback can allocate
  operations.

- [ ] 4.7 Change every operations `GetUserData()`/`SetUserData()` call in those
  four files to pass its dedicated nonzero family slot. The cleanup callback must
  clear the same slot with `SetUserData(nullptr, Slot)`, cast to the exact
  operations type, delete once, and record one release observation.

  Required callback shape per family:

  ```cpp
  void CleanupArrayOperations(asITypeInfo* TypeInfo)
  {
      const asPWORD Slot = GetAngelscriptContainerOperationsUserDataSlot(
          EAngelscriptContainerOperationsFamily::Array);
      FArrayOperations* Operations = static_cast<FArrayOperations*>(
          TypeInfo->SetUserData(nullptr, Slot));
      if (Operations != nullptr)
      {
          delete Operations;
          RecordAngelscriptContainerOperationsRelease(
              EAngelscriptContainerOperationsFamily::Array);
      }
  }
  ```

  Record a release only when the cleared pointer is non-null.

- [ ] 4.8 Record one allocation immediately after each successful `new
  F*Operations`; keep allocation ownership with type info even when later
  validation fails. Do not introduce an early manual delete that would leave a
  dangling cached pointer.

- [ ] 4.9 Search the four binding files for accidental default-slot operations
  storage:

  ```powershell
  rg -n "GetUserData\(\)|SetUserData\([^,\)]*\)" Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp
  ```

  Expected: no unkeyed operation-cache access remains in these four files.

- [ ] 4.10 Run lifetime and existing container owners:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeCorrectness.TemplateOperations+Angelscript.TestModule.Bindings.Container" -Label template-operations-green -TimeoutMs 600000
  ```

  Expected: allocations/releases balance for valid and allocated-invalid cases;
  existing array/map/set/optional behavior remains green.

- [ ] 4.11 Commit the plugin cleanup batch:

  ```powershell
  git add Source/AngelscriptRuntime/Binds/ContainerOperationsUserData.h Source/AngelscriptRuntime/Binds/ContainerOperationsUserData.cpp Source/AngelscriptRuntime/Binds/Bind_TArray.cpp Source/AngelscriptRuntime/Binds/Bind_TMap.cpp Source/AngelscriptRuntime/Binds/Bind_TSet.cpp Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp Source/AngelscriptTest/Core/AngelscriptTemplateTypeUserDataLifetimeTests.cpp
  git commit -m "[Angelscript] Fix: release container template type operations"
  ```

## 5. Documentation And Static Contract Audit

<!-- Non-TDD -->

- [ ] 5.1 Update `Documents/Knowledges/ZH/Type_Core.md` to remove every
  `LegacyDatabase` fallback example and state that ambient compatibility APIs
  require a checked current engine while explicit overloads never use ambient
  state.

- [ ] 5.2 Add a concise property-finder contract to the same document: failed
  finders cannot publish mutations; `true` requires a valid adapter; reflected
  qualifiers are applied after type resolution.

- [ ] 5.3 Document the current one-byte enum boundary and fail-closed treatment
  of wide native enum properties without presenting it as future wide-enum
  support.

- [ ] 5.4 Run stale-contract searches:

  ```powershell
  rg -n "LegacyDatabase|static FAngelscriptTypeDatabase" Documents/Knowledges/ZH/Type_Core.md Plugins/Angelscript/Source/AngelscriptRuntime/Core Plugins/Angelscript/Source/AngelscriptTest/Core
  ```

  Expected: the knowledge document contains no legacy fallback claim; the test
  that asserts legacy storage is absent may retain the searched token as test
  evidence.

- [ ] 5.5 Review the OpenSpec against the implemented enum policy, explicit
  overload signatures, cleanup slot helper, and actual test names; update the
  record if implementation evidence required a narrower compatible choice.

## 6. Build And Verification

<!-- Non-TDD -->

- [ ] 6.1 From the parent repository, confirm the intended plugin commits and
  parent-only OpenSpec/docs changes before building:

  ```powershell
  git -C Plugins/Angelscript status --short
  git -C Plugins/Angelscript log -4 --oneline
  git status --short
  git diff --submodule=short --stat
  ```

  Expected: no unrelated plugin files are staged or modified; the parent shows
  the intended plugin gitlink, this OpenSpec, and `Type_Core.md` only.

- [ ] 6.2 Build the editor target through the repository wrapper:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-type-correctness -TimeoutMs 1800000 -NoXGE
  ```

  Expected: exit code 0 with `AngelscriptRuntime` and `AngelscriptTest` compiled.

- [ ] 6.3 Run all new/focused type-correctness owners in one isolated report:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TypeUsage+Angelscript.TestModule.Engine.TypeDatabase+Angelscript.TestModule.Engine.BindingArchitecture.Fluent+Angelscript.TestModule.Engine.TypeCorrectness" -Label angelscript-type-correctness-focused -TimeoutMs 900000
  ```

  Expected: zero failures, skips, timeouts, crashes, and unexpected ensures.

- [ ] 6.4 Run adjacent enum/container/isolation regression owners:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.Isolation+Angelscript.TestModule.Coverage.UEnum+Angelscript.TestModule.Bindings.Enum+Angelscript.TestModule.Bindings.Container" -Label angelscript-type-correctness-adjacent -TimeoutMs 900000
  ```

  Expected: zero failures, skips, timeouts, crashes, and unexpected ensures.

- [ ] 6.5 Run the repository Smoke suite:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix angelscript-type-correctness-smoke -TimeoutMs 900000
  ```

  Expected: every configured Smoke prefix passes with no timeout or crash.

- [ ] 6.6 Validate the OpenSpec record and inspect its final status:

  ```powershell
  openspec validate fix-as-angelscript-type-correctness --strict
  openspec status --change "fix-as-angelscript-type-correctness" --json
  ```

  Expected: validation succeeds and every required artifact is present. Mark
  checklist items complete only for work actually performed.

- [ ] 6.7 Commit the parent repository after the plugin commits are final:

  ```powershell
  git add Plugins/Angelscript Documents/Knowledges/ZH/Type_Core.md openspec/changes/fix-as-angelscript-type-correctness
  git commit -m "[OpenSpec] Fix: record runtime type correctness repair"
  ```

  The parent commit records the final plugin gitlink and must not squash or
  rewrite unrelated user commits.

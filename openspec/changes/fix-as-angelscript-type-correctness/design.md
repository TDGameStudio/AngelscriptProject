## Context

`FAngelscriptType` is the plugin's runtime interop adapter: it connects an
AngelScript type to UE properties, storage operations, calls, GC, debugger
formatting, and StaticJIT metadata. `FAngelscriptTypeUsage` adds qualifiers,
subtypes, and one adapter-specific payload, while `FAngelscriptTypeDatabase`
owns the per-`FAngelscriptEngine` registries and property finders.

The per-engine database direction is already correct and the old process-wide
legacy database is gone. The repair must preserve that architecture and the
current public struct layout while closing five local correctness gaps:

1. The `FAngelscriptTypeUsage(TSharedPtr<FAngelscriptType>)` constructor does
   not initialize its anonymous payload union, although equality reads the
   `ScriptClass` member.
2. `FromProperty(Database, Property)` reuses one output object for every
   finder, so a finder can mutate it and return `false`; a later validity check
   can then accept the rejected partial result.
3. The explicit-database overloads in `FAngelscriptFunctionSignature` discard
   their database parameter and call ambient `FromProperty`/name lookups. This
   is incorrect under a different engine scope and on parallel preparation
   workers.
4. The enum finder records one- or four-byte storage, but `FEnumType` performs
   copy, size, call, hash, and debugger operations as `uint8`. This change does
   not widen the fork's one-byte script-enum ABI; it prevents unsupported
   native representations from entering the byte adapter.
5. Container template callbacks allocate operation objects and store them in
   the default type-info user-data slot without a cleanup callback. AngelScript
   clears the pointer during type-info destruction but cannot infer the C++
   deleter.

The existing `FunctionSignatureUsesExplicitTypeDatabaseOutsideTargetScope`
test already states part of the intended explicit-routing contract. This change
keeps and strengthens that regression rather than inventing a second competing
test surface.

## Goals / Non-Goals

**Goals:**

- Remove indeterminate reads from ordinary `FAngelscriptTypeUsage`
  construction and comparison.
- Make property finders transactional and fail closed.
- Make explicit database APIs independent of thread-local/ambient engine state.
- Ensure a valid enum usage is always compatible with the current one-byte
  adapter operations.
- Release every owned array/map/set/optional operations object exactly once at
  type-info teardown, including objects retained after validation failure.
- Add focused regressions whose automation owners can be run independently.
- Correct the Chinese knowledge document's obsolete legacy-database examples.

**Non-Goals:**

- Replacing the anonymous payload union with a tagged variant or changing
  `FAngelscriptTypeUsage` layout.
- Splitting the `FAngelscriptType` virtual interface into semantic, reflection,
  ABI, debugger, or runtime-operation components.
- Defining the Typed Semantic IR or making `FAngelscriptTypeUsage` its canonical
  type identity.
- Redesigning alias/canonical-name registration; that remains owned by
  `improve-as-library-namespace-canonicalization`.
- Redesigning script-type equivalence across namespace, module, or reload
  generations. That requires a stable nominal identity decision and will be a
  later type-system refactor.
- Widening AngelScript enum storage, changing bytecode, or adding support for
  wide native enum ABI. Wide-enum support requires a separate compatibility and
  persistence design.
- Freezing the whole type database or adding engine-generation handles.

## Decisions

### 1. Apply narrow repairs before structural type-system work

The change preserves the existing adapter/database model and changes only
contracts that can be tested without choosing the future semantic type model.
This gives the later Typed Semantic IR a reliable runtime lowering dependency
without coupling the two changes.

Alternative considered: fold these repairs into `feature-as-typed-semantic-aot`.
Rejected because the bugs affect ordinary reflection binding, engine isolation,
and shutdown even when Semantic AOT is disabled.

Alternative considered: replace `FAngelscriptTypeUsage` immediately. Rejected
for this change because it would mix ABI/layout migration and broad call-site
conversion with local correctness fixes.

### 2. Initialize the existing payload representation without changing layout

The default constructor, the adapter constructor, and `Reset()` all establish
the same empty invariant:

```cpp
ScriptClass == nullptr
bIsReference == false
bIsConst == false
SubTypes.IsEmpty()
```

The adapter constructor becomes equivalent to:

```cpp
explicit FAngelscriptTypeUsage(TSharedPtr<FAngelscriptType> InType)
    : Type(MoveTemp(InType))
    , ScriptClass(nullptr)
{
}
```

Initializing `ScriptClass` zeroes the shared union storage. The union remains in
place, so this repair changes neither `sizeof(FAngelscriptTypeUsage)` nor its
field offsets. Copy and move retain the source payload as today.

### 3. Treat each property finder result as a transaction

`FromProperty(Database, Property)` gives each finder a fresh candidate. A
candidate is committed only when the finder returns `true` and supplies a valid
`Type`:

```cpp
for (const FAngelscriptTypeFinder& Finder : Database.TypeFinders)
{
    FAngelscriptTypeUsage Candidate;
    if (!Finder(Property, Candidate))
        continue;

    if (!ensureMsgf(Candidate.Type.IsValid(),
        TEXT("A successful AngelScript type finder must return a valid type")))
        continue;

    Usage = MoveTemp(Candidate);
    bResolvedByFinder = true;
    break;
}
```

If no candidate is committed, the existing non-finder property matcher runs.
Property-level const/reference flags are applied after resolution so both finder
and fallback results receive identical qualifiers. Finder ordering remains
unchanged.

Alternative considered: reset the shared `Usage` object after every failed
finder. Rejected because it relies on every future payload field being included
in `Reset()` and still exposes one finder's mutations to the next finder during
the call.

### 4. Make database-explicit conversion a closed call chain

Core conversion helpers gain or retain explicit overloads that take every
piece of context needed for resolution:

```cpp
static FAngelscriptTypeUsage FromProperty(
    FAngelscriptTypeDatabase& Database,
    FProperty* Property);
static FAngelscriptTypeUsage FromProperty(
    FAngelscriptTypeDatabase& Database,
    asITypeInfo* ScriptType,
    int32 PropertyIndex);
static FAngelscriptTypeUsage FromTypeId(
    FAngelscriptTypeDatabase& Database,
    asIScriptEngine* ScriptEngine,
    int32 TypeId);
static FAngelscriptTypeUsage FromDataType(
    FAngelscriptTypeDatabase& Database,
    asIScriptEngine* ScriptEngine,
    const asCDataType& DataType);
static FAngelscriptTypeUsage FromReturn(
    FAngelscriptTypeDatabase& Database,
    asIScriptFunction* Function);
static FAngelscriptTypeUsage FromParam(
    FAngelscriptTypeDatabase& Database,
    asIScriptFunction* Function,
    int32 ParamIndex);
```

Explicit overloads use only the passed database and the passed or derivable
script engine. Recursive template-subtype resolution calls the same explicit
overload. They do not call `FAngelscriptEngine::Get()`, `GetTypeDatabase()`, or
an ambient name lookup.

Existing overloads without a database remain compatibility entry points. They
resolve the checked current engine once and delegate to the explicit overload;
they do not contain a second implementation.

`FAngelscriptFunctionSignature::InitFromFunction(TypeDatabase, ...)` and
`InitFromDB(TypeDatabase, ...)` call
`FAngelscriptTypeUsage::FromProperty(TypeDatabase, Property)` and perform mixin
name lookup through `GetByAngelscriptTypeName(TypeDatabase, Name)`. Their
ambient counterparts remain for callers that intentionally use the current
engine.

The explicit path is tested in three contexts: no ambient engine, a different
ambient engine, and a worker thread with no inherited thread-local scope.

### 5. Fail closed at the byte-enum representation boundary

This change formalizes the current implementation contract: script-visible enum
values handled by `FEnumType` use one-byte storage. The enum property finder may
therefore accept only:

- `FByteProperty` with a valid `UEnum`; or
- `FEnumProperty` whose underlying numeric property is `FByteProperty`.

It must reject `FIntProperty` enum associations and `FEnumProperty` instances
backed by `int16`, `uint16`, `int32`, `uint32`, `int64`, or `uint64`. Rejection
returns an invalid usage after all finders/fallbacks and emits a deterministic
diagnostic containing the enum path and underlying property class.

Native `UEnum` registration also checks that every exposed enumerator is in the
representable `0..255` range before publishing a byte-backed script enum. An
incompatible enum is skipped with a deterministic diagnostic; it is never
published with values that would truncate in VM storage.

`FEnumType` remains byte-sized. The unused four-byte `TypeIndex` acceptance path
is removed rather than pretending that the existing adapter supports it.
Byte-backed native enums and generated script enums keep their current behavior.

Alternative considered: branch every `FEnumType` operation on `TypeIndex`.
Rejected because the VM registration still gives script enums one-byte storage;
widening only UE copy helpers would leave VM calls, constants, bytecode, and
StaticJIT disagreeing about the ABI.

### 6. Give owned template operations dedicated cleanup slots

Each container family defines a unique nonzero `asPWORD` slot backed by the
address of a private static tag. Its type-infrastructure bind registers one
cleanup callback on the target `asIScriptEngine` before template instances are
validated. Validation reads/writes only that family slot:

```cpp
namespace
{
    uint8 GArrayOperationsUserDataTag;

    asPWORD GetArrayOperationsUserDataSlot()
    {
        return reinterpret_cast<asPWORD>(&GArrayOperationsUserDataTag);
    }

    void CleanupArrayOperations(asITypeInfo* TypeInfo)
    {
        delete static_cast<FArrayOperations*>(
            TypeInfo->SetUserData(nullptr, GetArrayOperationsUserDataSlot()));
    }
}
```

The same pattern is used with the correct concrete type for map, set, and
optional. Repeated validation returns the existing object. Successful and
failed validation objects are both owned by type info and are deleted exactly
once. Default slot `0` remains untouched because it carries borrowed
`UClass`/`UStruct`/`UEnum` data elsewhere.

Alternative considered: install one default-slot cleanup callback. Rejected
because the default slot mixes owned operations with borrowed UObject pointers
that must not be deleted.

### 7. Tests stay with their existing ownership layers

- Constructor and qualifier invariants extend
  `Core/AngelscriptTypeUsageTests.cpp`.
- Finder transactionality extends
  `Core/AngelscriptTypeDatabaseTests.cpp`.
- Explicit database routing strengthens
  `Core/AngelscriptDirectBindFluentTests.cpp`.
- Native enum representation probes use UHT fixtures in
  `Core/AngelscriptUhtCoverageTestTypes.h/.cpp` and a focused
  `Core/AngelscriptEnumTypeSafetyTests.cpp` owner.
- Container type-info ownership uses a focused
  `Core/AngelscriptTemplateTypeUserDataLifetimeTests.cpp` owner and real engine
  teardown; it does not rely on process-memory thresholds.

All tests use CQTest and the existing `FAngelscriptTestEngine`/
`FScopedAngelscriptModule` support. No hand-written editor process, world, or
custom build entry point is introduced.

## Risks / Trade-offs

- **[Previously visible wide enum disappears]** A script may have depended on a
  native enum that the byte adapter could not faithfully represent. → Emit a
  stable diagnostic with the exact enum/property and preserve all byte-safe
  enums; treat wide support as a separate ABI feature rather than truncating.
- **[Explicit overload drift]** A new helper could accidentally call an ambient
  overload. → Keep ambient overloads as one-line delegators and retain no-scope,
  wrong-scope, and worker-thread regressions.
- **[Cleanup slot collision]** Reusing an integer slot could invoke the wrong
  deleter. → Use addresses of distinct private static tags and test all four
  families in one engine lifecycle.
- **[Callback registered after instantiation]** An early template instance could
  receive owned data before its cleanup service exists. → Register the callback
  in the same type-infrastructure bind before installing/using the template
  callback.
- **[Finder behavior tightening]** A finder that returns `true` without a valid
  type will no longer stop resolution. → Emit an ensure and continue to the next
  finder/fallback; add a regression for this invalid contract.
- **[Public struct ABI concern]** Constructor semantics change while layout must
  remain stable. → Limit the production diff to constructor initialization and
  do not add, reorder, or replace fields.

## Migration Plan

1. Land failing constructor, finder, explicit-routing, enum, and cleanup
   regressions without changing production behavior.
2. Repair TypeUsage initialization and transactional finder commit, then run the
   TypeUsage/TypeDatabase owners.
3. Complete database-explicit overloads and function-signature routing, then run
   BindingArchitecture Fluent and Engine Isolation owners.
4. Enforce the byte-enum boundary and run the focused enum owner plus existing
   Coverage UEnum tests.
5. Move container operations to owned slots, register deleters, and run the
   lifetime owner plus existing container binding tests.
6. Update `Type_Core.md`, build through `Tools/RunBuild.ps1`, and run the focused
   combined prefixes followed by the Smoke suite.

Rollback is per repair batch. The cleanup-slot batch can be reverted without
changing serialized data; the explicit overloads and enum rejection add no
persisted format. A rollback must retain the tests that demonstrate the unsafe
behavior and record why the corresponding contract is temporarily waived.

## Open Questions

None. Wide enum ABI, nominal type identity, alias policy, tagged payloads, and
Typed Semantic IR ownership are intentionally deferred rather than left as
implementation-time decisions in this change.

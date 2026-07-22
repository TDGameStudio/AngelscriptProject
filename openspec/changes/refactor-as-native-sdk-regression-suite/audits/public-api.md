# Core Public API

This test inventory expands the 12-interface inventory into method families. It covers the core API declared by the fork's `AngelscriptRuntime/Core/angelscript.h`, not any `sdk/add_on` package. A family may use one scenario for several tightly coupled getters/setters, but every listed family must have an explicit final disposition and representative method name before closure.

Disposition terms:

- `Execute`: invoke real script/native behavior and assert the result/state.
- `Contract`: invoke the real implementation and assert metadata/lifecycle/error contracts.
- `Host double`: a minimal local implementation is driven through the real engine API.
- `Fork N/A`: surface is intentionally empty or structurally unavailable in this fork; document it without claiming execution.

## Global core functions

| API family | Required calls | Disposition / owner |
| --- | --- | --- |
| Library identity | `asGetLibraryVersion`, `asGetLibraryOptions` | Contract / Engine.LibraryIdentity |
| Engine factory/version guard | `asCreateScriptEngine` with current and invalid version | Contract / Engine.Lifecycle |
| Active execution lookup | `asGetActiveContext`, `asGetActiveFunction`, `asGetUsableContext` inside/outside execution | Execute / Runtime.ContextStack |
| Multithread lifecycle | `asGetThreadManager`, worker `asThreadCleanup`; prepare/unprepare classified separately | Non-mutating contract / Engine.Threading; process-global mutation prohibited by `global-state.md` |
| Global locks/atomics | exclusive/shared acquire/release, `asAtomicInc`, `asAtomicDec` | Execute / Engine.Atomic + Threading |
| Memory allocation | `asAllocMem`, `asFreeMem` | Execute / Engine.Memory |
| Global memory callbacks | `asSetGlobalMemoryFunctions`, `asResetGlobalMemoryFunctions` | Fork N/A: header declarations have no fork definitions because FMemory is structural; source-audit only |
| Fork object hooks | `asSetAllocScriptObjectFunction`, `asSetResolveObjectPtrFunction` | Process-global integration ownership; no in-process mutation because production hooks have no getter/restore surface |
| Shared bool factory | `asCreateLockableSharedBool` | Execute / Engine.LockableSharedBool |

## `asIScriptEngine`

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Reference/lifetime | `AddRef`, `Release`, `ShutDownAndRelease` | Contract / Engine.Lifecycle |
| Engine properties | set/get all properties used by BareSdk/ForkCompatibility profiles; invalid property boundary | Contract / Engine.Properties |
| Messages | set/get/clear callback, `WriteMessage`, compile diagnostic delivery | Contract / Engine.Messages + Compiler.Diagnostics |
| JIT | set/get compiler, compile/release callbacks and clearing | Host double / Embedding.JITCompiler |
| Global functions | register, count, index lookup, exact declaration lookup, invalid/duplicate registration | Execute + contract / Embedding.GlobalFunctions |
| Global properties | register, enumerate metadata/address/access mask, const behavior, invalid/duplicate registration | Execute + contract / TypeSystem.GlobalProperty |
| Object registration | object type/property/method/behavior, flags/offset/accessors, invalid signatures | Execute + contract / Embedding.ObjectRegistration |
| Native interfaces | interface/method registration and relationship/call behavior | Execute + contract / Embedding.Interfaces |
| String factory | register factory, return type ID/flags, constant lifecycle | Host double / Embedding.StringFactory |
| Default array type | register/get ID without importing a scriptarray add-on; unsupported/invalid boundary | Contract / Embedding.DefaultArrayContract |
| Enum/funcdef/typedef | register/enumerate/lookup and duplicate/invalid cases | Contract + script use / TypeSystem |
| Config state | begin/end/remove group, default access mask, default namespace | Contract / TypeSystem.ConfigGroup + Module.Namespaces |
| Modules | get modes, count/index, discard, missing module | Contract / Module.Lifecycle |
| Function by ID | valid and invalid function IDs | Contract / TypeSystem.ScriptFunction |
| Type identification | ID/declaration/primitive size/info by ID/name/decl, invalid inputs | Contract / TypeSystem.TypeInfo |
| Script objects | create/copy/uninitialized, assign/addref/release/ref-cast/weak flag | Execute / Runtime.ScriptObject |
| Context pool | create, request/return, custom request/return callbacks | Execute / Runtime.ContextPoolContract (raw SDK); plugin pool remains moved to Engine.ContextPool |
| Token parse | `ParseToken` valid/error/length cases | Contract / Frontend.Tokenizer |
| Garbage collection | collect/statistics/new object/enumerate/forward enum/release | Execute / Runtime.GarbageCollector |
| User data | set/get and all six cleanup callback owners | Contract / Embedding.UserDataCleanup |
| App exception translation | install callback and assert translated native exception | Execute / Embedding.ExceptionTranslation |

## `asIScriptModule`

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Identity/lifetime | engine, name set/get, discard | Contract / Module.Lifecycle |
| Compilation | pre-class data fork surface, sections/length/line offset, build, compile function, access mask, default namespace | Contract + execute / Module.Sections + Compiler.Builder |
| Functions | count/index/exact decl/name, ambiguity, remove function | Contract / Module.Functions |
| Globals | reset, count/declaration/metadata/address/remove | Execute + contract / Module.Globals |
| Types | object/enum/typedef enumeration and ID/name/decl lookups | Contract / Module.Types |
| Dynamic imports | count/index/declaration/source, bind/unbind one/all, success/error execution | Execute / Module.Imports |
| Bytecode | save/load, debug-strip flag, truncated/corrupt stream | Execute + contract / Module.SaveLoad |
| User data | set/get plus engine-owned cleanup callback | Contract / Embedding.UserDataCleanup |
| APV2 cross-module imports | `ImportModule`, `ClearImports` | Execute + contract / Module.CrossModuleImports |

## `asIScriptContext`

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Lifetime/engine | add/release, engine identity | Contract / Runtime.ContextLifecycle |
| Prepare/state stack | prepare/unprepare/execute/abort/suspend/state/push/pop/is-nested | Execute / Runtime.ContextControl |
| Object method call | `SetObject` valid/wrong/null object behavior | Execute / Runtime.ContextArguments |
| Arguments | byte/word/dword/qword/float/double/address/object/vartype and address-of-arg | Execute / Runtime.ContextArguments |
| Returns | byte/word/dword/qword/float/double/address/object/address-of-return | Execute / Runtime.ContextReturns |
| Exceptions | set/get text/line/function, callback set/clear | Execute / Runtime.ContextExceptions |
| Debug/introspection | instruction callback set/clear, line clear, call stack, function/line, variable metadata/address/scope, this type/pointer | Execute + contract / Runtime.ContextInspection |
| User data | set/get plus cleanup | Contract / Embedding.UserDataCleanup |

## `asIScriptGeneric`

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Invocation identity | engine/function/auxiliary/object/object type | Execute / Runtime.GenericCall |
| Arguments | count/type/flags and every scalar/address/object/address-of-arg getter | Execute / Runtime.GenericCall |
| Returns | type/flags and every scalar/address/object/return-location setter | Execute / Runtime.GenericCall |

## `asIScriptObject`

This fork exposes `asIScriptObject` as a concrete core surface rather than a normal pure-virtual interface. Coverage must follow the fork implementation rather than vanilla assumptions.

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Type/properties | type ID/info, property count/type/name/address | Execute / Runtime.ScriptObject |
| Copy/engine/user data | engine, `CopyFrom`, assignment, set/get user data | Execute + contract / Runtime.ScriptObject |
| Fork internal object operations | allocate uninitialized, copy object/handle, destructor | Direct + execute / Runtime.ScriptObject |

## `asITypeInfo`

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Ownership/identity | engine/config/access/module, add/release, name/namespace/base/derives/shadows, flags/size/type ID | Contract / TypeSystem.TypeInfo |
| Subtypes/interfaces | subtype IDs/types/count, interface enumeration, implements | Contract / TypeSystem.TypeRelationships |
| Factories/methods | count/index/name/exact decl and missing/ambiguous cases | Contract / TypeSystem.ObjectType |
| Properties/behaviors | metadata/declarations/inheritance, behavior kind/function | Contract + execute / TypeSystem.ObjectType + Language.Properties |
| Child/parent types | child funcdefs and parent type | Contract / TypeSystem.Funcdef |
| Enum/typedef/funcdef | enum values, underlying typedef ID, funcdef signature | Contract / TypeSystem |
| User data/copy | set/get, cleanup, fork `CopySystemType` boundary | Contract / TypeSystem.TypeInfo |

## `asIScriptFunction`

| Method family | Required surface | Disposition / owner |
| --- | --- | --- |
| Lifetime/identity | engine, add/release, ID/type/module/section/config/access/auxiliary/no-op | Contract / TypeSystem.ScriptFunction |
| Signature/traits | object/name/namespace/declaration, readonly/private/protected/final/override/shared/property, params/defaults, return | Contract / TypeSystem.ScriptFunction |
| Function type | type ID and compatibility | Contract + execute / TypeSystem.Funcdef |
| Delegate | object/type/function and invocation | Execute / Language.Functions |
| Debug/bytecode | locals/declarations/next code line/bytecode pointer+length | Contract / Compiler.Bytecode + Runtime.ContextInspection |
| User data | set/get and cleanup | Contract / Embedding.UserDataCleanup |

## Remaining host interfaces

| Interface | Required surface | Disposition / owner |
| --- | --- | --- |
| `asIBinaryStream` | read/write success, zero bytes, null/short bounds, restart; engine save/load drives it | Execute / Module.SaveLoad |
| `asILockableSharedBool` | add/release/get/set/lock/unlock and weak object flag | Execute / Engine.LockableSharedBool |
| `asIStringFactory` | constant acquire/release/raw length/query/copy and duplicate identity | Host double / Embedding.StringFactory |
| `asIJITCompiler` | compile/release and set/clear lifecycle | Host double / Embedding.JITCompiler |
| `asIThreadManager` | interface is intentionally empty in this fork; install/get plus multithread lifecycle occurs through globals | Contract / Engine.Threading; interface body documented Fork N/A |

## Closure rules

- The final static audit must find a disposition for every table row and reject placeholder owners.
- Representative final `TEST_METHOD` names are added to this test inventory after files settle.
- Error paths are required for registration, lookup, module/context state, and stream families; happy-path-only enumeration is insufficient.
- Public API metadata checks do not replace runtime execution where a real script/native call is feasible.
- Default-array registration is a core API contract only; this suite must not import or validate the scriptarray add-on implementation.
- Process-global API families follow `audits/global-state.md`; an inventory item with no safe restore surface must not be forced into a mutating runtime test.

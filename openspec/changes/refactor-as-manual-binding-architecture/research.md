# Research Notes — Direct Manual Binding Callbacks

Last refreshed: 2026-08-07

## Current Decision Authority

The selected architecture keeps the existing direct-execution property and removes only the avoidable indirection and global target selection:

- file-static `FAngelscriptBind` objects append compact callback records to the one existing process collection;
- `UAngelscriptSubsystem` loads generated modules and triggers one in-place validate/sort/seal pass, but stores no binding data;
- each full `FAngelscriptEngine` constructs an explicit `FAngelscriptBinds` context and directly replays the sealed callbacks;
- every callback explicitly declares one of seven `EAngelscriptBindPhase` values;
- `FAngelscriptBoundFunction` and `FAngelscriptBoundProperty` replace implicit PreviousBind mutation;
- project-owned runtime callables in production hand-written binds use named, bind-owned C++ functions, while the DSL retains supported lambda overloads;
- no expanded description of every declaration/method/property remains resident after registration.

The Registry/package proposal, the per-engine deferred-description proposal, and the process-wide expanded-info proposal are superseded. They remain below and in `review-2026-07-30.md` only as decision history. They are not implementation options within the current change.

## Direct-Execution Evidence

### Existing callback collection

`AngelscriptBinds.cpp` currently owns a function-local static `TArray<FBindFunction>`. Each record contains `FName BindName`, integer order, and `TFunction<void()>`. `RegisterBinds()` appends during static construction. `CallBinds()` calls `GetSortedBindArray()`, which copies the full array and sorts that copy for every full binding pass before invoking callbacks.

The new design can keep the same single collection and improve it without adding another repository:

1. change the stored callback to an explicit-target non-capturing function pointer, `void(*)(FAngelscriptBinds&)`;
2. load generated modules before finalization;
3. sort the original collection once and seal it;
4. let every engine iterate the immutable array without copying or sorting.

Production file-static providers found under Runtime, Editor, GameplayTags, and GAS use non-capturing outer lambdas or equivalent functions. Capturing callable behavior that must survive exists inside specific binding APIs, not as a requirement for the outer provider callback.

### Current engine execution

`FAngelscriptEngine::Initialize()` performs `PreInitialize_GameThread()`, may run `Initialize_AnyThread()` on `AnyHiPriThreadHiPriTask`, and returns to `PostInitialize_GameThread()`. `Initialize_AnyThread()` currently loads `Binds.Cache`, loads modules listed by `BindModules.Cache`, creates engine-owned binding stores, and calls `BindScriptTypes()`. `BindScriptTypes()` immediately calls `FAngelscriptBinds::CallBinds()`.

This proves that direct callback execution is the maintained behavior and already supports the product's threaded initialization shape. The redesign moves native module loading and collection finalization to subsystem-coordinated Game Thread work, but it does not need an intermediate representation to keep callback execution in `Initialize_AnyThread()`.

### Memory and repeated-engine trade-off

An expanded process-level binding representation would retain owned declaration strings, callable payloads, traits, documentation, reflection-derived entries, provenance, ordering identities, and auxiliary contributions after `asIScriptEngine` has created its own functions/types. That creates two process-lifetime representations of the binding surface.

The benefit would be amortizing author callback and reflection-expansion work across multiple full engines. Normal product startup owns one primary engine; repeated full-engine creation is primarily a test and validation scenario. The project therefore chooses the smaller normal-path design: replay compact callbacks for each deliberately created engine and retain no expanded registration data.

The sealed global array still saves repeat work relative to the current implementation because engines no longer copy and sort every callback record.

## Current Data Model

### Process callback record

The one process collection stores only:

```text
BindName
EAngelscriptBindPhase
OwnerModule
SourceFile / SourceLine
void(*)(FAngelscriptBinds&)
```

It does not store reflection results, declarations, methods/properties, AS ids/objects, resolved type info, enabled flags, dependencies, priorities, unregister handles, or module leases.

### Per-engine direct context

`FAngelscriptBinds` holds an explicit `FAngelscriptEngine&` and resolves every mutable target from that engine. Its class/type views retain only the short-lived target/type state required while a provider callback executes.

Function and property registration return `FAngelscriptBoundFunction` / `FAngelscriptBoundProperty`, which immediately target the exact registered result. These values replace ambient PreviousBind ids but do not become persistent process metadata.

### Engine-owned results

Every AS function/type/object, registration id, type adapter/finder result, ToString entry, BindDB state, interface signature, and native/StaticJIT result belongs to the explicit engine. A second engine replays callbacks and creates independent values.

## Current Ordering Model

The seven phases replace all integer order values:

```text
TypeDeclarations
TypeInfrastructure
ManualBindings
GeneratedBindings
ReflectionBindings
PostReflectionBindings
Finalization
```

Direct execution cannot classify individual statements inside an opaque callback. Consequently phase is required on every `FAngelscriptBind`, and a legacy callback that mixes phases must split into multiple file-static binds. This preserves file ownership without retaining deferred nodes.

Within one phase, stable owner/name/source sorting replaces static initialization order. Tight same-phase producer/consumer sequences remain inside one callback. Any coupling that cannot be expressed by phase selection, callback splitting, or local merge becomes evidence for a later dependency OpenSpec; it is not a reason to retain integer offsets.

The implementation audit must map every non-default manual expression and UHT-generated offset to a concrete phase/split/merge resolution before deleting `EOrder`.

## Current Alternatives Considered

| Alternative | Decision | Reason |
|---|---|---|
| Keep current global array and direct callbacks | Selected, with explicit target and one-time seal | Lowest resident memory and smallest conceptual model; preserves proven runtime behavior. |
| Subsystem stores pointers to file-static bind objects | Rejected | Adds a second array without improving lifetime or execution; the global collection already exists. |
| Move the global array into the subsystem | Rejected | Complicates tests and no-`GEngine` compatibility without reducing process state. |
| Cache reflection output only | Rejected | Creates separate manual/generated and reflection execution models. |
| Cache every expanded binding operation | Rejected | Duplicates the registered surface in memory to optimize a primarily test-driven multi-engine scenario. |
| First engine sorts opportunistically | Rejected | Leaves generated module loading and finalization on the engine/worker path; subsystem coordination gives a clearer boundary. |
| Keep integer `EOrder` | Rejected | Seven explicit phases plus local callback structure express the audited semantic requirements. |
| Automatic phase inference from calls inside a direct callback | Rejected | Requires replaying callbacks multiple times or recording their calls, reintroducing side effects or deferred data. |
| Author-required phase per callback | Selected | Makes execution intent visible and works with opaque direct callbacks. |
| Public Registry or central manifest | Rejected | Separates ownership from bind files and adds lifecycle/API surface without need. |

## Current Callable Debuggability Research

### Why inline binding lambdas are difficult to debug

`TLambdaFuncPtr<T>` in `Core/AngelscriptBinds.h` derives a regular CDECL function-pointer type from `T::operator()`. The binding overload converts a non-capturing lambda to that pointer, and `ASAutoCaller` later invokes it through a type-erased caller. This is efficient and must remain supported, but native tools commonly present the registered entry as an anonymous lambda `operator()` plus caller templates. The owning bind and AngelScript operation are therefore difficult to identify in breakpoints, crash stacks, samples, and optimized builds.

AngelScript's native registration contract already accepts ordinary C/C++ function pointers, while its debugger API focuses on script contexts, script functions, and script source lines rather than assigning friendly identities to anonymous C++ callables. A stable named C++ entry point is therefore the smallest solution at the correct layer:

- <https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_func.html>
- <https://www.angelcode.com/angelscript/sdk/docs/manual/doc_debug.html>
- <https://learn.microsoft.com/en-us/visualstudio/debugger/cpp-dynamic-debugging?view=visualstudio>

### Source inventory and boundary

The Runtime `Binds` directory contains 121 `Bind_*.cpp` files. A broad multiline source scan found direct method/global/constructor/behaviour lambda candidates in approximately 101 of them; the implementation baseline must replace this approximation with an exact audited inventory. The same audit must include existing project-owned file-local free, namespace, and static functions that are directly registered to AngelScript so the separation is responsibility-based rather than syntax-based.

The production migration covers callables supplied directly to `Method`, `Constructor`, `ImplicitConstructor`, `Factory`, `Destructor`, `Behaviour`, `TemplateCallback`, `BindGlobalFunctionForTarget`, and `BindGlobalGenericFunctionForTarget`. It does not mechanically rewrite:

- capturing `RegisterTypeFinder` and similar engine-owned auxiliary values;
- local algorithm lambdas that do not escape their function;
- UE delegate, weak-lambda, task, and async callbacks created inside a bound operation;
- focused tests that prove the public DSL still accepts non-capturing lambdas.

### Selected file and owner model

A hand-written bind with custom callable implementations uses one sortable family:

```text
Bind_<Name>.cpp
Bind_<Name>_Functions.h
Bind_<Name>_Functions.cpp
```

The registration file owns phases, declarations, DSL calls, and traits. The header declares one primary `FAngelscript<Name>Binds` owner, and the implementation file defines its non-template runtime callables. Pointer-only binds do not receive empty companion files. One bind file retains one primary owner even when it registers several related UE types; semantic method names distinguish receiver and overload variants.

Existing plural owners such as `FAngelscriptActorBinds`, `FAngelscriptMapBinds`, `FAngelscriptSetBinds`, and `FAngelscriptOptionalBinds` remain plural and are not renamed solely for normalization. New owners also use the plural `Binds` suffix. When an existing owner spans multiple registration files, callable ownership may split while the established name remains with its primary bind.

Non-template implementations belong in `_Functions.cpp`. Required template definitions remain in `_Functions.h`, and existing container operations/support types are not redesigned. Implementation-only helpers remain private or in an anonymous namespace.

### StaticJIT and performance findings

`FUNC` and `FUNC_TRIVIAL` are not cosmetic pointer macros when `AS_CAN_GENERATE_JIT` is enabled: they also submit the C++ callable name and trivial flag as a native form. Template bindings separately use `SCRIPT_NATIVE_TEMPLATED_CALL*` strings, and `StaticJITHelperFunctions.h` / `StaticJITHeader.h` include several bind helper headers so generated C++ can resolve those names. Consequently:

- a former ordinary lambda becomes `&FAngelscript<Name>Binds::Function`, not `FUNC(...)`, so it does not silently gain a native form;
- an existing native/trivial/template form preserves its classification, required export visibility, generated spelling, and include reachability after moving;
- generated StaticJIT/precompiled C++ must be compiled as a migration check, rather than validating only the Runtime DLL;
- the design does not add blanket `FORCENOINLINE`, disable optimization, insert a runtime tracing scope, or store one metadata record per function.

### Alternatives considered

| Alternative | Decision | Reason |
|---|---|---|
| Named bind-owned static functions | Selected | Stable native symbols and source ownership with the same function-pointer call shape and no new runtime state. |
| Keep inline lambdas and add function-level source metadata | Rejected | Helps dumps/tools but does not make the native callable symbol readable and adds binding-surface-sized resident diagnostics. |
| Add a tracing/trampoline scope around every AS-to-C++ call | Rejected | Adds hot-path indirection or instrumentation cost to solve a source-symbol problem. |
| Force all wrappers no-inline or disable optimization | Rejected | Would penalize high-frequency math/container bindings and still would not give anonymous callables good semantic names. |
| Remove lambda overloads from the DSL | Rejected | Breaks a supported authoring form unnecessarily; production style and public capability are separate concerns. |
| Rewrite every lambda under `Binds/` | Rejected | Conflates direct AS entries with type-finder ownership, local algorithms, and asynchronous UE callback lifetimes. |

## Superseded Design Record: Deferred Manual Binding Plan

> The sections from here through the original `Research Conclusion` preserve the earlier deferred-description investigation. They do not define the current implementation. The later container-template/type research remains relevant background because direct callbacks must preserve those behaviors.

## Executive Finding

The existing global-array idea is useful and can be retained, provided it is narrowed to discovery metadata. The clean boundary is:

- file-static objects append provider metadata globally;
- the first engine loads all known bind modules and permanently seals that provider set;
- each engine executes providers on the Game Thread to build a descriptor plan;
- the initialization worker applies the plan to an explicit AS engine;
- no binding module writes registration code in `StartupModule()`;
- no provider dependency or runtime-disable system is introduced.

This keeps bind files self-contained and preserves the source-plugin customization model. It also removes the two unsafe parts of the current design: doing real binding work through ambient current-engine state and attaching metadata to whichever AS function happened to be registered most recently.

## Source Inventory

### Manual provider scale

The current tree contains:

| Scope | `Bind_*.cpp` files |
|---|---:|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds` | 121 |
| `Plugins/AngelscriptGameplayTags` | 1 |
| `Plugins/AngelscriptGAS` | 5 |
| **Total manual bind files** | **127** |

`FAngelscriptBinds::FBind` appears in 141 source files across the three plugins because the registrar also appears outside the canonical `Bind_*.cpp` set and in support/test/generated-related code. The implementation inventory must use symbol search, not only filename enumeration.

### Existing order vocabulary

Manual providers currently use 16 distinct numeric expressions:

```text
Early-1, Early, Early+1,
Normal,
Late-10, Late-5, Late-1, Late, Late+1, Late+10,
Late+49, Late+60, Late+100, Late+105, Late+110, Late+150
```

The UHT runtime-linked emitter separately generates `Late + 50`. These values encode several different concerns in one integer: type declaration, type support, ordinary hand-written members, generated native functions, reflective fallback, and final aggregation. That observation supports fixed semantic stages. It does not yet support a general string dependency graph.

### Callable forms that must survive

Representative current call sites show all of the following:

- direct member pointers such as `&FTopLevelAssetPath::IsValid`;
- `METHOD_TRIVIAL`, `METHODPR_TRIVIAL`, `FUNC`, and `FUNC_TRIVIAL` wrappers;
- non-capturing method/global lambdas for marshalling and behavior adaptation;
- constructor lambdas receiving placement memory;
- direct/generic calls with explicit user data and call-convention behavior;
- dynamic declarations generated from reflection, for example actor/component/class/delegate helpers;
- TFunction-like capturing entries in type-finder/adapter-style registries.

Therefore descriptor-first cannot mean "function pointers only" or "no lambdas." It means the callable payload is owned by the descriptor plan and invoked by AngelScript later, after registration, instead of the builder invoking the registration API immediately.

### Previous-bind coupling

Current bind files call `SetPreviousBind*`, `DeprecatePreviousBind`, compile-out helpers, documentation/native macros, and in a few cases read the returned function id. These operations are order-sensitive because they target mutable process/current-engine state. The correct replacement is a node view returned by the exact `Method` / `Constructor` / global/property authoring call. Registered ids remain per-engine apply results.

### Auxiliary side effects

The current callbacks do more than register AS declarations. Earlier source scans found these high-volume patterns:

| Pattern | Approximate files in the previous audit | Required new representation |
|---|---:|---|
| `FAngelscriptType::Register` | 43 | engine-owned type-adapter descriptor |
| `FToStringHelper::Register` | 33 | ToString contribution + final aggregate |
| `RegisterTypeFinder` | 13 | engine-owned finder factory descriptor |
| `FAngelscriptBindDatabase::Get` | 9 | explicit BindDB contribution/finalizer |

The counts are navigation aids, not acceptance baselines. The important finding is categorical: removing immediate callbacks without modeling these operations would silently remove behavior. They need first-class descriptor kinds, not a generic "custom callback" escape hatch.

## Lifecycle Evidence

### UE module timing

The plugin modules load at `PostDefault`, before `GEngine` completes its subsystem-driven AngelScript initialization. Generated modules are already enumerated through `BindModules.Cache`. This makes the following sequence viable:

1. the OS/UE loader runs file-static provider constructors as native modules load;
2. first engine startup reads `BindModules.Cache` and loads the complete generated-module set;
3. the provider catalog is sealed only after those module loads;
4. provider builders then run on the Game Thread.

This is analogous to other UE deferred static-registration patterns: static code contributes metadata, while a later controlled phase consumes it. The design does not rely on cross-translation-unit constructor order because the consumer sorts stable identities after sealing.

### Engine threading

The current engine lifecycle already distinguishes Game Thread pre-initialization from AnyThread initialization. Reflection enumeration, UObject/class access, module loading, and BindDB input capture belong in `PreInitialize_GameThread`. AngelScript registration can then consume an owned frozen plan in `Initialize_AnyThread`. Publishing and UE notifications remain in `PostInitialize_GameThread` after successful apply.

### Generated binding paths

Source evidence identifies three generated paths that currently have distinct arrival mechanisms:

- `AngelscriptFunctionBindingEmitters.cs` emits runtime-linked `FBind` callbacks;
- the same UHT tool emits `NativeModuleFunctionAddress` shards that use `IModularFeatures` registration/unregistration;
- editor CodeGen emits module code with a `StartupModule()` that calls `RegisterBinds()`.

RuntimeLinked and editor CodeGen can move to file-static providers. NativeModuleFunctionAddress cannot do so in this change: its target shards compile into UE modules that are already dependencies of `AngelscriptRuntime`, so instantiating Runtime-owned `FAngelscriptBind` there would introduce a circular dependency. Its existing POD/`IModularFeatures` arrival and unload bridge remains until `refactor-as-native-module-binding-preseal-transport`; reflective fallback classification stays unchanged.

## Alternatives Considered

| Option | Result | Reason |
|---|---|---|
| Module-owned Registry populated in `StartupModule()` | Rejected | Forces every module to maintain submission code and separates bind ownership from the bind file. |
| Central manifest of providers | Rejected | Easy to forget and duplicates source ownership at the largest bind count. |
| File-static `FAngelscriptBind` metadata catalog | Selected | Keeps each bind self-contained; static work stays engine-free and deterministic after sorting. |
| `AS_BIND` macro | Rejected | Hides ordinary C++ construction without solving lifecycle or ordering. |
| Linker sections | Rejected | Adds platform/toolchain behavior and difficult diagnostics for little benefit. |
| Build-time scan/generation of `Bind_*.cpp` | Rejected | Couples correctness to filenames and adds a generator when static metadata is sufficient. |
| Author-written stage | Rejected | Requires every binding author to understand global scheduling and recreates numeric order under new names. |
| Seven phases declared per direct callback | Selected | Captures declarations, infrastructure, manual/generated/reflection work, post-reflection callable synthesis, and finalization without numeric order. |
| `Requires` / `Before` / `After` strings | Deferred | No irreducible case has yet justified a name-resolution/dependency subsystem. |
| Runtime bind disabling | Rejected | Source delivery already gives users a simpler customization mechanism; disabling creates dependency and partial-surface complexity. |
| Dynamic unregister/unload and snapshot leases | Rejected | Registered native addresses cannot be safely removed from a live AS engine; restart is the honest contract. |
| Engine-independent AngelScript declaration parser | Rejected | Duplicates/refactors semantic authority for preflight that can instead fail safely before engine publication. |
| Opaque custom apply callbacks | Rejected | Recreates the current architecture and defeats stage/identity/reporting guarantees. |
| Full legacy compile gate | Rejected as target architecture | The in-tree migration should end with zero old-path production references, not two permanent binding systems. |

## Chosen Data Model

### Provider record (process lifetime)

```text
OwnerModuleName
LogicalBindName
SourceFile / SourceLine
BuildFunction
```

No AS engine, AS object/id, reflection result, BindDB record, enabled flag, dependency, stage, priority, unregister handle, or module lease belongs here.

### Engine plan node

```text
Provider identity and source/origin
Descriptor kind -> fixed semantic stage
Stable node identity
Owned AS declaration/target identity when applicable
Callable payload (asSFuncPtr/caller/callconv/userdata/native form)
Traits and documentation
Owned auxiliary/generated/reflection inputs
```

The plan is created once per engine and frozen before crossing from Game Thread pre-initialization to AnyThread application.

### Engine apply result

```text
Node identity and stage
Applied/failed status
AngelScript return code/diagnostic
Engine-local function/property/type id or pointer when needed internally
Build/apply timing when observation is enabled
```

Only engine-owned structures retain AS ids or objects.

## Ordering Audit Method

During implementation, every non-default legacy `EOrder` occurrence must be classified into one of four outcomes:

1. its descriptor kind naturally places it in an earlier/later fixed stage;
2. a single old callback must be split into producer and consumer nodes in different stages;
3. the operation is generated/reflection/finalization work and moves to that origin's stage;
4. tightly coupled local operations remain in one provider with stable node order.

The audit must record any case that cannot be expressed this way. Implementation is not authorized to add a one-off priority or string dependency; such a case triggers a separate design review/OpenSpec.

## Compatibility Authorities

- Existing script-visible type/function/property/behavior/funcdef declarations and runtime behavior.
- Existing native/trivial/StaticJIT metadata and documentation traits.
- Existing reflection fallback eligibility, especially RPC/Net UFunctions.
- Multi-engine lifecycle and formatting/type-info isolation tests.
- UHT function-strategy analysis and generated artifact tests.
- `Binds.Cache` reflection-database create/load behavior; catalog identity is not added to its schema.
- `FAngelscriptNativeModuleFunctionBinding` / view layout and its version file unless the POD layout itself changes.

Raw AS registration ids and legacy callback order numbers are not compatibility authorities.

## Research Conclusion

The selected architecture is intentionally smaller than the superseded Registry/package proposal. It keeps the successful part of the old global-array approach—automatic per-file discovery—but moves every engine-sensitive action into one explicit per-engine direct callback execution context, without a retained plan/apply representation. Production hand-written runtime callables additionally gain stable bind-owned C++ names without adding runtime metadata or tracing. The remaining uncertainty is migration volume, not an unresolved architectural decision.

## 后续研究：容器模板与 `FAngelscriptType`（2026-08-07）

本节针对两个问题记录源码审计结果：手写 `TArray` / `TMap` / `TSet`
绑定怎样支持 AngelScript 模板，以及 `FAngelscriptType` 在其中承担什么角色。
这里记录的是当前实现，不代表已经批准任何行为修改。

### 一句话结论

`FAngelscriptType` 是插件侧的“类型能力适配器”。它不是 AngelScript SDK
中的类型身份对象，也不是某个容器模板实例。它回答的是：当插件面对某种
AngelScript 类型的值时，应该如何存储、构造、复制、析构、比较、哈希、扫描
UObject 引用、映射 `FProperty`、通过 `FFrame` 传参和返回、在调试器中展示，
以及在存在安全原生快路径时如何表示成 C++ 类型。

`FAngelscriptTypeUsage` 表示这个适配器的一次具体使用。它在基础适配器之上
补充模板实参、`const` / 引用限定，以及具体 AngelScript 类型等上下文信息。
例如，所有 `TArray` 实例共享同一个数组类型适配器，而 `TArray<int>` 的
`FAngelscriptTypeUsage` 会额外保存 `int` 的子类型 Usage。

因此，最重要的分层是：

| 对象 | 权威来源 | 职责 |
| --- | --- | --- |
| `asITypeInfo` / `asCObjectType` | AngelScript SDK | 语言可见的类型身份、模板基类/实例身份、方法、行为、属性和子类型 id。 |
| `FAngelscriptType` | Unreal AngelScript 集成层 | 安全处理某个基础类型值所需的操作和能力。 |
| `FAngelscriptTypeUsage` | Unreal AngelScript 集成层 | 适配器的一次具体、带限定符的使用，包含递归解析后的模板参数。 |
| `FArrayOperations` / `FMapOperations` / `FSetOperations` | 容器绑定层 | 针对某个具体模板实例缓存尺寸、对齐、布局、生命周期标志、比较和哈希行为。 |
| `FScriptArray` / `FScriptMap` / `FScriptSet` | Unreal Core 容器 | 通用运行时路径实际使用的类型擦除存储。 |

源码依据：`Core/AngelscriptType.h` 定义能力接口和可递归组合的
`FAngelscriptTypeUsage`；`Core/AngelscriptType.cpp::FromTypeId` 把 SDK 类型
id 解析为“适配器 + 递归子类型”。`Binds/Helper_CppType.h` 中的
`TAngelscriptCppType<NativeType>` 则展示了典型适配器如何利用 C++ 类型 traits
实现这些操作。

### 为什么存在两层类型注册

容器支持依赖两类不能混为一谈的注册：

1. `Binds.ValueClassForTarget(...)` 以及相应方法和 behavior 注册脚本编译器
   能看见、能调用的类型表面。
2. `FAngelscriptType::Register(...)` 和 Type Finder 注册 Unreal 集成层知道如何
   操作的值类型。

所以，一个类型可能已经被 AngelScript 编译器认识，却仍然不能作为容器元素：
如果插件无法为它解析出有效的 `FAngelscriptType`，通用容器就不知道该怎样安全
构造、复制、析构、比较或哈希这个值。

第二套注册表并非重复造一个语言类型系统，而是在补齐 AngelScript SDK 本身不负责
的 Unreal 互操作语义。

当前类型数据库只由对应 `FAngelscriptEngine` 持有。生产绑定通过显式 database
overload 操作目标 engine；仍保留的兼容查询 API 只允许路由到 checked current
engine，并在缺少 engine-owned database 时 fail closed，不再创建进程级
`LegacyDatabase` 回退。

### 容器模板怎样注册给 AngelScript

`Bind_TArray.cpp`、`Bind_TMap.cpp` 和 `Bind_TSet.cpp` 基本遵循同一套流程：

1. 使用 `FBindFlags::bTemplate = true` 注册值类型，并给出模板参数声明，同时附加
   `asOBJ_TEMPLATE_SUBTYPE_COVARIANT`。
2. SDK 可见声明分别是 `TArray<class T>`、`TMap<class K, class V>` 和
   `TSet<class T>`。
3. 针对 Unreal 的类型擦除存储注册构造和析构 behavior。
4. 注册 `asBEHAVE_TEMPLATE_CALLBACK`，用于验证每个具体模板实例。
5. 只用带 `T` / `K` / `V` 的声明注册一次方法；SDK 生成模板实例时负责替换为
   具体类型。
6. 注册容器自己的 `FAngelscriptType` 适配器和 `FProperty` Type Finder，使脚本
   类型与 Unreal 反射容器属性能够双向转换。

SDK 侧，`asCScriptEngine::RegisterObjectType` 创建模板基类型和占位子类型；
`GetTemplateInstanceType` 按“模板基类型 + 具体子类型身份”查找或缓存实例，调用
模板回调，替换方法/属性声明中的占位类型，最终发布具体的 `asCObjectType`。

因此，语言层模板实例化使用的是 AngelScript 自己的模板机制。脚本每出现一种新
元素类型时，插件并不会即时让 C++ 编译器生成一个新的 `TArray<ConcreteType>`。

### 完整例子：`TArray<int>`

当前通用执行路径可以概括为：

```text
脚本解析 TArray<int>
  -> AngelScript 找到 TArray<T> 模板基类型
  -> SDK 创建或复用具体 asCObjectType 实例
  -> 模板回调调用 FAngelscriptTypeUsage::FromTypeId(int)
  -> int 的类型适配器证明所需生命周期能力齐全
  -> 为这个具体实例创建 FArrayOperations
  -> 把 Operations 缓存在该实例的类型信息 user-data 槽中
  -> SDK 克隆 TArray<T> 方法并把 T 替换成 int
  -> 调用容器方法时，把具体对象类型作为隐藏原生参数传入
  -> FArrayOperations 取回缓存的子类型 Usage 和元素步长
  -> 通过类型适配器操作 FScriptArray 存储
```

隐藏的类型元数据参数是这套设计的关键。像 `FArrayOperations::Add` 这样的通用
原生函数需要知道当前具体模板实例，但脚本声明里并没有这个额外参数。绑定调用
`PreviousBindPassScriptObjectTypeAsFirstParam()` 后，调用元数据会被标为
`ScriptObjectType`；`as_context.cpp` 随后把当前调用描述中的
`descr->objectType` 注入原生参数列表。通用函数再通过这个类型对象找到缓存的
Operations。

### 能力组合，而不只是语法校验

容器模板回调本质上是在检查类型能力：

| 容器 | 实例化时要求的子类型能力 | 额外行为 |
| --- | --- | --- |
| `TArray<T>` | 有效适配器、尺寸/对齐、构造、析构、复制 | 相等、Contains、Remove 等具体操作在使用时再检查比较能力。 |
| `TMap<K,V>` | Key：构造/析构/复制/比较/哈希；Value：构造/析构/复制 | 适配器没有哈希时，脚本 struct 的 `Hash()` 可以补充 Key 哈希。 |
| `TSet<T>` | 构造/析构/复制/比较/哈希 | 适配器没有哈希时，脚本 struct 的 `Hash()` 可以补充哈希。 |

每个具体模板实例的 Operations 会把抽象能力固化为元素尺寸、对齐、
`FScriptMapLayout` / `FScriptSetLayout` 以及具体函数选择。因此，即使 C++ 编译器
从未实例化对应的原生容器，Map/Set 仍能安全容纳运行时发现的脚本 struct。

### 通用运行时路径与原生快路径

当前存在两种执行策略，但只有第一种是一般语义基础：

- 通用运行时路径使用 `FScriptArray`、`FScriptMap` 或 `FScriptSet`，并组合
  `FAngelscriptTypeUsage` 和缓存的 Operations。它能支持运行时才发现的类型。
- StaticJIT 可以向 `FAngelscriptTypeUsage::GetCppForm()` 查询真正的 C++ 类型拼写。
  如果存在安全的原生表达形式，就生成对 `TArray<X>` 等 C++ 模板 helper 的调用；
  否则保留通用路径。

所以，C++ 模板实例化只是可选优化和原生互操作手段，不是 AngelScript 模板语法和
任意运行时容器元素类型得以工作的根本机制。

### 当前嵌套规则

Array、Map、Set 的类型适配器都把 `CanBeTemplateSubType()` 重写为 `false`。
对应模板回调因此拒绝 `TArray<TArray<int>>` 这类嵌套值容器。这是当前插件主动
设置的能力边界，不是 AngelScript 模板解析器本身做不到。

数组模板回调存在一个必要的绑定期例外：如果子类型还是带
`asOBJ_TEMPLATE_SUBTYPE` 的 SDK 占位类型，它会暂时放行。原因是 Map/Set 的方法
声明包含 `TArray<K>`、`TArray<V>` 和 `TArray<T>`；注册外层模板时，K/V/T 还没有
替换成具体类型。如果把这种中间占位实例也当作真实嵌套容器拒绝，相关方法声明
本身就无法形成。

### 已确认的发现与待验证风险

1. **当前报错混淆了两种失败原因。** 模板回调只要看到
   `CanBeTemplateSubType() == false`，就报告
   `Containers cannot be nested in other containers`。真实嵌套容器会返回 false，
   但“没有解析出有效类型适配器”同样会走到这里。于是，一个只完成脚本注册、
   没有注册插件类型适配器的手写非 `USTRUCT` 值类型，也可能得到错误的“容器不能
   嵌套”提示。本地历史问题材料中已有这种实例。未来应分别报告“缺少类型适配器/
   能力”和“不支持嵌套容器”，并指出具体失败子类型。

2. **正确性同时依赖 SDK 注册表和插件类型注册表。** 这是必要的架构依赖，但对
   绑定作者并不直观。未来的 typed binding API 应把脚本声明与
   `FAngelscriptType` 描述符一起构建，或者在预检阶段明确报出缺少适配器。

3. **类型数据库选择仍有隐式环境状态。** 正常路径已经是引擎自有数据库，但静态
   facade 和 legacy fallback 让所有权、销毁顺序及多引擎不变量不够显式。计划中的
   engine-scoped descriptor 架构需要保留递归类型查找能力，同时消除“当前引擎是谁”
   对注册目标的隐式影响。

4. **具体容器 Operations 使用无类型的 SDK user-data 槽。**
   `FArrayOperations`、`FMapOperations`、`FSetOperations` 由模板验证回调创建，
   然后存入具体类型的 `plainUserData`。其他类型也把同一个原始槽用于完全不同的
   payload，因此其类型安全和所有权依赖约定。

5. **Operations 的释放路径目前是待验证问题。** 本轮审计找到了三个 Operations
   的 `new` 和 user-data 写入点，但尚未在 Runtime 中找到 SDK type-info user-data
   cleanup callback 的注册，也没有找到直接 `delete` 路径。SDK 清理 user data 时
   只会调用已注册的 cleanup callback。因此，这可能形成“每个模板实例一份”的
   生命周期泄漏，但目前只能记为候选问题，不能记为已确认缺陷。需要针对模块卸载/
   引擎销毁的生命周期测试或分配器计数来证实或排除。

6. **`FAngelscriptTypeUsage` 中存在隐式上下文不变量。** 它用一个 union 复用
   `ScriptClass`、`UnrealProperty` 和 `TypeIndex` 存储位。结构很紧凑，但当前有效
   含义由调用约定而不是显式 discriminant 表达。新的描述符作者接口不应继续暴露
   这种歧义。

### 主要源码锚点

- `Source/AngelscriptRuntime/Core/AngelscriptType.h` 和 `.cpp`
- `Source/AngelscriptRuntime/Core/AngelscriptBinds.h` 和 `.cpp`
- `Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`、`.h` 和
  `Bind_TArray_Functions.h`
- `Source/AngelscriptRuntime/Binds/Bind_TMap.cpp` 和 `.h`
- `Source/AngelscriptRuntime/Binds/Bind_TSet.cpp` 和 `.h`
- `Source/AngelscriptRuntime/Binds/Helper_CppType.h`
- `Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp` 和 `.h`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp`

### 下一轮待查问题

- 证明或排除三种容器 Operations 在模块丢弃和引擎销毁时的释放问题。
- 分别选择一个反射 `FArrayProperty` 和一个脚本自定义 struct，完整跟踪
  `FAngelscriptTypeUsage::FromProperty` / `FromTypeId` 的双向路径。
- 判断禁止嵌套容器究竟是产品需求，还是递归布局、GC 与属性桥尚未闭环形成的
  实现限制。
- 盘点哪些手写原生值类型已经对脚本可见，却没有注册对应适配器，并为计划中的
  preflight 设计更准确的诊断模型。

## 后续验证：模板 Operations 所有权（2026-08-07）

上一节把 Operations 释放问题标为“候选泄漏”。本轮沿分配、SDK user-data、
模板类型销毁、模块重建和 `FAngelscriptEngine` 销毁路径完成了控制流审计。结论
现在可以升级为：**当前 Runtime 中的模板 Operations payload 存在已确认的所有权
泄漏**。泄漏对象不只是前三种容器，还包括同样采用该模式的 `TOptional`。

这个结论只针对附着在 type-info 上的 Operations payload。当前 SDK fork 已经在
引擎销毁时释放生成的模板 `asCObjectType`，因此不能把问题表述为“模板类型实例
本身没有释放”。

### 影响范围

源码中共有四类相同的堆分配：

| 模板类型 | payload | 分配与附着位置 |
| --- | --- | --- |
| `TArray<T>` | `FArrayOperations` | `Bind_TArray.cpp::ValidateArrayOperations` |
| `TMap<K,V>` | `FMapOperations` | `Bind_TMap.cpp::ValidateMapOperations` |
| `TSet<T>` | `FSetOperations` | `Bind_TSet.cpp::ValidateSetOperations` |
| `TOptional<T>` | `FOptionalOperations` | `Bind_TOptional.cpp::ValidateOptionalOperations` |

四者都使用 `new` 创建 payload，再以没有显式 slot key 的
`TemplateType->SetUserData(Ops)` 写入默认 user-data 槽；运行时热路径则直接读取
`asCObjectType::plainUserData`。仓库搜索没有找到：

- Runtime 对 `SetTypeInfoUserDataCleanupCallback(...)` 的调用；
- 四种 Operations 的 `delete`；
- 持有它们的 `TUniquePtr` / `TSharedPtr` / engine-owned registry；
- 能在 type-info 销毁前接管这些指针的其他所有者。

Operations 本身也不是无状态 POD。它们持有一个或多个
`FAngelscriptTypeUsage`，后者包含 `TSharedPtr<FAngelscriptType>` 和递归
`SubTypes`；Map/Set 还可能缓存 engine-owned `asIScriptFunction*`。因此缺少
`delete` 不仅遗失 allocation，也跳过了 `FAngelscriptTypeUsage` 的正常析构和
shared-reference 释放。

### SDK user-data 的真实所有权语义

`asCTypeInfo::SetUserData(data, 0)` 只执行以下操作：

1. 返回旧的 `plainUserData`；
2. 把新指针写入 `plainUserData`。

它不取得 C++ 对象所有权，也不会在替换时调用 deleter。

`asCTypeInfo::CleanUserData()` 在 type-info 销毁时会检查引擎注册的
`cleanTypeInfoFuncs`：

- 默认槽非空时，只调用 key 为 `0` 的 cleanup callback；
- 自定义槽非空时，只调用与该自定义 key 匹配的 callback；
- 无匹配 callback 时，仅把指针清零并清空槽数组。

当前 Runtime 没有注册任何 type-info cleanup callback，所以四种默认槽中的
Operations 指针在 `CleanUserData()` 中只会被遗忘，不会被释放。

### 模板类型和引擎确实执行了销毁

当前 SDK fork 的销毁侧已经闭环：

1. `asCObjectType::DestroyInternal()` 会调用 `CleanUserData()`；
2. `asCObjectType` 析构函数也会进入 `DestroyInternal()`；
3. `asCScriptEngine` 析构时遍历 `templateInstanceBuckets`，对生成的模板实例调用
   `DestroyInternal()` 和 `ReleaseInternal()`；
4. 对 application-registered 类型也会执行相同的内部销毁与引用释放；
5. `FAngelscriptEngine` 调用 `Engine->ShutDownAndRelease()` 后，才 Reset 自己的
   `TypeDatabase` 等辅助数据库。

所以 type-info 的销毁函数确实运行了，而且运行时 `TypeDatabase` 仍然存活，具备
安全析构 Operations 所持 `FAngelscriptTypeUsage` 的顺序条件。唯一缺失的环节是：
没有人为 Operations payload 建立 cleanup callback 或其他 owner。

### 成功实例和失败实例的泄漏时机

成功模板实例的行为是确定的：每个引擎中的每个具体模板实例至多创建一份
Operations；类型或引擎销毁时，type-info 被释放，但 Operations allocation 保留
到进程终止。

失败实例还存在更短的泄漏路径：

```text
SDK 创建临时模板 asCObjectType
  -> 调用 Runtime 模板验证回调
  -> 回调 new Operations 并写入默认 user-data
  -> 后续能力检查失败，回调返回 false
  -> SDK 立即 Release/销毁临时 asCObjectType
  -> CleanUserData 只清零指针
  -> Operations 当次即失去最后一个可达地址
```

具体而言：

- Array 在元素缺少构造/析构/复制能力或尺寸无效时，会在分配 Operations 后失败；
- Map/Set 在缺少比较、哈希或生命周期能力时，会在分配 Operations 后失败；
- Optional 在子类型生命周期能力不足时，会在分配 Operations 后失败；
- 真正的嵌套容器拒绝发生在 `new` 之前，所以该特定失败分支不会分配 Operations。

非 deferred validation 路径不会把失败实例加入模板 bucket；以后再次请求相同失败
类型时可以重新创建临时 type-info 和 Operations，因此反复编译同一能力错误可能
反复泄漏，而不是稳定为“每个类型一次”。

模块重建或热重载销毁模板实例时也会进入同一个 `CleanUserData()` 路径，因此当前
行为同样只销毁 type-info，不销毁附着的 Operations。

### 为什么现有测试没有排除这个问题

`AngelscriptEngineMemoryLifecycleTests.cpp` 已经覆盖 isolated full engine 销毁、
多轮引擎创建、GC、UObject 脱离和进程物理内存快照，但它主要断言：

- generated `UASClass` / `UASStruct` 是否解除 root；
- UEnum / delegate / UObject 数量是否回到有界范围；
- GC 性能是否保持有界。

内存快照以 MiB 为粒度，而且没有对 Operations 的创建/销毁数量做断言。小型 C++
allocation 还会受到 UE allocator 缓存影响，所以现有测试即使通过，也不能证明这四
种 payload 被析构。

现有 Native SDK cleanup service 测试证明了 callback 按 slot 派发，但没有把 Runtime
容器 Operations 接到该服务上。因此它证明“SDK 提供了正确机制”，不证明当前
容器绑定已经使用该机制。

### 同仓库中的正确对照

Standalone 使用的 AngelScript `scriptarray` addon 具有高度相似的 per-type cache：

1. 为数组 type-info 创建 `SArrayCache`；
2. 使用专用 key `ARRAY_CACHE` 写入自定义 user-data slot；
3. 注册 `CleanupTypeInfoArrayCache`；
4. callback 从同一 slot 取出 cache，显式执行析构并释放内存。

这个对照确认，SDK 的设计预期是“附着者显式注册 slot cleanup”，而不是
`SetUserData` 自动取得内存所有权。

### 根因

直接原因是：四种 Operations 的 heap ownership 从未赋给任何对象；
`plainUserData` 被当成了 owning slot，但 SDK 实际把它定义成不透明的 borrowed
pointer slot。

更深层的架构原因是默认 `plainUserData` 同时承担多种语义：

- 容器/Optional 模板实例中保存 owning Operations；
- UObject、UStruct、delegate 等类型中保存 non-owning Unreal 对象指针或 tag；
- 热路径直接读取该字段以避免自定义 slot 查找和锁开销。

因此，不能简单为默认 key `0` 注册一个“见指针就 delete”的全局 callback；那会把
借用的 `UClass*` / `UStruct*` 等错误释放。缺陷本质上是“默认槽中的所有权类型没有
被编码”，而不仅是漏写一行 cleanup 注册。

SDK 引擎析构附近的注释还说明了历史背景：该 UE fork 过去默认引擎与进程同寿命，
模板实例 bucket 曾经也留到进程结束；现在 Standalone 和多引擎路径已经要求反复
创建/销毁引擎，SDK 侧模板 type-info 所有权已经补齐，但 Runtime 附着 payload 的
旧进程生命周期假设没有同步闭环。

### 后续设计必须满足的约束

本轮尚未选择修复结构；在用户确认是否纳入实现范围之前，只记录以下不可回避的
设计约束：

- Operations 必须随具体 type-info 销毁，而不只是随进程退出；
- 模板验证失败必须立即回收刚分配的 Operations；
- 模块重建、热重载和完整引擎销毁必须走同一所有权规则；
- 不得给所有默认 `plainUserData` 统一套用 `delete`；
- 容器方法的高频 Operations 读取不应无意引入全局引擎锁；
- cleanup 必须在 `FAngelscriptTypeUsage` 所依赖的 engine-owned 类型数据库仍有效时
  运行；
- 测试必须直接观察四类 Operations 的创建/销毁平衡，不能只依赖 MiB 级进程内存
  或 UObject 数量；
- 需要同时覆盖成功实例的 engine teardown，以及分配后验证失败的即时销毁路径。

### 新增源码锚点

- `Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp` 和 `.h`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.cpp`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_objecttype.cpp`
- `Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp`
- `Standalone/ThirdParty/AngelScriptAddons/scriptarray/scriptarray.cpp`

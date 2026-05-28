## Context

### 当前状态(代码事实,非推断)

1. **UHT 工具的输出形态**:`Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs:21-26` 的 `[UhtExporter]` 必须保留 `ModuleName = "AngelscriptRuntime"`、`CppFilters = ["AS_FunctionTable_*.cpp"]`。UE UHT 插件 exporter 不允许省略 `ModuleName`;同时 `UhtExportFactory.MakePath(...)` 在 `PluginModule != null` 时会强制使用插件模块 OutputDirectory,不能直接靠 `factory.MakePath(targetModule, ...)` 写入目标模块。当前 `AngelscriptFunctionTableCodeGenerator.cs:120` 因此把 *所有* shard 都落到 `AngelscriptRuntime` 的 OutputDirectory,shard 内容为 `FAngelscriptBinds::AddFunctionEntry(<Class>::StaticClass(), "Func", { ERASE_AUTO_METHOD_PTR(<Class>, Func), … })`,强依赖 `Core/AngelscriptBinds.h` 与 `Core/FunctionCallers.h`。`DeleteStaleOutputs` 同样仅 enumerate AngelscriptRuntime 自己的 output dir。
2. **跨模块未导出函数会被预先剔除**:`AngelscriptHeaderSignatureResolver.cs:109-117` `HasLinkableExport` 在"模块不是 AngelscriptRuntime 且函数没匹配 `<MODULE>_API` / `UE_API` / `RequiredAPI` / `inline` / `FORCEINLINE` / `constexpr`、且类不是 `MinimalAPI` 也没 API 宏"时,把候选打成 `unexported-symbol`。`AngelscriptFunctionTableCodeGenerator.cs:482-489` 该候选退化为 `ERASE_NO_FUNCTION()` stub,运行时由 `Bind_BlueprintCallable.cpp:178-197` 走 `BindBlueprintCallableReflectionFallback` 反射路径。`AS_FunctionTable_SkippedReasonSummary.csv` 中 `unexported-symbol` 一行就是这部分被 stub 化的函数。
3. **反射 fallback 性能基线**:`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp:96-105` 注释自陈,即使开启 `as.ReflectiveFallback.UseCache=1`(默认)使用 `FReflectiveParamCache + FFrame + UFunction::Invoke` 路径,也比直绑 `asCALL_THISCALL` 慢 3-6×;关闭缓存时退到 legacy `ProcessEvent` 路径,慢更多。**重要事实**:cached 路径明确说"with FUNC_Net branch",反射路径**保留 RPC 路由**;直绑路径会绕过该路由,因此 RPC 函数必须继续走反射(见 D-RPC-Skip)。
4. **Verse 在引擎内的同形方案**:`Engine/Source/Runtime/CoreUObject/Public/VerseVM/VVMVerseClass.h::FVerseCallableThunk = { const char* NameUTF8; Verse::VNativeFunction::FThunkFn Pointer; }`。Phase 1 调研补充:Verse 的会合点其实是 **CoreUObject 中的 `COREUOBJECT_API RegisterVerseCallableThunks(UClass*, FVerseCallableThunk*, uint32)`**(在 `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMUECodeGen.cpp`)。每个引擎模块的 `<Class>.gen.cpp` 在 `StaticRegisterNatives()` 里调一次,把 thunk 表写到 `UVerseClass::VerseCallableThunks` 成员;Verse VM 加载时反查 UClass 元数据并填回 `VNativeFunction::Thunk`。**关键洞察:跨模块的关键不是"把 emit cpp 放到目标模块",而是"会合点在引擎模块本就 link 的位置"**。
5. **AngelscriptRuntime 的现有依赖**(`AngelscriptRuntime.Build.cs:33-66`):已 link `Engine`、`CoreUObject`、`Core`、`SlateCore`、`UMG`、`AIModule`、`NavigationSystem`、`GameplayTags` 等(为 manual binds 与反射 fallback 服务)。**本 change 的硬约束:不再新增任何引擎模块依赖**(尤其禁止反向 link RenderCore、PhysicsCore、HairStrandsCore 等任意 BlueprintCallable 出现在的模块)。
6. **`IModularFeatures`**(`Engine/Source/Runtime/Core/Public/Features/IModularFeatures.h`):UE 现成的"字符串 ID 中央注册表",在 Core,所有引擎模块与 AngelscriptRuntime 本就 link Core。提供 `RegisterModularFeature(FName, IModularFeature*)` / `GetModularFeatureImplementations(FName)` / `OnModularFeatureRegistered` 委托,但 UE 5.7 没有全局 `IModularFeatures::IsAvailable()`。`IModularFeature` 当前是空接口,没有虚析构/虚方法,因此 reader layout 不包含 vtable padding;feature 实例仍统一采用显式 ctor,把 constructor-only 作为生成物不变量。`OnModularFeatureRegistered` 委托不保证在 GameThread 触发。
7. **`Bind_BlueprintCallable.cpp:324`** 注释明确"AS Engine register half (must run on GameThread)"。所有写入 `ClassFuncMaps` / 调用 `BindMethodDirect` 的代码路径都必须在 GameThread。

### 约束

- 不可修改引擎源码;所有改动在 `Plugins/Angelscript/` 内。
- **AngelscriptRuntime 不新增任何引擎模块依赖** — 跨模块边界只穿过 `IModularFeatures`(Core 已有)和 POD 数据,不通过 link 解析任何"在引擎模块内定义的符号"。
- 引擎模块不能反向依赖 `AngelscriptRuntime`,因此跨模块 emit 的 cpp 不可 `#include "Core/AngelscriptBinds.h"`、不可使用 `FAngelscriptBinds::AddFunctionEntry` / `ASAutoCaller` / `FGenericFuncPtr` / PMF 这类强类型形态,**也不可 include AS SDK 头(`angelscript.h`)** — 后者依赖 `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/...` 的 include path,引擎模块的 build.cs 无该路径,引入即等同于改引擎 build 配置。
- 必须保留 Launcher / 不重编引擎用户的运行链路,即现有 `BlueprintCallableReflectiveFallback` 在该路径不可用时无缝兜底。
- **必须保留所有 `FunctionFlags & (FUNC_Net|FUNC_NetServer|FUNC_NetClient|FUNC_NetMulticast)` 的 RPC 路由**:这些函数继续走反射 fallback,绝不 emit 到 cross-module direct bind。
- 必须保留 `AS_FunctionTable_*.cpp` 文件名前缀(本身已不被引擎 `CodeGen` exporter 的 `CppFilters` 模式 `*.generated.cpp` / `*.generated.*.cpp` / `*.gen.cpp` / `*.gen.*.cpp` 命中,跨模块 emit 不会被 `CullOutput` 误删 — 这是本方案能在引擎模块 OutputDirectory 落地的关键依据)。

## Goals / Non-Goals

**Goals:**
- 把今天因"跨模块 + 无 API 宏"而被打成 `ERASE_NO_FUNCTION()` 的 *非 RPC 且安全签名* `BlueprintCallable`/`BlueprintPure` UFunction,迁移到与 AngelscriptRuntime 模块内函数同样的"直绑"路径,跳过反射 fallback。
- **跨模块中央会合点用 `IModularFeatures`**:每个引擎模块 emit 的 cpp 在 DLL 加载时静态构造把一个 POD-payload feature 注册到 `IModularFeatures`,字符串 ID `"AngelscriptCrossModuleBindings"`;AS Runtime 在 `EOrder::Late + 60` 阶段 `GetModularFeatureImplementations` 一次性拉取,**完全不 link 任何引擎模块**。
- **Modular(Editor)与 Monolithic(Shipping)设计同路径**:`IModularFeatures` 不依赖 PE 导出表,设计上适用于两种 build 配置。当前 change 的验证边界是 source-build Development Editor；Monolithic Shipping 与 Launcher 安装引擎烟测作为后续 release-hardening 矩阵。Launcher / 不重编引擎用户的目标模块根本没编出 cross-module shard,运行时拉空,反射 fallback 兜底。
- **Thunk raw 形态,emit cpp 不 include AS SDK**:thunk 签名 `void(*)(UObject* Self, void** Args, void* Ret)`,emit cpp 仅 include `Features/IModularFeatures.h` 与目标类头;asIScriptGeneric ↔ raw 缓冲区桥接由 AS Runtime 端单一通用 generic hook 完成。
- **覆盖安全 UFunction 子集**:本次自动 emit 限定在无需额外 BPVM 写回协议的安全签名。返回支持 `void`、bool/numeric/enum/struct、`FString`、`FName`、`FText`、`UObject*`;参数支持 bool/numeric/enum/struct、`FString`、`FName`、`FText`、`UObject*`、`UClass*`、soft object、weak object。out-param、WorldContextObject、ref-return、static arrays 与 `TArray/TSet/TMap` 容器显式 deferred。
- **三道 ABI 防护**:编译期 `static_assert(sizeof(...))` + runtime `LayoutVersion` magic + null/range 校验;`LayoutVersion` 由 `cross-module-layout-version.txt` 单 token 文件管理,generator 与 AS Runtime 公共头共用,bump 规则成文。
- **Shutdown 时序安全**:`~FAutoReg()` 与 AS Runtime `OnPreExit` 都使用 shutdown flag 兜底,绝不在 Core 单例销毁后 dereference `IModularFeatures::Get()`。
- **回调线程安全**:`OnModularFeatureRegistered` 回调 marshal 到 GameThread 后再写 `ClassFuncMaps` / 调 `BindMethodDirect`。
- 在 Day-0 用最小 probe 验证 (i) UBT 是否会自动纳编"目标模块 OutputDirectory 下额外 `AS_FunctionTable_<Module>_CrossModule_*.cpp`"、(ii) 引擎模块静态构造期 `IModularFeatures::Get()` 已就绪、(iii) AS Runtime 端 `GetModularFeatureImplementations` 在 Late+60 阶段能拉到;任一项失败即 STOP,本 change 整体作废。

**Non-Goals:**
- **不**改造 `UASFunction` 内部 dispatch、StaticJIT、AngelScript JIT 入口 — 这些由 `uasfunction-runtime-dispatch-coverage`、`uasfunction-dispatch-matrix-and-jit-paths` spec 单独覆盖。
- **不**改 `BlueprintCallableReflectiveFallback` 内部逻辑;它仍然作为 RPC/Net 函数、Launcher 路径、"目标模块未 emit"时的安全网。
- **不**让 RPC/Net 函数走 cross-module direct bind — 反射 fallback 是 RPC 路由的唯一正确通道。
- **不**新增 `UFUNCTION` 标签或 meta 扩展;沿用现有 `BlueprintCallable`/`BlueprintPure` + `NotInAngelscript`/`BlueprintInternalUseOnly` skip 规则,不增加用户侧负担。
- **不**触及 PMF / `FGenericFuncPtr` 跨模块传递。所有跨模块边界只过 raw thunk 函数指针和 POD 字段。
- **不**让 emit cpp include 任何 AS Runtime / AS SDK 头(包括 `angelscript.h`)。
- **不**给 `AngelscriptRuntime.Build.cs` 增加任何引擎模块依赖。

## Decisions

### D1: 用 UHT 跨模块 emit 而不是引擎源码改造

**选择**:UHT C# 插件保留 `ModuleName="AngelscriptRuntime"`,same-module shard 继续用 plugin factory 默认路径;cross-module shard 使用目标 `UhtModule.Module.OutputDirectory` 绝对路径并通过 `factory.CommitOutput(...)` 写入。Day-0 probe 必须先证明这种跨目录输出会被 UBT 纳编进目标模块。

**为什么**:
- 不需要改引擎源码,与 AGENTS.md "AS 插件作为独立可复用插件"目标一致。
- 与 Verse 同形(emit 进函数所在模块)。
- UE UHT 插件 exporter 必须指定 `ModuleName`;且 `factory.MakePath(uhtModule, suffix)` 在 `PluginModule != null` 时会回落到插件模块 OutputDirectory,所以不能作为目标模块输出手段。

**未选**:
- 给所有目标 UFUNCTION 加 `<MODULE>_API` — 需要改引擎源码,违反约束。
- 在 AngelscriptRuntime 里手写跨模块 forwarder — 跨模块取地址在 link 阶段失败,正是当前 `unexported-symbol` 的根因,无法解决。

### D-IMF: 中央会合点 = `IModularFeatures` + POD payload

**选择**:每个引擎模块 emit 的 cpp 通过静态全局对象的构造函数,把一个 `IModularFeature` 派生类(只携带 POD 数据,无新增虚方法)注册到 `IModularFeatures::Get()`,字符串 ID `FName("AngelscriptCrossModuleBindings")`。AS Runtime 在 Late+60 调 `GetModularFeatureImplementations(...)` 一次性拉取,并在 `OnModularFeatureRegistered` 委托上挂回调处理后到模块。

**ABI 契约**(双端 layout 必须一致,由 generator 输出与 AS Runtime 公共头同步保证):

```cpp
struct FAngelscriptCrossModuleEntry
{
    const TCHAR* ClassName;
    const TCHAR* FunctionName;
    void (*Thunk)(class UObject* Self, void** Args, void* Ret);
    uint16  ArgCount;
    uint16  RetSize;     // 0 = void;非 0 = 字节大小,AS Runtime 据此分配 Ret 缓冲
    uint32  Flags;       // bit0 Static / bit1 Const / bit2 WorldContext / bit3 HasOutParams / 余位预留
};

struct FAngelscriptCrossModuleFeature : public IModularFeature
{
    const FAngelscriptCrossModuleEntry* Table;
    int32        Count;
    const TCHAR* ModuleName;
    uint32       LayoutVersion;

    FAngelscriptCrossModuleFeature(
        const FAngelscriptCrossModuleEntry* InTable,
        int32 InCount,
        const TCHAR* InModuleName,
        uint32 InLayoutVersion)
        : Table(InTable), Count(InCount), ModuleName(InModuleName), LayoutVersion(InLayoutVersion) {}
};
```

AS Runtime 端定义同 layout 的 reader 并 reinterpret_cast `IModularFeature*`。UE 5.7 的 `IModularFeature` 当前是空接口、非多态,reader 不包含 vtable padding;Day-0 probe 与后续 `static_assert` 负责在 Core 接口形态变化时先失败:

```cpp
struct FAngelscriptCrossModuleFeatureReader
{
    const FAngelscriptCrossModuleEntry*  Table;
    int32                                Count;
    const TCHAR*                         ModuleName;
    uint32                               LayoutVersion;
};
```

实例化必须用 ctor(见 D-Aggregate-Init):

```cpp
static const FAngelscriptCrossModuleEntry GTable[] = { /* ... */ };
static FAngelscriptCrossModuleFeature GFeature(
    GTable, UE_ARRAY_COUNT(GTable), TEXT("Engine"), 0xA5C0DE01u);
```

**为什么**:
- AS Runtime **零新引擎模块依赖**(`Features/IModularFeatures.h` 来自 Core,Core 已在依赖列表)。
- Modular / Monolithic 都工作 — IModularFeatures 不依赖 PE 导出表。
- 模块加载顺序无关 — 谁先静态构造谁先注册;后到模块由 `OnModularFeatureRegistered` 处理。
- 与 Verse 同形(中央会合点在 Core/CoreUObject;每个模块 emit cpp 在自己 OutputDirectory)。

**未选**:
- `FPlatformProcess::GetDllExport` 运行时符号查表 — Monolithic Shipping 通常 strip 导出符号,不能保证;user 选定 Shipping 必须直绑,排除单走 GetDllExport。
- `extern Get_AS_Bindings_<Module>` + Build.cs 加引擎模块 link — 反向依赖爆炸,user 在 review 时明确否决,**这是本次重写的根本起因**。

### D-Aggregate-Init: 派生类 ctor 而非 brace-init

**选择**:`FAngelscriptCrossModuleFeature` 必须显式声明 ctor,实例化用 `static FFeature GF(GTable, Count, TEXT("..."), 0xA5C0DE01u);`。即使 UE 5.7 的 `IModularFeature` 当前是空接口、技术上可聚合初始化,生成物仍固定采用 constructor-only 形态,让两端 layout 与实例化方式长期稳定。

**为什么**:constructor-only 是生成物不变量,避免未来 `IModularFeature` 变成多态/带析构时才暴露 brace-init 兼容问题。Phase 0 probe 与 ABI `static_assert` 负责在接口形态变化时先失败,而不是让运行时 reader 静默错位。

**未选**:
- C++20 `designated initializers` — 仍属于初始化风格分叉,不利于 generator/reader 双端保持单一不变量。
- `T = T(...)` copy-init — ctor 直接初始化更直白,无收益。

### D-Thunk: Thunk 签名 `void(*)(UObject*, void**, void*)`,asIScriptGeneric 桥接由 AS Runtime 通用 hook 完成

emit cpp 的 thunk 形态:

```cpp
static void Thunk_AActor_GetActorLocation(UObject* Self, void** /*Args*/, void* Ret) {
    *static_cast<FVector*>(Ret) = static_cast<const AActor*>(Self)->GetActorLocation();
}

static void Thunk_ACharacter_AddMovementInput(UObject* Self, void** Args, void* /*Ret*/) {
    FVector Dir   = *static_cast<FVector*>(Args[0]);
    float   Scale = *static_cast<float*>(Args[1]);
    bool    bForce= *static_cast<bool*>(Args[2]);
    static_cast<ACharacter*>(Self)->AddMovementInput(Dir, Scale, bForce);
}
```

AS Runtime 端:**所有 cross-module entry 共用同一个通用 generic hook** `static void GAngelscriptCrossModuleGenericHook(asIScriptGeneric* G)`,通过 AS user-data 携带 `FAngelscriptCrossModuleEntry` 指针;hook 内从 `G` 拿 Self 与各 arg 槽,写入 raw `void**` Args 数组、使用 AS 提供的返回槽(若 `RetSize > 0`)、调 `E.Thunk(Self, Args, Ret)`。当前 safe-scope 不自动 emit out-param / ref-return / WorldContext entry,因此没有额外 out-param writeback 协议。

**为什么**:
- emit cpp 只 include `Features/IModularFeatures.h`(Core)+ 目标类头,**不 include `angelscript.h`**(后者要求引擎模块 build.cs 加 AS SDK include path,违反"不改引擎"约束)。
- 比 D2 原版"emit cpp 直接接 asIScriptGeneric*"少一处 SDK 头依赖,代价是 AS Runtime 端多写一个通用 hook(50 行内可解决)。
- 比 PMF 跨模块传递更稳健:raw thunk 是普通 C 函数指针,跨 DLL ABI 完全等价。

**未选**(对比原 D2):
- `void(*)(asIScriptGeneric*)` 直接形态 — 见上,SDK 头依赖问题。
- 跨模块传 PMF 二进制位 — MSVC PMF 大小受多继承影响,跨 DLL 风险高于 raw 函数指针。

**Scope note**: static `ScriptMethod` functions and class-level `ScriptMixin` projections stay outside the automatic safe set. They project the first C++ parameter into script `this`; this change's raw thunk bridge does not yet inject that implicit object into `Args[0]`, so emitting them would call the target function with shifted arguments.

### D-Param-Marshal: 当前 safe-scope 的 thunk 解包契约

generator 必须按 `UhtFunction` 签名为下列 safe-scope 形态 emit 正确解包:

| 形态 | thunk 体 | AS Runtime 桥接 hook 行为 |
|---|---|---|
| **static 函数** | `Self == nullptr`;thunk 体走 `T::Func(...)` 而非 `static_cast<T*>(Self)->Func(...)` | hook 检测 `Flags & bit0 Static`,跳过 Self 提取;AS Runtime 注册时走 `BindGlobalFunction`(命名空间 = ClassName) |
| **`const` 修饰** | thunk 体走 `static_cast<const T*>(Self)->Func()` | AS Runtime 注册 method declaration 时附 `const`(`Flags & bit1 Const`) |
| **non-trivial 值参数/返回**(`FString` / `FName` / `FText` / struct) | `Args[i]` 是 AS generic 提供的槽地址;thunk 体按 `PassCrossModuleArg<T>` 解引用;非 trivial return 用 placement construction 写入 Ret | hook 端只转交 AS generic 槽地址,不自行管理复杂生命周期 |
| **object/class/soft/weak wrapper 参数** | `Args[i]` 按已解析 C++ 类型解引用后传入目标函数 | hook 端只转交 AS generic 槽地址 |
| **UENUM 标签** | `Args[i]` 按底层宽度(uint8 / int32 / uint64);thunk 体 `static_cast<EnumType>(*static_cast<UnderlyingType*>(Args[i]))` | hook 端按底层宽度槽位写入 |

`Flags` 位定义:`bit0 Static`、`bit1 Const`、`bit2 WorldContext`、`bit3 HasOutParams`、`bit4 ReturnByRef`(若 UFunction 返回引用,Ret 是指向真值的指针),其余预留。

**为什么**:safe-scope 优先关闭跨模块链接边界与基础 raw thunk 桥接,避免在未建立完整 BPVM writeback / WorldContext 注入协议前把复杂形态直接切到 direct path。out-param、WorldContext、ref-return、static arrays 与 `TArray/TSet/TMap` 容器保留为后续 change。

### D-RPC-Skip: RPC / Net 函数继续走反射 fallback

**选择**:`AngelscriptFunctionTableCodeGenerator.ShouldGenerate` 与 `AngelscriptFunctionTableExporter.IsBlueprintCallable` 增加判定:`function.FunctionFlags` 中含 `Net` / `NetServer` / `NetClient` / `NetMulticast` 任一,**直接 skip cross-module shard 路径,继续走原有反射 fallback**。`AS_FunctionTable_SkippedReasonSummary.csv` 记录 reason `rpc-net-function`。

**为什么**:`UFunction::Invoke` / `UObject::ProcessEvent` 内部按 `FUNC_Net` 路由 RPC(server-only / client-only / multicast / WithValidation 各分支)。raw thunk 直接 `static_cast<T*>(Self)->Func()` 会绕过这一切,**把"应 marshal 到对端、本地仅触发 stub"的语义变成"本地直接执行函数体"**,导致网络复制语义破坏。`BlueprintCallableReflectiveFallback.cpp:96-105` 注释明确该路径"with FUNC_Net branch",因此反射 fallback 是 RPC 路由的唯一正确通道。

**风险若不做**:Server-only 函数被客户端脚本调用时直接执行,绕过权威方校验;NetMulticast 不再多播;WithValidation 不再走验证 — 严重的 *正确性* 漏洞,不是性能问题。

### D-LayoutBump: LayoutVersion 由 `cross-module-layout-version.txt` 单 token 管理

**选择**:新增 `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt`,文件内容仅一行 `0xA5C0DE01`(或类似 32-bit hex)。generator C# 启动时读该文件,emit cpp 与 AS Runtime 公共头都从该值生成 / 引用。**任何对 `FAngelscriptCrossModuleEntry` POD 段、`FAngelscriptCrossModuleFeature` POD 段的 add/remove/reorder/widen/narrow 字段 MUST bump 该文件中的值**(自增 / 修订)。

**bump 触发条件**(必须在文件顶部注释里写明):
- 增删 POD 字段
- 调整字段顺序
- 改变字段宽度(int32 ↔ int64 / uint16 ↔ uint32)
- 改变字段语义(同名同类型但 Flags 含义变化)
- AS Runtime reader 与 emit cpp 任一端单方面修改

**为什么**:Magic 字段最容易"忘记 bump"。把它做成 generator 与 runtime 都强制读的单一文件 → 修改其中一端的 layout 时不更新此文件 → CI 上 `static_assert(sizeof) == EXPECTED` 失败;更新此文件但忘了同步 layout → runtime 校验 reject 所有 features → coverage 测试失败。这两条路径共同把"layout 漂移"抓在 cold-start。

**未选**:
- 让 generator 用 `MD5(struct text)` 自动算 — 自动化太智能,人工调 layout 时反而难追。
- 写到 Build.cs 的 PublicDefinitions — Build.cs 与 generator 有时序差,文件 token 更稳。

### D3: 文件名沿用 `AS_FunctionTable_*` 前缀

跨模块输出命名:`AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp`(`NNN` 由 `MaxEntriesPerShard = 256` 分片产生,与现有 shard 化策略复用)。

**为什么**:
- 引擎 `CodeGen` exporter 的 `CppFilters` 是 `*.generated.cpp / *.generated.*.cpp / *.gen.cpp / *.gen.*.cpp`,`AS_FunctionTable_*` 不命中,**不会被 `CullOutput` 删除**。
- 沿用 `AngelscriptFunctionTableExporter` 自己的 `CppFilters = ["AS_FunctionTable_*.cpp"]`,保持本 exporter 对自己输出物的清理边界一致。

### D-MultiShardSameModule: 同模块多 shard = 多个 feature 实例

**选择**:大模块按 `MaxEntriesPerShard = 256` 分片,每个 shard 文件有自己的 anonymous `GFeature` + `GAutoReg`;**同一引擎模块在 IModularFeatures 注册表中会出现 N 条同名(`"AngelscriptCrossModuleBindings"`)feature 实例**。AS Runtime 按 *feature 实例* 迭代 `GetModularFeatureImplementations` 返回的数组,而不是按 ModuleName 去重。`ModuleName` 字段仅用于诊断日志,允许同名重复。

**为什么**:`IModularFeatures` 本就支持同字符串 ID 多 implementor;反过来若让同模块 shard 共享单一全局对象,需要跨 TU 引用,引入 `extern` 又破坏 anonymous-namespace 隔离,得不偿失。多实例方案更直接。

**风险**:如果某 entry 在两个 shard 里 *都* 出现(generator bug),Late+60 第二次写时被 D4 优先级规则挡住,行为退化但不崩。回归测试 2.4 已守住该不变量。

### D4: AngelscriptRuntime 端的注入阶段选 `EOrder::Late + 60`

现有 shard 在 `EOrder::Late + 50` 注入(`AngelscriptFunctionTableCodeGenerator.cs:306`)。新增 `Bind_CrossModuleDirect.cpp` 选 `EOrder::Late + 60`,**晚于 module 内 shard,确保 ClassFuncMaps 已基本就绪**;同时早于 `Bind_BlueprintCallable.cpp` 真正消费 entry 的阶段。

**为什么**:
- 直绑表先于 `Bind_BlueprintCallable.cpp` 消费,`Entry->FuncPtr.IsBound()` 判定时即可见,跳过 fallback。
- 同名条目优先级:同模块内 shard(Late+50)若已写入直绑指针,跨模块表(Late+60)发现 `Entry->FuncPtr.IsBound()==true` 时 **不覆盖**,只补缺;这套优先级与 `FAngelscriptBinds::AddFunctionEntry` 已有"map 中存在则不覆盖"语义一致。
- 同模块多个 cross-module feature(D-MultiShardSameModule)按 `GetModularFeatureImplementations` 返回顺序处理,先到先绑,后到不覆盖。

### D5: HasLinkableExport 收敛为只过滤"真不可达"

**改后**:
- `Private/` 头继续 skip(原逻辑保留)。
- `CustomThunk` 继续 skip(原逻辑保留)。
- `Interface`/`NativeInterface` 继续 emit stub(原逻辑保留,`Bind_BlueprintCallable` 用 `CallInterfaceMethod` 走 `FindFunction + ProcessEvent`)。
- **新增 `FUNC_Net` 类 skip**:见 D-RPC-Skip。
- **去掉**"跨模块 + 无 API 宏 → unexported-symbol"判定 — 因为新 emit 路径不再依赖跨模块取地址。
- 新增"目标模块未在 supported modules 列表中" → emit stub(实际等价于反射 fallback,语义不变)。

### D-StaleCleanup: stale shard 清理跨所有 supported module

**选择**:`AngelscriptFunctionTableCodeGenerator.DeleteStaleOutputs` 改为 enumerate **所有 supported module 的 OutputDirectory**(由 `LoadSupportedModules` 已有列表驱动),清理每个目录下匹配 `AS_FunctionTable_<Module>_CrossModule_*.cpp` 但不在本次 generated set 中的旧文件。

**为什么**:某函数被加 `NotInAngelscript` / 移走 / 改签名后,旧 cross-module shard 不删 → UBT 仍编它 → 该 entry 二次定义 / 命名冲突 / 链接错误。原 `DeleteStaleOutputs` 只看 AngelscriptRuntime 自己的 dir,跨模块场景下 100% 漏。

**实现要点**:`generatedPaths` 集合需按 module 分组;清理时按目标模块分别 enumerate;AngelscriptRuntime 自己的 dir 仍按现有逻辑清。

### D-ShutdownOrder: DLL 卸载与 IModularFeatures 单例销毁的安全协议

**选择**:
- emit cpp 通过 `FCoreDelegates::OnPreExit` 设置本 TU 的 shutdown flag;`~FAutoReg()` 若看到 shutdown flag 为 true 则 no-op,否则执行正常 `UnregisterModularFeature`。
- AS Runtime `Bind_CrossModuleDirect.cpp` 在 `FCoreDelegates::OnPreExit.AddStatic(&Unsubscribe)` 中提前移除 `OnModularFeatureRegistered` 订阅,防止 Core 单例销毁后回调触发。

**为什么**:`IModularFeatures` 是 Meyers singleton;跨 DLL 的 Meyers singleton 析构顺序未定义。若 Core 内单例先销毁、引擎模块后卸载,引擎模块 `~FAutoReg` 调 `Get()` 解引用就崩。

**风险若不做**:Editor 退出 / 项目切换 / hot reload 时偶发 crash,极难 root-cause。

### D-OnModularFeatureRegisteredThread: 回调 marshal 到 GameThread

**选择**:AS Runtime 订阅的 `OnModularFeatureRegistered` 回调内,**绝不在调用线程上直接写 `ClassFuncMaps` 或调 `BindMethodDirect`**;而是 `AsyncTask(ENamedThreads::GameThread, [Feature](){ /* 实际处理 */ });`。

**为什么**:UE 不保证该委托在 GameThread 触发;动态加载 plugin / 后台 thread 的 `RegisterModularFeature` 都会触发回调。`Bind_BlueprintCallable.cpp:324` 注释已明确"AS Engine register half (must run on GameThread)"。

**风险若不做**:偶发 race condition,`ClassFuncMaps` map mutation 与 BPVM 读 race;`BindMethodDirect` 在非 GameThread 调可能直接撞 AS Engine 内部 assert。

### D7: Day-0 probe 是 STOP 门禁

第一项任务必须先在 Engine 模块手写一份最小 IModularFeatures self-register cpp(不经 generator),并在 AngelscriptRuntime 加一个 headless 单测,验证:

1. UBT 是否自动把目标模块 OutputDirectory 下额外的 `AS_FunctionTable_*_LinkProbe.cpp` 纳入该模块编译;
2. 引擎模块静态构造期 `IModularFeatures::Get()` 已就绪、`RegisterModularFeature` 调用成功;
3. AngelscriptRuntime 在 `EOrder::Late + 60` 调 `GetModularFeatureImplementations` 能拿到这个 probe feature。

**任一项失败即 STOP,proposal 整体作废,绝不绕路**。

## Risks / Trade-offs

| 风险 | 影响 | Mitigation |
|---|---|---|
| **R1**:UBT 不自动纳编目标模块 OutputDirectory 下的 `AS_FunctionTable_*_CrossModule_*.cpp` | 整个方案作废 | Day-0 probe(D7),失败即 STOP;不试图绕路用 `AddCustomCppFile` 等内部 API |
| **R2**:`asCALL_GENERIC` + raw thunk 比 `asCALL_THISCALL` 慢 | 直绑收益缩水 | 必须在 `TestPerformance.md` micro-bench 量化,设最低收益门槛(具体阈值在 tasks 阶段量产基线后定);未达阈值则保留方案,但作为后续"thiscall 升级"的目标 |
| **R3**:UHT 插件改动触发引擎模块全量重编 | 开发体验变差 | 严格遵循 `SaveIfChanged` — generator 输出已按 ClassName/FunctionName Ordinal 排序、无时间戳;新加的 cross-module shard 同样保持稳定排序;tasks.md 明确禁止把 `DateTime.Now` 等不稳定字段写进 emit |
| **R-FUNC_Net**:RPC / Net 函数误走直绑 | 网络复制语义破坏(Server-only 在客户端执行 / NetMulticast 不多播 / WithValidation 不验证) | D-RPC-Skip:generator `ShouldGenerate` 显式过滤 `FUNC_Net|FUNC_NetServer|FUNC_NetClient|FUNC_NetMulticast`;`AS_FunctionTable_SkippedReasonSummary.csv` 计数;当前 change 用生成端诊断测试守住,多端 RPC 行为测试留给后续网络矩阵 |
| **R-AggregateInit**:`static FFeature GF = { ... }` 编译不过 | Phase 0 probe 撞墙 | D-Aggregate-Init:所有示例代码 / generator emit 模板用 ctor 形态;静态扫描测试断言 emit cpp 中无 `= { GTable,` 等 brace-aggregate-init 残留 |
| **R-Layout**(原 R7 升级):双端 `FAngelscriptCrossModuleEntry` / `FAngelscriptCrossModuleFeature` layout 漂移 | 拉到错误指针、crash 风险 | D-LayoutBump:`cross-module-layout-version.txt` 单 token 文件;三道防线:(a) 编译期 `static_assert(sizeof)` 双端等价;(b) `LayoutVersion` magic 不一致即 runtime warn + skip;(c) null/range 校验。字段全用指针/int32/uint32,禁止 `bool`/`uint8`。derived class 禁止后续加新虚方法 |
| **R-StaticInitFiasco**:静态构造期 `IModularFeatures::Get()` 是否就绪 | 引擎模块 DLL 加载即崩 | `IModularFeatures` 在 Core,Core 早于一切引擎模块加载,理论安全;由 Day-0 probe 实证 |
| **R-OnModularFeatureRegistered-Timing**:Late+60 之后才加载的模块 entries 丢失 | 部分 UFunction 进不到 ClassFuncMaps | D-LateRegister:订阅 `OnModularFeatureRegistered`,收到回调时走与 Late+60 完全一致的路径 |
| **R-OnModularFeatureRegisteredThread**:回调在 worker thread 触发 | 与 BPVM / AS Engine 并发写 race;`ClassFuncMaps` 数据竞争 | D-OnModularFeatureRegisteredThread:回调 `AsyncTask(ENamedThreads::GameThread, ...)` marshal;Phase 3 加 worker-thread 触发 register 的并发回归测试 |
| **R-ShutdownOrder**:DLL 卸载时 `IModularFeatures` 单例已销毁 | Editor 退出 / hot reload 偶发 crash | D-ShutdownOrder:`OnPreExit` 设置 shutdown flag + 主动 unsubscribe;Phase 5 加 graceful shutdown 测试 |
| **R-StaleShardCleanup**:`DeleteStaleOutputs` 不覆盖跨模块 dir | 旧 shard 残留 → 重复定义 link error | D-StaleCleanup:扩展 enumerate 到所有 supported module;Phase 2 加专门 task 覆盖;增量 build 回归测试断言旧 shard 自动清 |
| **R-MultiShardSameModule**:同模块多个 feature 实例处理顺序错乱 | 重复绑定 / 无效覆盖 | D-MultiShardSameModule:AS Runtime 按 feature 实例迭代,D4 优先级规则保护;Phase 2 加多 shard 测试 |
| **R5**:Hot-reload 改动引擎模块 .h 触发重 emit | 影响开发循环 | 跨模块 emit 内容稳定排序 + `SaveIfChanged` 保护;hot reload 路径仍走反射 fallback,与现状一致 |
| **R6**:跨模块表与同模块 shard 同名条目冲突 | 重复绑定 / 覆盖错误 | D4 优先级规则:同模块 shard 先到,Late+60 仅补缺,不覆盖;通过单元测试断言 |

(原 R4 "目标模块未启用编译时 extern 解析失败 → link error" **已删除** — 新机制下根本不存在 link 步骤,目标模块没编出 cross-module shard 时 `IModularFeatures` 自然拉空,行为退化到反射 fallback,自然落地。)

## Migration Plan

1. **Phase 0**(Day-0 probe):新增最小 IModularFeatures self-register probe → 三项验证全过 → 解锁后续工作;任一项不通过 → STOP,提交 `Documents/Reports/CrossModuleLinkProbe_<Date>.md` 记录失败原因并归档 change。同时确认 shutdown 兜底采用 `OnPreExit` flag + 析构 no-op 形态。
2. **Phase 1**(ABI 与公共头):新增 `cross-module-layout-version.txt`、`AngelscriptCrossModuleBindings.h`(POD layout、reader、`LayoutVersionExpected`、ctor、`static_assert`)、`Bind_CrossModuleDirect.cpp` 骨架(通用 generic hook + `OnModularFeatureRegistered` 订阅 + GameThread marshal + `OnPreExit` unsubscribe),用 safe-scope entry 跑通 raw thunk bridge。
3. **Phase 2**(UHT 自动化):改造 `AngelscriptFunctionTableExporter` / `AngelscriptHeaderSignatureResolver` / `AngelscriptFunctionTableCodeGenerator`,把 safe-scope "unexported-symbol" 路径迁移到自动 cross-module emit(IModularFeatures 自注册形态 + raw thunk + POD 表 + ctor 实例化);新增 RPC/Net skip 与 reason 统计;`DeleteStaleOutputs` 扩展跨模块清理。
4. **Phase 3**(测试):新增 `Angelscript.CppTests.UHTToolResolver.*` 一组 resolver/runtime 边界测试,覆盖 probe、public header、ABI 三道防线、generic hook、`OnModularFeatureRegistered` 后到模块、worker-thread 注册并发安全、同模块多 feature 不去重与生成物 diagnostics。
5. **Phase 4**(后续):Bindings CQTest、复杂参数 marshal、RPC 多端行为、Monolithic/Launcher/full suite、micro-bench、`BindGapAuditMatrix.md` 与 `TestPerformance.md` 数字刷新进入后续 hardening changes。
6. **Phase 5**(收尾):OpenSpec validate、维护文档更新、review notes 准备。

**Rollback**:本 change 全部代码以"新增 + UHT 改造"形式落地。回滚通过(a) 还原 `AngelscriptHeaderSignatureResolver.HasLinkableExport`、(b) 还原 `AngelscriptFunctionTableExporter.Export` 单点输出、(c) 移除 `Bind_CrossModuleDirect.cpp`、`AngelscriptCrossModuleBindings.h`、`cross-module-layout-version.txt`、(d) 还原 `DeleteStaleOutputs` 单 dir 范围 四步即可,运行时回到现有反射 fallback,不破坏 ABI。

## Open Questions

- **Q1**:Cross-module shard 的 include 集合最小化策略 — 是直接 include `<Class>.h` 还是更精细化(避免 PCH 膨胀)?在 Phase 1 端到端跑通后给出测量值,Phase 2 generator 实现前敲定。
- **Q3**:`asCALL_GENERIC` + raw thunk 性能未达预期时,thiscall 直绑升级的范围阈值 — 同模块直绑路径能否复用现 shard,而仅对 cross-module 引入第二张表?Phase 4 micro-bench 出数后定。
- **Q-ShutdownIdiom**:Phase 0 probe 采用的 `OnPreExit` shutdown flag 是否足以覆盖 Editor 退出 / DLL unload 顺序?若实测仍有卸载顺序问题,后续 runtime reader 只能保守 no-op 并依赖进程退出释放,不能引入不存在的 `IModularFeatures::IsAvailable()`。

(原 Q2 "Launcher 路径下 extern 跳过的具体宏形态" **已关闭** — `IModularFeatures` 路径不依赖编译期宏,目标模块未编出 cross-module shard 时自然没有 feature 注册,运行时拉空,反射 fallback 兜底,无需额外宏开关。)

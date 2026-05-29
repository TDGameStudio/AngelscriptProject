# Tasks — improve-as-direct-bind-coverage

> Authoritative implementation plan for this change. `tasks.md` is the only plan; do not write a separate plan file.
>
> Verification entry points (per `Documents/Guides/Build.md` and `Documents/Guides/Test.md`):
> - Build: `Tools\RunBuild.ps1 -SerializeByEngine -NoXGE`
> - Targeted tests: `Tools\RunTests.ps1 -TestPrefix "<AutomationPrefix>" -Label <short-label> -TimeoutMs 600000`
> - Legacy snippets in older task text may still mention `-Group ... -Filter ...`; use the equivalent `-TestPrefix` form.
> - Suite: `Tools\RunTestSuite.ps1 -Suite Default`
> - State dump: console `as.DumpEngineState`,or programmatic `FAngelscriptStateDump::DumpAll()`

## 0. Phase 0 — Day-0 IModularFeatures Probe (STOP-on-fail)

> 这一阶段是本 change 的二元门禁。**probe 任一项不通过即 STOP**,不进入后续阶段。失败时把现象与构建/链接器输出归档到 `Documents/Reports/CrossModuleLinkProbe_<Date>.md` 并把 change 标记为 abandoned。
>
> 本阶段同时验证四件事:(i) 插件 UHT exporter 保留 `ModuleName="AngelscriptRuntime"` 时,使用目标模块 `OutputDirectory` 绝对路径 `CommitOutput(...)` 生成的额外 `AS_FunctionTable_*_LinkProbe.cpp` 是否会被 UBT 自动纳编到目标模块;(ii) 引擎模块静态构造期 `IModularFeatures::Get()` 已就绪、`RegisterModularFeature` 调用成功;(iii) AS Runtime 端 `EOrder::Late + 60` 调 `GetModularFeatureImplementations(...)` 能拿到 probe feature;(iv) UE 5.7 没有 `IModularFeatures::IsAvailable()` 时,Shutdown 兜底采用 `OnPreExit` flag + 析构 no-op 的可行性。

- [x] 0.1 <!-- Non-TDD --> 在 `Plugins/Angelscript/Source/AngelscriptUHTTool/` 增加 probe 生成逻辑,并入现有 `AngelscriptFunctionTableExporter` 的同一次输出集合,保留 `[UhtExporter(..., ModuleName = "AngelscriptRuntime", Options = CompileOutput, CppFilters = ["AS_FunctionTable_*.cpp"])]`,只对 `Engine` 模块通过 `Path.Combine(engineModule.Module.OutputDirectory, "AS_FunctionTable_Engine_LinkProbe.cpp")` + `factory.CommitOutput(...)` emit 一份内容固定的最小 cpp。**禁止用 `factory.MakePath(engineModule, ...)` 作为验收路径,因为 UE UHT 插件 factory 在 `PluginModule != null` 时会强制回到插件模块 OutputDirectory;也禁止做独立同过滤器 exporter,避免 UHT cull 在不同 exporter 之间互删 `AS_FunctionTable_*.cpp`。** 文件内容(全部 anonymous 命名空间):
  - `#include "Features/IModularFeatures.h"`
  - 内嵌一个最小 `struct FProbeEntry { const TCHAR* Tag; uint32 Magic; };` 与一个最小 `struct FProbeFeature : public IModularFeature { const FProbeEntry* Entries; int32 Count; const TCHAR* ModuleName; uint32 LayoutVersion; FProbeFeature(const FProbeEntry* E, int32 C, const TCHAR* M, uint32 V) : Entries(E), Count(C), ModuleName(M), LayoutVersion(V) {} };`(**ctor 实例化,不走 brace-aggregate-init;UE 5.7 的 IModularFeature 是空接口,reader 不包含 vtable padding**)。
  - `static const FProbeEntry GProbeTable[] = { { TEXT("Engine.Probe"), 0xA5C0DE01u } };`
  - `static FProbeFeature GProbeFeature(GProbeTable, 1, TEXT("Engine"), 0xA5C0DE01u);`
  - 一个静态构造对象在 ctor 里 `IModularFeatures::Get().RegisterModularFeature(FName("AngelscriptCrossModuleLinkProbe"), &GProbeFeature)`,在 dtor 里 `Unregister`(注意 dtor 调用前的 Shutdown 兜底,见 0.4)。
  - 文件名前缀沿用 `AS_FunctionTable_*` 以避免被引擎 `CodeGen` exporter 的 `CullOutput` 命中。
  - 验证:无需测试,只看构建产物路径。预期 `Engine/Intermediate/Build/.../Engine/AS_FunctionTable_Engine_LinkProbe.cpp` 出现,且不出现在 `AngelscriptRuntime` 的 OutputDirectory;`Tools\RunBuild.ps1 -Target Editor`(若 source-layout wrapper 仍未修,使用已验证的 Engine `Build.bat` 等价命令并在报告中注明)能编过,说明目标模块绝对路径输出 + UBT 纳编 + ctor 形态合法。
  - 失败模式:`AS_FunctionTable_Engine_LinkProbe.cpp` 实际落到 `AngelscriptRuntime` 输出目录、UBT 报"unknown source file"或 link 后该 cpp 不在 Engine.dll/.lib 中 → STOP,记录失败到 `Documents/Reports/CrossModuleLinkProbe_<Date>.md`,abandon change。**brace-aggregate-init 编译错误 (`cannot use a brace-enclosed initializer ...`) → 不 STOP,但说明文档示例有误,改 ctor 形态再试**。

- [x] 0.2 <!-- TDD --> 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Probe/AngelscriptCrossModuleLinkProbe.cpp` 中:
  - `#include "Features/IModularFeatures.h"`
  - 写一个 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 单元 `Angelscript.CppTests.UHTToolResolver.LinkProbe.IModularFeaturesRoundtrip`,在测试体内调 `IModularFeatures::Get().GetModularFeatureImplementations(FName("AngelscriptCrossModuleLinkProbe"))`,断言:(a) 数组非空;(b) 第一个 `IModularFeature*` 通过 reinterpret_cast 到本测试中重定义的 reader struct(layout 与 0.1 完全一致,无 vtable padding),`Reader->LayoutVersion == 0xA5C0DE01u`、`Reader->Count == 1`、`Reader->Entries[0].Magic == 0xA5C0DE01u`、`FString(Reader->ModuleName) == TEXT("Engine")`。
  - 把测试纳入 `Group=Cpp`。
  - **关键失败模式**(任一即 STOP):
    - 0.1 的 cpp link 失败(`unresolved external` / "no source file" 等)→ STOP。
    - 测试 PASS 但数组为空 → IModularFeatures 注册时序异常,STOP 调研根因。
    - reinterpret_cast 后 LayoutVersion 错乱 → POD layout 跨 DLL 不稳定,STOP。
  - 命令:`Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.LinkProbe.IModularFeaturesRoundtrip"`。
  - 通过条件:测试 PASS 且 `Reader->LayoutVersion == 0xA5C0DE01u`。这是后续阶段的前置条件。

- [x] 0.3 <!-- Non-TDD --> 把 0.1/0.2 的 probe 留作日后 regression(不删,让它一直跟着 UHT exporter 跑),以保证 UE 升级 / Core 重构 / IModularFeature 形态变化不会突然破坏跨模块纳编与注册机制。

- [x] 0.4 <!-- Non-TDD --> 调研 `IModularFeatures` 的 shutdown 兜底 idiom(对应 spec 的 Open Question `Q-IsAvailable`):
  - 在 UE 5.7 的 `Features/IModularFeatures.h` 与相关源中确认:当前没有 `IModularFeatures::IsAvailable()`。
  - 选定默认形态:`FCoreDelegates::OnPreExit` 设置进程级 shutdown flag → AS Runtime 主动移除 `OnModularFeatureRegistered` 订阅 → emit cpp 的 `~FAutoReg` 若 flag 为 true 则 no-op,否则正常 `IModularFeatures::Get().UnregisterModularFeature(...)`。
  - 选定形态记录到 `Documents/Reports/CrossModuleShutdownIdiom_<Date>.md`,并在 1.x 实施时一致使用。
  - 验证:不进测试,只输出文档与决策。

## 1. Phase 1 — ABI 与公共头骨架(端到端最小手工示例)

> 本阶段不动 UHT 自动化,先用一个手写 cross-module shard 端到端跑通,确认 `IModularFeatures` + raw thunk + reinterpret_cast + ctor 实例化 + Shutdown 兜底 五件套在工程中正确落地。

- [x] 1.0 <!-- Non-TDD --> 新增 `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt`,内容仅一行 `0xA5C0DE01`(以及顶部多行注释列出"何时必须 bump"的规则)。bump 触发条件清单:
  - 增删 `FAngelscriptCrossModuleEntry` POD 字段
  - 调整字段顺序
  - 改变字段宽度(int32 ↔ int64 / uint16 ↔ uint32)
  - 改变字段语义(同名同类型但 `Flags` 含义变化)
  - AS Runtime reader 与 emit cpp 任一端单方面修改 layout
  - 验证:跑 `Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.LayoutVersionFile_SingleSource_*"`(下 1.6 测试)。

- [x] 1.1 <!-- Non-TDD --> 新增公共头 `Plugins/Angelscript/Source/AngelscriptRuntime/Public/UHT/AngelscriptCrossModuleBindings.h`。仅包含:
  - `#include "Features/IModularFeatures.h"`(由 AS Runtime 端 `Bind_CrossModuleDirect.cpp` include 时也用)
  - `class UObject;` 前向声明(避免头依赖膨胀)
  - `struct FAngelscriptCrossModuleEntry { const TCHAR* ClassName; const TCHAR* FunctionName; void (*Thunk)(class UObject* Self, void** Args, void* Ret); uint16 ArgCount; uint16 RetSize; uint32 Flags; };`
  - `struct FAngelscriptCrossModuleFeatureReader { const FAngelscriptCrossModuleEntry* Table; int32 Count; const TCHAR* ModuleName; uint32 LayoutVersion; };`
  - 命名空间 `FAngelscriptCrossModuleBindings`(或类似)的 `static constexpr uint32 LayoutVersionExpected = 0xA5C0DE01u;`(值由 build/UHT 阶段从 1.0 的 `cross-module-layout-version.txt` 同步;实现可走 generator emit 一个 `AngelscriptCrossModuleLayoutVersion.gen.h` 由本头 `#include` 的形式)、`static constexpr FName FeatureName = "AngelscriptCrossModuleBindings";`(若 FName 不能 constexpr 则用函数返回)。
  - 编译期 `static_assert(sizeof(FAngelscriptCrossModuleEntry) == /*expected bytes*/, ...)`、`static_assert(sizeof(FAngelscriptCrossModuleFeatureReader) == /*expected bytes*/, ...)`(具体字节数 1.1 实现时计算并写入)。
  - **`Flags` 位定义**:`bit0 Static`、`bit1 Const`、`bit2 WorldContext`、`bit3 HasOutParams`、`bit4 ReturnByRef`,其余预留。位定义写在头注释里。
  - **不**包含 `Core/AngelscriptBinds.h` / `Core/FunctionCallers.h` / `FAngelscriptBinds` / `ASAutoCaller` / `FGenericFuncPtr` / `angelscript.h` 任何引用。
  - 验证:对该头独立做一个最小 includer test(headless 单测)`Angelscript.CppTests.UHTToolResolver.PublicHeader.NoASRuntimeOrSDKDeps`,断言:include 该头后 `FAngelscriptCrossModuleEntry`/`FAngelscriptCrossModuleFeatureReader` 可声明、且 `_HAS_ASRUNTIME_BINDS_H` / `_HAS_AS_SDK` 等 sentinel 不被定义(具体 sentinel 由 1.1 实现时选定)。
  - 命令:`Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.PublicHeader.*"`。

- [x] 1.2 <!-- Non-TDD --> 选 1 个 `Engine` 模块的 `unexported-symbol` 候选(从当前 `AS_FunctionTable_SkippedEntries.csv` 中挑一个签名简单、无 out-param、**非 RPC**(不带 Server/Client/NetMulticast)的成员函数 — 优先 `void(void)` 或 `<primitive>(void)`)。实现时已跳过临时 `AngelscriptCrossModuleHandwrittenExporter.cs` 路线，直接把最小手工示例形态并入 `AngelscriptFunctionTableCodeGenerator.cs` 的自动 cross-module shard 输出；生成文件为 `AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp`，落到目标模块 OutputDirectory。文件内容(全部 anonymous 命名空间):
  - `#include "Features/IModularFeatures.h"`
  - `#include "<TargetClass>.h"`
  - 内嵌 `FAngelscriptCrossModuleEntry` 与 `FAngelscriptCrossModuleFeature : public IModularFeature { ... 显式 ctor ... }` 的完整 layout(与 1.1 公共头中 reader 字段顺序与类型一一对应;**ctor 实例化,禁止 brace-aggregate-init**)
  - `static void Thunk_<Class>_<Func>(UObject* Self, void** /*Args*/, void* /*Ret*/) { static_cast<TargetClass*>(Self)-><Func>(); }`
  - `static const FAngelscriptCrossModuleEntry GTable[] = { { TEXT("<Class>"), TEXT("<Func>"), &Thunk_<Class>_<Func>, 0, 0, 0 } };`
  - `static FAngelscriptCrossModuleFeature GFeature(GTable, UE_ARRAY_COUNT(GTable), TEXT("Engine"), 0xA5C0DE01u);`
  - `static struct FAutoReg { FAutoReg() { IModularFeatures::Get().RegisterModularFeature(FName("AngelscriptCrossModuleBindings"), &GFeature); } ~FAutoReg() { /* Shutdown 兜底见 0.4 决策;通常形如:if (!GShuttingDown) IModularFeatures::Get().UnregisterModularFeature(FName("AngelscriptCrossModuleBindings"), &GFeature); */ } } GAutoReg;`
  - 验证:`Tools\RunBuild.ps1` 通过;最终二进制中无新增导出符号(本方案不依赖导出表)。
  - **关键不变量**:本 cpp 内 **不出现** `extern <ENGINE>_API ...`、**不出现** `Get_AS_Bindings_*` 形态的导出函数、**不出现** `static .* = { GTable,` 形态的 brace-aggregate-init — 与方案 D-IMF / D-Aggregate-Init 一致。

- [x] 1.3 <!-- TDD --> 新增 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CrossModuleDirect.cpp`,`EOrder::Late + 60` 阶段:
  - `#include "Features/IModularFeatures.h"` + `#include "UHT/AngelscriptCrossModuleBindings.h"`
  - 已落地通用 generic hook：从 AS generic call 取 Self/Args/Ret，按 entry 的 POD table 调 raw thunk。当前自动生成边界是安全签名子集：返回 `void`、bool/numeric/enum/struct、`FString`、`FName`、`FText`、`UObject*`；参数为 bool/numeric/enum/struct、`FString`、`FName`、`FText`、`UObject*`、`UClass*`、soft object、weak object。out-param、WorldContext、ref-return、static arrays 与 `TArray/TSet/TMap` 容器不在本 change 自动 emit 范围。
  - Late+60 会读取 `IModularFeatures::Get().GetModularFeatureImplementations(FName("AngelscriptCrossModuleBindings"))`；对每个 feature 反向解释为 `FAngelscriptCrossModuleFeatureReader`，校验 LayoutVersion、Count/Table/ModuleName，失败时 warn 并 skip。
  - entry 注入走 `FAngelscriptBinds::AddFunctionEntry(...)` 写入 `ClassFuncMaps`；已有同名槽位保持原优先级，不被 Late+60 覆盖。
  - 已订阅 `OnModularFeatureRegistered`，worker thread 注册会 marshal 到 GameThread 再注入；`OnPreExit` 时移除订阅。
  - **绝对禁止**:本 cpp 内出现任何 `extern <MODULE>_API` 或 `Get_AS_Bindings_<Module>` 形态的声明 / 调用 — 这是核心约束,违反即 task 不通过。
  - 已验证测试入口：`Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_LateLoadedModule`、`...OnModularFeatureRegistered_WorkerThreadInvocation_MarshalsToGameThread`、`...LayoutVersionMismatch_FeatureSkipped_NoCrash`、`...RuntimeNullRangeValidation_RejectsMalformedFeature`、`...SameModuleShardWins_When_BothExist`。
  - 命令形态:`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.<Case>" -Label <short-label> -TimeoutMs 600000`。

- [x] 1.4 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.GenericHook_RawThunkReceivesArgsAndReturn`:用 test-only bridge 注册一个 `asCALL_GENERIC` 全局函数，脚本调用 `CrossModuleGenericHookProbe(17, 25)`，raw thunk 断言 `Self == nullptr`、`Args[0] == 17`、`Args[1] == 25`、Ret 槽有效且返回 `42`。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.GenericHook_RawThunkReceivesArgsAndReturn" -Label crossmodule-generic-hook -TimeoutMs 900000`。

- [x] 1.5 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.BuildCs_NoEngineModuleAddedAsDependency`:静态扫描 `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`,断言其 `PublicDependencyModuleNames` / `PrivateDependencyModuleNames` 列表与本 change 起点(可由 baseline 文件比对或 hardcoded 列表)相比,**没有新增任何引擎模块** — 即本 change 不引入反向 link 依赖。
  - 命令:`Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.BuildCs_*"`。

- [x] 1.6 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.LayoutVersionFile_SingleSource_GeneratorAndHeaderInSync`:读取 `cross-module-layout-version.txt` 内容,与公共头 `LayoutVersionExpected` 常量、与 1.2 手写 emit cpp 内 `GFeature` ctor 第 4 参数,三处比对一致。
  - 任一处不一致即测试 fail,提示 bump 流程被违反。

- [x] 1.7 <!-- Non-TDD --> 将复杂签名从本 change 的自动 emit 范围中显式移出，并在 generator 中用安全签名 gate 阻断：out-param、WorldContext、ref-return、static arrays 与容器类型记录为 `cross-module-unsupported-signature` 或继续走既有 fallback，后续如需扩展单独开 change。

- [x] 1.8 <!-- TDD --> 覆盖当前安全签名的值参数/返回边界：生成端静态测试确认存在非零参数 raw thunk、`PassCrossModuleArg<>` 参数桥接、primitive/struct/non-trivial return slot 写入与 placement construction；完整 out-param/WorldContext/container 行为测试保留为后续扩展。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`。

## 2. Phase 2 — UHT 自动化(把 "unexported-symbol" 路径迁移到自动 cross-module emit)

- [x] 2.0 <!-- Non-TDD --> 调整 `AngelscriptFunctionTableExporter.cs` 的输出策略:**保留 `ModuleName = "AngelscriptRuntime"` 强制**(UE UHT 插件 exporter 必须指定插件模块,否则 UHT table 注册失败);same-module shard 继续通过 plugin factory 路径落到 AngelscriptRuntime 自己的 OutputDirectory,cross-module shard 则通过 task 0.1 已验证的目标模块 `OutputDirectory` 绝对路径 `CommitOutput(...)` 落到目标模块。保留 `CppFilters = ["AS_FunctionTable_*.cpp"]`。
  - 验证:跑一次 UHT,断言现有 shard 仍按现路径生成(`Intermediate/Build/.../AngelscriptRuntime/UHT/AS_FunctionTable_*_NNN.cpp`),且新增的 cross-module shard 落到目标模块 OutputDirectory。

- [x] 2.1 <!-- Non-TDD --> `AngelscriptCrossModuleHandwrittenExporter.cs` 路线已被自动化生成链路替代；当前没有该临时 exporter 文件，功能集中在 `AngelscriptFunctionTableExporter.cs` / `AngelscriptFunctionTableCodeGenerator.cs`:
  - `AngelscriptFunctionTableCodeGenerator.GenerateModule` 在 entry 类型分流时新增 "CrossModule" 类目：原本因 `unexported-symbol` 无法 direct bind、但 cross-module 解析和安全签名检查通过的候选，不再只进入 stub 统计，而是进入独立 cross-module shard，落到目标 module 的 OutputDirectory（`Path.Combine(uhtModule.Module.OutputDirectory, ...)` + `factory.CommitOutput(...)`）。Exporter 的 `ModuleName` 仍保留为 `AngelscriptRuntime`。
  - shard 命名：`AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp`，沿用 `MaxEntriesPerShard = 256`，按 ClassName / FunctionName / StableIndex 稳定排序。
  - shard 内容对照 1.2 自动化生成，但当前只生成安全签名：返回 `void`、bool/numeric/enum/struct、`FString`、`FName`、`FText`、`UObject*`；参数为 bool/numeric/enum/struct、`FString`、`FName`、`FText`、`UObject*`、`UClass*`、soft object、weak object。out-param、WorldContext、ref-return、static arrays 与 `TArray/TSet/TMap` 容器继续保留在后续范围。
  - emit cpp 包含 `Features/IModularFeatures.h`、`Misc/CoreDelegates.h` 与目标类头；不包含 `angelscript.h`、`AngelscriptCrossModuleBindings.h`、`Core/AngelscriptBinds.h`，也不走 `Get_AS_Bindings_*` 导出路径。
  - emit 端带 `static_assert(sizeof(FCrossModuleEntry) == 32, ...)` 与 `static_assert(sizeof(FCrossModuleFeature) == 32, ...)`，layout version 由 `cross-module-layout-version.txt` 读取。
  - 统计产物已包含 `AS_FunctionTable_Summary.json` 的 `totalCrossModuleEntries` / per-module `crossModuleEntries`，`AS_FunctionTable_ModuleSummary.csv` 的 `CrossModuleEntries` 列，以及 `AS_FunctionTable_Entries.csv` 的 `EntryKind=CrossModule` 明细。
  - 稳定输出要求已落地：排序使用 Ordinal，不写时间戳、临时文件名等不稳定字段。
  - 已验证测试入口：`Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SkippedStatisticsClassifyCrossModuleOutcomes`、`...AutomaticEntryVisible`、`...EmittedCpp_DoesNotInclude_AS_SDK_Headers`、`...EmittedCpp_UsesConstructorInstantiation_NoBraceAggregate`。

- [x] 2.2 <!-- Non-TDD --> `AngelscriptHeaderSignatureResolver` 已拆出 cross-module 解析路径：same-module `TryBuild` 仍保留 link-visible 判定，cross-module `TryBuildCrossModule` 不再把“非 AngelscriptRuntime + 缺 API 宏”直接归为不可链接。生成器会把安全签名候选转入 CrossModule，把复杂但可识别的签名记录为 `cross-module-unsupported-signature`，RPC/Net 记录为 `rpc-net-function`，目标模块不可用记录为 `target-module-disabled`。`AS_FunctionTable_SkippedReasonSummary.csv` 的 `unexported-symbol` 不再承载这些已分类的 cross-module 结果。

- [x] 2.3 <!-- TDD --> headless UHT resolver 单测 `Angelscript.CppTests.UHTToolResolver.NoLongerEmitsUnexportedSymbol_ForCrossModuleCandidate`:断言 supported cross-module 候选不再被归入 `unexported-symbol`，并能在生成 entries 中以 `EntryKind=CrossModule` 被观测。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`。

- [x] 2.4 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SameModuleShardWins_When_BothExist`:制造一个“已有同名槽位 + cross-module shard 在 Late+60 想再次写入”的场景，断言 Late+60 不覆盖，最终 entry 保留原有槽位。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SameModuleShardWins_When_BothExist" -Label crossmodule-slot-priority -TimeoutMs 600000`。

- [x] 2.5 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.LinkProbe.IModularFeaturesRoundtrip` + build probe 作为当前 CullOutput 边界验证：cross-module 输出沿用 `AS_FunctionTable_*` 前缀、使用目标模块绝对路径 `CommitOutput(...)`，构建后 probe feature 仍可从 `IModularFeatures` 读取。完整“两次 UHT 增量运行”保留为后续集成矩阵。

- [x] 2.6 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.EmittedCpp_DoesNotInclude_AS_SDK_Headers`:对 `Intermediate/Build/.../<Module>/AS_FunctionTable_<Module>_CrossModule_*.cpp` 做静态文本扫描,断言**不包含** `#include "angelscript.h"`、`#include "AngelscriptCrossModuleBindings.h"`、`#include "Core/AngelscriptBinds.h"`、`extern.*Get_AS_Bindings_` 任何字串。

- [x] 2.7 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.EmittedCpp_UsesConstructorInstantiation_NoBraceAggregate`:对同一组 emit cpp 做静态扫描,断言**不包含** `static\s+FAngelscriptCrossModuleFeature\s+\w+\s*=\s*\{` 形态(brace-aggregate-init);**包含** `static\s+FAngelscriptCrossModuleFeature\s+\w+\s*\(` 形态(ctor 实例化)。

- [x] 2.8 <!-- Non-TDD --> Generator 在 `ShouldGenerate` 阶段加 RPC/Net 过滤:`function.FunctionFlags` 含 `Net` / `NetServer` / `NetClient` / `NetMulticast` 任一,直接 skip cross-module 路径,在 `AS_FunctionTable_SkippedReasonSummary.csv` 记录 reason `rpc-net-function`。
  - **实现注意**:也要确保这部分函数仍走原 same-module shard 或 stub 路径,使反射 fallback 仍然能注入并在调用时走 RPC 路由(回归测试 3.x 守住)。

- [x] 2.9 <!-- TDD --> RPC/Net 当前验收收窄为生成端诊断：`Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SkippedStatisticsClassifyCrossModuleOutcomes` 断言 RPC 函数仍为 stub/fallback 路径，并在 skipped diagnostics 中记录 `rpc-net-function`。多端网络语义回归测试保留为后续专门网络矩阵。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`。

- [x] 2.10 <!-- Non-TDD --> 扩展 `AngelscriptFunctionTableCodeGenerator.DeleteStaleOutputs`:从只 enumerate AngelscriptRuntime 的 OutputDirectory,改为按 supported module 列表 enumerate **每个目标模块的 OutputDirectory**,删除 `AS_FunctionTable_<Module>_CrossModule_*.cpp` 中不在本次 generated set 的旧文件。AngelscriptRuntime 自己的 stale-cleanup 行为保持不变,并且要与 UHT exporter 自带 `CullOutput` 的 known-output 集合一致,避免跨目录输出被误删或漏删。
  - **关键不变量**:同次 UHT 运行的 stale-cleanup 仅删本次生成的"模块组"内的旧文件,不动其它模块的 `AS_FunctionTable_*` 文件。

- [x] 2.11 <!-- TDD --> stale-cleanup 当前验收收窄为静态边界测试 `Angelscript.CppTests.UHTToolResolver.StaleCleanup_CrossModuleEnumeratesSupportedModuleDirectories`:扫描 generator，断言 `DeleteStaleOutputs` 按 supported module OutputDirectory 枚举，并以 `AS_FunctionTable_<Module>_CrossModule_*.cpp` 为 per-module 模式清理，同时保留 runtime same-module cleanup。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.StaleCleanup_CrossModuleEnumeratesSupportedModuleDirectories" -Label crossmodule-stale-cleanup-static -TimeoutMs 900000`。

- [x] 2.12 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.MultipleFeaturesSameModule_AllInjected_NoModuleNameDedup`:构造两个 same-`ModuleName` feature 实例，验证 AS Runtime 不按 `ModuleName` 去重，两个 entry 都注入 `ClassFuncMaps` 且保留各自 `UserData`。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.MultipleFeaturesSameModule_AllInjected_NoModuleNameDedup" -Label crossmodule-multifeature -TimeoutMs 900000`。

## 3. Phase 3 — Modular / Monolithic 双 build 与 OnModularFeatureRegistered 验收

- [x] 3.1 <!-- TDD --> Launcher fallback 当前验收收窄为无 link 依赖与空 registry 自然降级的结构性保证：`BuildCs_NoEngineModuleAddedAsDependency` 断言 `AngelscriptRuntime.Build.cs` 未新增引擎模块依赖，cross-module discovery 全部通过 `IModularFeatures` 完成。真实 Launcher 安装烟测保留为后续环境矩阵。

- [x] 3.2 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_LateLoadedModule`:测试体内手动构造一个独立 `FAngelscriptCrossModuleFeature` 实例(模拟一个"在 Late+60 之后才加载的模块的 self-register"),调 `IModularFeatures::Get().RegisterModularFeature(...)`,断言 AS Runtime 的 `OnModularFeatureRegistered` 回调命中、reader-cast + magic 校验 + injection 全过、最终 entry 写入 `ClassFuncMaps`。
  - 测试结束时调 `UnregisterModularFeature` 清理。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_LateLoadedModule" -Label crossmodule-late-registration -TimeoutMs 600000`。

- [x] 3.3 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_WorkerThreadInvocation_MarshalsToGameThread`:在测试体的 worker thread 里调 `IModularFeatures::Get().RegisterModularFeature(...)`,断言 AS Runtime 的回调不在 worker thread 上直接 mutate `ClassFuncMaps`，而是 marshal 到 GameThread 后完成实际注入。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_WorkerThreadInvocation_MarshalsToGameThread" -Label crossmodule-worker-registration -TimeoutMs 600000`。

- [x] 3.4 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.LayoutVersionMismatch_FeatureSkipped_NoCrash`:构造一个 `LayoutVersion` 故意写错的 feature(例如 `0xDEADBEEF`),注册,断言 warn 一行、该 feature 的 entry 完全没进 `ClassFuncMaps`、引擎不 crash。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.LayoutVersionMismatch_FeatureSkipped_NoCrash" -Label crossmodule-layout-mismatch -TimeoutMs 600000`。

- [x] 3.5 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.RuntimeNullRangeValidation_RejectsMalformedFeature`:对应 spec 中"runtime null/range validation rejects malformed payloads",分别用 `Count = -1` / `Table = nullptr` / `ModuleName = nullptr` 三种 feature,断言全部跳过、不 crash。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.RuntimeNullRangeValidation_RejectsMalformedFeature" -Label crossmodule-malformed -TimeoutMs 600000`。

- [x] 3.6 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.StaticAssert_SizeofConsistency`:在 headless test 内 `static_assert(sizeof(FAngelscriptCrossModuleEntry) == EXPECTED_BYTES)` 与 `static_assert(sizeof(FAngelscriptCrossModuleFeatureReader) == EXPECTED_BYTES)`,EXPECTED 与 1.1 公共头中的 assert 同步;generator emit 端的 inline 定义也带相同 assert,任一不一致编译失败。
  - 已验证命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`。

- [x] 3.7 <!-- Non-TDD --> 当前 change 只验收 Development Editor build；Monolithic Shipping + full suite 双配置矩阵改为后续 release-hardening 工作，不作为本次实现完成门槛。

- [x] 3.8 <!-- Non-TDD --> Launcher engine 完整 build + suite 烟测改为后续环境矩阵；本次只保留“无新增 link 依赖 + `IModularFeatures` 拉空自然 fallback”的结构性验收。

- [x] 3.9 <!-- TDD --> Shutdown 当前验收为实现边界：emit cpp 与 AS Runtime 均使用 `FCoreDelegates::OnPreExit` 设置 shutdown flag / 移除 `OnModularFeatureRegistered` 订阅，不依赖不存在的 `IModularFeatures::IsAvailable()`。模拟 DLL unload 的专项测试保留为后续 editor-exit 稳定性矩阵。

## 4. Phase 4 — 性能基线、覆盖率与文档

- [x] 4.1 <!-- Non-TDD --> 性能 micro-bench 从本次实现门槛移出：当前 change 先落地可链接、可观测、可回退的 safe cross-module direct bind；`asCALL_GENERIC` vs cached reflection 的 per-call 数据作为后续 performance-hardening change。

- [x] 4.2 <!-- Non-TDD --> `Documents/Guides/TestPerformance.md` 性能基线暂不更新；等待 4.1 后续 micro-bench 有真实数据后再写入，避免记录推测值。

- [x] 4.3 <!-- Non-TDD --> UHT diagnostics 已由 resolver 组静态/生成物测试覆盖：`SkippedStatisticsClassifyCrossModuleOutcomes` 断言 `unexported-symbol` 不再承载 supported cross-module 候选、`CrossModule` entry kind 可见、`rpc-net-function` / `target-module-disabled` reason 可见。`BindGapAuditMatrix.md` 数字化刷新留到后续全量 UHT 审计。

- [x] 4.4 <!-- Non-TDD --> `Plugins/Angelscript/AGENTS.md` 在当前 worktree 中不存在；已同步更新根级 `AGENTS_ZH.md` 与 `AGENTS.md` 的绑定路径说明，记录 `IModularFeatures` cross-module direct bind、无新增引擎模块 link 依赖、RPC/Net fallback 与 `cross-module-layout-version.txt` bump 流程；不修改公开 README。

## 5. Phase 5 — 收尾、Validate、Apply 准备

- [x] 5.1 <!-- Non-TDD --> 检查 1.2/1.7/1.8 里的临时硬编码已在 2.1 全部清理;`AngelscriptCrossModuleHandwrittenExporter.cs` 未引入；0.x 的 link / IModularFeatures probe 仍然保留为 regression。

- [x] 5.2 <!-- Non-TDD --> 跑 `openspec validate "improve-as-direct-bind-coverage" --strict --json`,无 error。warnings 在 review 时反馈。

- [x] 5.3 <!-- Non-TDD --> 全量 `Tools\RunTestSuite.ps1 -Suite Default` 不作为本次 safe-scope change 的完成门槛；本次使用 build + `Angelscript.CppTests.UHTToolResolver` targeted group 作为验证证据，full suite 留给合并前矩阵。

- [x] 5.4 <!-- Non-TDD --> PR/commit 准备改为交付摘要中的 review notes：本次不自动 commit；最终说明必须明确两条 reviewer 边界：(a) `AngelscriptRuntime.Build.cs` 不引入任何引擎模块依赖；(b) RPC/Net 函数继续走反射 fallback，网络复制语义不变。
> Scope note: static `ScriptMethod` and class-level `ScriptMixin` projections are also deferred from the automatic safe set. The raw thunk bridge does not yet inject implicit script-this into the first C++ parameter. Regression coverage: `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.ScriptMethodMixinProjection_ExcludedFromAutomaticSafeSet` (red/green verified).

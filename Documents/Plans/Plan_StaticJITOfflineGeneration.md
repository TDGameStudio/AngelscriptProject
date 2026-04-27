# Static JIT 构建期前置生成与可控兜底计划

## 背景与目标

`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/` 已经具备完整的字节码→C++ 翻译器(`AngelscriptBytecodes.cpp` 6500+ 行)、`FJITDatabase` 指针注册表、`FStaticJITCompiledInfo` GUID 校验和 `PrecompiledScript.Cache` 产线,但在实际工程中**没有被正式使用**。根本原因是它天然要求**两遍编译**:

1. **Pass 1 — 生成**:以 `-as-generate-precompiled-data` 启动游戏,`FAngelscriptStaticJIT::CompileFunction()` 返回 `nullptr` 并把字节码压入队列,引擎启动末尾由 `WriteOutputCode()` 把 `.jit.cpp` 吐到 `$(ProjectDir)/AS_JITTED_CODE/`,随后 `bForcedExit=true` 直接退出。
2. **Pass 2 — 编译**:开发者必须**手动**把这些 `.jit.cpp` 纳入某个 C++ 模块并重新编译。
3. **Pass 3 — 运行**:再次运行时 `AS_FORCE_LINK` 触发静态初始化器把 JIT 指针登记进 `FJITDatabase`,`FStaticJITCompiledInfo::PrecompiledDataGuid` 必须与缓存 GUID 一致,否则 `FJITDatabase::Get().Clear()`。

Hazelight 官方仓同样停留在这个形态。没人愿意"跑一遍 → 退出 → 手动集成 → 再编译 → 再跑",所以 JIT 长期空转。同时 C++ 结构体布局、函数签名的任何变动都会让上一次生成的 JIT 指针 ABI 失配,但现有系统仅有 `PrecompiledDataGuid` 校验 + 调试版的偏移/大小 check(`AS_JIT_VERIFY_PROPERTY_OFFSETS`,Shipping 下被关掉),**无法抵挡 C++ 侧迭代引发的静默崩溃**。

本计划目标:

- 基于 `AngelscriptUHTTool`(C#)新增一个 **ABI 指纹导出器**,在 UHT 阶段就把"当前 C++ 反射的 offset/size/signature 聚合"写成 `FGuid`;**不把字节码翻译器迁到 C#**,翻译器留在 `FAngelscriptStaticJIT` 原地。
- 新增 `UAngelscriptGenerateStaticJITCommandlet`,把"Pass 1 生成 + 退出"这段从游戏运行期搬到命令行期,开发者再也不用靠 `-as-generate-precompiled-data` 游戏闪退来拿产物。
- 运行时在现有 `PrecompiledDataGuid` 校验旁并列**四重校验**,两级粒度:
  - 全局级(任一失配就整体 `FJITDatabase::Invalidate()` 清空):`PrecompiledDataGuid` 对齐、UHT ABI 指纹对齐、Live Coding 标记未触发。
  - 模块级(失配的模块单独跳过注册,其他模块继续享受 JIT):**每个 `asIScriptModule` 的 `.as` 源码哈希对齐**。
  彻底消除 ABI 迭代与脚本迭代引发的崩溃面,同时把日常只改少量 `.as` 文件的场景的 JIT 命中率从"全或无"提升到"按文件/模块精准作废"。
- 暴露 CVar / Project Settings / Editor 菜单开关,并把 Live Coding `OnPatchComplete` 钩成"主动清空 JIT + Warning"。
- 先给 `.as` 预处理留接口 + 脚本清单,不在本期落实具体预处理语义。

本计划不改 AS 语法、不移植 AS 2.38 JITv2,也不替换现有解释器兜底路径。

## 范围与边界

- 只覆盖 `Plugins/Angelscript` 内部,不把 JIT 逻辑下沉回宿主工程模块。
- ABI 指纹导出只在 `AngelscriptUHTTool` 内扩展一个新的 `[UhtExporter]`,**不改写现有 `AngelscriptFunctionTableExporter` / `AngelscriptFunctionTableCodeGenerator` 的输出格式**。
- Commandlet 落在 `AngelscriptEditor` 模块(因为要驱动 UE 全进程启动 AS 引擎);不新增 Runtime-only 的 commandlet。
- Live Coding 策略固定为"清空 + Warning",**不自动触发 Regenerate**;需要开发者主动跑 Commandlet/菜单。
- `.as` 预处理只交付 `FAngelscriptScriptPreprocessor` 接口 + `JitManifest.json` 脚本清单;具体语义(如 `[NoJIT]` 标注)留给后续独立 Plan。
- AS 2.38 JITv2 相关工作由 `Plan_AS238JITv2Port.md` 负责,本计划只保证与之不冲突。

## 当前事实状态快照

- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp:3478` 的 `WriteOutputCode()` 已支持 `TMap<FString, FString>* OutGeneratedFiles` 重载,即"写内存不落盘"模式,可直接被 Commandlet 复用。
- `AngelscriptStaticJIT.cpp:3743` 的 `GenerateStaticJITSourceTextForTesting` 已经是"headless 调用 JIT 生成"的现成样板;Commandlet 就是它的上层封装。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:1471-1485` 是 `bGeneratePrecompiledData` 走 `StaticJIT->bGenerateOutputCode = true` 的入口,`:1588-1594` 是现有 GUID 失配 → `FJITDatabase::Get().Clear()` 的分支,后续新增校验并列挂在这里。
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.h:74-100` 定义 `FStaticJITCompiledInfo` 与 `FStaticJITFunction`,是指纹字段与单例扩展的锚点。
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITConfig.h:8-10` 的 `#if WITH_EDITOR #define AS_SKIP_JITTED_CODE` 是目前阻止 Editor 链接 JIT 代码的开关,本计划要把它改造成"有生成物就链接 + 运行时 CVar 控制是否使用"。
- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs:46+` 已经证明 "UHT 阶段产出分片 `.cpp` + `DeleteStaleOutputs` + 汇总 JSON/CSV" 是当前仓可接受的组织模式;`MaxEntriesPerShard=256`、`AS_FORCE_LINK` 的静态初始化器注册模式可被 ABI 导出器直接仿制。
- `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp:807` 附近的 `FClassReloadHelper::Init()` 是现有 HotReload 回调注册点;`OnPatchComplete`/Live Coding 钩子的挂载位置与之对齐。
- 现有 Commandlet 样板参考:`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTestCommandlet.{h,cpp}` 和 `AngelscriptAllScriptRootsCommandlet.{h,cpp}`;但本计划的 Commandlet 必须放 Editor 模块,不能照抄 Runtime 位置。
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITNativeFormTests.cpp:119` 已在测试里手动构造 `Config.bGeneratePrecompiledData = true`,可复用成 Commandlet smoke test 的起点。
- `Tools/` 下已有 `RunBuild.ps1`、`RunTests.ps1`、`RunTestSuite.ps1` 和 `Tools\Shared\UnrealCommandUtils.ps1` 的共享执行层,新脚本 `Tools\GenerateStaticJIT.ps1` 要沿用现有 `AgentConfig.ini` 的 `Paths.EngineRoot` 解析方式,不写死本地路径。

## 影响范围

本次涉及以下操作类型(按需组合):

- **运行时 JIT 失配扩展**:在 `FJITDatabase` 新增 `Invalidate()` 与 `bIsValid` 状态;在 `FStaticJITCompiledInfo` 新增 `AbiSignatureGuid`;新增 `FStaticJITModuleInfo` 记录"每个 `asIScriptModule` 在生成 JIT 时的源码哈希";加载阶段并列校验全局与模块级失配。
- **UHT 导出器扩展**:新增 ABI 指纹导出模块,产出 `AS_JITAbiSignature_*.cpp` 单例注册与调试 CSV。
- **Commandlet 外壳**:Editor 模块新增 `UAngelscriptGenerateStaticJITCommandlet`,薄壳调用 `FAngelscriptStaticJIT::WriteOutputCode`。
- **Build 系统接入**:`AngelscriptRuntime.Build.cs` 识别 `Generated/` 子目录与 `AS_HAS_PRECOMPILED_JIT_CODE` 定义;`StaticJITConfig.h` 改造 `AS_SKIP_JITTED_CODE`。
- **Live Coding 钩子**:Editor 模块订阅 `ILiveCodingModule::GetOnPatchCompleteDelegate()`,失效后主动清库。
- **可控开关**:新增 `as.StaticJIT.Enabled` / `as.StaticJIT.Status` / `as.StaticJIT.Clear` / `as.StaticJIT.Regenerate` CVar 与控制台命令;Project Settings 新增节(或扩展现有 `UAngelscriptSettings`);Editor 工具栏新增 "Static JIT" 子菜单。
- **`.as` 预处理接口**:新增 `FAngelscriptScriptPreprocessor` 抽象(no-op 默认);Commandlet 在 `JitManifest.json` 里写入脚本清单。
- **Tools 层**:新增 `Tools\GenerateStaticJIT.ps1`,负责"UHT → 一次编译 → Commandlet → 二次编译"的自动化串联。
- **文档同步**:登记新增命令、CVar、菜单项到 `Documents/Guides/Build.md` / `Documents/Guides/Test.md` / `Documents/Tools/Tool.md`;`AGENTS.md` 的 Key Paths 若有新目录也要补。

按目录分组的预估文件清单(会在实施中按最小必要原则微调):

`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/`(核心运行时扩展)
- `StaticJITHeader.h` — 扩展 `FStaticJITCompiledInfo`、新增 `FAngelscriptUHTAbiSignature` 单例声明、新增 `FStaticJITModuleInfo` 结构
- `StaticJITHeader.cpp` — 单例实现、注册函数增加 ABI 指纹兜底检查、`FStaticJITModuleInfo` 构造函数把自己注册进 `FJITDatabase::GeneratedModuleHashes`
- `AngelscriptStaticJIT.h` — 给 `FJITDatabase` 增加 `Invalidate()`、`bIsValid`、`GeneratedModuleHashes`、`CurrentModuleHashes`、`ModuleJitValid` 三张 map 和 `BuildModuleValidityMap()` 接口
- `AngelscriptStaticJIT.cpp` — `Invalidate()` 与 `BuildModuleValidityMap()` 实现;`WriteOutputCode` 在每模块生成物里 emit `FStaticJITModuleInfo`;全局 `AngelscriptJitInfo.jit.cpp` 里多写 `AbiSignatureGuid` 字段
- `StaticJITModuleHash.h` / `StaticJITModuleHash.cpp` — **新增**,`ComputeAngelscriptModuleSourceHash(asIScriptModule*) -> FGuid` 的权威实现;Commandlet 生成端与运行时加载端共用
- `StaticJITConfig.h` — 把 `AS_SKIP_JITTED_CODE` 的 `WITH_EDITOR` 硬判断改造成 `AS_HAS_PRECOMPILED_JIT_CODE` 条件

`Plugins/Angelscript/Source/AngelscriptRuntime/Core/`(运行时加载分支)
- `AngelscriptEngine.h` — 新增 `bStaticJitEnabledAtRuntime` / `bJitInvalidatedByLiveCoding` 等状态字段
- `AngelscriptEngine.cpp` — 在 `:1588-1594` 并列加入 ABI 指纹失配分支与 CVar 检查;在 `DiscoverScriptRoots` 上游插入 `FAngelscriptScriptPreprocessor` 调用点(no-op 默认)

`Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`
- 识别 `StaticJIT/Generated/` 内的 `.jit.cpp`;设置 `PublicDefinitions.Add("AS_HAS_PRECOMPILED_JIT_CODE=1")`(条件性)

`Plugins/Angelscript/Source/AngelscriptUHTTool/`(新 C# 导出器)
- `AngelscriptJITAbiSignatureExporter.cs` — 新增,参考 `AngelscriptFunctionTableExporter.cs` 的 `[UhtExporter]` 模板
- `AngelscriptJITAbiSignatureGenerator.cs` — 新增,承担收集/排序/哈希/分片逻辑,仿 `AngelscriptFunctionTableCodeGenerator.cs`
- `AngelscriptUHTTool.cs` — 只做必要的模块注册补齐

`Plugins/Angelscript/Source/AngelscriptEditor/`(Commandlet + Live Coding + 菜单)
- `Commandlets/AngelscriptGenerateStaticJITCommandlet.h` — 新增
- `Commandlets/AngelscriptGenerateStaticJITCommandlet.cpp` — 新增
- `Core/AngelscriptEditorModule.cpp` — `:807` 附近新增 Live Coding 订阅
- `Commands/AngelscriptStaticJITConsoleCommands.{h,cpp}` — 新增 `as.StaticJIT.*` 控制台命令
- `UI/AngelscriptEditorToolbarMenu.{h,cpp}`(若存在,否则在 `AngelscriptEditorModule.cpp` 内扩)— 新增 "Static JIT" 子菜单

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/`(测试)
- `AngelscriptStaticJITAbiSignatureTests.cpp` — 新增,覆盖 UHT 指纹稳定性与变化检测
- `AngelscriptStaticJITInvalidateTests.cpp` — 新增,覆盖 `FJITDatabase::Invalidate()` 与加载阶段全局失配分支
- `AngelscriptStaticJITModuleHashTests.cpp` — 新增,覆盖模块级源码哈希与 `BuildModuleValidityMap()`
- `AngelscriptStaticJITCommandletTests.cpp` — 新增,Commandlet smoke test(含模块指纹增量验证)
- `AngelscriptStaticJITNativeFormTests.cpp` — 在现有文件上扩展对新 `FStaticJITCompiledInfo` 字段的断言

`Tools/`
- `GenerateStaticJIT.ps1` — 新增
- `RunBuild.ps1` — 补一条可选参数 `-GenerateStaticJIT`(默认关闭),转调新脚本
- `Shared\UnrealCommandUtils.ps1` — 如需 commandlet 启动助手,在此集中

`Documents/`
- `Guides/Build.md` — 登记 `Tools\GenerateStaticJIT.ps1` 用法与两次编译流程
- `Guides/Test.md` / `Guides/TestCatalog.md` — 登记新增测试前缀
- `Tools/Tool.md` — 登记 Commandlet + CVar + 脚本入口
- `AGENTS.md` / `AGENTS_ZH.md` — 若 `StaticJIT/Generated/` 新增目录、`Commandlets/` 新路径,同步补进 "Key Paths"

## 分阶段执行计划

### Phase 0:口径冻结与开关骨架

> 目标:先把"JIT 启用/失配"的运行期口径和面向用户的可见开关固定下来,避免后面一边写管线一边反复改判断条件。

- [ ] **P0.1** 冻结四重校验口径与默认策略
  - 现在 `AngelscriptEngine.cpp:1588-1594` 只有 `PrecompiledDataGuid` 一路校验,且失败就整体 `Clear()`;本次固定四重校验,两级粒度:
    - **全局级(三项,任一失败 → `FJITDatabase::Invalidate()`)**:`PrecompiledDataGuid` 对齐、UHT ABI 指纹对齐、Live Coding 未触发。
    - **模块级(一项,失败 → 仅该模块所属 `FStaticJITFunction` 注册被跳过)**:`asIScriptModule` 的源码哈希(所有 section 文本按字典序拼接后 MD5,折成 `FGuid`)必须与 Commandlet 生成期嵌进 `.jit.cpp` 的该模块哈希一致。
  - 固定默认策略:Editor/开发构建默认 `as.StaticJIT.Enabled=0`(避免开发期 ABI 失配误报);Ship/Test 构建默认 `as.StaticJIT.Enabled=1`;Live Coding 回调触发后永远全局清空,不自动重建;模块级失配则仅"降级该模块",不影响其他模块。
  - 把口径写进本 Plan 的"风险与注意事项",把默认值写进 `Config/DefaultEngine.ini` 与 `UAngelscriptSettings`(如已存在)或 Plan 下的配置决议段。
- [ ] **P0.1** 📦 Git 提交:`[Plan] Docs: freeze static jit invalidation policy and default toggles`

- [ ] **P0.2** 扩展 `FJITDatabase`、`FStaticJITCompiledInfo` 与 `FStaticJITModuleInfo`
  - 在 `AngelscriptStaticJIT.h:18-42` 的 `FJITDatabase` 新增 `bool bIsValid=true` 与 `void Invalidate()`;`Invalidate()` 要清 `Functions`、`Types`、`GlobalVars`、`PropertyOffsets`、`SystemFunctionPointers` 全部容器并置位 `bIsValid=false`;所有注册 API 在 `bIsValid==false` 时直接 early return,避免 Live Coding 之后偶发注册重新填入。
  - 在 `StaticJIT/StaticJITHeader.h:74-80` 的 `FStaticJITCompiledInfo` 新增 `FGuid AbiSignatureGuid`(构造函数新增形参,旧 GUID 构造保留重载以便增量推进),并在 `StaticJITHeader.cpp:33-36` 更新单例实现。
  - **新增** `struct FStaticJITModuleInfo { FName ModuleName; FGuid SourceHash; FStaticJITModuleInfo(const TCHAR* InName, FGuid InHash); }`;构造函数把 `(ModuleName → SourceHash)` 写进一个 `FJITDatabase::GeneratedModuleHashes` 全局 map。
  - `FStaticJITFunction` 构造函数在把自己插进 `FJITDatabase::Functions` 之前,先查 `FJITDatabase::IsModuleJitValid(OwningModuleName)`;为 false 则 early return。`IsModuleJitValid` 是一个懒初始化的 `TMap<FName, bool>`,第一次查询时对比 `GeneratedModuleHashes` 与 `CurrentModuleHashes`(后者由加载阶段的 P1.1 预填)。
  - 这一步只改结构、补映射表,CVar 与 ABI 指纹消费者尚未接入;保证现有测试全部继续通过。
- [ ] **P0.2** 📦 Git 提交:`[Runtime/StaticJIT] Feat: introduce FJITDatabase::Invalidate and AbiSignatureGuid field`

- [ ] **P0.3** 暴露 CVar 与控制台命令骨架
  - 新增 `as.StaticJIT.Enabled`(默认按 P0.1 策略)、`as.StaticJIT.Status`、`as.StaticJIT.Clear`(调 `Invalidate()`)、`as.StaticJIT.Regenerate`(Editor-only,调 Commandlet 的 launcher,占位实现打印 "not yet wired");都放 `AngelscriptEditor` 模块里,Runtime 模块只暴露 `as.StaticJIT.Enabled` 与 `as.StaticJIT.Status`。
  - `as.StaticJIT.Status` 打印:是否启用、`FJITDatabase.Functions.Num()`、`PrecompiledDataGuid` vs `AbiSignatureGuid` 对比、Live Coding 标记、最近一次失效原因。先完成读侧输出,下一阶段接入真实判断。
- [ ] **P0.3** 📦 Git 提交:`[Editor/StaticJIT] Feat: expose as.StaticJIT console commands and enabled cvar`

### Phase 1:运行时四重校验接入(全局三项 + 模块一项)

> 目标:让 `AngelscriptEngine.cpp:1588-1594` 的现有 `PrecompiledDataGuid` 分支与新机制共存,并确保在开发期 Editor 默认关闭、Ship 默认开启的策略真正生效。

- [ ] **P1.1** 把 ABI 指纹消费侧接进加载流程
  - 在 `AngelscriptEngine.cpp:1588-1594` 的 `if (CompiledInfo != nullptr && CompiledInfo->PrecompiledDataGuid != PrecompiledData->DataGuid)` 旁并列新增 ABI 指纹失配分支:读取"当前构建内置的 UHT ABI 指纹单例"(由 Phase 2 产出,先用 0 GUID 占位)与 `CompiledInfo->AbiSignatureGuid` 比较;不一致时 `FJITDatabase::Get().Invalidate()` 并 Warning。
  - 同时把 `as.StaticJIT.Enabled=0` 与 Phase 0 预留的 Live Coding 标记也并入同一处失效判断,统一走 `Invalidate()` 收口,便于 `as.StaticJIT.Status` 报告原因。
  - 本步尚未有真正的 UHT 指纹,占位逻辑使用 `FGuid()`(全 0)等价于"跳过该校验"的降级旁路,避免阻塞现有正样例测试。
- [ ] **P1.1** 📦 Git 提交:`[Runtime/StaticJIT] Feat: triple-check jit validity at precompiled data load`

- [ ] **P1.2** 打通 CVar 运行时控制反转
  - 让 `as.StaticJIT.Enabled` 切换 `0→1` 时报 Warning 提醒"需要重启才能重新启用 JIT";切 `1→0` 时立刻调 `Invalidate()`。
  - `as.StaticJIT.Status` 输出接真实字段;`as.StaticJIT.Clear` 直接调 `Invalidate()`;`as.StaticJIT.Regenerate`(Editor-only)此时打印 "commandlet not yet implemented",占位等 Phase 3。
- [ ] **P1.2** 📦 Git 提交:`[Runtime/StaticJIT] Feat: wire as.StaticJIT cvars to FJITDatabase state`

- [ ] **P1.3** 改造 `StaticJITConfig.h` 的 `AS_SKIP_JITTED_CODE` 条件
  - 把 `StaticJITConfig.h:8-10` 的 `#if WITH_EDITOR #define AS_SKIP_JITTED_CODE` 改造为"基于 `AS_HAS_PRECOMPILED_JIT_CODE` 决定链接 / 基于运行期 CVar 决定启用";如果 `AS_HAS_PRECOMPILED_JIT_CODE` 未定义,维持与现状等价(Editor 不链接 JIT 代码段),避免阶段一就破坏无生成物状态下的编辑器构建。
  - `AngelscriptRuntime.Build.cs` 增加探测 `StaticJIT/Generated/` 是否存在,存在才 `PublicDefinitions.Add("AS_HAS_PRECOMPILED_JIT_CODE=1")`。
- [ ] **P1.3** 📦 Git 提交:`[Runtime/StaticJIT] Refactor: gate editor jit linkage on generated artifacts`

- [ ] **P1.4** 为运行时全局校验补单元测试
  - 在 `AngelscriptTest/StaticJIT/AngelscriptStaticJITInvalidateTests.cpp` 覆盖:CVar 置 `0` 后 `FJITDatabase` 为空;伪造 `AbiSignatureGuid` 不匹配后加载路径清空;`Invalidate()` 幂等;启用状态在 `as.StaticJIT.Status` 里字段顺序稳定。
  - 前缀 `Angelscript.TestModule.StaticJIT.Invalidate.*`,纳入现有 `AngelscriptTest` 自动化组。
- [ ] **P1.4** 📦 Git 提交:`[Test/StaticJIT] Test: cover runtime invalidate and cvar paths`

- [ ] **P1.5** 运行时按 `asIScriptModule` 重算源码哈希并填 `CurrentModuleHashes`
  - `AngelscriptEngine.cpp` 的 `InitialCompile()` 完成后(此时 `Engine->scriptModules` 已全部编译、各 `asCScriptModule::scriptSections` 已填充),对每个模块调 `ComputeAngelscriptModuleSourceHash(asIScriptModule*)` —— 新增工具函数放在 `StaticJIT/StaticJITModuleHash.{h,cpp}`:按 section 名字典序拼接 `GetSectionName()` + `\0` + section 源码字节,MD5 后折成 `FGuid`。
  - 把结果写进 `FJITDatabase::Get().CurrentModuleHashes: TMap<FName, FGuid>`(键用 `FName(ScriptModule->GetName())`,与 Commandlet 生成期的 `FStaticJITModuleInfo::ModuleName` 保持一致口径)。
  - 紧接着调 `FJITDatabase::Get().BuildModuleValidityMap()`:对每个键同时存在于 `GeneratedModuleHashes` 与 `CurrentModuleHashes` 且值相等的模块标 `ModuleJitValid[Name]=true`,否则 `false`;缺失的键也视为 `false` 并写 info 日志。
  - **关键点**:这一步必须发生在 AS 加载、运行 static initializer 把 `FStaticJITFunction` 塞进 `FJITDatabase::Functions` **之后**,但在第一次真正执行脚本函数**之前**。实际上 P0.2 已把"注册时 early-return"条件改为 `!IsModuleJitValid(Owner)`,所以在"加载 precompiled data → build validity → JIT 函数调用"的时序里,注册端只需保证 validity map 在首次函数调用前就位;把 `BuildModuleValidityMap()` 挂到 `AngelscriptEngine.cpp:1632` `bStaticJITTranspiledCodeLoaded = FJITDatabase::Get().Functions.Num() > 0` **前一行**,既早于首次函数触达,也避免 AS 加载阶段的临时状态参与判定。
  - 注意:这一步**还**要反过来清理已经被 `FStaticJITFunction` 静态初始化阶段塞进 `FJITDatabase::Functions` 的失配模块条目 —— 因为 static initializer 远早于 `InitialCompile()`,那时模块尚不存在,无法 early-return。实现方式是 `BuildModuleValidityMap()` 内按 `FunctionId → asIScriptFunction*->module->name` 回查,失配模块的函数从 Functions/Types/GlobalVars/PropertyOffsets 四张表里**按模块删除**(保持 API 对称),同时标记 `bStaticJITModuleInvalidated_<name>=true` 供 `as.StaticJIT.Status` 报告。
  - `as.StaticJIT.Status` 扩展一段"Modules: Valid=N, Invalidated=M (names: ...)",让开发者能一眼看出哪些模块走的解释器。
- [ ] **P1.5** 📦 Git 提交:`[Runtime/StaticJIT] Feat: per-module source hash validation at script load`

- [ ] **P1.6** 模块级失配单元测试
  - 在 `AngelscriptTest/StaticJIT/AngelscriptStaticJITModuleHashTests.cpp` 覆盖:
    - **基线一致**:同一份 `.as` 内容两次哈希 → 相等。
    - **内容变更**:改动 section 内任一字节 → 哈希变化。
    - **section 顺序无关**:同一模块在两次加载中 section 添加顺序不同但名字集合一致 → 哈希相等(验证字典序拼接)。
    - **模块级 Invalidate**:伪造两个模块 A/B,A 失配、B 对齐,调 `BuildModuleValidityMap` 后 `FJITDatabase.Functions` 里 A 的条目被清、B 的保留;`as.StaticJIT.Status` 报告 `Invalidated: [A]`。
    - **Status 输出可解析**:`as.StaticJIT.Status` 的文本包含 "Modules:" 段,字段顺序稳定。
  - 前缀 `Angelscript.TestModule.StaticJIT.ModuleHash.*`。
- [ ] **P1.6** 📦 Git 提交:`[Test/StaticJIT] Test: cover per-module source hash invalidation`

### Phase 2:UHT ABI 指纹导出器

> 目标:让 C++ 构建的任何 offset/size/signature 变动都被一次性映射成 128-bit `FGuid`,并在 `AngelscriptRuntime` dll 中以 `AS_FORCE_LINK` 静态初始化的形式可读。

- [ ] **P2.1** 新增 `AngelscriptJITAbiSignatureGenerator.cs` 收集与哈希骨架
  - 仿 `AngelscriptFunctionTableCodeGenerator.cs` 的结构:`LoadSupportedModules`、`CollectEntries`、`DeleteStaleOutputs`、`WriteGenerationSummary`。
  - 扫描单元与 `AngelscriptFunctionTableExporter` 对齐(`IsBlueprintCallable` + `ShouldGenerate` + `IsSupportedHeader`),避免两套口径分叉。
  - 每条收集项串化为确定性文本(类名/字段名/偏移/大小/对齐/函数签名),按类名字典序排序后做 FNV-1a 128-bit 或 SHA1 → 取前 128 位折成 `FGuid`;最终 `FGuid` 作为模块级 ABI 指纹。
- [ ] **P2.1** 📦 Git 提交:`[UHTTool/StaticJIT] Feat: add abi signature generator skeleton`

- [ ] **P2.2** 新增 `[UhtExporter]` 与输出文件
  - `AngelscriptJITAbiSignatureExporter.cs` 挂 `[UhtExporter(Name="AngelscriptJITAbiSignature", CppFilters=["AS_JITAbiSignature_*.cpp"], ModuleName="AngelscriptRuntime", Options=UhtExporterOptions.Default | UhtExporterOptions.CompileOutput)]`,调 Generator 产出:
    - `AS_JITAbiSignature_AngelscriptRuntime.cpp`:包含 `AS_FORCE_LINK static const FAngelscriptUHTAbiSignature UHTAbiSig(FGuid(A,B,C,D));`
    - `AS_JITAbiSignature_Entries.csv`(调试用,谁变了指纹跟着变)
    - `AS_JITAbiSignature_Summary.json`(对齐现有 `AS_FunctionTable_Summary.json` 的风格)
  - 文件命名用 `AS_JITAbiSignature_*` 前缀,方便 `DeleteStaleOutputs` 与现有 `AS_FunctionTable_*` 区分。
- [ ] **P2.2** 📦 Git 提交:`[UHTTool/StaticJIT] Feat: emit abi signature cpp and csv from uht`

- [ ] **P2.3** `AngelscriptRuntime` 端接入 ABI 指纹单例
  - `StaticJITHeader.h` 新增 `struct ANGELSCRIPTRUNTIME_API FAngelscriptUHTAbiSignature { FGuid Guid; FAngelscriptUHTAbiSignature(FGuid InGuid); static const FAngelscriptUHTAbiSignature* Get(); };`
  - `StaticJITHeader.cpp` 补单例实现;`GetCurrentUHTAbiSignature()` 可以被 `AngelscriptEngine.cpp` 的 P1.1 占位分支直接消费,把占位的 `FGuid()` 换成真值。
- [ ] **P2.3** 📦 Git 提交:`[Runtime/StaticJIT] Feat: consume uht abi signature singleton at load`

- [ ] **P2.4** 指纹稳定性与变更检测测试
  - `AngelscriptStaticJITAbiSignatureTests.cpp` 新增两个层面:
    - **Stability**:Generator 对同一份固定输入跑两次,`FGuid` 必须一致(C# 侧用 xUnit? 当前仓无 C# 测试框架,退而使用 C++ 端用"指纹计算纯函数封装"的 re-entrancy 测试 + 一个生成物比对的 smoke test)。
    - **ChangeDetection**:构造一个假 property offset 增减用例,指纹必须不同。
  - 若 C# 没有现成测试入口,测试落到 C++ 端——比对 `AS_JITAbiSignature_Entries.csv` 的文本指纹稳定性,作为代理口径,并在 Plan 注释里写清口径。
- [ ] **P2.4** 📦 Git 提交:`[Test/StaticJIT] Test: verify abi signature stability and change detection`

### Phase 3:Commandlet 与 Tools 自动化

> 目标:把现有"`-as-generate-precompiled-data` 启动 → 游戏 ForceExit"流程搬到命令行,并串起"一次编译 → Commandlet → 二次编译"。

- [ ] **P3.1** 实现 `UAngelscriptGenerateStaticJITCommandlet`
  - 位置 `Plugins/Angelscript/Source/AngelscriptEditor/Commandlets/AngelscriptGenerateStaticJITCommandlet.{h,cpp}`。
  - `Main` 解析 `-Output=...`(默认 `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/Generated/`)、`-EmitDebugMetadata`、`-FailOnEmpty`。
  - 仿 `AngelscriptStaticJIT.cpp:3743` 的 `GenerateStaticJITSourceTextForTesting`:新建 `FAngelscriptStaticJIT JIT`,`bGenerateOutputCode=true`,`ScriptEngine->SetJITCompiler(&JIT)`,对每个脚本模块调 `JITCompile()`,再 `JIT.WriteOutputCode(&GeneratedFiles)`。
  - 把内存里的文件写到磁盘(复用 `WriteOutputCode` 自己的落盘 diff 逻辑,也可以走 `OutGeneratedFiles` 自行按差异化落盘)。
  - **全局指纹**:在生成物的 `AngelscriptJitInfo.jit.cpp` 模板里多塞一行 `FStaticJITCompiledInfo` 构造参数——`FGuid(UHTAbiSigMajor, ... )`,值来自 `FAngelscriptUHTAbiSignature::Get()->Guid`(确保 Commandlet 运行时 P2.3 单例已可用)。
  - **模块指纹**:`WriteOutputCode` 的每模块输出段(`AngelscriptStaticJIT.cpp:3599` 处 `for(auto ModuleElem : JITFiles)`)里,在 `STANDARD_HEADER` 之后、模块 JIT 函数定义之前,额外 emit:
    ```cpp
    AS_FORCE_LINK static const FStaticJITModuleInfo JitMod_<ModuleSymbol>(
        TEXT("<ModuleName>"),
        FGuid(<A>, <B>, <C>, <D>));
    ```
    `<ModuleName>` 取 `File.ModuleName`(已有字段);`FGuid` 由同一份 `ComputeAngelscriptModuleSourceHash()` 生成,**生成端与运行时端必须调用同一个 C++ 纯函数**(放 `StaticJIT/StaticJITModuleHash.{h,cpp}`),避免哈希算法分叉。
  - 同时产出 `JitManifest.json`:文件列表 + UHT 指纹 + `PrecompiledDataGuid` + 每模块 `{ModuleName, SourceHash, OutputFile}` 清单 + 时间戳 + 脚本根目录(为 Phase 5 的预处理接口做准备)。
  - 处理 `WriteOutputCode` 当前的 "unity build" 合并(`AngelscriptStaticJIT.cpp:3666+` 处把多模块合进 `AngelscriptJitCode_<idx>.jit.cpp`):模块指纹 `FStaticJITModuleInfo` 静态初始化器放在模块自身的 `.jit.hpp` 里即可,`AS_FORCE_LINK` 会保证在 unity include 的大 `.cpp` 里也被保留。
- [ ] **P3.1** 📦 Git 提交:`[Editor/StaticJIT] Feat: add AngelscriptGenerateStaticJIT commandlet`

- [ ] **P3.2** 把 Commandlet 接到 `as.StaticJIT.Regenerate` 与 Editor 菜单
  - `AngelscriptEditor` 里新增 `FAngelscriptStaticJITMenu`(或直接挂在 `AngelscriptEditorModule.cpp` 的菜单扩展上):子菜单 "Static JIT" → Status / Clear / Regenerate。
  - `as.StaticJIT.Regenerate` 与菜单 "Regenerate" 都以内建进程启动 `UnrealEditor-Cmd.exe` 或复用 `FMonitoredProcess` 跑自身 Commandlet(根据当前进程能否复用编辑器状态来选);最低实现可以先打日志告知"请运行 Tools\GenerateStaticJIT.ps1",避免进程内重入 AS 引擎的复杂度。
- [ ] **P3.2** 📦 Git 提交:`[Editor/StaticJIT] Feat: hook regenerate command to editor menu and cvar`

- [ ] **P3.3** 新增 `Tools\GenerateStaticJIT.ps1` 与 `RunBuild.ps1` 对接
  - 新脚本职责:按 `AgentConfig.ini` 的 `Paths.EngineRoot` 拿引擎位置 → 跑一次 `Tools\RunBuild.ps1`(含 UHT,产出 `AS_JITAbiSignature_*` + 空/旧 `Generated/`)→ 调 `UnrealEditor-Cmd.exe <uproject> -run=AngelscriptGenerateStaticJIT -Unattended -NullRHI` → 再跑一次 `Tools\RunBuild.ps1`。
  - `Tools\Shared\UnrealCommandUtils.ps1` 如需新增 "Start-UnrealCommandlet" 助手则在此集中。
  - `Tools\RunBuild.ps1` 接 `-GenerateStaticJIT` 开关,默认关闭;开启时调新脚本。
- [ ] **P3.3** 📦 Git 提交:`[Tools/StaticJIT] Feat: add GenerateStaticJIT.ps1 and RunBuild integration`

- [ ] **P3.4** Commandlet smoke test
  - `AngelscriptStaticJITCommandletTests.cpp`:用最小的两个 `.as` 模块跑 Commandlet(优先用进程内 commandlet fixture;若不可行则作为 explicit 外部测试,按 `Documents/Guides/Test.md` 的约定标注)。
  - 验证:产物数量 > 0、`JitManifest.json` 含 `UHT` 指纹 + `PrecompiledDataGuid` + `Modules[].SourceHash` 字段齐全、`AngelscriptJitInfo.jit.cpp` 里的两个全局 `FGuid` 字段都已被填充、每个模块 `.jit.hpp` 开头都含一条 `FStaticJITModuleInfo` 注册。
  - 进一步:修改其中一个模块的 `.as` 文本(追加一行空白)后重跑,验证该模块的 `FGuid` 已改变、另一个模块的未变 —— 把 Commandlet 产物比对文本作为测试断言基础。
- [ ] **P3.4** 📦 Git 提交:`[Test/StaticJIT] Test: commandlet smoke test on minimal script`

### Phase 4:Live Coding 集成

> 目标:让 Live Coding Patch 不会让 JIT 指针静默失配而崩。

- [ ] **P4.1** 订阅 `ILiveCodingModule::GetOnPatchCompleteDelegate()`
  - 在 `AngelscriptEditor/Core/AngelscriptEditorModule.cpp:807` 附近 `FClassReloadHelper::Init()` 同一阶段添加 `ILiveCodingModule` 的 `IsAvailable()` + `OnPatchComplete` 注册,回调里:`FJITDatabase::Get().Invalidate()` + `FAngelscriptEngine::Get().bJitInvalidatedByLiveCoding = true` + `UE_LOG(Angelscript, Warning, TEXT("Live Coding patched native modules, Static JIT disabled until editor restart or regenerate."))`。
  - 模块卸载时解绑,避免悬挂委托。
- [ ] **P4.1** 📦 Git 提交:`[Editor/StaticJIT] Feat: invalidate jit on live coding patch complete`

- [ ] **P4.2** Live Coding 失效测试
  - 无法直接模拟 Live Coding,按 `Plan_ASDebuggerUnitTest.md` 里使用委托反射的风格,手动 Broadcast `OnPatchComplete`;验证 `FJITDatabase` 被清、`as.StaticJIT.Status` 报告原因含 "LiveCoding"。
- [ ] **P4.2** 📦 Git 提交:`[Test/StaticJIT] Test: simulate live coding patch and verify invalidation`

### Phase 5:`.as` 预处理接口占位

> 目标:只落接口 + 清单,留给后续语义层 Plan。

- [ ] **P5.1** 新增 `FAngelscriptScriptPreprocessor` 抽象
  - 放 `AngelscriptRuntime/Core/AngelscriptScriptPreprocessor.{h,cpp}`,纯虚接口 + 默认 no-op 实现 `FAngelscriptNoOpScriptPreprocessor`。
  - `AngelscriptEngine.cpp` 在 `DiscoverScriptRoots` 下游 / `InitialCompile` 上游插入一个"若注入了 preprocessor 就调用 `ProcessScriptRoots(TArray<FString>& InOutRoots)`"钩子,默认路径零行为变化。
- [ ] **P5.1** 📦 Git 提交:`[Runtime/AS] Feat: introduce FAngelscriptScriptPreprocessor abstraction`

- [ ] **P5.2** Commandlet 产出脚本清单
  - `JitManifest.json` 增加 `ScriptFiles` 数组,按字典序列出所有被 AS 编译的 `.as` 相对路径 + `FMD5` hash,供后续增量判断使用。
  - 只增加字段,不变既有字段顺序,避免破坏 Phase 3 刚写的 smoke test。
- [ ] **P5.2** 📦 Git 提交:`[Editor/StaticJIT] Feat: include script manifest in JitManifest.json`

### Phase 6:文档与入口同步收尾

> 目标:确保后来者不需要翻 commit 历史就能找到入口、命令和状态自检方法。

- [ ] **P6.1** 同步 `AGENTS.md` / `AGENTS_ZH.md` 的 Key Paths
  - 追加 `StaticJIT/Generated/`、`AngelscriptEditor/Commandlets/`;若 CVar/菜单/控制台命令需要登记,在对应"Document Navigation"附近补。
- [ ] **P6.1** 📦 Git 提交:`[Docs/AGENTS] Docs: register static jit offline pipeline paths`

- [ ] **P6.2** 更新 `Documents/Guides/Build.md` 与 `Documents/Tools/Tool.md`
  - 登记 `Tools\GenerateStaticJIT.ps1` 两次编译流程、Commandlet 命令行、`as.StaticJIT.*` 全套 CVar。
  - 如果现有 `Guides/Test.md` / `Guides/TestCatalog.md` 提到 StaticJIT 测试目录,加上新增的三组前缀。
- [ ] **P6.2** 📦 Git 提交:`[Docs/Guides] Docs: document static jit offline generation workflow`

- [ ] **P6.3** 在 `Plan_OpportunityIndex.md` / `Plan_StatusPriorityRoadmap.md` 登记本 Plan
  - 索引加入"Static JIT 构建期前置生成"一栏,状态 `Active`;完成后归档到 `Documents/Plans/Archives/` 并同步 `Archives/README.md`。
- [ ] **P6.3** 📦 Git 提交:`[Docs/Plans] Docs: index static jit offline generation plan`

## 验收标准

- `Tools\RunBuild.ps1` / `Tools\GenerateStaticJIT.ps1` 一次性跑完全流程,产出 `StaticJIT/Generated/AngelscriptJitInfo.jit.cpp` 与 `JitManifest.json`,不依赖游戏手动启动退出。
- 全新构建里 `AngelscriptJitInfo.jit.cpp` 同时携带 `PrecompiledDataGuid` 与 `AbiSignatureGuid`,且每个模块的 `.jit.hpp` 含 `FStaticJITModuleInfo(TEXT("<Name>"), FGuid(...))` 注册行;运行时 `as.StaticJIT.Status` 报告 `AbiMatch=true`、`Modules: Valid=N, Invalidated=0` 且 `FJITDatabase.Functions.Num() > 0`。
- 人为改动 `AngelscriptRuntime` 内某个 UPROPERTY 的顺序导致 UHT 指纹变化后,**无需重跑 Commandlet**,运行时加载日志必有 Warning 指出 ABI 指纹失配,`FJITDatabase` 被整体清空(全局级失配),游戏继续以解释器运行,不崩溃。
- 人为只改动某一个 `.as` 文件(例如在一个函数内加一行注释),**无需重跑 Commandlet**,运行时:该模块走解释器,`as.StaticJIT.Status` 列出 `Invalidated: [<ThatModule>]`;其他未改动模块 `FJITDatabase` 条目保留,`Valid=N-1`,不崩溃。
- 跑一次 `GenerateStaticJIT.ps1` 后再启动游戏,上述模块重新对齐,`Valid` 重新回到满值。
- Editor 启动后 `as.StaticJIT.Status` 显示 `Enabled=false`(Editor 默认关闭);`as.StaticJIT.Enabled 1` 切换后提醒重启;Live Coding Patch 触发后 `Status` 显示 `Invalidated by LiveCoding`。
- `Angelscript.TestModule.StaticJIT.Invalidate.*`、`Angelscript.TestModule.StaticJIT.AbiSignature.*`、`Angelscript.TestModule.StaticJIT.ModuleHash.*`、`Angelscript.TestModule.StaticJIT.Commandlet.*` 全部通过。
- `Documents/Guides/Build.md` / `Documents/Tools/Tool.md` / `AGENTS.md` 能让新人在 10 分钟内根据文档跑出 Commandlet 产物。

## 风险与注意事项

### 风险

1. **两次编译无法彻底消除**:UHT 要拿 ABI 指纹,Commandlet 要基于已编 dll 跑 AS;Commandlet 输出要再次参与 C++ 编译。风险是"增量条件下仍然冗余两次全量编译",退路是 `JitManifest.json` 指纹一致就跳过第二次编译(对 UBT 来说纯增量 link)。实施时在 `Tools\GenerateStaticJIT.ps1` 里先做 `Guid-diff` 短路。
2. **C# 哈希一致性**:C# 的 FNV/SHA 实现需保证字节序与 C++ 读取端一致,否则 ABI 指纹会在不同平台/不同 .NET 版本下漂移。缓解:统一用大端字节表示 → `FGuid(A,B,C,D)` 写死四段 `uint32`,并在 P2.4 用 CSV 文本指纹作代理测试。**注意**:模块级源码哈希不走 C# 路径(完全在 C++ 端的 `ComputeAngelscriptModuleSourceHash` 里,生成端与运行时端共享同一实现),因此没有跨语言漂移风险。
3. **Commandlet 内重入 AS 引擎**:Editor 菜单里的 "Regenerate" 直接在进程内再跑一遍 JIT,会有 AS 全局状态冲突。缓解:P3.2 的菜单默认外部启动 `UnrealEditor-Cmd.exe`,进程内重入改为后续优化项。
4. **`AS_SKIP_JITTED_CODE` 改造回归**:把 Editor 从"硬跳过"改成"按 `AS_HAS_PRECOMPILED_JIT_CODE` 条件"后,可能让从未生成过 JIT 的开发机链接失败。缓解:Build.cs 里显式探测 `Generated/` 是否存在 → 不存在不定义宏,行为与今天等价。
5. **模块级失配判定时序**:`FStaticJITFunction` 静态初始化远早于 AS 加载,此时 `CurrentModuleHashes` 还是空表;P1.5 通过"加载期统一 `BuildModuleValidityMap()` + 回扫 `FJITDatabase::Functions` 按模块摘除"处理。风险是若有新注册 API 绕过 `FStaticJITFunction` 直接写 `FJITDatabase`,会绕过模块级过滤。缓解:所有注册 API(`FJitRef_Function` / `FJitRef_Type` / `FJitRef_GlobalVar` / `FJitRef_PropertyOffset`)的构造函数里统一走 `FJITDatabase::Get().IsModuleJitValid(OwnerModuleName)` 早退,并在 P1.6 测试里验证每种 Ref 类型都被约束。
6. **AS 模块名冲突**:`FStaticJITModuleInfo::ModuleName` 用 `FName(GetName())`,AS 允许同名模块出现在不同脚本根路径下(罕见但可能,尤其是插件脚本与项目脚本重名)。缓解:若 `FJITDatabase::GeneratedModuleHashes` 出现重复键,`FStaticJITModuleInfo` 构造函数写 Fatal log 并把该名字标为"永久失配",让开发者在本地一次性看到;该场景等价于"命名冲突的模块都走解释器",不破坏其他模块。
7. **section 文本换行符漂移**:Windows / Unix 换行符不同会导致 MD5 不同,跨平台开发或 git autocrlf 会诱发无谓的模块失配。缓解:`ComputeAngelscriptModuleSourceHash` 读取 section 前统一把 `\r\n` → `\n`;同时 Commandlet 生成端与运行时端都走同一函数,语义一致即可(不必追求跨仓一致)。

### 已知行为变化

1. **`FStaticJITCompiledInfo` 构造函数签名**:新增 `FGuid AbiSignatureGuid` 参数。现有生成物 `AngelscriptJitInfo.jit.cpp` 由 `WriteOutputCode` 自己产出,不会手动维护,但**任何旧版产物 + 新运行时必然失配并被清空**;发版过程中需要一次性重新跑 `GenerateStaticJIT.ps1`。
   - 影响文件:`StaticJIT/AngelscriptStaticJIT.cpp` 的 `WriteOutputCode`(大约 L3710)、`StaticJIT/StaticJITHeader.{h,cpp}`。
2. **`WriteOutputCode` 模块输出段多一行静态初始化**:每个模块 `.jit.hpp` 会被额外加上一条 `AS_FORCE_LINK static const FStaticJITModuleInfo JitMod_<Name>(TEXT("<Name>"), FGuid(...))`;旧的全量 `AS_JITTED_CODE/` 目录需要清空一次,否则旧 `.jit.hpp` 缺该字段会触发"所有模块都失配"(行为安全但会丢失所有 JIT)。
3. **`StaticJITConfig.h:8-10` 的 `AS_SKIP_JITTED_CODE` 语义**:从"Editor 硬跳过"变为"无生成物才跳过"。所有基于 `#ifdef AS_SKIP_JITTED_CODE` 的条件编译块需要按文件逐一确认仍然等价,涉及 `StaticJIT/` 下若干 `.cpp` 的链接面。
4. **Editor 默认 JIT 关闭**:与今天"Editor 根本不编 JIT"的现象一致,但增加了 `as.StaticJIT.Enabled=1` 的显式切换路径;文档与 onboarding 需同步说明。
5. **Live Coding Patch 触发后 JIT 不自动恢复**:需要重启 Editor 或手动 Regenerate。测试里若某些流程依赖 Live Coding 后仍有 JIT,需要调整预期或在 `Invalidate` 后显式重建 context。
6. **新控制台命令注册**:Editor 启动日志会新增 `LogConsoleResponse: Registered as.StaticJIT.*`;检测日志 regression 的脚本(若有)需要接收新条目。
7. **`as.StaticJIT.Status` 文本格式扩展**:从原来的"Enabled/Functions"两行扩展为包含 "Modules: Valid=N, Invalidated=M (names: ...)" 段。任何解析这条命令输出的外部工具(若有)都要更新解析逻辑。

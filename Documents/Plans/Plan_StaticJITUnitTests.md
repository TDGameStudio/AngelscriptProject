# Static JIT 单元测试实施计划

## 背景与目标

### 背景

`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/` 目前已经承载了 Static JIT 的核心实现，包括：

- `PrecompiledData.h/.cpp`：预编译模块、函数、类、属性、全局变量与引用补丁逻辑。
- `StaticJITBinds.h/.cpp`：`FScriptFunctionNativeForm` 与 `SCRIPT_NATIVE_*` 绑定分发入口。
- `AngelscriptStaticJIT.h/.cpp`：`FAngelscriptStaticJIT`、`FStaticJITContext`、`FJITDatabase` 等 JIT 编译与运行时注册表。
- `StaticJITConfig.h`：`AS_CAN_GENERATE_JIT`、`AS_SKIP_JITTED_CODE`、`AS_JIT_VERIFY_PROPERTY_OFFSETS` 等编译期约束。

但当前仓库内与 Static JIT 直接相关的自动化测试只有 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp`，而且只覆盖了两个回归点：

1. `FAngelscriptPrecompiledClass` 对 `asOBJ_EDITOR_ONLY` 等高位 flag 的 round-trip。
2. `asCModule::DiffForReferenceUpdate()` 对高位 flag 的结构变化判断。

这意味着 Static JIT 的绝大多数 deterministic 路径仍然没有单元测试保护：`PrecompiledData` 的类型/模块重建、`FScriptFunctionNativeForm` 的 native form 选择、`FJITDatabase` 的全局注册表状态等一旦漂移，只能靠更高层回归或人工排查发现。

另外，`StaticJIT` 相关代码大量依赖 `FAngelscriptEngine` 与 `source/as_*.h` 内部类型，不适合放到 `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`。首轮测试应继续沿用 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 的 `Angelscript.TestModule.CppTests.*` 层级，保持与现有 `AngelscriptPrecompiledDataTests.cpp` 一致的内部测试模式。

### 目标

1. 为 Static JIT 建立一套**首轮纯单元/窄依赖自动化测试**，优先覆盖最稳定、最值得回归的 deterministic 路径。
2. 固定 Static JIT 单元测试的**目录落点、命名前缀、运行命令与文档入口**，避免后续新增测试继续散落。
3. 明确首轮只做 **EditorContext 下可稳定运行的单元测试**，不把 cooked/package/JIT 产物执行验证混入本计划。

## 范围与边界

- **范围内**
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
  - `Documents/Guides/Test.md`
  - `Documents/Guides/TestCatalog.md`
- **范围外**
  - 真实 generated `.as.jit.hpp` 全量文本 snapshot
  - cooked/package 后执行真正 jitted 产物的端到端验证
  - HotReload、Scenario、World/Actor/Blueprint 级场景测试
  - 与 Static JIT 单元测试无直接关系的运行时代码修复
- **边界约束**
  - 新增测试默认落在 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`，使用 `Angelscript.TestModule.CppTests.StaticJIT.*` 前缀；**不要**放进 `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`。
  - 测试可以继续使用 `FAngelscriptEngine::CreateForTesting(...)`、`StartAngelscriptHeaders.h` 与 `source/as_*.h`，但要像现有 Runtime tests 一样，把 fixture 控制在最小范围内。
  - 由于 `StaticJITConfig.h` 在 `WITH_EDITOR` 下定义了 `AS_SKIP_JITTED_CODE`，首轮测试应验证**数据、绑定选择、注册表状态**，不要把“执行真正 jitted 代码”当作完成条件。

## 当前事实状态

### 关键代码与测试映射

| 路径 | 当前职责 | 当前测试状态 |
| --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h` | 预编译数据结构定义，含 `FAngelscriptPrecompiledDataType`、`FAngelscriptPrecompiledFunction`、`FAngelscriptPrecompiledClass`、`FAngelscriptPrecompiledModule` | 仅有高位 flag 回归，没有覆盖类型/模块重建主路径 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.cpp` | round-trip、引用补丁、stage apply 逻辑 | 无针对 `ApplyToModule_Stage1/2/3` 的单元测试 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.h` | `FScriptFunctionNativeForm` 与 `SCRIPT_NATIVE_*` 绑定入口 | 无 direct tests |
| `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h` | `FAngelscriptStaticJIT`、`FStaticJITContext`、`FJITDatabase` | `FJITDatabase` 无 direct tests |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp` | Static JIT 现有 runtime test 入口 | 仅 2 个 regression，用例面过窄 |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptBytecodeTests.cpp` | 说明仓库允许通过内部 header 测低层引擎细节 | 可借鉴命名与 minimal fixture 方式，但 Static JIT 首轮仍以 Runtime tests 为主 |

### 测试层级决策

本计划固定将 Static JIT 单元测试放在 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`，原因如下：

1. 现有 `AngelscriptPrecompiledDataTests.cpp` 已证明 Runtime tests 层可以合法访问 `FAngelscriptEngine` 与 `source/as_*.h`，且命名是 `Angelscript.TestModule.CppTests.StaticJIT.*`，最符合当前仓库事实。
2. `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` 的边界是“只用 `AngelscriptInclude.h` / `angelscript.h` 暴露的公共 API”，而 Static JIT 的预编译/绑定/数据库测试显然越过了这条边界。
3. 首轮要补的是 deterministic 低层逻辑，不需要 World/Actor/Editor helper；放进 `AngelscriptRuntime/Tests/` 能避免把测试层级人为抬高。

## 建议文件落点

### 新增文件

- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptStaticJITModuleRoundtripTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptStaticJITNativeFormTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptStaticJITDatabaseTests.cpp`

### 修改文件

- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp`
- `Documents/Guides/Test.md`
- `Documents/Guides/TestCatalog.md`

## 执行前置命令速查

### 构建

先按 `Documents/Guides/Test.md` 读取 `AgentConfig.ini`，然后构建 `AngelscriptProjectEditor`：

对 Editor 目标使用 `Tools\RunBuild.ps1`（例如加 `-Label debug-static -TimeoutMs 180000 -- -SerializeByEngine`），避免直接调用 `Build.bat` 并保持与共享 `AgentConfig.ini` 的路径/超时一致。

### Static JIT 测试前缀

推荐统一前缀：

```text
Angelscript.TestModule.CppTests.StaticJIT
```

### 运行命令

```powershell
powershell.exe -ExecutionPolicy Bypass -File "Tools\RunTests.ps1" -TestPrefix "Angelscript.TestModule.CppTests.StaticJIT" -Label "StaticJIT_Unit"
```

## 分阶段执行计划

### Phase 1：补齐 PrecompiledData 主路径回归

> 目标：先把 `PrecompiledData` 的类型、模块与 stage apply 主路径覆盖起来，让 Static JIT 最核心的序列化/重建链路不再只有两个高位 flag 回归点。

- [ ] **P1.1** 扩展 `AngelscriptPrecompiledDataTests.cpp` 覆盖 `FAngelscriptPrecompiledDataType` 的核心分支
  - 当前文件只保护 editor-only/high-bit flag 回归，`InitFrom()` / `Create()` 的 primitive、object handle、reference、auto 等主分支仍然裸奔；这些分支一旦漂移，会直接污染 `PrecompiledFunction`、`PrecompiledProperty`、`PrecompiledGlobalVariable` 的所有重建路径。
  - 继续沿用现有 `FAngelscriptEngine::CreateForTesting(..., EAngelscriptEngineCreationMode::Clone)` 与局部 `asCModule` / `asCObjectType` fixture，不额外新建测试层，也不把这类内部类型 round-trip 测试移到 `AngelscriptTest/AngelScriptSDK/`。
  - 至少为四类输入建立显式断言：primitive、object-handle、reference、auto。断言不仅看 `operator<<` 序列化后的字段，还要验证 `Create()` 还原出的 `asCDataType` 与原始输入在 token、handle、const、reference 语义上保持一致。
- [ ] **P1.1** 📦 Git 提交：`[StaticJIT] Test: expand precompiled datatype roundtrip coverage`

- [ ] **P1.2** 新增 `AngelscriptStaticJITModuleRoundtripTests.cpp`，覆盖 `FAngelscriptPrecompiledModule` 的 end-to-end stage apply
  - `PrecompiledData.h` 已公开 `FAngelscriptPrecompiledModule::InitFrom()` 与 `ApplyToModule_Stage1/2/3()`，但当前没有任何自动化测试证明“一个真实 module 经预编译后还能按三阶段恢复类、函数、全局与 import 信息”。
  - 使用最小脚本/模块 fixture 构造一个包含全局函数、脚本类、属性、全局变量的 module，执行 `InitFrom()` → 序列化/反序列化 → `ApplyToModule_Stage1/2/3()`，最后在新 module 中断言类名、方法数、全局变量、声明事件/委托、脚本相对路径等关键状态都保持一致。
  - 不在首轮对整份 bytecode 或生成文本做全文 snapshot；重点验证结构恢复、关键字段、stage apply 顺序，以及恢复后 module 可以被查询和继续使用。
- [ ] **P1.2** 📦 Git 提交：`[StaticJIT] Test: add precompiled module roundtrip coverage`

### Phase 2：补齐 native form 与 JIT 数据库单元测试

> 目标：让 Static JIT 绑定分发与运行时注册表这两块“失败后很难靠高层日志定位”的区域，至少拥有 deterministic、可重复的低层保护。

- [ ] **P2.1** 新增 `AngelscriptStaticJITNativeFormTests.cpp`，覆盖 `FScriptFunctionNativeForm::GetNativeForm()` 与常见 native form 能力位
  - `StaticJITBinds.h` 暴露的 `FScriptFunctionNativeForm` 是 Static JIT 能否走 AngelScriptSDK/custom/pointer call 的关键分发点，但当前仓库没有任何 direct test 保护 `GetNativeForm()`、`IsTrivialFunction()`、`CanCallNative()` 这类判定逻辑。
  - 通过最小绑定 fixture 注册至少一类 trivial native function、一类 native method，必要时补一类 UFunction/native constructor 场景，验证 `GetNativeForm()` 返回非空且能力位与绑定时声明的 trivial/custom 行为一致；同时补一个未绑定或不适用场景，防止“任何函数都误命中 native form”。
  - 该文件内部继续使用 `#if AS_CAN_GENERATE_JIT && WITH_DEV_AUTOMATION_TESTS` 与最小引擎夹具，不把测试设计成依赖真实 jitted 代码执行。
- [ ] **P2.1** 📦 Git 提交：`[StaticJIT] Test: cover native form resolution and capabilities`

- [ ] **P2.2** 新增 `AngelscriptStaticJITDatabaseTests.cpp`，覆盖 `FJITDatabase` 的 singleton 与清理语义
  - `FJITDatabase` 持有 `Functions`、`FunctionLookups`、`GlobalVarLookups`、`TypeInfoLookups`、`PropertyOffsetLookups` 等全局状态；一旦 `Clear()` 漏清或测试污染顺序，后续 Static JIT 问题会变成高度偶现。
  - 为 `Get()` 的 singleton 稳定性、`Clear()` 的全量清空、以及 lookup array / map 的恢复行为建立显式断言，并在测试夹具中保存/恢复初始数据库状态，避免新测试本身成为跨 case 污染源。
  - 这一步只验证数据库状态机和容器语义，不在首轮把 `FAngelscriptStaticJIT::GenerateCppCode()` 的大量文本输出也一起拉进来，防止单元测试退化成脆弱 snapshot。
- [ ] **P2.2** 📦 Git 提交：`[StaticJIT] Test: add jit database state coverage`

### Phase 3：固定文档入口与首轮回归命令

> 目标：把新增 Static JIT 单元测试的前缀、层级与执行方式同步到文档，避免代码已经补齐而测试入口仍然只能靠记忆搜索。

- [ ] **P3.1** 更新 `Documents/Guides/Test.md`，明确 Static JIT 单元测试的层级与运行方式
  - 在现有自动化测试指南中补充 `Angelscript.TestModule.CppTests.StaticJIT` 前缀，说明这组测试属于 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 的 Runtime unit 层，适合 `NullRHI` + EditorContext 环境执行。
  - 明确写出本计划的边界：首轮验证 `PrecompiledData`、`NativeForm`、`FJITDatabase` 等 deterministic 单元，不把 cooked/package/JIT 产物执行纳入同一组回归。
  - 如果需要补充推荐执行顺序，就放在 `CppTests` / Runtime unit 小节下，不要新开与现有测试分层冲突的术语桶。
- [ ] **P3.1** 📦 Git 提交：`[StaticJIT] Docs: document runtime unit test entrypoints`

- [ ] **P3.2** 更新 `Documents/Guides/TestCatalog.md` 并完成首轮 Static JIT 前缀回归记录
  - 在测试目录文档中补充 `Angelscript.TestModule.CppTests.StaticJIT.PrecompiledData.*`、`Angelscript.TestModule.CppTests.StaticJIT.Module.*`、`Angelscript.TestModule.CppTests.StaticJIT.NativeForm.*`、`Angelscript.TestModule.CppTests.StaticJIT.Database.*` 的主题归属，避免后续再把 Static JIT 用例混成“无目录、无主题”的孤立测试。
  - 构建 `AngelscriptProjectEditor` 后执行 `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.StaticJIT"`，记录报告目录、日志路径和结果；如果某些 case 受 `AS_CAN_GENERATE_JIT` 或平台限制而跳过，也要在目录文档中说明，而不是默默接受灰色行为。
  - 这一步的完成标志不是“代码看起来写完了”，而是文档里已经出现可复用的前缀与首轮执行记录，后续任何人都能直接按该入口复跑。
- [ ] **P3.2** 📦 Git 提交：`[StaticJIT] Docs: catalog static jit unit coverage and verification`

## 验收标准

1. `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 中存在一组可按 `Angelscript.TestModule.CppTests.StaticJIT` 前缀筛选的 Static JIT 单元测试，至少覆盖：
   - `PrecompiledDataType` round-trip
   - `PrecompiledModule` stage apply / module round-trip
   - `FScriptFunctionNativeForm` 解析与能力位
   - `FJITDatabase` singleton / clear 语义
2. 现有 `AngelscriptPrecompiledDataTests.cpp` 的高位 flag 回归继续保留并通过，没有被新覆盖重写掉。
3. `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.StaticJIT"` 在当前 Windows editor 环境下可以作为稳定入口执行；若有平台/宏 gating，也有明确的测试内 skip 或文档说明。
4. `Documents/Guides/Test.md` 与 `Documents/Guides/TestCatalog.md` 已同步 Static JIT 的测试层级、前缀与首轮执行结果。
5. 整个首轮方案没有把 Static JIT 低层测试错误地下沉到 `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`，也没有把非 deterministic 的 generated code 全文 snapshot 当作主要回归手段。

## 风险与注意事项

- `StaticJITConfig.h` 在 `WITH_EDITOR` 下定义了 `AS_SKIP_JITTED_CODE`；这意味着 EditorContext 自动化测试更适合验证“数据是否可恢复、绑定是否可解析、数据库是否干净”，而不是验证真实 jitted 函数是否已经执行。
- `FJITDatabase` 是全局单例。若测试不显式清理/恢复状态，最容易出现“单测本身制造 flaky”的问题；这类恢复逻辑要作为 fixture 的一等职责，而不是 scattered cleanup。
- `PrecompiledData` 中很多 API 依赖真实 `asCModule` / `asCScriptFunction` / `asCObjectType`。首轮 fixture 应优先通过最小真实引擎对象构造，避免手写半残对象导致测试本身失真。
- `FScriptFunctionNativeForm` 的测试要关注“命中/不命中”和 capability bits 是否正确，不要依赖某份具体生成代码文本或地址值；否则测试会对实现细节过度耦合。
- 如果 Phase 1 执行后发现 `PrecompiledModule` round-trip 需要额外 helper，优先抽出 Runtime tests 内部的最小 fixture，而不是把 Static JIT 测试整体迁往更重的 `AngelscriptTest/` 层。

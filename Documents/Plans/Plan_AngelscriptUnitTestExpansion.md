# Angelscript 单元测试扩展与整理计划

## 背景与目标

### 背景

当前 `Plugins/Angelscript/Source/AngelscriptTest/` 已经积累了较多自动化测试，但从“插件可复用交付物”的角度看，测试体系仍有三类明显问题：

1. **目录与分层仍不够稳定**
   - `Examples/` 仍承担了较宽泛的示例/能力验证职责，部分测试本质上应回归到 `Bindings/`、`Delegate/`、`Actor/` 等具体主题目录。
   - 大量主题化测试虽然落在具体目录中，但注册路径仍使用 `Angelscript.TestModule.Scenario.*` 这一宽泛前缀，不利于按主题分组、并行和回归。
2. **文档基线与源码现状存在漂移**
   - `Documents/Guides/TestCatalog.md` 记录的是 `AngelscriptTest` 模块的 `275/275 PASS` 基线。
   - 直接扫描 `Plugins/Angelscript/Source/` 下测试宏与 spec 注册，当前插件源码中已存在约 `352` 个 automation/spec 测试入口，说明文档、目录口径与实际注册数量已经分离。
3. **高风险子系统的“纯单元/窄范围自动化”覆盖仍然不足**
   - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h`
   - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.h`
   - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptAbilitySystemComponent.h`
   - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptAttributeSet.h`
   - `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h`
   - `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/Network/FakeNetDriver.h`
   - `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.h`
   - `Plugins/Angelscript/Source/AngelscriptEditor/ContentBrowser/AngelscriptContentBrowserDataSource.h`

这些区域要么是 cooked/build critical path，要么是 Editor / Networking / GAS 等用户感知强、回归成本高的插件能力面；如果没有更明确的单元测试分层和执行入口，后续继续补测试会越来越散，无法支撑插件级稳定交付。

### 目标

1. 固定 Angelscript 插件的测试分层、目录归属、命名约定与执行分组，先把“测试怎么放、怎么跑、怎么统计”整理清楚。
2. 把当前宽泛的 `Examples/` / `Scenario.*` 使用收敛到更明确的主题目录和分组，不再让新增测试继续堆进模糊桶里。
3. 基于风险优先级，为 Runtime / Editor / 集成测试建立一份可分波次执行的新增单元测试路线图，优先覆盖 StaticJIT、BindDatabase、GAS、Debug、Networking、Editor Reload 等缺口。
4. 在文档与配置层明确回归入口，让后续执行者能够按 `Smoke` / `Unit` / `Editor` / `Scenario` 等组别逐步推进，并可在 `NullRHI`/并行日志隔离模式下复用。

## 范围与边界

- **范围内**
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
  - `Plugins/Angelscript/Source/AngelscriptEditor/Tests/`（本计划中允许新增）
  - `Plugins/Angelscript/Source/AngelscriptTest/`
  - `Documents/Guides/Test.md`
  - `Documents/Guides/TestCatalog.md`
  - `Config/DefaultEngine.ini`
- **范围外**
  - `Source/AngelscriptProject/` 宿主工程逻辑
  - 与测试补齐无直接关系的运行时功能重构
  - 图形截图 / 依赖 GPU 的视觉回归（本计划默认不扩展这类测试）
  - 未被新增测试直接暴露的问题修复；若新测试揭露运行时缺陷，需在单独的 bugfix 任务中处理
- **边界约束**
  - 绝大多数新增测试仍应优先落在插件目录内，不把插件逻辑回推到宿主工程。
  - `Plugins/Angelscript/Source/AngelscriptTest/` 下继续按具体主题组织，不新增泛化 `Scenarios/` 桶。
  - 新计划中的路径、命令与配置一律引用 `AgentConfig.ini` / 工程相对路径，不写死本机绝对路径。

## 当前事实状态

### 目录与测试层现状

```text
Plugins/Angelscript/Source/
  AngelscriptRuntime/
    AngelscriptRuntime.Build.cs
    Tests/
      AngelscriptCodeCoverageTests.cpp
      AngelscriptDependencyInjectionTests.cpp
      AngelscriptMultiEngineTests.cpp
      AngelscriptPrecompiledDataTests.cpp
      AngelscriptSubsystemOwnershipTests.cpp
      AngelscriptSubsystemTests.cpp
  AngelscriptEditor/
    AngelscriptEditor.Build.cs
    Private/
      ClassReloadHelper.h
      AngelscriptContentBrowserDataSource.h
  AngelscriptTest/
    AngelscriptTest.Build.cs
    Shared/
    Core/
    Angelscript/
    Bindings/
    Compiler/
    Preprocessor/
    HotReload/
    AngelScriptSDK/
    Actor/
    Blueprint/
    Component/
    Delegate/
    GC/
    Interface/
    Inheritance/
    Subsystem/
    Examples/
    Template/
    Editor/
```

### 已确认的关键事实

1. `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 已存在，适合作为 **纯 C++ / 窄范围 Runtime 单元测试层**。
2. `Plugins/Angelscript/Source/AngelscriptEditor/` 目前没有系统化测试目录，Editor 内部 helper 仍缺稳定测试入口。
3. `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` 已依赖 `CQTest`、`UnrealEd`、`AngelscriptEditor`，说明现有 Test 模块具备承载 EditorContext / 快速回归测试的基础条件。
4. `Config/DefaultEngine.ini` 当前没有 `AutomationTestSettings` 分组配置，测试组仍主要依赖路径前缀手工筛选。
5. `Documents/Guides/TestCatalog.md` 的 documented baseline 仍是 `275/275 PASS`，但源码扫描显示插件内已注册约 `352` 个 automation/spec 测试入口；Phase 0 必须先收敛文档与实际清单。
6. `Examples/` 当前仍包含至少以下“应迁回主题目录”的文件：
   - `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleArrayTest.cpp`
   - `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleMapTest.cpp`
   - `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleDelegatesTest.cpp`
   - `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleTimersTest.cpp`
   - `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleActorTest.cpp`

### 风险优先级排序

1. **Cooked / 缓存 / 序列化路径**
   - `StaticJIT/PrecompiledData.h`
   - `Core/AngelscriptBindDatabase.h`
2. **核心引擎与绑定扩展路径**
   - `Core/AngelscriptEngine.h`
   - `Core/AngelscriptType.h`
   - `Core/AngelscriptAbilitySystemComponent.h`
   - `Core/AngelscriptAttributeSet.h`
3. **Debug / Networking / Editor 工具链路径**
   - `Debugging/AngelscriptDebugServer.h`
   - `Testing/Network/FakeNetDriver.h`
   - `AngelscriptEditor/HotReload/ClassReloadHelper.h`
   - `AngelscriptEditor/ContentBrowser/AngelscriptContentBrowserDataSource.h`

## 目标测试分层与目录策略

为避免继续把所有自动化测试都塞进一个入口，本计划固定以下分层：

1. **Runtime Unit（纯 C++ / 窄依赖）**
   - 目录：`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
   - 适用：序列化、缓存、数据库、网络驱动、引擎生命周期、无 World/Asset 依赖的逻辑
2. **Editor Unit（Editor 内部 helper / 数据源）**
   - 目录：`Plugins/Angelscript/Source/AngelscriptEditor/Tests/`
   - 适用：Class reload、Content Browser、Editor-only helper、菜单/索引/数据源逻辑
3. **Plugin Fast Tests（带轻量引擎 helper 的快速回归）**
   - 目录：`Plugins/Angelscript/Source/AngelscriptTest/{Shared,Core,AngelScriptSDK,Bindings,Compiler,Preprocessor,ClassGenerator}`
   - 适用：脚本编译、绑定、预处理器、类生成、内部机制的快速验证
4. **Scenario / Integration（需要 World / Actor / Blueprint / PIE 风格上下文）**
   - 目录：`Plugins/Angelscript/Source/AngelscriptTest/{Actor,Blueprint,Component,Delegate,GC,HotReload,Interface,Inheritance,Subsystem,Template}`
   - 适用：生命周期、交互、热重载、蓝图集成、子系统行为
5. **Examples（仅保留示例/教学性质验证）**
   - 只保留真正需要验证“示例脚本仍能编译/运行”的用例；凡是明显属于具体主题的能力验证，都应迁回具体目录

### 现有目录 → 目标分层矩阵

| 当前目录 | 目标分层 | 处理规则 |
| --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` | Runtime Unit | 保持为纯 C++ / 窄依赖测试层，优先承接缓存、序列化、引擎生命周期、网络驱动类测试 |
| `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` | Editor Unit | 本计划新增；只承接强 Editor-only helper / data source / reload 决策逻辑 |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/` | Plugin Fast Tests | 承接共享 helper 与 helper 自测，不承接 Runtime / Editor 私有逻辑 |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/` | Plugin Fast Tests | 承接引擎封装、配置、兼容性、快速核心回归 |
| `Plugins/Angelscript/Source/AngelscriptTest/Angelscript/` | Plugin Fast Tests | 承接脚本语言行为、执行、类型、函数、对象模型等快速回归 |
| `Plugins/Angelscript/Source/AngelscriptTest/Bindings/` | Plugin Fast Tests | 承接绑定成功/失败路径、GAS wrapper、容器/工具/引擎 API 可见性验证 |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` | Plugin Fast Tests | 承接 tokenizer / parser / compiler / bytecode / GC / restore 等内部机制测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/Compiler/` | Plugin Fast Tests | 承接编译管线端到端但仍无需 World 的快速测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/` | Plugin Fast Tests | 承接预处理、include/import、宏、错误恢复等快速测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` | Plugin Fast Tests | 承接类生成与最小 class compile/spawn 前验证 |
| `Plugins/Angelscript/Source/AngelscriptTest/FileSystem/` | Plugin Fast Tests | 承接文件系统与磁盘辅助路径验证，默认不归入 Scenario |
| `Plugins/Angelscript/Source/AngelscriptTest/Editor/` | Plugin Fast Tests | 保留现有轻量 EditorContext 回归；强 Editor 私有 helper 后续迁往 `AngelscriptEditor/Tests/` |
| `Plugins/Angelscript/Source/AngelscriptTest/Actor/` | Scenario / Integration | 保持 Actor 生命周期、交互、属性与 spawned actor 行为测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/Blueprint/` | Scenario / Integration | 保持 Blueprint 子类化与运行时行为测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/Component/` | Scenario / Integration | 保持组件生命周期与默认组件场景测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/Delegate/` | Scenario / Integration | 保持需要脚本对象/实例上下文的委托场景测试；纯绑定可见性放回 `Bindings/` |
| `Plugins/Angelscript/Source/AngelscriptTest/GC/` | Scenario / Integration | 保持需要对象生命周期/World 交互的 GC 场景测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/HotReload/` | Scenario / Integration | 保持热重载场景测试；纯判定逻辑未来可拆回 Runtime / Editor Unit |
| `Plugins/Angelscript/Source/AngelscriptTest/Interface/` | Scenario / Integration | 保持接口声明/实现/调用的脚本与 UClass 场景验证 |
| `Plugins/Angelscript/Source/AngelscriptTest/Inheritance/` | Scenario / Integration | 保持继承行为场景测试 |
| `Plugins/Angelscript/Source/AngelscriptTest/Subsystem/` | Scenario / Integration | 保持子系统生命周期与 Actor 访问场景验证 |
| `Plugins/Angelscript/Source/AngelscriptTest/Template/` | Scenario / Integration | 仅作为模板/脚手架目录，不承载长期增长的泛化测试桶 |
| `Plugins/Angelscript/Source/AngelscriptTest/Examples/` | Examples | 仅保留示例/教学性质回归；主题能力用例逐步迁出 |

### 分组命名的两阶段策略

1. **临时分组（Phase 0）**
   - 只为当前已经稳定的前缀或目录建立分组，避免在目录迁移前就把过滤规则写死。
   - 例如：
     - `AngelscriptRuntimeUnit` → `Angelscript.TestModule.CppTests.*`
     - `AngelscriptFast` → `Angelscript.TestModule.Core.*`、`Angelscript.TestModule.Bindings.*`、`Angelscript.TestModule.AngelScriptSDK.*`、`Angelscript.TestModule.Compiler.*`、`Angelscript.TestModule.Preprocessor.*`、`Angelscript.TestModule.Angelscript.*`
     - `AngelscriptScenario` → 当前 `Angelscript.TestModule.Scenario.*` 与已确认的主题化场景前缀
2. **最终分组（Phase 1 之后）**
   - 待 `Examples/` 迁移、`Scenario.*` 前缀收敛、Editor bootstrap 跑通后，再统一调整为稳定前缀规则。
   - 只有最终分组才允许成为长期 CI / 文档推荐入口。

### `AngelscriptSmoke` 的固定定义

`AngelscriptSmoke` 必须满足“单个测试短、小、定位明确、失败后易归因”。初版只允许纳入以下四类：

1. `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptMultiEngineTests.cpp` 中 1~2 个 engine create/destroy 冒烟用例
2. `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp` 中 1 个最小序列化 round-trip 用例
3. `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineCoreTests.cpp` 中 `CreateDestroy` / `CompileSnippet` 类最小入口用例
4. `Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp` 或后续 Editor bootstrap 中 1 个轻量注册/发现用例

任何依赖 World tick、复杂 Actor 场景、重载分析链或大批量脚本样例的测试，都不能在第一版 `AngelscriptSmoke` 中出现。

### live inventory 的固定统计规则

Phase 0 记录 live inventory 时，统一使用“扫描源码中的 automation/spec 注册点”的口径，而不是人工数表格。默认统计规则固定为：

```text
统计范围：Plugins/Angelscript/Source/
匹配模式：IMPLEMENT_SIMPLE_AUTOMATION_TEST( / IMPLEMENT_COMPLEX_AUTOMATION_TEST( / BEGIN_DEFINE_SPEC( / DEFINE_SPEC(
输出要求：
1. 按模块区分 AngelscriptRuntime / AngelscriptEditor / AngelscriptTest
2. 按目录输出命中数
3. 在 TestCatalog 中同时记录统计日期与匹配模式
```

后续如果需要精确到“实际注册成功数量”，可以追加运行期清单校验，但不能替代源码扫描口径。

## 执行前置命令速查

### 构建命令

Use `Tools\RunBuild.ps1`（例如 `Tools\RunBuild.ps1 -Label bootstrap -TimeoutMs 180000 -- -SerializeByEngine`）来验证 `AngelscriptProjectEditor`，保持和 `AgentConfig.ini` 中的路径/超时一致，同时自动处理 UBT 进程锁和日志输出。

### 单组自动化测试命令（NullRHI）

自动化测试建议通过 `Tools\RunTests.ps1 -TestPrefix <TestName> -Label <Label> -TimeoutMs 600000 -- -NullRHI` 来启动；日志、报告与摘要统一由脚本写入 `Saved/Tests/<Label>/<RunId>/`，不再手写 `-ABSLOG` / `-ReportExportPath`。

### 执行约束

- 先读取 `AgentConfig.ini` 中的 `Paths.EngineRoot`。
- 默认超时按 `600000ms` 预留；若本地 `AgentConfig.ini` 存在统一测试超时配置，则沿用本地设置。
- 并行跑多个测试实例时，必须为每个实例指定独立的 `-ABSLOG` 与 `-ReportExportPath`。
- 本计划默认所有非图形测试均使用 `-NullRHI`；若后续新增图形测试，应在单独计划中处理。

## 分阶段执行计划

### Phase 0：固定基线、分层和分组口径

> 目标：先让“有多少测试、属于哪一层、怎么筛选执行”成为稳定事实，再开始搬迁和补新覆盖。

- [ ] **P0.1** 对齐文档基线与源码注册数量
  - 修改 `Documents/Guides/TestCatalog.md`
  - 将当前文档中的 `275/275 PASS` 明确标注为 `AngelscriptTest` 模块已编目基线
  - 新增“源码扫描口径”小节，记录插件源码当前约 `352` 个 automation/spec 入口的事实，并区分：
    - `Plugins/Angelscript/Source/AngelscriptTest/`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
    - 后续新增的 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/`
  - 目的不是马上更新成最终全量数字，而是先把“文档基线”和“源码注册清单”两套口径分开，避免误读
- [ ] **P0.1** 📦 Git 提交：`[Test/Coverage] Docs: separate documented baseline from live test inventory`

- [ ] **P0.2** 在 `Documents/Guides/Test.md` 固定测试分层与目录归属
  - 明确 Runtime Unit / Editor Unit / Plugin Fast Tests / Scenario / Examples 五层定义
  - 明确新增测试应优先放置的位置：
    - Runtime 逻辑 → `AngelscriptRuntime/Tests/`
    - Editor helper → `AngelscriptEditor/Tests/`
    - 需要 `Shared` helper 的脚本/绑定/预处理器测试 → `AngelscriptTest/<Theme>/`
  - 明确“不要继续新增长尾 `Examples/` 能力验证”的规则
- [ ] **P0.2** 📦 Git 提交：`[Test/Coverage] Docs: define test tiers and placement rules`

- [ ] **P0.3** 在 `Config/DefaultEngine.ini` 新增自动化测试分组
  - 新增 `[/Script/AutomationTest.AutomationTestSettings]`
  - 第一轮先建立**临时分组**，只吸纳当前路径稳定、无需等待迁移完成的测试：
    - `AngelscriptSmoke`
    - `AngelscriptRuntimeUnit`
    - `AngelscriptEditorUnit`
    - `AngelscriptFast`
    - `AngelscriptScenario`
  - 过滤条件以测试路径前缀为主，不依赖文件名；其中：
    - `AngelscriptRuntimeUnit` 初版仅收 `Angelscript.TestModule.CppTests.*`
    - `AngelscriptFast` 初版仅收 `Angelscript.TestModule.Core.*`、`Angelscript.TestModule.Angelscript.*`、`Angelscript.TestModule.Bindings.*`、`Angelscript.TestModule.AngelScriptSDK.*`、`Angelscript.TestModule.Compiler.*`、`Angelscript.TestModule.Preprocessor.*`
    - `AngelscriptScenario` 初版允许同时覆盖 `Angelscript.TestModule.Scenario.*` 与已明确主题前缀
    - `AngelscriptEditorUnit` 在 Editor bootstrap 跑通前可以为空组，但条目必须预留
  - `AngelscriptSmoke` 第一版只允许包含 4~6 个最小入口测试，不得混入 World tick / 多帧 / 热重载链路长用例
- [ ] **P0.3** 📦 Git 提交：`[Test/Coverage] Chore: add automation groups for Angelscript test tiers`

- [ ] **P0.4** 固定执行前基线检查动作
  - 先构建一次 `AngelscriptProjectEditor`
  - 依次跑：
    - `Automation RunTests Group:AngelscriptSmoke`
    - `Automation RunTests Group:AngelscriptRuntimeUnit`
    - `Automation RunTests Group:AngelscriptFast`
  - 第一版 `AngelscriptSmoke` 默认从以下入口中挑选：
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptMultiEngineTests.cpp` 中 1 个 create/destroy 测试
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp` 中 1 个最小 round-trip 测试
    - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineCoreTests.cpp` 中 `CreateDestroy` / `CompileSnippet`
    - `Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp` 或后续 Editor bootstrap 冒烟测试 1 个
  - 把输出日志路径、报告路径、是否 `NullRHI` 的规则补进 `Documents/Guides/Test.md`
- [ ] **P0.4** 📦 Git 提交：`[Test/Coverage] Docs: add baseline execution flow for test groups`

- [ ] **P0.5** 固定 live inventory 的统计命令与落表格式
  - 在 `Documents/Guides/TestCatalog.md` 中记录统一统计口径：扫描 `Plugins/Angelscript/Source/` 下的 `IMPLEMENT_SIMPLE_AUTOMATION_TEST(`、`IMPLEMENT_COMPLEX_AUTOMATION_TEST(`、`BEGIN_DEFINE_SPEC(`、`DEFINE_SPEC(`
  - 在计划或文档中给出示例统计命令/模式，要求输出按模块和目录聚合，附统计日期
  - 任何后续“当前总测试数”更新都必须说明它是源码扫描数还是实际执行通过数
- [ ] **P0.5** 📦 Git 提交：`[Test/Coverage] Docs: make live inventory counting reproducible`

### Phase 1：整理目录与模板，停止继续向模糊桶堆积

> 目标：先把测试入口的“摆放方式”整理好，再开始补高风险覆盖，避免新增测试继续落错层。

- [ ] **P1.1** 对 `Examples/` 做主题归并清单
  - 审计并为以下文件确定新归属：
    - `Examples/AngelscriptScriptExampleArrayTest.cpp` → `Bindings/`
    - `Examples/AngelscriptScriptExampleMapTest.cpp` → `Bindings/`
    - `Examples/AngelscriptScriptExampleDelegatesTest.cpp` → `Delegate/`
    - `Examples/AngelscriptScriptExampleActorTest.cpp` → `Actor/`
    - `Examples/AngelscriptScriptExampleTimersTest.cpp` → 新增 `Timing/` 或并入更准确主题目录
  - 对仍保留在 `Examples/` 的文件补“保留理由”，限定为示例/教学/回归样例，而非主题能力测试
- [ ] **P1.1** 📦 Git 提交：`[Test/Structure] Docs: freeze example-to-theme migration map`

- [ ] **P1.2** 实施首批示例测试迁移与命名整理
  - 修改对应 `.cpp` 文件路径与注册路径前缀
  - 优先把纯主题能力用例从 `ScriptExamples.*` / 宽泛 `Scenario.*` 收敛为主题前缀，例如：
    - `Angelscript.TestModule.Bindings.*`
    - `Angelscript.TestModule.Delegate.*`
    - `Angelscript.TestModule.Actor.*`
  - 同步更新 `Documents/Guides/TestCatalog.md`
- [ ] **P1.2** 📦 Git 提交：`[Test/Structure] Refactor: move theme-owned example tests out of broad buckets`

- [ ] **P1.3** 为后续新增单元测试补模板与共享约束
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/Template/` 新增或更新模板文件，至少覆盖：
    - Runtime Unit 模板
    - Editor Unit 模板
    - Shared helper + cleanup 模板
  - 在模板或文档中固定以下约束：
    - 默认带 `WITH_AUTOMATION_TESTS` 宏保护
    - 默认使用 `ON_SCOPE_EXIT` / 局部清理
    - 默认使用可并行的日志/报告参数
    - 简单窄范围测试默认沿用 `IMPLEMENT_SIMPLE_AUTOMATION_TEST`
    - 需要 fixture / `BeforeEach` / `AfterEach` 的 deterministic editor/helper 测试允许使用 `.spec.cpp`
    - 只有当确实需要 PIE helper 或命令编排时才引入 `CQTest`，不要为了“看起来新”改写全部现有测试
- [ ] **P1.3** 📦 Git 提交：`[Test/Structure] Feat: add reusable templates for runtime and editor unit tests`

- [ ] **P1.4** 审计 `Shared/` helper 的最小补强点
  - 评估是否需要在以下文件补统一 helper：
    - `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h`
    - `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h`
  - 只补“重复出现”的能力，例如：日志路径生成、报告路径生成、统一 teardown、统一编译错误断言
  - 不把 Runtime/Editor 私有逻辑塞进共享 helper
- [ ] **P1.4** 📦 Git 提交：`[Test/Shared] Refactor: add common helper utilities for repeatable unit tests`

- [ ] **P1.5** 提前完成 Editor test bootstrap 冒烟
  - 在 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` 创建 1 个最小测试文件（可为 `AngelscriptEditorSmokeTests.cpp`）
  - 只验证：Editor 模块内测试可编译、可注册、可通过 `Automation RunTests` 被发现并执行
  - 该步骤不承接真实 class reload / content browser 逻辑，只作为后续 Phase 4 的先决门槛
- [ ] **P1.5** 📦 Git 提交：`[Editor/Test] Test: bootstrap editor unit test entrypoint early`

- [ ] **P1.6** 运行结构调整后的阶段性 sanity 回归
  - 执行：
    - `Automation RunTests Group:AngelscriptSmoke`
    - `Automation RunTests Group:AngelscriptFast`
    - `Automation RunTests Group:AngelscriptEditorUnit`
  - 目标是尽早发现分组、前缀、模板、Editor 依赖问题，而不是拖到最终 Phase 5
- [ ] **P1.6** 📦 Git 提交：`[Test/Structure] Test: verify grouping and editor bootstrap after reorganization`

### Phase 2：补齐 Runtime 核心单元测试缺口

> 目标：先覆盖最容易影响 cooked 构建、缓存、引擎生命周期的 Runtime 关键路径，优先使用 `AngelscriptRuntime/Tests/` 这一窄依赖层。

- [ ] **P2.1** 扩展 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp`
  - 增补 round-trip 场景：保存 → 加载 → Apply 到 module / bind cache
  - 覆盖至少以下分支：
    - 空模块 / 单模块 / 多模块
    - 版本号或 build identifier 不匹配时的失败路径
    - 读取损坏数据时的错误返回，而非 silent success
  - 最少拆成以下具体测试：
    - `FAngelscriptPrecompiledDataSaveLoadRoundtripTest`
      - Setup：创建 testing engine、构造最小 module/class/function 数据
      - Action：`InitFromActiveScript()` → `Save()` → 新上下文 `Load()`
      - Assert：`Modules.Num()`、`DataGuid`、`BuildIdentifier` 与输入一致，`IsValidForCurrentBuild()` 为 true
    - `FAngelscriptPrecompiledDataBuildIdentifierMismatchTest`
      - Setup：构造有效数据后手工篡改 `BuildIdentifier`
      - Action：重新 `Load()` / 调用 `IsValidForCurrentBuild()`
      - Assert：明确判 invalid，不允许 silent success
    - `FAngelscriptPrecompiledModuleApplyStageSequenceTest`
      - Setup：单模块 + 含属性/方法的 class
      - Action：依次执行 `ApplyToModule_Stage1()` / `Stage2()` / `Stage3()`
      - Assert：Stage1 只建立类型骨架、Stage2 完成 property、Stage3 完成 function/virtuals，禁止跨阶段提前填满
    - `FAngelscriptPrecompiledClassPropertyRoundtripTest`
      - Setup：构造含 `int` / `float` / object handle 三种 property 的 class
      - Action：`FAngelscriptPrecompiledClass::InitFrom()` → 序列化 → 反序列化 → `Create()` / `ProcessProperties()`
      - Assert：property 数量、名称、offset、flags 保持一致
    - `FAngelscriptPrecompiledFunctionBytecodeReferenceTest`
      - Setup：构造含 global/function/typeinfo 引用的 bytecode
      - Action：`InitFrom()` → `Create()` → `Process()`
      - Assert：global / function / typeinfo 引用均被正确解析，不留悬挂引用
    - `FAngelscriptPrecompiledDataCorruptedFileTest`
      - Setup：保存合法数据后破坏关键字段或长度
      - Action：`Load()`
      - Assert：失败路径可见、不会崩溃、不会留下半初始化 `Modules`
    - `FAngelscriptPrecompiledEnumRoundtripTest`
      - Setup：构造带多个枚举值的 enum
      - Action：`InitFrom()` → 序列化 → `Create()`
      - Assert：枚举名、value 数量、value 名称与整数值保持一致
    - `FAngelscriptPrecompiledGlobalVariableRoundtripTest`
      - Setup：构造带 init function 的全局变量
      - Action：`InitFrom()` → `Create()` → `Process()`
      - Assert：global property 与 init function 均可恢复
- [ ] **P2.1** 📦 Git 提交：`[Runtime/StaticJIT] Test: expand precompiled data round-trip coverage`

- [ ] **P2.2** 新增 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptBindDatabaseTests.cpp`
  - 覆盖 `AngelscriptBindDatabase.h` 的保存/读取/命中/失配路径
  - 验证 cooked cache / bind hash 变化后不会错误复用旧条目
  - 若需要，补最小 fake data builder，避免依赖宿主工程对象
  - 最少拆成以下具体测试：
    - `FAngelscriptBindDatabaseSaveLoadRoundtripTest`
      - Setup：填充 `Classes` / `Structs`，class bind 内含 method/property 条目
      - Action：`Save()` → `Clear()` → `Load()`
      - Assert：class/struct 数量与首个条目的 `TypeName`、method/property 数量一致
    - `FAngelscriptBindDatabaseEmptyDatabaseTest`
      - Setup：空数据库
      - Action：`Save()` / `Load()`
      - Assert：空输入 round-trip 后仍为空，不产生伪条目
    - `FAngelscriptBindDatabaseMethodBindDetailsTest`
      - Setup：构造含 `bStaticInUnreal`、`WorldContextArgument`、`bTrivial` 等 flag 的 method bind
      - Action：保存后读取
      - Assert：所有 flag 和索引字段保持一致
    - `FAngelscriptBindDatabasePropertyBindFlagsTest`
      - Setup：构造含 `bCanWrite`、`bCanRead`、`bGeneratedGetter`、`bGeneratedSetter` 的 property bind
      - Action：保存后读取
      - Assert：读写/生成器 flag 全部保持一致
    - `FAngelscriptBindDatabaseClearTest`
      - Setup：先填入多条 class/struct 记录
      - Action：调用 `Clear()`
      - Assert：`Classes.Num()` / `Structs.Num()` 归零
    - `FAngelscriptBindDatabaseMultiClassTest`
      - Setup：构造 10 个 method/property 数量不同的 class bind
      - Action：保存后读取
      - Assert：每个 class 的 method/property 数量逐项对应，避免只验证第一项
- [ ] **P2.2** 📦 Git 提交：`[Runtime/Core] Test: add bind database serialization and cache tests`

- [ ] **P2.3** 扩展 Runtime 引擎隔离与恢复测试
  - 优先改造以下现有文件，而不是平铺新文件：
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptMultiEngineTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDependencyInjectionTests.cpp`
  - 补齐多引擎并行、失败编译恢复、全局指针恢复、clone engine 隔离等用例
  - 最少拆成以下具体测试：
    - `FAngelscriptEnginePrecompiledDataLifecycleTest`
      - Setup：完整 engine + module + precompiled data
      - Action：销毁 engine → 新建 engine → 加载 precompiled data → 应用 stages
      - Assert：class/function 仍可使用，生命周期跨 engine 不丢失关键数据
    - `FAngelscriptCloneEnginePrecompiledDataIsolationTest`
      - Setup：source engine + clone engine
      - Action：仅在 clone 中加载/应用 precompiled data
      - Assert：source engine module 状态不被 clone 污染
    - `FAngelscriptEngineBindDatabaseLifecycleTest`
      - Setup：engine + populated bind database
      - Action：保存 bind database → 重建 engine → 重新加载
      - Assert：database 恢复后 class/struct bind 可见
    - `FAngelscriptEngineFailedCompileDoesNotPoisonNextEngineTest`
      - Setup：先在 engine A 中触发失败编译，再创建 engine B
      - Action：在 engine B 中编译合法脚本
      - Assert：engine B 不受前一次失败污染，诊断与模块状态隔离
- [ ] **P2.3** 📦 Git 提交：`[Runtime/Core] Test: strengthen engine isolation and recovery coverage`

- [ ] **P2.4** 补 Runtime 预处理 / 类型系统的窄范围覆盖
  - 评估新增：
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptTypeSystemTests.cpp`
- 或扩展 `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorTests.cpp`
    - 或扩展 `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptDataTypeTests.cpp`
  - 优先覆盖：嵌套宏、循环 import、错误恢复、类型匹配边界
  - 若同一能力更适合 `AngelscriptTest/` helper 层，则写在对应目录，但必须在提交说明中解释“不留在 Runtime/Tests 的原因”
  - 最少拆成以下具体测试：
    - `FAngelscriptPreprocessorNestedMacroExpansionTest`
      - Setup：两层以上宏展开脚本
      - Action：预处理并编译
      - Assert：最终展开结果可编译，且输出中不残留未展开宏
    - `FAngelscriptPreprocessorCircularImportReportsDeterministicErrorTest`
      - Setup：A 导入 B，B 导入 A
      - Action：触发预处理/编译
      - Assert：出现稳定错误信息，不死循环、不 silent fail
    - `FAngelscriptPreprocessorMalformedDirectiveRecoveryTest`
      - Setup：损坏的 directive / 缺失结束标记
      - Action：预处理
      - Assert：报告错误并中止当前文件，不污染后续编译
    - `FAngelscriptTypeSystemNestedContainerCompatibilityTest`
      - Setup：嵌套容器/handle/type usage 组合
      - Action：创建 type usage / 编译验证
      - Assert：允许的组合成功，不允许的组合给出明确错误
- [ ] **P2.4** 📦 Git 提交：`[Runtime/Core] Test: add preprocessor and type edge coverage`

- [ ] **P2.5** 运行 Runtime 阶段性回归
  - 执行：
    - `Automation RunTests Group:AngelscriptRuntimeUnit`
    - 以及新增/扩展文件的前缀子集
  - 目标是确认 Runtime 新增测试没有破坏现有 `CppTests` 分层
- [ ] **P2.5** 📦 Git 提交：`[Runtime/Test] Test: verify runtime unit coverage after phase 2`

### Phase 3：补齐绑定、GAS 与网络相关单元测试

> 目标：补强用户最容易直接感知的 API 绑定与能力系统支持，并为后续多人/复制路径准备稳定的最小测试基线。

- [ ] **P3.1** 新增 GAS 绑定覆盖
  - 新建 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptGASBindingsTests.cpp`
  - 以 `AngelscriptAbilitySystemComponent.h` 和 `AngelscriptAttributeSet.h` 为中心，覆盖：
    - ability 授予/查询/激活入口的脚本可见性
    - attribute 读写 / delegate 回调注册的最小 happy path
    - 明确不在本阶段覆盖完整多人玩法流程
  - 先落 **unit/narrow** 用例，再扩到 actor scenario，最少包含：
    - `FGASBindings_GetGameplayAttribute_Valid`
      - Setup：定义带 `Health` UPROPERTY 的测试 `AttributeSet`
      - Action：调用 `GetGameplayAttribute(TestClass, "Health")`
      - Assert：返回 attribute 有效
    - `FGASBindings_GetGameplayAttribute_InvalidName`
      - Setup：合法 class + 非法属性名
      - Action：调用 `GetGameplayAttribute()`
      - Assert：命中预期错误或 ensure，不默默返回合法 attribute
    - `FGASBindings_TryGetGameplayAttribute_Success` / `Fail`
      - Assert：bool 返回值与 attribute 有效性一致
    - `FGASBindings_CompareGameplayAttributes_Equal` / `Different`
      - Assert：同一 attribute 相等、不同 attribute 不相等
    - `FGASBindings_AttributeSet_PreAttributeChange`
      - Setup：测试 `AttributeSet` 子类记录回调
      - Action：直接调用 `PreAttributeChange()`
      - Assert：BP/native 回调被触发且携带正确值
    - `FGASBindings_AttributeSet_PostAttributeChange`
      - Action：调用 `PostAttributeChange()`
      - Assert：旧值/新值透传正确
    - `FGASBindings_AttributeSet_OnRep_Attribute_Blacklisted`
      - Setup：将属性加入 `ReplicatedAttributeBlackList`
      - Action：调用 `OnRep_Attribute`
      - Assert：黑名单路径被跳过，不触发错误副作用
- [ ] **P3.1** 📦 Git 提交：`[Test/Bindings] Test: add GAS component and attribute coverage`

- [ ] **P3.2** 补齐绑定失败路径与诊断断言
  - 优先扩展以下文件：
    - `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptEngineBindingsTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptUtilityBindingsTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`
  - 增补 null、类型不匹配、禁用绑定、错误消息精确性断言
  - 最少包含以下失败路径：
    - null ability class 传给 `BP_GiveAbility()` 时返回 invalid handle
    - 未注册 attribute 时 `TryGetAttributeCurrentValue()` / `TrySetAttributeBaseValue()` 返回 false
    - `BindConfig` 禁用项命中时错误消息含具体 bind 名
    - 容器/utility binding 类型不匹配时，日志里能定位到参数或函数签名，而不是只报 generic compile failed
- [ ] **P3.2** 📦 Git 提交：`[Test/Bindings] Test: add binding failure-path and diagnostic coverage`

- [ ] **P3.3** 建立最小网络/复制测试层
  - 新增 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptFakeNetDriverTests.cpp`
  - 以 `Testing/Network/FakeNetDriver.h` 为中心，验证最小驱动初始化、连接模拟、复制路径入口不崩溃
  - 如果需要更高层场景，再在后续单独追加 `Plugins/Angelscript/Source/AngelscriptTest/Networking/` 主题目录；本阶段不直接引入重量级集成场景
  - 最少拆成以下具体测试：
    - `FFakeNetDriver_ServerFlag_DefaultTrue`
      - Setup：`NewObject<UFakeNetDriver>()`
      - Action：读取 `bIsServer`
      - Assert：默认值与构造语义一致
    - `FFakeNetDriver_ServerFlag_CanSetFalse`
      - Action：`bIsServer = false` 后调用 `IsServer()`
      - Assert：返回 false
    - `FFakeNetDriver_IsA_NetDriver`
      - Assert：对象类型仍是 `UNetDriver` 子类，保证后续测试 seam 正确
    - `FFakeNetDriver_GC_Survives`
      - Setup：加 root 或持有效引用
      - Action：触发 GC
      - Assert：对象生命周期符合预期，不被过早回收
- [ ] **P3.3** 📦 Git 提交：`[Runtime/Networking] Test: add fake net driver baseline coverage`

- [ ] **P3.4** 为后续多人/复制专题预留目录与文档入口
  - 视 `P3.3` 结果决定是否创建：
    - `Plugins/Angelscript/Source/AngelscriptTest/Networking/`
  - 只有当需要 World / Actor / RPC 场景时才创建，不把纯 Runtime 驱动测试错误地放入 `Scenario` 路径
  - 若创建 `Networking/`，只允许承接下列 **scenario seam**：
    - `FGASScenario_RegisterAttributeSet_Success` / `DuplicateIdempotent`
    - `FGASScenario_AttributeChanged_Callback`
    - `FGASScenario_GiveAbility_Success` / `CancelAbility_Success`
    - `FGASScenario_HasGameplayTag_True` / `OnOwnedTagUpdated_Delegate`
  - 明确不在本阶段承接：跨进程 client/server、真实 packet、完整 gameplay effect 仿真、多角色网络同步
- [ ] **P3.4** 📦 Git 提交：`[Test/Networking] Docs: define boundary between net unit tests and scenarios`

- [ ] **P3.5** 运行 GAS / Bindings / Networking 阶段性回归
  - 执行：
    - `Automation RunTests Angelscript.TestModule.Bindings` 相关子集
    - `Automation RunTests Group:AngelscriptRuntimeUnit`
    - 若创建 `Networking/` 或 `GAS/` 场景目录，再单独跑对应前缀
  - 目标是把 narrow tests 与 scenario tests 的分层验证开，不等到最终总回归才发现目录/前缀混放
- [ ] **P3.5** 📦 Git 提交：`[Test/Bindings] Test: verify GAS and networking coverage boundaries`

### Phase 4：补齐 Editor 与 Debug 工具链测试

> 目标：为目前最薄弱的 Editor / Debug 区域建立可持续扩展的测试入口，而不是继续只有一个 SourceNavigation 用例。

- [ ] **P4.1** 为 Editor 模块建立测试目录和最小依赖
  - 新建 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/`
  - 必要时修改 `Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs`
  - 保证 Editor unit tests 可以在 `WITH_AUTOMATION_TESTS` 下独立编译，不强耦合 `AngelscriptTest` 模块
  - 如 `FClassReloadHelper` 或相关 helper 需要跨模块访问，优先选择“测试留在 Editor 模块内部”；只有在确有必要时才补 `ANGELSCRIPTEDITOR_API`
  - 若 `ContentBrowserData`、`ContentBrowser`、`AssetRegistry` 等模块依赖不足，在这一阶段一次性补齐，不要拖到具体测试实现时再分散调整
- [ ] **P4.1** 📦 Git 提交：`[Editor/Test] Chore: add editor unit test entrypoint and dependencies`

- [ ] **P4.2** 新增 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/AngelscriptClassReloadHelperTests.cpp`
  - 覆盖 class reload helper 的依赖判断、最小重载路径、失败回退
  - 优先验证“给定输入状态 → reload 决策 / 辅助动作”这一类 deterministic 逻辑
  - 最少拆成以下具体测试：
    - `FAngelscriptClassReloadStateTrackingTest`
      - Setup：创建 `FReloadState`，准备 mock old/new class
      - Action：触发 new class 与 reload class 两种 `OnClassReload` 路径
      - Assert：`ReloadClasses` 映射与 `NewClasses` 集合都被正确更新
    - `FAngelscriptStructReloadTrackingTest`
      - Setup：创建 old/new `UScriptStruct`
      - Action：触发 `OnStructReload`
      - Assert：`ReloadStructs` 记录 old→new，且 `bRefreshAllActions` 被置为 true
    - `FAngelscriptDelegateReloadTrackingTest`
      - Setup：创建 old/new `UDelegateFunction`
      - Action：触发 `OnDelegateReload`
      - Assert：`ReloadDelegates` 与 `NewDelegates` 正确记录
    - `FAngelscriptEnumReloadTrackingTest`
      - Setup：准备 changed/new `UEnum`
      - Action：触发 `OnEnumChanged`、`OnEnumCreated`
      - Assert：`ReloadEnums` 收到变化项，`NewEnums` 收到新项
    - `FAngelscriptAssetReloadTrackingTest`
      - Setup：准备 old/new literal asset `UObject`
      - Action：触发 `OnLiteralAssetReload`
      - Assert：`ReloadAssets` 建立 old→new 映射
    - `FAngelscriptGetTablesDependentOnStructTest`
      - Setup：创建 `UDataTable`，令 `RowStruct` 指向测试 struct
      - Action：调用 `GetTablesDependentOnStruct`
      - Assert：返回结果包含该 `DataTable`
    - `FAngelscriptVolumeReloadDetectionTest`
      - Setup：创建继承 `AVolume` 的测试 class
      - Action：触发 `OnClassReload`
      - Assert：`bReloadedVolume` 为 true
    - `FAngelscriptInterfaceReloadRefreshTest`
      - Setup：创建带 `CLASS_Interface` flag 的 class
      - Action：触发 `OnClassReload`
      - Assert：接口参与 reload 时强制 `bRefreshAllActions`
- [ ] **P4.2** 📦 Git 提交：`[Editor/Reload] Test: add class reload helper coverage`

- [ ] **P4.3** 新增 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/AngelscriptContentBrowserDataSourceTests.cpp`
  - 覆盖 content browser data source 的枚举、过滤、路径转换、非法输入处理
  - 避免上来就做真实资源扫描；先做 deterministic 单元测试
  - 最少拆成以下具体测试：
    - `FAngelscriptContentBrowserCompileFilterTest`
      - Setup：创建 `UAngelscriptContentBrowserDataSource` 与 `FContentBrowserDataFilter`
      - Action：调用 `CompileFilter`
      - Assert：产出的 compiled filter 中包含正确 class include/exclude 条件
    - `FAngelscriptContentBrowserEnumerateAssetsTest`
      - Setup：向脚本资产容器注入最小测试 asset
      - Action：`EnumerateItemsMatchingFilter(IncludeFiles | IncludeAssets)`
      - Assert：回调收到期望 item，路径与 payload 正确
    - `FAngelscriptContentBrowserClassFilterExclusionTest`
      - Setup：同时设置 include/exclude class filter
      - Action：执行枚举
      - Assert：被排除 class 的 asset 不出现在结果中
    - `FAngelscriptContentBrowserGetItemAttributeTest`
      - Setup：通过 `CreateAssetItem` 构造 item
      - Action：查询 `ItemTypeName`、`ItemIsProjectContent`
      - Assert：返回值分别为脚本资产类型和 project content 标识
    - `FAngelscriptContentBrowserUpdateThumbnailTest`
      - Setup：构造带有效 payload 的 item 和 `FAssetThumbnail`
      - Action：调用 `UpdateThumbnail`
      - Assert：thumbnail 绑定到正确 asset data
    - `FAngelscriptContentBrowserLegacyAssetDataTest`
      - Action：调用 `Legacy_TryGetAssetData`
      - Assert：返回 `FAssetData` 与 payload 中 asset 一致
    - `FAngelscriptContentBrowserLegacyPackagePathTest`
      - Action：调用 `Legacy_TryGetPackagePath`
      - Assert：包路径与 payload 路径一致
  - 若当前实现把 payload struct 设为私有，先补最小测试 seam 或注入 helper，不要在测试里通过不稳定的反射/偏移强取内部状态
- [ ] **P4.3** 📦 Git 提交：`[Editor/ContentBrowser] Test: add data source filtering coverage`

- [ ] **P4.4** 新增 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDebugServerProtocolTests.cpp`
  - 覆盖消息编码/解码、无效消息防御、断点/变量检查消息的最小协议路径
  - 不在本阶段做真实 TCP 端到端压测；先把协议层和消息分派层固定住
  - 最少拆成以下具体测试：
    - `FAngelscriptDebugMessageStartDebuggingSerializationTest`
      - Setup：构造 `FStartDebuggingMessage`
      - Action：`FMemoryWriter` 序列化后再用 `FMemoryReader` 反序列化
      - Assert：`DebugAdapterVersion` 保持一致
    - `FAngelscriptDebugMessageStoppedSerializationTest`
      - Setup：构造带 `Reason` / `Description` / `Text` 的 `FStoppedMessage`
      - Action：序列化 round-trip
      - Assert：所有字符串字段保持一致
    - `FAngelscriptDebugMessageBreakpointSerializationTest`
      - Setup：构造带 `Filename`、`LineNumber`、`Id`、`ModuleName` 的断点
      - Action：round-trip
      - Assert：断点字段完整保留
    - `FAngelscriptDebugMessageVariablesSerializationTest`
      - Setup：构造 2 个变量，覆盖 `Name` / `Value` / `Type` / `bHasMembers` / `ValueAddress` / `ValueSize`
      - Action：在 `DebugAdapterVersion >= 2` 下序列化
      - Assert：地址/尺寸等扩展字段未丢失
    - `FAngelscriptDebugMessageDataBreakpointSerializationTest`
      - Setup：构造多个 data breakpoint
      - Action：round-trip
      - Assert：`Id` / `Address` / `AddressSize` / `HitCount` / `bCppBreakpoint` / `Name` 全部保留
    - `FAngelscriptDebugMessageCallStackSerializationTest`
      - Setup：构造 2 层 call stack frame
      - Action：round-trip
      - Assert：函数名、源码、行号、module 名保留
    - `FAngelscriptDebugMessageDiagnosticsSerializationTest`
      - Setup：构造 diagnostics 数组
      - Action：round-trip
      - Assert：message、line、character、error/info flag 精确一致
    - `FAngelscriptDebugMessageDebugDatabaseSettingsSerializationTest`
      - Setup：构造全量 bool flag 的 settings
      - Action：按 Version=5 round-trip
      - Assert：settings flag 全保留
    - `FAngelscriptDebugMessageAssetDatabaseSerializationTest`
      - Setup：构造 asset path 列表
      - Action：按 Version=1 round-trip
      - Assert：asset 数组完整
    - `FAngelscriptDebugMessageFindAssetsSerializationTest`
      - Setup：构造 `Assets + ClassName`
      - Action：round-trip
      - Assert：assets 与 class name 均保留
    - `FAngelscriptDebugServerDataBreakpointLimitTest`
      - Setup：准备超过 `DATA_BREAKPOINT_HARDWARE_LIMIT` 的 breakpoint 请求
      - Action：更新 server 的 data breakpoints
      - Assert：最终只保留 4 个硬件断点，不越界、不 silent overwrite
    - `FAngelscriptDebugServerCanonizeFilenameTest`
      - Setup：准备不同路径格式的 filename
      - Action：调用 `CanonizeFilename`
      - Assert：得到稳定 canonical form
  - 若 `FAngelscriptDebugServer` 当前默认构造会绑定真实 TCP 端口，则先补测试专用 seam / 构造路径，禁止在单元测试里依赖真实监听端口
- [ ] **P4.4** 📦 Git 提交：`[Runtime/Debug] Test: add debug server protocol coverage`

- [ ] **P4.5** 运行 Editor / Debug 阶段性回归
  - 执行：
    - `Automation RunTests Group:AngelscriptEditorUnit`
    - `Automation RunTests Angelscript.TestModule.Editor`
    - 新增 debug/runtime 协议测试对应前缀
  - 目标是确认 Editor unit bootstrap、ContentBrowser 依赖、Debug protocol round-trip 在阶段内就已闭环
- [ ] **P4.5** 📦 Git 提交：`[Editor/Test] Test: verify editor and debug coverage after phase 4`

### Phase 5：收口回归、目录登记与执行手册同步

> 目标：把前面新增的测试真正变成“可查、可分组、可回归、可并行”，而不是只在源码里新增几个文件。

- [ ] **P5.1** 更新 `Documents/Guides/TestCatalog.md`
  - 将新增或迁移后的目录、文件、分组路径录入目录文档
  - 区分 Runtime Unit / Editor Unit / Plugin Fast / Scenario / Examples
  - 为每个新增主题记录“验证什么”，而不只是文件名
  - 对每个新增文件至少记录 1 行“代表性测试点”，例如：
    - PrecompiledData round-trip / mismatch / corruption
    - BindDatabase save-load / flags / clear
    - GAS attribute lookup / delegate callback / ability lifecycle
    - Editor reload tracking / content browser filtering
    - Debug message serialization / breakpoint limit
- [ ] **P5.1** 📦 Git 提交：`[Test/Coverage] Docs: register new unit test themes and ownership`

- [ ] **P5.2** 更新 `Documents/Guides/Test.md`
  - 增加按组执行示例：
    - `Group:AngelscriptRuntimeUnit`
    - `Group:AngelscriptEditorUnit`
    - `Group:AngelscriptFast`
    - `Group:AngelscriptScenario`
  - 增加并行日志隔离示例（`-ABSLOG` / `-ReportExportPath`）
  - 明确哪些组默认走 `NullRHI`
- [ ] **P5.2** 📦 Git 提交：`[Test/Coverage] Docs: add grouped execution and log isolation guidance`

- [ ] **P5.3** 执行分层回归并记录结果
  - 至少执行：
    - `Automation RunTests Group:AngelscriptSmoke`
    - `Automation RunTests Group:AngelscriptRuntimeUnit`
    - `Automation RunTests Group:AngelscriptEditorUnit`
    - `Automation RunTests Group:AngelscriptFast`
  - 若 `AngelscriptScenario` 耗时过长，可分目录/分前缀执行，但必须记录拆分策略
  - 回归结果写回 `Documents/Guides/TestCatalog.md` 或配套执行记录文档
- [ ] **P5.3** 📦 Git 提交：`[Test/Coverage] Test: verify grouped Angelscript automation entrypoints`

## 建议执行顺序

1. **先做 Phase 0**：否则后续新增测试没有统一统计和执行入口。
2. **再做 Phase 1**：先阻止目录继续变乱，再补覆盖。
3. **优先执行 Phase 2**：StaticJIT / BindDatabase / Engine isolation 对插件稳定交付价值最高。
4. **随后执行 Phase 3 与 Phase 4**：Bindings/GAS/Networking 与 Editor/Debug 可以按 owner 并行推进，但不要编辑同一个 helper 文件。
5. **最后做 Phase 5**：统一回归、整理文档和分组执行手册。

## 验收标准

1. `Documents/Guides/TestCatalog.md` 不再只有单一“275/275 PASS”口径，而是明确区分 documented baseline 与 live inventory，并登记 Runtime / Editor / Test 模块测试层。
2. `Documents/Guides/Test.md` 明确说明五层测试分层、放置规则、分组命名与 `NullRHI` / 并行日志隔离执行方法。
3. `Config/DefaultEngine.ini` 存在 `AutomationTestSettings` 分组，可直接按 `AngelscriptSmoke` / `AngelscriptRuntimeUnit` / `AngelscriptEditorUnit` / `AngelscriptFast` / `AngelscriptScenario` 运行。
4. `Examples/` 不再继续承担泛能力验证桶；至少首批数组、Map、Delegate、Actor、Timer 类示例测试的归属已经被明确并开始迁移。
5. Runtime 层至少新增或扩展以下覆盖：
   - PrecompiledData round-trip
   - BindDatabase 序列化/缓存
   - Engine isolation / recovery
   - FakeNetDriver baseline
   - DebugServer protocol baseline
6. Editor 层至少新增：
   - ClassReloadHelper tests
   - ContentBrowserDataSource tests
7. 新增的执行入口可在 `NullRHI` + 独立日志/报告路径下跑通，且回归记录可被后续维护者直接复用。

## 风险与注意事项

- **文档基线漂移继续扩大**
  - 风险：新增测试后，文档仍只维护旧口径。
  - 应对：Phase 0 先把 documented baseline 与 live inventory 分开记录，Phase 5 再回写新增覆盖。
- **Editor 测试依赖过重，导致构建面突然扩大**
  - 风险：把本应落在 `AngelscriptTest` 的 fast tests 过早塞进 `AngelscriptEditor`，引入大量额外依赖。
  - 应对：只把强 Editor 内部 helper 测试放进 `AngelscriptEditor/Tests/`；其余仍走 `AngelscriptTest`。
- **Networking / GAS 过早变成重量级集成场景**
  - 风险：测试一开始就需要 World、Pawn、多人会话，导致成本过高。
  - 应对：本计划先固定 FakeNetDriver / wrapper / baseline 路径，复杂场景后移。
- **目录迁移影响已有筛选脚本或前缀**
  - 风险：移动 `Examples/` 中的文件后，已有 `Automation RunTests` 前缀选择失效。
  - 应对：Phase 1 迁移时同步调整注册路径、分组过滤和 TestCatalog 文档，不做“只移动文件不改入口”。
- **测试耗时失控**
  - 风险：新增覆盖后，所有测试都堆到一个长命令里，CI 与本地验证都变慢。
  - 应对：优先按组执行，并始终保留 `Smoke` / `RuntimeUnit` / `Fast` 三个快速入口。




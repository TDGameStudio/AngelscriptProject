# Test 指南

## 强制规则

- 本仓库的标准自动化测试入口是 `Tools\RunTests.ps1`。
- 具名 suite 只能通过 `Tools\RunTestSuite.ps1` 调度；不要手写一组 `RunTests` 命令散落到文档里。
- 不再允许把 `UnrealEditor-Cmd.exe` 直调命令、`Start-Process UnrealEditor-Cmd.exe` 拼参命令、或旧的 `Tools\RunAutomationTests.ps1` 当作标准入口写入指南。
- 所有测试命令都必须显式带超时，且超时不得超过 `900000ms`。
- 默认测试超时来自 `AgentConfig.ini` 的 `Test.DefaultTimeoutMs`；仓库标准默认值为 `600000ms`。
- 测试过程必须实时输出；超时或异常退出后脚本必须清理整棵编辑器/UBT 进程树。
- 每次测试都必须写入自己的独立输出目录；禁止多个 run 共用同一份 `Automation.log` 或报告目录。

## AgentConfig.ini 与 bootstrap

执行测试前，先读取项目根目录的 `AgentConfig.ini`。

关键配置项：

```ini
[Paths]
EngineRoot=<UE 根目录>
ProjectFile=<当前 worktree 的 .uproject>

[Test]
DefaultTimeoutMs=600000
```

如果当前 worktree 还没有配置，先执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1
```

批量补齐所有 worktree：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -AllRegisteredWorktrees
```

只想拿标准命令模板时，使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1
```

## 标准入口

### 按测试前缀运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings -TimeoutMs 600000
```

反射回退绑定专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.BlueprintCallableReflectiveFallback" -Label reflective-fallback -TimeoutMs 600000
```

GeneratedFunctionTable 三分类统计专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionTable" -Label generated-table -TimeoutMs 600000
```

Compilation hook / event 专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-hooks -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label compiler-events -TimeoutMs 600000
```

这两个前缀覆盖 `PreprocessorContext`、`Preprocess.ProcessChunks` / `Preprocess.PostProcessCode` summary-backed hook 事件、`Compile.Begin` / `Compile.End`、module stage events、JIT availability metadata，以及 per-run `FAngelscriptCompilationContext` 隔离语义。

AngelScript native SDK 分层前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Tokenizer" -Label sdk-tokenizer -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Parser" -Label sdk-parser -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.ScriptNode" -Label sdk-scriptnode -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Bytecode" -Label sdk-bytecode -TimeoutMs 600000
```

对应的 UHT 生成统计会在每次标准 build/UHT 运行时写入：

```text
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_Summary.json
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_ModuleSummary.csv
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_Entries.csv
```

该文件当前至少包含这些字段：

- `totalGeneratedEntries`
- `totalDirectBindEntries`
- `totalStubEntries`
- `directBindRate`
- `stubRate`
- `totalShardCount`
- `moduleCount`
- `modules[]`（逐模块 `totalEntries/directBindEntries/stubEntries/directBindRate/stubRate/shardCount`）

CSV 侧的用途区分如下：

- `AS_FunctionTable_ModuleSummary.csv`：按模块聚合，适合快速看 `total/direct/stub/rate/shards`
- `AS_FunctionTable_Entries.csv`：逐条函数明细，适合按 `ModuleName/ClassName/FunctionName/EntryKind/EraseMacro/ShardIndex` 过滤查询

### 按测试组运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptDebugger -Label debugger -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptPerformance -Label perf -TimeoutMs 900000
```

### 按具名 suite 运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Debugger -LabelPrefix debugger -TimeoutMs 600000
```

### 需要真实渲染时

默认测试会追加 `-NullRHI`。只有明确需要真实渲染时才加 `-Render`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke-render -TimeoutMs 600000 -Render
```

## 脚本默认行为

`Tools\RunTests.ps1` 会自动：

- 读取当前 worktree 的 `AgentConfig.ini`
- 在启动编辑器前预热 `Intermediate/TargetInfo.json`
- 防御性等待外部旧流程留下的 `Build.bat` 全局锁，避免把整个超时都耗在不可见争用上
- 以统一参数启动 `UnrealEditor-Cmd.exe`
- 默认追加 `-BUILDMACHINE`、`-stdout -FullStdOutLogOutput -UTF8Output`、`-Unattended -NoPause -NoSplash -NOSOUND`
- 非渲染模式下追加 `-NullRHI`
- 通过 `-ABSLOG` 与 `-ReportExportPath` 把日志和报告写入当前 run 的独立目录
- 在超时或异常退出时结束整棵编辑器/UBT 进程树

`Tools\RunTestSuite.ps1` 是基于 `Tools\RunTests.ps1` 的官方调度层。它会顺序执行内置 suite 中的前缀，并把 `-TimeoutMs`、`-OutputRoot`、`-NoReport` 透传给每个子 run。

`GeneratedFunctionTable` 相关验证除了自动化报告外，还应结合 `AS_FunctionTable_Summary.json` 一起看；前者回答“测试是否通过”，后者回答“本次 UHT 生成了多少条格式绑定，以及 direct/stub 的模块分布”。

当需要定位“某个函数为什么是 direct 还是 stub”时，优先查询 `AS_FunctionTable_Entries.csv`，不要再从 `AS_FunctionTable_*.cpp` shard 文件中手工 grep。前者是正式产物，后者是代码生成中间结果。

## 常用参数

### `Tools\RunTests.ps1`

```powershell
Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 120000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests." -Label runtime-unit -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump" -Label dump -TimeoutMs 600000
Tools\RunTests.ps1 -Group AngelscriptFunctional -Label functional -TimeoutMs 900000 -Render
Tools\RunTests.ps1 -Group AngelscriptFast -Label fast -TimeoutMs 600000 -- -log
```

- `-TestPrefix`：按测试名前缀运行
- `-Group`：按 `Config/DefaultEngine.ini` 中定义的 automation group 运行
- `-TimeoutMs`：本次测试超时，必须大于 `0` 且不超过 `3600000`
- `-Label`：输出目录标签
- `-OutputRoot`：自定义输出父目录；脚本会在其下再创建 `Tests/<Label>/<RunId>/`
- `-Render`：关闭 `-NullRHI`
- `-NoReport`：跳过 `Summary.json` 生成
- `-- <ExtraArgs>`：透传额外编辑器命令行参数

### `Tools\RunTestSuite.ps1`

```powershell
Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000
Tools\RunTestSuite.ps1 -Suite Debugger -LabelPrefix debugger -TimeoutMs 600000 -DryRun
Tools\RunTestSuite.ps1 -Suite FunctionalSamples -LabelPrefix functional -TimeoutMs 900000 -OutputRoot "D:\Tmp\SuiteRuns"
```

- `-Suite`：具名 suite 名称
- `-LabelPrefix`：每一波子 run 的标签前缀
- `-TimeoutMs`：透传给每个 `RunTests` 子 run 的超时
- `-OutputRoot`：透传给每个 `RunTests` 子 run 的输出父目录
- `-NoReport`：透传给每个 `RunTests` 子 run
- `-ListSuites`：列出内置 suite 与对应前缀
- `-DryRun`：只打印将要执行的命令

## 输出与产物

默认输出目录：

```text
Saved/Tests/<Label>/<RunId>/
  Automation.log
  Report/
  RunMetadata.json
  Summary.json
```

如果传入 `-OutputRoot D:\Tmp\TestRuns`，实际目录会变成：

```text
D:\Tmp\TestRuns\Tests\<Label>\<RunId>\
```

注意：

- `-OutputRoot` 只是父目录，不是最终目录
- 每次调用都会新建独立 `RunId`
- `Automation.log`、`Report/`、`RunMetadata.json`、`Summary.json` 都是 run 私有产物，不能手写成共享路径

## 常用 group 与 suite

常用 group 以 `Config/DefaultEngine.ini` 为准，典型入口包括：

- `AngelscriptSmoke`
- `AngelscriptNative`
- `AngelscriptRuntimeUnit`
- `AngelscriptDebugger`
- `AngelscriptFast`
- `AngelscriptFunctional`
- `AngelscriptEditor`
- `AngelscriptExamples`

常用 suite 以 `Tools\RunTestSuite.ps1 -ListSuites` 输出为准，当前重点包括：
推荐顺序：

1. 快速冒烟：`AngelscriptSmoke`
2. 无 world 的运行时回归：`AngelscriptRuntimeUnit`、`AngelscriptFast`
3. 需要 world / actor / subsystem 的集成回归：`AngelscriptFunctional`
4. 编辑器相关：`AngelscriptEditor`

### Commandlet 相关回归

本仓库的标准 commandlet 入口是 `Tools\RunCommandlet.ps1`。需要跑项目 commandlet 时，优先使用这个 runner，让 `AgentConfig.ini`、日志路径、超时和 worktree 单飞锁保持一致。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-scan -TimeoutMs 600000
```

额外 commandlet 参数通过 `-ExtraArgs` 传入：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-changed -TimeoutMs 600000 -ExtraArgs "-ChangedScript=Foo.as;Bar.as"
```

### Blueprint impact commandlet 相关回归

新增 Blueprint impact 相关功能后，优先使用以下入口：

- Editor 内部 scanner / commandlet 入口回归：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.BlueprintImpact" -TimeoutMs 300000
```

- Blueprint 场景与磁盘资产回归：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.BlueprintImpact" -TimeoutMs 300000
```

- commandlet 手工验证：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-scan -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-changed -TimeoutMs 600000 -ExtraArgs "-ChangedScript=Foo.as;Bar.as"
```

`Tools\RunCommandlet.ps1` 会从当前 worktree 的 `AgentConfig.ini` 读取 `<ProjectFile>`，不要在常规执行说明里写死其他 worktree 的 `.uproject` 路径。

### StaticJIT AOT 相关回归

StaticJIT AOT 测试验证的是“生成 C++ → 二次构建 → 运行时注册和执行”整条链路。标准流程固定为：

1. 先构建一次，让 AOT commandlet 与生成 helper 进入 `AngelscriptTest` 模块。
2. 运行 `AngelscriptStaticJITAotTest` commandlet 的 `Generate` 模式，更新 `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/` 下的 `.jit.cpp`、`.jit.hpp`，并在同目录生成本地 `StaticJITAotFixture.Cache`。
3. 再构建一次，让 UBT 自动发现并编译生成的 `.jit.cpp` 文件。
4. 运行 `Angelscript.TestModule.StaticJIT.AOT` 或更宽的 `Angelscript.TestModule.StaticJIT` 前缀。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-aot-build -TimeoutMs 180000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptStaticJITAotTest -Label staticjit-aot-generate -TimeoutMs 600000 -ExtraArgs "-Mode=Generate"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-aot-generated -TimeoutMs 180000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label staticjit-aot -TimeoutMs 600000
```

生成物校验由 `Angelscript.TestModule.StaticJIT.AOT.GeneratedOutputVerify` 覆盖：源码文本严格比对；`StaticJITAotFixture.Cache` 是本地生成产物，不提交到 git，但测试会要求它存在，并按 fixture GUID、build id、模块与函数元数据做语义校验。cache 内部保存旧指针引用，因此不能用裸文件 hash 作为 stale 判断依据。fresh checkout 后需要先执行 generate -> rebuild -> test 流程，不能直接只跑 AOT runtime 测试。

常用具名 suite 以 `Tools\RunTestSuite.ps1 -ListSuites` 的输出为准，当前重点包括：

- `Smoke`
- `NativeCore`
- `RuntimeCpp`
- `Debugger`
- `Bindings`
- `HotReload`
- `FunctionalSamples`
- `All`

## CQTest 框架使用指南

### 概述

CQTest 是 UE 5.x 引入的声明式自动化测试框架（`Engine/Source/Developer/CQTest/`），相比传统 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 提供更简洁的语法和更好的 setup/teardown 结构化支持。本项目已在 `AngelscriptTest.Build.cs` 中加入 `CQTest` 依赖（editor builds），当前作为 PoC 在绑定测试中使用。

引入头文件：

```cpp
#include "CQTest.h"
```

### 核心宏

| 宏 | 作用 | 映射 |
|---|---|---|
| `TEST_CLASS(Name, Path)` | 声明测试类，Path 为 Automation ID 前缀 | 生成 `FAutomationTestBase` 子类 |
| `TEST_CLASS_WITH_FLAGS(Name, Path, Flags)` | 同上，但可指定 `EAutomationTestFlags` | 同上 |
| `TEST_METHOD(Name)` | 在类内声明一个测试方法 | 每个方法注册为独立 Automation Test |
| `BEFORE_ALL()` | **静态方法**，整个测试类执行前调用一次 | `static void BeforeAll(const FString&)` |
| `AFTER_ALL()` | **静态方法**，整个测试类执行后调用一次 | `static void AfterAll(const FString&)` |
| `BEFORE_EACH()` | 每个 `TEST_METHOD` 执行前调用 | `virtual void Setup() override` |
| `AFTER_EACH()` | 每个 `TEST_METHOD` 执行后调用 | `virtual void TearDown() override` |
| `ASSERT_THAT(expr)` | 断言失败时 `return`，不继续执行 | `if (!this->Assert.expr) { return; }` |

### 与 Angelscript 引擎集成的推荐模式

由于 `ASTEST_BEGIN/END_SHARE_CLEAN` 等宏展开为大括号对（包含 `FAngelscriptEngineScope` RAII），无法跨 CQTest 的 `Setup()/TearDown()/TEST_METHOD()` 边界拆分。推荐的适配模式如下：

```cpp
TEST_CLASS_WITH_FLAGS(FMyBindingsTest,
    "Angelscript.TestModule.Bindings.MyType",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
    BEFORE_ALL()
    {
        // 整个类开始时一次性获取干净的共享引擎
        ASTEST_CREATE_ENGINE_SHARE_CLEAN();
    }

    AFTER_ALL()
    {
        // 整个类结束后一次性重置引擎
        FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
        AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
    }

    TEST_METHOD(SomeSection)
    {
        // 获取共享引擎（无 reset，因为 BEFORE_ALL 已经清理过）
        FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
        FAngelscriptEngineScope Scope(Engine);

        // FCoverageModuleScope 自动在析构时 DiscardModule
        FCoverageModuleScope Mod(*TestRunner, Engine, Profile, TEXT("Section"), TEXT(R"(
            // AS code here
        )"));
        if (!Mod.IsValid()) return;
        auto& M = Mod.GetModule();

        // 断言
        ExpectGlobalInts(*TestRunner, Engine, M, Profile, Cases);
    }
};
```

关键设计决策：

- **`BEFORE_ALL` / `AFTER_ALL`（推荐）**：引擎获取和重置只执行各一次。由于它们是 `static` 方法，不能直接设置实例成员变量，但可以操作进程级共享引擎单例。
- **`BEFORE_EACH` / `AFTER_EACH`（避免）**：每个 `TEST_METHOD` 前后都执行，会导致不必要的引擎重置。`FCoverageModuleScope` 的 RAII 析构已经负责每个测试的模块清理，无需额外的整引擎重置。
- **`FCoverageModuleScope`**：每个 `TEST_METHOD` 内通过 RAII 创建和销毁 AS 模块，测试结束时自动 `DiscardModule`，保证测试间的模块隔离。
- **`TestRunner` 指针**：CQTest 将 `TestRunner` 暴露为 `static` 指针（类型为 `TTestRunner<FNoDiscardAsserter>*`），传给需要 `FAutomationTestBase&` 的函数时需要解引用为 `*TestRunner`。

### setup 层级选择

| 层级 | 用途 | 示例 |
|---|---|---|
| `BEFORE_ALL` / `AFTER_ALL` | 引擎获取/重置、重量级资源创建 | `ASTEST_CREATE_ENGINE_SHARE_CLEAN()` |
| `BEFORE_EACH` / `AFTER_EACH` | 每个测试必须隔离的状态（如 `AddExpectedError`） | 仅在特殊需要时使用 |
| `TEST_METHOD` 内 RAII | 模块创建/销毁、局部作用域 | `FCoverageModuleScope`、`FAngelscriptEngineScope` |

### 跨边界 FString 测试模式

绑定测试中常见三种 C++ ↔ AS 数据传递路径：

**1. AS 内部比较，返回 int**（最常用）：

```cpp
// AS 代码
int MyTest() {
    FString S = "Hello".ToUpper();
    return (S == "HELLO") ? 1 : 0;
}

// C++ 断言
ExpectGlobalInts(*TestRunner, Engine, M, Profile, Cases);
```

**2. AS 返回 FString，C++ 验证内容**：

```cpp
// AS 代码
FString MyReturnTest() {
    return "Hello".ToUpper();
}

// C++ 断言
ExpectGlobalReturnCustom<FString>(*TestRunner, Engine, M, Profile,
    TEXT("FString MyReturnTest()"),
    TEXT("ToUpper returns HELLO"),
    [](FAutomationTestBase& T, const FString& V) -> bool {
        return T.TestEqual(TEXT("upper"), V, TEXT("HELLO"));
    });
```

**3. C++ 传入 FString 参数，AS 处理**：

```cpp
// AS 代码
FString Pass_Upper(const FString& in S) {
    return S.ToUpper();
}

// C++ 调用
FString Input = TEXT("hello");
FASGlobalFunctionInvoker Inv(*TestRunner, Engine, M,
    TEXT("FString Pass_Upper(const FString& in)"));
Inv.AddArgRef(Input);
if (Inv.Call()) {
    FString Result;
    if (Inv.ReadReturnStruct(Result)) {
        TestRunner->TestEqual(TEXT("upper"), Result, TEXT("HELLO"));
    }
}
```

### 现有 CQTest PoC 参考

| 文件 | 测试数 | 覆盖范围 |
|---|---|---|
| `AngelscriptFStringBindingsTests.cpp` | 17 个 TEST_METHOD，300+ 用例 | FString 全 API + 全局函数 + 跨边界传参/返回 |

## 测试模板（Template/ 目录）

`Plugins/Angelscript/Source/AngelscriptTest/Template/` 下保存了一组「教学型」测试模板，作为新测试的起点。它们本身也是 Automation 测试、会随回归一起运行，但首要价值是**演示标准做法**。新增同类测试时优先 copy-paste 改写一个模板，而不是从零拼接。

| 模板 | 主题 | Automation 前缀 | 推荐起点的场景 |
|---|---|---|---|
| `Template_CQTest.cpp` | CQTest 骨架（编译 / 单 / 多断言 / 错误处理） | `Angelscript.Template.CQTest.*` | 任何要写 AS 编译执行回归的纯 C++ 测试，先看它 |
| `Template_GlobalFunctions.cpp` | 通过 `FASGlobalFunctionInvoker` 调用 AS 全局函数 | `Angelscript.Template.GlobalFunctions.*` | C++ 直接调 AS 全局函数（非 `UFUNCTION`）传参 / 返回 |
| `Template_ReflectionAccess.cpp` | 通过 `ReadPropertyValue` / `GetEnumByPath` 读 AS 端 UPROPERTY / UFUNCTION | `Angelscript.Template.Reflection.*` | UE 5.x 反射读 AS-side 属性，含 `float` ↔ `FDoubleProperty` 注意点 |
| `Template_WorldTick.cpp` | World.Tick / Actor.Tick / Component.Tick 三种驱动方式 | `Angelscript.Template.WorldTick.*` | 任何与「逐帧推进」绑定的 actor / component 测试 |
| `Template_GameLifetime.cpp` | 完整 Actor 生命周期：Construction → BeginPlay → Tick → EndPlay → Destroyed | `Angelscript.Template.GameLifetime.*` | 验证生命周期事件链 / 顺序、Destroy 后属性读取 |
| `Template_Blueprint.cpp` | 以 AS 类为父的瞬态 Blueprint 子类 | `Angelscript.Template.Blueprint.*` | Blueprint 继承 / 参数链 / 编译验证 |
| `Template_BlueprintWorldTick.cpp` | Blueprint actor child 在 world tick 下的回调链 | `Angelscript.Template.Blueprint.*` | Blueprint 子类的 BeginPlay / Tick 集成 |

约定：

- 模板文件位于 `Template/`，**不**作为新增功能 case 的最终落点。新功能 case 仍按 `Documents/Guides/TestConventions.md` 第 3 节的层级落到对应主题目录（`Actor/`、`Bindings/` 等）。
- 模板的 Automation 前缀统一使用 `Angelscript.Template.*`，避免与功能测试主题冲突。
- 新增 / 修改模板时同步更新本表与 `TestCatalog.md`。

### Actor / World Tick 测试推荐 harness

`Shared/AngelscriptTestWorld.h::FAngelscriptTestWorld` 是当前 actor / component 类功能测试的标准 harness（在 `FActorTestSpawner` 之上做组合扩展，自带 `FAngelscriptEngineScope`）。`Template_WorldTick.cpp` 与 `Template_GameLifetime.cpp` 是它的两份示范用法；harness 自身契约由 `Shared/AngelscriptTestWorldTests.cpp`（前缀 `Angelscript.TestModule.Shared.TestWorld.*`）锁定。

构造与基本用法：

```cpp
FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
FAngelscriptEngineScope Scope(Engine);

FAngelscriptTestWorld W(*TestRunner, Engine);
ASSERT_THAT(IsTrue(W.IsValid()));

AActor* Actor = W.SpawnActorOfClass(ScriptClass);
W.BeginPlay(*Actor);
```

三种 tick 驱动方式必须按场景区分使用：

| 方法 | 行为 | 适合的断言 |
|---|---|---|
| `W.Tick(Dt, N)` | `World.Tick` + 手动 `TActorIterator` 派发 actor / component tick | `>= N` 弱断言；多 actor / 含 component 场景 |
| `W.TickViaManager(Dt, N)` | 仅调用 `World.Tick`，由 UE world scheduler 决定派发 | `>= 1` 弱断言；演示 UE 调度路径 |
| `W.DispatchActorTick(Actor, Dt, N)` / `W.DispatchComponentTick(Comp, Dt, N)` | 直接循环 `Actor->Tick` / `Component->TickComponent`，绕开调度器 | **`== N` 严格断言**；首选用于精确 tick 计数 |

> **常见坑**：在 test world 里 `World.Tick` 不保证每一帧都派发 `ReceiveTick`。任何要做 `TickCount == NumTicks` 严格断言的测试必须用 `DispatchActorTick` / `DispatchComponentTick`，否则会出现实际跑了 N 帧但 AS 端只记录 1 次的偏差。

完整生命周期（Construction → BeginPlay → Tick → EndPlay → Destroyed）的标准模式：

```cpp
FAngelscriptTestWorld W(*this, Engine);
AActor* Actor = W.SpawnActorOfClass<AActor>(ScriptClass);  // 触发 UserConstructionScript
W.BeginPlay(*Actor);                                       // 触发 BeginPlay
W.Tick(0.016f, 3);                                         // 触发 Tick × N
W.DestroyAndDrain(*Actor);                                 // 同步触发 EndPlay + Destroyed
```

要点：

- AS 中的 `UFUNCTION(BlueprintOverride) void UserConstructionScript()` 才是 Spawn 阶段的构造回调，**不是** `ConstructionScript`。
- `Actor->Destroy()` 会同步派发 `EndPlay(EEndPlayReason::Destroyed)` 与 `Destroyed`，actor 随后被标记 `PendingKill`；但 UObject 内存仍存活，`FProperty::GetPropertyValue_InContainer`（即 `ReadPropertyValue`）依然可读，所以 `DestroyAndDrain` 之后断言阶段计数与 `LastEndPlayReason` 是合法做法。`TWeakObjectPtr::IsValid()` 在 `PendingKill` 后返回 `false`，不要把它当存活检查。
- AS 声明的 `float UPROPERTY` 在 UE 5.x 下被反射为 `FDoubleProperty`；C++ 侧必须用 `ReadPropertyValue<FDoubleProperty>` + `double`，否则 `FFloatProperty` 查找会返回空。
- Component tick 需要在 spawn 后手动开启，AS 不会自动翻 flag：

```cpp
Component->PrimaryComponentTick.bCanEverTick = true;
Component->SetComponentTickEnabled(true);
```

- BeginPlay 通过 harness 调用是幂等的（内部依赖 `AActor::HasActorBegunPlay()` 守卫），重复调用不会重派发。

新增 actor / component 测试时，不要再手写 `FActorTestSpawner` + 局部 `FAngelscriptEngineScope` + 局部 dispatch helper，统一用 `FAngelscriptTestWorld`。模块清理仍按现行 RAII 模式手写：

```cpp
static const FName ModuleName(TEXT("MyTestModule"));
ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };
```

## 与 Gauntlet 的边界

- `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` 负责仓库内标准自动化测试入口、日志、摘要和超时收口。
- `Gauntlet` 只在需要 outer shell、多进程会话编排、联网拓扑或更复杂生命周期管理时使用。
- 常规本地回归、AI Agent 执行和普通 CI 不要绕过官方 runner 去手写 `RunUAT` / `UnrealEditor-Cmd.exe`。

## 故障排除

### 测试前卡在构建阶段

如果日志里长时间没有任何编译推进，优先排查：

1. 是否有其他 worktree 还在跑旧的 `Build.bat` 路径
2. 是否需要在对应 build 中透传 `-NoXGE`
3. `Intermediate/TargetInfo.json` 是否已通过 bootstrap 正常预热

### 测试无输出直到超时

按以下顺序排查：

1. 确认参数名正确，前缀用 `-TestPrefix`，不是 `-Filter`
2. 用 `Tools\Diagnostics\powershell\Get-UbtProcess.ps1` 检查是否有残留 UBT / Editor
3. 确认同一 worktree 内没有第二个 build/test 正在运行
4. 检查当前 run 的 `RunMetadata.json`，看是否卡在 `TargetInfo` 预热、`Build.bat` 锁等待或编辑器执行阶段

## 对 AI Agent 的要求

1. 先读取根目录 `AgentConfig.ini`
2. 配置缺失或 worktree 路径不匹配时先跑 `Tools\Bootstrap\powershell\BootstrapWorktree.ps1`；新 worktree 需要显式传 `-EngineRoot`
3. bootstrap 会自动初始化子模块；如果子模块仍缺失，参考 `Documents/Guides/SubmoduleWorktreeWorkflow.md`
4. 单条测试只通过 `Tools\RunTests.ps1`
5. suite 波次只通过 `Tools\RunTestSuite.ps1`
6. 显式传入或继承一个不超过 `900000ms` 的超时
7. 不要手写 `UnrealEditor-Cmd.exe`、`RunAutomationTests.ps1` 或共享日志路径

## 推荐提示词

```text
请先读取项目根目录的 AgentConfig.ini；如果缺失或 ProjectFile 不属于当前 worktree，先执行 Tools\Bootstrap\powershell\BootstrapWorktree.ps1（新 worktree 需要 -EngineRoot 参数）。bootstrap 会自动初始化子模块；如果子模块目录仍然为空，参考 Documents/Guides/SubmoduleWorktreeWorkflow.md 中的 fallback 策略。自动化测试只能通过 Tools\RunTests.ps1 或 Tools\RunTestSuite.ps1 执行，并显式带一个不超过 3600000ms 的超时。不要手写 UnrealEditor-Cmd.exe 命令，也不要手写 -ABSLOG / -ReportExportPath 共享路径；日志、报告和摘要必须写入当前 run 的独立目录。除非明确需要真实渲染，否则保持默认 headless 模式。
```

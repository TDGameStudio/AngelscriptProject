## Why

`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h` 已经膨胀为 **967 行的"上帝头"**，在同一头里 inline 实现了 7 段不同职责（生产/隔离/瞬态引擎获取、UASClass + BP Action DB 的 GC 清理、内存探针、shared engine 重置 + 调试日志、模块编译/函数查找、AS 函数执行/异常断言、`FAngelscriptTestFixture`），并把 `BlueprintActionDatabase.h`、`K2Node_GetSubsystem.h` 以及 SDK 三件套传染给 **400+ 个测试 `.cpp`**。同时 `Shared/` 目录另存在 4 个纯转发别名（`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`，共 ~46 个 callsite）是历史迁移残留。

与此同时，`AngelscriptTest/Bindings/` 71 个 `.cpp` 文件里"调用 AS 函数"这件事的入口高度分散：`Shared/AngelscriptBindingsAssertions.h` 提供 9 个 `Expect*` 一行式断言、`Shared/AngelscriptGlobalFunctionInvoker.h` 提供底层 `FASGlobalFunctionInvoker` fluent 类、各 Bindings/*.cpp 内还散落 4-5 份私有 `Execute*Function*` helper（Math/Orientation/Curve/WorldFunc 等），加上 `AngelscriptTestUtilities.h` 自带的 `ExecuteIntFunction*` / `ExecuteInt64Function`，**同一意图至少 7 个并行入口**，命名族（`Expect*` / `Execute*Function*` / `.Call()` / `.CallAndReturn`）互不对齐，与 UE 风格 / AS 底层 `asIScriptContext::Execute()` 也不一致。

本次把它收成「纯聚合 umbrella + 6 个主题小头」，并新建第 7 个主题头 `AngelscriptTestExecute.h` 作为唯一收口；同时建立以 `Execute` 为根动词的命名族契约（`Execute` / `ExecuteAndGet<T>` / `ExecuteAndExpect<Type>` / `ExecuteAndExpectNear<Type>` / `ExecuteBatchAndExpect<Type>` / `ExecuteAndValidate<T>` / `ExecuteAndExpectException` / `CompileAndExpectFailure`）。**新代码强制走 `Execute*` 族**；所有旧符号 / 旧头 / 散落 helper 通过 inline alias + forward 头**永久保留兼容**，确保仓库内任何旧 callsite 继续编译通过，由后续 follow-up change 渐进重命名清理。

## What Changes

### Header 拆分（沿用原 proposal 范围 + 1 个主题头改名）

- 拆 `AngelscriptTestUtilities.h` 967 行 inline 实现为 **6 个主题头 + 1 个 .cpp**（全部平铺在 `Shared/`）：`AngelscriptTestEngineAcquisition.h/.cpp`、`AngelscriptTestEngineCleanup.h`、`AngelscriptTestMemoryProbe.h`、`AngelscriptTestModuleBuilder.h`、**`AngelscriptTestExecute.h`**（改名 — 原 proposal 中的 `AngelscriptTestExecution.h` 直接命名为 `AngelscriptTestExecute.h`，与下文新命名族收口名对齐）、`AngelscriptTestFixture.h`。
- `AngelscriptTestUtilities.h` 缩成 **~40 行的纯聚合入口头**，只 `#include` 上面 6 个新头 + 现有 `AngelscriptTestEngine.h` + `Misc/AutomationTest.h`，不再放任何函数实现。继续作为 400+ 测试 `.cpp` 的兼容包含入口。
- **BREAKING（测试模块内部）**：退役 4 个纯转发别名 `GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`，~46 个 callsite 替换为 `GetOrCreateSharedCloneEngine` / `AcquireCleanSharedCloneEngine` / `ResetSharedCloneEngine`。**不影响外部插件**（`AngelscriptGAS` 等），因 audit 显示这些别名仅在 `AngelscriptTest` 模块内部被调用。
- 把 `WITH_EDITOR` 的 `BlueprintActionDatabase` / `K2Node_*` 依赖**收敛到 `AngelscriptTestEngineCleanup.h` 一个文件**，不再透传给所有测试 TU（主要的编译时间收益）。
- 新增 `Shared/README.md`，给 47+ 个文件提供 1 屏内的导航索引，与 `TestConventions.md` 的 helper 推荐表对齐。
- 在每个新头顶部加 ~15 行块注释，说明职责边界、依赖头、典型调用方。

### Execute 单文件收口（新增 — 第 7 个主题头的扩展职责）

- **`AngelscriptTestExecute.h` 吸收**：
  - 原 `Shared/AngelscriptGlobalFunctionInvoker.h`（408 行）全部内容（底层 fluent executor 类 + `ResolveFunctionByDecl` / `ResolveFunctionByName`）。
  - 原 `Shared/AngelscriptBindingsAssertions.h`（378 行）全部内容（`Expect*` 一行式断言族）。
  - `AngelscriptTestUtilities.h` 原 873-1015 段的 `ExecuteIntFunction` / `ExecuteIntFunctionExpectingScriptException` / `ExecuteInt64Function`。
- **旧两个共享头改为永久 forward 头**：`AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` 各缩为 ~3 行 `#include "AngelscriptTestExecute.h"`，在 follow-up change 内最终删除。
- **Bindings/*.cpp 内文件私有 `Execute*Function*` helper 保持原状不动**（不被吸收到 `Execute.h`），仅在文件头加 `// TODO(refactor-as-test-shared-layout-and-naming): migrate to AngelscriptTestExecute.h` 标记，由 follow-up change 内逐文件迁入。

### `Execute*` 命名族契约（新增）

新建 `FAngelscriptTestExecutor` 类 + 以 `Execute` 为根的自由函数族，词位 `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect|(空)][Near|AtLeast|(空)][<Type>|<T>]`：

| 旧 API（永久 inline alias）| 新 API（强制收口）|
|---------------------------|-------------------|
| `FASGlobalFunctionInvoker` | `FAngelscriptTestExecutor` |
| `.Call()` | `.Execute()` |
| `.CallAndReturn<T>(Fallback)` | `.ExecuteAndGet<T>(Fallback)` |
| `.ReadReturnStruct<T>(Out)` | `.ExecuteAndExtractStruct<T>(Out)` |
| `ExpectGlobalInt` / `ExpectGlobalBool` / `ExpectGlobalDouble` | `ExecuteAndExpectInt` / `ExecuteAndExpectBool` / `ExecuteAndExpectDouble` |
| `ExpectGlobalReturnFloat` | `ExecuteAndExpectNearFloat` |
| （新增） | `ExecuteAndExpectNearDouble` |
| `ExpectGlobalIntAtLeast` | `ExecuteAndExpectIntAtLeast` |
| `ExpectGlobalInts` | `ExecuteBatchAndExpectInt` |
| `ExpectGlobalReturnCustom<T>` | `ExecuteAndValidate<T>(..., Validator)` |
| `ExecuteFunctionExpectingScriptException` / 散落 `ExecuteFunctionExpectingException` | `ExecuteAndExpectException` |
| `ExpectBindingCompileFailure` | `CompileAndExpectFailure`（独立 `Compile*` 族）|

设计原则：

1. `Execute` 不带后缀 = 仅执行不取值，与 AS 底层 `asIScriptContext::Execute()` 严格对齐。
2. `AndGet` 取返回不断言 / `AndExpect` 取返回并断言相等 / `AndValidate` 取返回并自定义校验。
3. 修饰词位置：`Near` / `AtLeast` 紧贴 `Expect`（修饰断言语义），`Batch` 紧贴 `Execute`（修饰执行行为）。
4. 类型后缀在最末（`Int` / `Bool` / `Float` / `Double` / `<T>`），无歧义时省略（成员 `ExecuteAndGet<T>`）。
5. 不引入 `Expect*` / `Invoke*` / `Call*` 等并行词族 — 旧名仅作 inline alias 兼容，spec 内禁止新代码使用。
6. compile-side 独立成 `Compile*` 族（仅 `CompileAndExpectFailure` 一员）。
7. `ExecuteAndValidate<T>` 与 `ExecuteAndExpect<T>` 故意分名，避免 lambda 重载歧义。

### 兼容策略（核心翻转 — 撤销原 proposal 的「0 改名」承诺）

- 原 proposal 承诺「公共符号名 0 改名」。本次改为：**新增 `Execute*` 主命名族；旧符号全部以 inline alias / forward 头永久兼容**。
- 任何 `AngelscriptTest` 模块内或外部插件（如 `AngelscriptGAS`）的旧 callsite 在本 change 落地后**继续编译通过**，无需任何修改。
- 唯一在本 change 内进行 callsite 改名的位置是 `AngelscriptBindingsExampleSection.h`（80 行示例），作为新命名的官方示范。
- 71 个 Bindings/*.cpp 文件、~200+ callsite、Profile 字段全词化、Profile 实例变量名重命名、AS 脚本字符串 namespace 改写、最终删除兼容层 — **全部推迟到 follow-up change**，由用户驱动渐进重命名。

### Profile 字段双字段并存（C++ 可 alias，本 change 内落地）

- `FBindingsCoverageProfile` 字段 `BodyInst` / `MsgDlg` / `MathOrient` / `CollisionVal` / `MathPlat` / `JsonConv` 等 6+ 处缩写：**新增全词字段**（如 `BodyInstance`），构造 / 初始化时与旧缩写字段同步赋值；旧缩写字段保留为 inline reference / `using` alias。
- Profile 实例变量名（如全局 `GBodyInstProfile`）**不动** — C++ 没有变量名 alias 机制，留 follow-up change 处理。
- `ModulePrefix` 全词化（`AS<Subject>` 不带 `Bindings`）也作为新字段并存方案的一部分。

### 不在本 change 范围

- **AS 脚本侧 namespace 改写**（`SetIter_SumElements` → `SetIter::SumElements`，1500+ 字符串字面量）：AS 不允许同名函数同时存在于 namespace 内外，**没有兼容期可走**，整个推迟到独立 follow-up change。
- **Bindings/*.cpp callsite 批量替换** + **删除兼容层**（旧符号 / forward 头 / inline alias）+ **Profile 实例变量名重命名** + **散落 helper 收编**：登记在本 change `followups.md`，由后续 follow-up change 渐进处理。
- **不动 Shared/ 子目录化** — 用户明确要求保持平铺。
- **不进入** `MockDebugServer`、`TestEnginePool`、`TestLegacyHelpers`、`Debugger*` 套件、`TestEngineHelper`（它的 `ExecuteIntFunction(Engine*, ModuleName, ...)` 重载与 TestUtilities 的同名函数签名 / 抽象层不同，非重复，本次不合并）。
- **不迁移** `AngelscriptTestLegacyHelpers.h`（11 个老 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 用户）— 作为遗留事项另开 OpenSpec。
- **不动** `AngelscriptTestMacros.h`、`AngelscriptTestEngine.h/.cpp`、`AngelscriptReflectiveAccess.h` — 与本次目标无关。
- **不修改** 已有 `refactor-angelscript-test-helper-api` 定义的外部消费契约（`angelscript-test-helper-api` capability）— 本次是模块**内部**结构重组 + 命名族契约新增，umbrella header 路径 `Shared/AngelscriptTestUtilities.h` 保持外部可见且语义不变，旧的 `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` 头路径通过 forward 头继续可用。
- **文档同步**（`.agents/skills/_angelscript-test-guide/SKILL.md` 与 `Documents/Guides/TestConventions.md`）：另开 follow-up change。

## Capabilities

### New Capabilities

- `as-test-utilities-header-layout`：定义 `AngelscriptTest/Shared/` 中「umbrella header + 主题小头」的契约 — 包括 `AngelscriptTestUtilities.h` 作为聚合入口的兼容性保证、6 个主题头的职责边界（含 `AngelscriptTestExecute.h` 作为 AS 函数调用主要入口）、退役符号清单、`Shared/README.md` 导航索引要求、编辑器头依赖收敛到 Cleanup 头的规则，以及旧 `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` 在本 change 内永久 forward（删除推迟到 follow-up）。
- `as-bindings-test-execute-and-naming`：定义 `Execute*` 命名族契约 — 包括 `FAngelscriptTestExecutor` 作为唯一底层 executor 类、`Execute*` 自由函数族词位规则、`Compile*` 独立族、Profile 双字段并存规则、`ModulePrefix=AS<Subject>` 收敛、新代码强制走新命名族、旧符号仅作 inline alias 兼容。

### Modified Capabilities

- 无。本次不修改已有 `angelscript-test-helper-api` capability 的外部消费契约（旧头路径通过 forward 头永久保留）。

## Impact

- **代码（拆分）**：`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h`（主拆分目标，967 行 → ~40 行）；新增 `AngelscriptTestEngineAcquisition.h/.cpp`、`AngelscriptTestEngineCleanup.h`、`AngelscriptTestMemoryProbe.h`、`AngelscriptTestModuleBuilder.h`、`AngelscriptTestExecute.h`、`AngelscriptTestFixture.h`、`Shared/README.md`。
- **代码（命名族）**：`Shared/AngelscriptTestExecute.h` 含 `FAngelscriptTestExecutor` 类 + `Execute*` 自由函数族 + 全部旧符号 inline alias（约 1100 行）；`Shared/AngelscriptGlobalFunctionInvoker.h`（408 行 → ~3 行 forward）；`Shared/AngelscriptBindingsAssertions.h`（378 行 → ~3 行 forward）；`Shared/AngelscriptBindingsCoverage.h`（104 行 → ~140 行，双字段并存）。
- **代码（标记）**：71 个 Bindings/*.cpp 中含私有 `Execute*Function*` helper 的 4-5 份（Math / Orientation / Curve / WorldFunc 等）顶部加 `// TODO(refactor-as-test-shared-layout-and-naming)` 标记。
- **代码（callsite 改名）**：仅 `AngelscriptBindingsExampleSection.h` 内示例（~80 行）改为新命名作为官方示范。
- **API（兼容性）**：所有旧符号（`FASGlobalFunctionInvoker` / `.Call` / `.CallAndReturn` / `ExpectGlobal*` / `ExecuteIntFunction*` / `ExpectBindingCompileFailure`）通过 inline alias / forward 头**永久可用**；新增 `Execute*` 族 + `FAngelscriptTestExecutor` 作为新代码强制入口。
- **API（破坏性）**：仅 4 个 `AngelscriptTestSupport::` 别名函数移除（`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`），共 ~46 callsite 在本 change 内同步替换。
- **依赖图**：测试模块 TU 不再透传 `BlueprintActionDatabase.h` / `K2Node_GetSubsystem.h`，除非显式包含 `AngelscriptTestEngineCleanup.h`。
- **文档**：`Documents/Guides/TestConventions.md` 与 `.agents/skills/_angelscript-test-guide/SKILL.md` 同步推迟到 follow-up change；本 change 仅新增 `Shared/README.md`。
- **构建系统**：无 `Build.cs` 改动 — `AngelscriptTest.Build.cs` 维持现状。
- **测试**：不影响 Automation 前缀；不新增 / 移除 / 禁用任何 test case；`275/275` C++ baseline + `301/301` ASSDK 子套不退化。
- **OpenSpec**：新增 `as-test-utilities-header-layout` 与 `as-bindings-test-execute-and-naming` 两个 capabilities；新建 `followups.md` 登记 8 项渐进清理工作交由 follow-up change 处理。

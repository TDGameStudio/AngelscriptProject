# 全量测试失败分诊与修复计划（2026-05-02）

## 背景与目标

2026-05-02 按 `Documents/Guides/Test.md` 规范分波执行全量自动化测试（4 波，各自独立 run 目录），总计 **1407 个用例，1366 通过，35 warning，6 failed**，通过率 **99.57%**。

6 个失败用例集中在 `Angelscript.TestModule.*`（`Angelscript.CppTests / Angelscript.Editor / Angelscript.Template` 三波 94 个用例全绿）。本 Plan 将 6 个失败按根因归类，固化修复方向，后续按 Phase 顺序推进。

**当前基线：1401/1407 通过**。目标：1407/1407 全绿。

### 本次全量回归产物

| 标签 | 前缀 | 用例 | 成功 | 警告 | 失败 | 用时 | Run 目录 |
|---|---|---:|---:|---:|---:|---:|---|
| `full-cpptests` | `Angelscript.CppTests` | 1 | 0 | 1 | 0 | 1.5s | `Saved/Tests/full-cpptests/20260502_152234_324_7cfb569a/` |
| `full-testmodule` | `Angelscript.TestModule` | 1313 | 1276 | 31 | **6** | 510.3s | `Saved/Tests/full-testmodule/20260502_151117_771_0e18229b/` |
| `full-editor` | `Angelscript.Editor` | 65 | 63 | 2 | 0 | 37.9s | `Saved/Tests/full-editor/20260502_152051_967_e7789a32/` |
| `full-template` | `Angelscript.Template` | 28 | 27 | 1 | 0 | 3.9s | `Saved/Tests/full-template/20260502_152200_527_ac86a7df/` |

备注：
- `All` suite（前缀 `Angelscript`）单波需要 > 15 分钟，无法在 `-TimeoutMs` 硬上限 `900000ms` 内跑完，因此分 4 波执行；4 波前缀联合覆盖等价于 `All`。
- `Tools\RunTestSuite.ps1 -Suite Smoke` 当前因内置前缀 `Angelscript.CppTests.MultiEngine` 无匹配而导致 suite 整体失败（与本次回归无关的 suite 定义偏差），已记入下方 Phase 5。

---

## 失败用例汇总

| # | Automation Path | 触发形式 | 根因分组 |
|---|---|---|---|
| 1 | `Angelscript.TestModule.Engine.BindConfig.FAngelscriptBindConfigTests.UnnamedBindBackwardCompatibility` | `TestTrue` 断言失败 | **B：测试与新约定不一致**（生产侧行为重构） |
| 2 | `Angelscript.TestModule.FunctionLibraries.Widget.FAngelscriptWidgetFunctionLibraryTest.RenderTransformNullGuard` | 模块编译失败 | **C：跨测试污染（共享引擎状态）** |
| 3 | `Angelscript.TestModule.Syntax.TypeDeclaration.FAngelscriptSyntaxTypeDeclarationTest.Class_Negative` | Error 日志泄漏 | **A：Negative 用例缺 AddExpectedError** |
| 4 | `Angelscript.TestModule.Syntax.TypeDeclaration.FAngelscriptSyntaxTypeDeclarationTest.Struct_Negative` | Error 日志泄漏 | **A** |
| 5 | `Angelscript.TestModule.Syntax.UFunction.FAngelscriptSyntaxUFunctionTest.Specifiers_Negative` | Error 日志泄漏 | **A** |
| 6 | `Angelscript.TestModule.Syntax.UProperty.FAngelscriptSyntaxUPropertyTest.Specifiers_Negative` | Error 日志泄漏 | **A** |

---

## Phase 1：Syntax Negative 用例补齐期望错误登记（A 组，4 个）

### 问题描述

4 个 `*_Negative` 用例共用 `SyntaxTestHelpers::AssertFailsToCompile` / `AssertFailsWithError`（`Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h:174 / :112`），仅通过 `UE_SET_LOG_VERBOSITY(Angelscript, Fatal)` 压制 `LogAngelscript`（`Shared/AngelscriptTestEngineHelper.cpp:135-138`）。

但 `AngelscriptPreprocessor::LineError / ChunkError / MacroError`（`AngelscriptPreprocessor.cpp:4558/4582/4594`）走的是 `FAngelscriptEngine::ScriptCompileError()` 诊断通道——**不经过 LogAngelscript verbosity 过滤**。Automation framework 仍然通过其他通道捕获到这些 error，被判为泄漏。

helper 也从未调用 `Test.AddExpectedError(...)`。4 个 Negative 用例没有任何一处自行登记期望错误。

### 具体泄漏清单

| 用例 | 泄漏诊断 | 产生位置 |
|---|---|---|
| #3 `Class_Negative` | `Class AClassBadParentActor has an unknown super type ANonExistentActor.` / `Class ASelfActor has an unknown super type ASelfActor.` | `AngelscriptPreprocessor.cpp:2905 LineError` |
| #4 `Struct_Negative` | `Error parsing script struct FChild. Structs may not inherit from anything.` | `AngelscriptPreprocessor.cpp:1246 ChunkError` |
| #5 `UFunction.Specifiers_Negative` | `Unknown function specifier InvalidSpecifier on method AUFuncInvalidActor::Foo.` / `... 999 on method AUFuncNumSpecActor::Foo.` / `... None on method AUFuncEmptyCommaActor::Foo.` | `AngelscriptPreprocessor.cpp:1639 MacroError` |
| #6 `UProperty.Specifiers_Negative` | `Unknown property specifier InvalidSpecifier ...` / `The NotReplicated specifier is only allowed structs.` / `Unknown property specifier None ...` / `No function specified for ReplicatedUsing on property AUPropRepNoFuncActor::X.` / `Unknown property specifier 123 ...` | `AngelscriptPreprocessor.cpp:2500 / 2509 / 2651 MacroError` |

### 影响文件

- `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h`
- `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTypeDeclarationTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxUFunctionTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxUPropertyTests.cpp`

### 任务清单

- [ ] **P1.1** 升级 `SyntaxTestHelpers::AssertFailsToCompile` / `AssertFailsWithError`
  - 增加 `TConstArrayView<FString> ExpectedErrorFragments = {}` 参数（或等价的变参）
  - 在进入编译前调用 `Test.AddExpectedError(Fragment, EAutomationExpectedErrorFlags::Contains, 0)` 把每条预期 error 登记为"允许次数不限"
  - 保持 `bSuppressCompileErrorLogs=true` 路径不变（仍然对 `LogAngelscript` 有效，减少噪声）
- [ ] **P1.1** 📦 Git 提交：`[AngelscriptTest/Syntax] Refactor: thread expected error fragments into AssertFailsToCompile helpers`

- [ ] **P1.2** 修复 `Class_Negative`（`AngelscriptSyntaxTypeDeclarationTests.cpp:131`）
  - 给 `ClassN_BadParent` 调用传入 `{TEXT("unknown super type")}`
  - 给 `ClassN_BadMember` / `ClassN_NoBrace` / `ClassN_Duplicate` 按实际诊断补齐
  - 注意：`ASelfActor : ASelfActor` 的测试片段会触发 2 条相同诊断，`AddExpectedError` 的默认次数策略要覆盖 `>=1`（`ExpectedCount=0` 表示匹配任意次数）
- [ ] **P1.2** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register expected errors for Class_Negative diagnostics`

- [ ] **P1.3** 修复 `Struct_Negative`（同文件 `:270`）
  - 补 `{TEXT("Structs may not inherit from anything"), TEXT("Duplicate"), TEXT("Invalid member type")}` 等
- [ ] **P1.3** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register expected errors for Struct_Negative diagnostics`

- [ ] **P1.4** 修复 `UFunction.Specifiers_Negative`（`AngelscriptSyntaxUFunctionTests.cpp:198`）
  - 统一传 `{TEXT("Unknown function specifier"), TEXT("UFUNCTION")}` 覆盖 `InvalidSpecifier` / `999` / `None`（后两条同样走 `Unknown function specifier` 分支）
  - `UFuncSN_OnProperty` / `UFuncSN_MissingParen` 按 Automation.log 的实际诊断补齐
- [ ] **P1.4** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register expected errors for UFunction Specifiers_Negative`

- [ ] **P1.5** 修复 `UProperty.Specifiers_Negative`（`AngelscriptSyntaxUPropertyTests.cpp:187`）
  - 需要覆盖的片段列表：
    - `Unknown property specifier`（覆盖 `InvalidSpecifier` / `None` / `123`）
    - `The NotReplicated specifier is only allowed structs.`（注意文案缺介词，保留原字符匹配）
    - `No function specified for ReplicatedUsing`
- [ ] **P1.5** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register expected errors for UProperty Specifiers_Negative`

- [ ] **P1.6** 验证 Phase 1：
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "Angelscript.TestModule.Syntax" -Label triage-phase1 -TimeoutMs 600000
  ```
  - 目标：4 个用例全部通过，无 `LogAutomationController: Error` 泄漏
- [ ] **P1.6** 📦 Git 提交（如需）

### 备选方案

若 `AddExpectedError` 在 helper 级别登记会干扰其他断言的 `ReportCompileDiagnostics` 流程，退回方案：**在每个 `TEST_METHOD` 开头一次性登记通用模式**，例如：

```cpp
TEST_METHOD(Specifiers_Negative)
{
    TestRunner->AddExpectedError(TEXT("Unknown function specifier"), EAutomationExpectedErrorFlags::Contains, 0);
    // ...
}
```

---

## Phase 2：BindConfig 匿名 bind 约定重构跟随（B 组，1 个）

### 问题描述

测试 `UnnamedBindBackwardCompatibility`（`AngelscriptBindConfigTests.cpp:308`）断言：匿名 `FAngelscriptBinds::FBind(lambda)` 注册后，新增的 bind name 以 `"UnnamedBind_"` 为前缀。

但 working-tree 中 `AngelscriptBinds.cpp/.h` 的未提交改动引入了 **"匿名 bind 使用 `__builtin_FILE()` stem 作为稳定名"** 的新约定：

- `FBind` ctor 追加默认参数 `const ANSICHAR* CallerFile = __builtin_FILE()`
- `RegisterBinds(int32, TFunction, const ANSICHAR* CallerFile)` 签名扩展，消费 `CallerFile`
- 新 helper `MakeBindNameFromCallerFile(CallerFile)`：取 `FPaths::GetBaseFilename(CallerFile)` 得到 stem；同 stem 第 2+ 次加 `#N` 后缀；仅当 `CallerFile == nullptr / ""` 或 stem 为空时才 fallback 回 `MakeUnnamedBindName()` → `"UnnamedBind_%d"`

### 新约定的设计动机

同批改动新增 `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptEnumTableBaselineProbe.{h,cpp}`（`Plan_UhtArtifactExpansion.md` P3.2 Phase 0 baseline probe），核心 API `RecordBindTiming(FName BindName, int32 BindOrder, double DurationSeconds)` 需要按"每个 bind 调用点"聚合 startup timing。旧的 `UnnamedBind_%d` 计数器依赖 TU 初始化顺序，**跨 build 不稳定**，无法与源文件对应；新的 stem 命名让 probe 数据可以落回源文件（`Bind_UEnum` / `Bind_BlueprintType#2` …），且用 `__builtin_FILE()` 默认参数实现了**对所有 `Bind_*.cpp` 调用点零改**的 migration。

结论：**新约定是有意的设计增强**，不是回归。测试锁死 `"UnnamedBind_"` 字面前缀过于实现细节，应跟随新约定调整。

### 影响文件

- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`

### 任务清单

- [ ] **P2.1** 改写 `UnnamedBindBackwardCompatibility` 断言
  - 不再依赖 `StartsWith("UnnamedBind_")`
  - 改用 `NewBindNames`（基线 diff 的结果集）判定：本用例只注册 1 个匿名 bind，**期望 `NewBindNames.Num() == 1`，`GeneratedUnnamedBindName = NewBindNames[0]`**
  - 保留原有 `BindOrder == 0` / `bEnabled == true` / `FBindExecutionRecorder::Get(CounterKey) == 1` 的后续断言（这些测的是行为语义，与命名无关）
- [ ] **P2.1** 📦 Git 提交：`[AngelscriptTest/Core] Fix: align UnnamedBindBackwardCompatibility with caller-file naming convention`

- [ ] **P2.2** （可选）顺势把测试名里的 `Unnamed` 语义更新
  - 考虑改名为 `CallerFileNamedBindBackwardCompatibility` 或新增 sibling 用例 `CallerFileStemRegistration`，明确验证 stem 命名路径
  - 保留原名以减少 blast radius 亦可；视 review 意见决定
- [ ] **P2.2** 📦 Git 提交（如执行）

- [ ] **P2.3** （可选）补测试覆盖新约定的边角
  - 同文件多个匿名 `FBind` 的 `#1`/`#2` 递增
  - 显式 `FAngelscriptBinds::RegisterBinds(0, fn, nullptr)` 走 `UnnamedBind_%d` fallback 路径
  - `StemDuplicateCounter` 跨测试不重置的行为语义文档化（function-static，进程级）
- [ ] **P2.3** 📦 Git 提交（如执行）

- [ ] **P2.4** 验证 Phase 2：
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "Angelscript.TestModule.Engine.BindConfig" -Label triage-phase2 -TimeoutMs 600000
  ```
- [ ] **P2.4** 📦 Git 提交（如需）

### 备选方案

若 `MakeBindNameFromCallerFile` 这次改动实际是误入 working tree（需确认是否属于某个未合并计划）：
- 退回旧签名 `RegisterBinds(int32, TFunction<void()>)`，`CallBinds` 的 probe scope 用 `Bind.BindName`（仍是 `UnnamedBind_%d`）
- 不修改测试

该备选方案的代价是 **probe 数据不可读**，不推荐。

---

## Phase 3：Widget 函数库用例跨测试污染（C 组，1 个）

### 问题描述

`RenderTransformNullGuard`（`AngelscriptWidgetFunctionLibraryTests.cpp:63`）在 `FCoverageModuleScope Mod(...)` 构造（`:87`）时就失败，`Shared/AngelscriptTestUtilities.h:746` 抛出 `Failed to compile script module 'ASWidget_RenderTransform'`。

脚本源本身（调用 `Widget.GetRenderTransform()` 并读 `FWidgetTransform.Translation/Scale/Angle`）没有语法错误。该用例**单跑可过**，仅在全量回归中失败——与 `AngelscriptEngineTypeInteropTests.cpp:139` 已标注的已知问题同根：

```
Warning: FIntPoint struct mapping: got null, expected IntPoint.
Known full-suite issue — prior tests contaminate global type binding state. Passes in isolation.
```

推测：共享引擎在前序测试（`Angelscript.TestModule.FunctionLibraries.*` 或更早）执行后，`FWidgetTransform` 或 `UWidget` 相关类型注册表被污染，导致模块解析 `Widget.GetRenderTransform()` 返回值类型时失败。

### 影响文件

- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptWidgetFunctionLibraryTests.cpp`
- （诊断时可能需要改动）`Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineTypeInteropTests.cpp`
- （根因修复时可能需要改动）`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` 类型注册清理路径

### 任务清单

- [ ] **P3.1** 短期隔离修复
  - 把 `AngelscriptWidgetFunctionLibraryTests` 的 `BEFORE_ALL` 从 `ASTEST_CREATE_ENGINE()` 切换到 `ASTEST_CREATE_ENGINE_SHARE_CLEAN()`（见 `Documents/Guides/Test.md` CQTest 推荐模式）
  - 或在 `BEFORE_ALL` 里 `ASTEST_CREATE_ENGINE_SHARE()` 后立即 `AngelscriptTestSupport::ResetSharedCloneEngine(Engine)` 强制清理
  - 验证：全量跑 `Angelscript.TestModule.FunctionLibraries.Widget` 通过；隔离跑仍通过
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptTest/FunctionLibraries] Fix: reset shared engine before Widget function library cases`

- [ ] **P3.2** 诊断根因（可作为独立 ticket 拆出去）
  - 复现：先跑 `Angelscript.TestModule.FunctionLibraries`，立即接 `RenderTransformNullGuard`，抓取 `FWidgetTransform` 的 `asITypeInfo*` 与 `GetTypeDatabase().GetUnrealStructFromTypeId()` 返回
  - 对齐 `AngelscriptEngineTypeInteropTests.cpp:139` 的 `FIntPoint` 现象，判断是否是**同一个** known full-suite issue
  - 如是，统一到 `Plan_TestEngineIsolation` / `Plan_TestSuiteAccumulationStability` 的后续工作中
- [ ] **P3.2** 📦 Git 提交（如需，通常只产出诊断文档或 ticket 链接）

- [ ] **P3.3** 验证 Phase 3：
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "Angelscript.TestModule.FunctionLibraries" -Label triage-phase3 -TimeoutMs 600000
  ```
- [ ] **P3.3** 📦 Git 提交（如需）

### 备选方案

若 `ResetSharedCloneEngine` 对整个 `FunctionLibraries` 套件性能影响过大（全量回归多花数十秒），可改为**仅** `RenderTransformNullGuard` 用例入口处调用：

```cpp
TEST_METHOD(RenderTransformNullGuard)
{
    FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
    AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
    FAngelscriptEngineScope Scope(Engine);
    // ...
}
```

---

## Phase 4：全量回归复测

- [ ] **P4.1** 单独跑 `Angelscript.TestModule.Syntax` / `Angelscript.TestModule.Engine.BindConfig` / `Angelscript.TestModule.FunctionLibraries`，各自 label 独立
- [ ] **P4.2** 跑 `Angelscript.TestModule` 全前缀（`full-testmodule` 等价波次），确认 1313/1313 全绿
- [ ] **P4.3** 顺带跑 `Angelscript.CppTests` / `Angelscript.Editor` / `Angelscript.Template` 三波，保持基线不退
- [ ] **P4.4** 把新基线数据归档到本 Plan 末尾"执行记录"节
- [ ] **P4.4** 📦 Git 提交：`[Docs/Plans] Docs: record full-suite green snapshot after triage`

---

## Phase 5：外围遗留问题（非本轮阻塞）

以下问题在本次回归中被发现但不在 6 个失败用例之内，登记在此避免丢失。

### P5.1 `Tools\RunTestSuite.ps1 -Suite Smoke` 定义 stale

- 现象：Smoke suite 内置前缀 `Angelscript.CppTests.MultiEngine` 当前匹配 0 个测试，导致 suite 整体退出码 ≠ 0，后续波次被 `throw` 阻断
- 位置：`Tools\RunTestSuite.ps1` 内置 suite 定义中 `Smoke` 条目
- 建议修复：把过期前缀替换为 `Angelscript.CppTests.Engine.DependencyInjection` 等仍然存在的具体前缀；或直接用 `Angelscript.CppTests.Engine`
- [ ] **P5.1** 📦 Git 提交：`[Tools/RunTestSuite] Fix: refresh Smoke suite prefixes after CppTests restructure`

### P5.2 `All` suite 不再能在 15 分钟内跑完

- 现象：`Tools\RunTestSuite.ps1 -Suite All` 以 `Angelscript` 前缀执行，实际耗时 > 900s，触发 `-TimeoutMs 900000` 硬上限
- 候选方案：
  - 方案 A：在 `RunTestSuite.ps1` 里把 `All` 拆分为 `All-CppTests / All-TestModule / All-Editor / All-Template` 四个子 suite，脚本层串行调度
  - 方案 B：把 `-TimeoutMs` 硬上限放宽到 `1800000`（30 分钟）——需要同步改 `Documents/Guides/Test.md` 规范
- 决策放到下一轮技术债盘点
- [ ] **P5.2** 📦 Git 提交（视决策）

### P5.3 产品文案 `The NotReplicated specifier is only allowed structs.`

- `AngelscriptPreprocessor.cpp:2509` 诊断文案缺介词（应为 `"only allowed in structs"` 或 `"only allowed on structs"`）
- 非阻塞，但可顺手修掉；注意修正后要同步 P1.5 里的 `AddExpectedError` 片段
- [ ] **P5.3** 📦 Git 提交：`[Angelscript/Preprocessor] Docs: fix NotReplicated specifier diagnostic phrasing`

---

## 优先级与建议推进顺序

1. **P0：Phase 1（A 组 4 个用例）** — 改动集中、机制清晰、收益确定（4/6 立刻回绿 + 后续 Negative 用例写法有模板）
2. **P1：Phase 2（B 组 1 个）** — 跟随 working-tree 中已完成的 bind 命名重构，修测试即可（1/6 回绿）
3. **P2：Phase 3（C 组 1 个）** — 短期隔离修复快（1/6 回绿）；根因留 ticket 对接现有 test isolation Plan
4. **P3：Phase 4** — 复测归档
5. **P4：Phase 5** — 技术债，随时可做

预计总工作量：**半天内可以把 6 个失败全部回绿**（Phase 1 + 2 + 3.1 一轮）；Phase 3.2 / Phase 5 看排期。

---

## 参考资料

- 全量测试产物目录：`Saved/Tests/full-*`
- 测试运行规范：`Documents/Guides/Test.md`
- CQTest 与 `AddExpectedError` 用法：`Documents/Guides/Test.md` 第 "CQTest 框架使用指南" 节
- 已知全量污染参考：`Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineTypeInteropTests.cpp:139`（`FIntPoint: Known full-suite issue`）
- 关联 Plan：
  - `Documents/Plans/Plan_TestEngineIsolation.md`
  - `Documents/Plans/Plan_TestSuiteAccumulationStability.md`
  - `Documents/Plans/Plan_KnownTestFailureFixes.md`（前一轮 7 个已知失败修复的经验）
  - `Documents/Plans/Plan_UhtArtifactExpansion.md`（P3.2 Phase 0 baseline probe，驱动了本次 bind 命名重构）

---

## 执行记录

<!-- 每轮执行完成后在此追加：日期、runner label、通过/失败计数、Summary.json 路径、备注 -->

- 2026-05-02 初始基线：1401/1407 通过（Phase 1~3 待执行）
  - `Saved/Tests/full-testmodule/20260502_151117_771_0e18229b/Summary.json`
  - `Saved/Tests/full-editor/20260502_152051_967_e7789a32/Summary.json`
  - `Saved/Tests/full-template/20260502_152200_527_ac86a7df/Summary.json`
  - `Saved/Tests/full-cpptests/20260502_152234_324_7cfb569a/Summary.json`

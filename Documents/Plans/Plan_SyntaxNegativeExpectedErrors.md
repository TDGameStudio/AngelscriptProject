# Syntax Negative Expected Error 收口计划

## 背景与目标

2026-05-09 全量 `Angelscript` 自动化回归结果为 **1403/1410 通过，7 failed**。其中 4 个失败集中在 Syntax 负向语法测试：

| # | Automation Path | 表面失败 | 实际语义 |
|---|---|---|---|
| 1 | `Angelscript.TestModule.Syntax.TypeDeclaration.FAngelscriptSyntaxTypeDeclarationTest.Class_Negative` | `LogAngelscript Error` 泄漏 | 非法 class 编译失败，负向断言符合预期 |
| 2 | `Angelscript.TestModule.Syntax.TypeDeclaration.FAngelscriptSyntaxTypeDeclarationTest.Struct_Negative` | `LogAngelscript Error` 泄漏 | 非法 struct 编译失败，负向断言符合预期 |
| 3 | `Angelscript.TestModule.Syntax.UFunction.FAngelscriptSyntaxUFunctionTest.Specifiers_Negative` | `LogAngelscript Error` 泄漏 | 非法 `UFUNCTION` specifier 编译失败，负向断言符合预期 |
| 4 | `Angelscript.TestModule.Syntax.UProperty.FAngelscriptSyntaxUPropertyTest.Specifiers_Negative` | `LogAngelscript Error` 泄漏 | 非法 `UPROPERTY` specifier 编译失败，负向断言符合预期 |

本计划目标是把 Syntax 负向语法测试中的“预期编译错误”与 UE Automation 的 expected-error 机制对齐，使这些测试继续验证编译失败，同时不再因为预期中的 `LogAngelscript Error` 被判红。

当前证据：

- 全量结果：`Saved/Tests/full-angelscript-after-gas-split/20260509_121011_996_243d553f/Summary.json`
- 单测复现：`Saved/Tests/syntax-class-negative-investigate/20260509_140407_502_648fdc62/Summary.json`
- 单独运行 `Class_Negative` 仍失败，证明不是全量顺序污染。

---

## 当前事实快照

### 测试 helper 现状

`SyntaxTestHelpers::AssertFailsToCompile` 位于 `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h:174`：

- 调用 `CompileModuleWithSummary(..., bSuppressCompileErrorLogs=true)`
- 调用 `ReportCompileDiagnostics(...)` 把源码与 diagnostics 作为 `AddInfo` 输出
- 只断言 `Summary.bCompileSucceeded == false`
- 不调用 `AddExpectedError` / `AddExpectedErrorPlain`

`SyntaxTestHelpers::AssertFailsWithError` 位于同文件 `:112`：

- 会额外检查 `Summary.Diagnostics` 是否包含指定错误片段
- 同样没有在编译前注册 Automation expected-error

### suppress 覆盖范围

`CompileModuleWithSummary` 位于 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp:328`，调用顺序是：

1. 清空 `Engine->Diagnostics`
2. `BuildModulesForSummary(...)`
3. `CompilePreparedModules(...)`
4. `CollectCompileTraceDiagnostics(...)`

`bSuppressCompileErrorLogs` 目前只在 `CompilePreparedModules` 内部通过 `UE_SET_LOG_VERBOSITY(Angelscript, Fatal)` 包住 `Engine->CompileModules(...)`，位置是 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp:135`。

这些失败 case 的 error log 多数发生在 `BuildModulesForSummary(...)` 内的 `Preprocessor.Preprocess()` 阶段，早于 suppression block，因此仍会被 UE Automation 捕获为未预期 error。

### runtime 诊断路径

`FAngelscriptEngine::ScriptCompileError(const FString&, const FDiagnostic&)` 位于 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:5207`：

- 先写入 `Engine.Diagnostics`
- 再根据 severity 直接 `UE_LOG(Angelscript, Error/Warning, ...)`

这条路径不同于 AngelScript SDK message callback `LogAngelscriptError(...)`。`LogAngelscriptError(...)` 会检查 `bIgnoreCompileErrorDiagnostics`，但 `ScriptCompileError(...)` 当前不会检查用于“只压日志、不丢 diagnostics”的独立标志。

### 已有工作模式

Preprocessor 专项测试已经采用“先注册 expected-error，再触发预期错误”的模式：

- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorClassTests.cpp:38`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorStructTests.cpp:41`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorFunctionMacroTests.cpp:168`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorPropertyTests.cpp:41`

这说明测试侧显式登记 expected-error 是仓库内已有惯例，不是新机制。

---

## 影响范围

本计划优先只处理 Syntax 测试层，不改 runtime 生产语义。

| 文件 | 操作 |
|---|---|
| `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h` | 增加 expected-error 登记能力或新增专用 helper |
| `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTypeDeclarationTests.cpp` | 为 `Class_Negative` / `Struct_Negative` 中会打 `ScriptCompileError` 的 case 登记 expected-error |
| `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxUFunctionTests.cpp` | 为 `Specifiers_Negative` 中会打 `Unknown function specifier` 的 case 登记 expected-error |
| `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxUPropertyTests.cpp` | 为 `Specifiers_Negative` 中会打 property specifier / callback 错误的 case 登记 expected-error |
| `Documents/Guides/TechnicalDebtInventory.md` | 若该文档记录 live failures，执行完成后同步更新 Syntax 4 个失败的状态 |

不在本计划内：

- `BindConfig.UnnamedBindBackwardCompatibility`
- `Widget.RenderTransformNullGuard`
- `ScriptExamples.Aura.CharacterInputContextIsBuiltInScript`
- GAS split 相关插件边界调整
- 全量测试 runner / suite 定义修复

---

## 分阶段执行计划

### Phase 1：固定最小复现与失败边界

- [ ] **P1.1** 运行 4 个 Syntax 失败用例的最小复现
  - 分别运行 4 个具体 prefix，确认失败仍然由 `LogAutomationController: Error: Angelscript: ... [log]` 触发，而不是 `should NOT compile` 断言失败。
  - 记录每个用例的 run 目录，并把实际 error 片段复制到本计划“执行记录”章节，作为后续修复的精确匹配依据。
  - 命令示例：
    ```powershell
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
      -TestPrefix "Angelscript.TestModule.Syntax.TypeDeclaration.FAngelscriptSyntaxTypeDeclarationTest.Class_Negative" `
      -Label syntax-negative-class-baseline -TimeoutMs 600000
    ```
- [ ] **P1.1** 📦 Git 提交：`[Docs/Plans] Docs: record syntax negative failure baseline`

- [ ] **P1.2** 对齐每个失败片段对应的源码触发点
  - `Class_Negative`：确认 `ClassN_BadParent` 与 `ClassN_SelfInherit` 分别触发 `unknown super type`。
  - `Struct_Negative`：确认 `StructN_Inherit` 触发 `Structs may not inherit from anything`。
  - `UFunction.Specifiers_Negative`：确认 `UFuncSN_Invalid` / `UFuncSN_NumberSpec` / `UFuncSN_EmptyComma` 触发 `Unknown function specifier`。
  - `UProperty.Specifiers_Negative`：确认 `UPropSN_Invalid` / `UPropSN_ConflictRepNotRep` / `UPropSN_EmptyComma` / `UPropSN_RepUsingNoFunc` / `UPropSN_NumberSpec` 的实际消息。
- [ ] **P1.2** 📦 Git 提交：`[Docs/Plans] Docs: map syntax negative diagnostics to call sites`

### Phase 2：补齐 Syntax helper 的 expected-error 能力

- [ ] **P2.1** 设计 helper API
  - 首选方案：为 `AssertFailsToCompile` 增加一个重载，接受 expected log fragments，并在编译前逐条调用 `Test.AddExpectedErrorPlain(Fragment, EAutomationExpectedErrorFlags::Contains, Count)`。
  - 该重载只用于会通过 `ScriptCompileError` 打 `Error` 日志的 case；普通 AS compiler 语法错误可以继续走现有重载，避免扩大匹配面。
  - 建议避免使用 `ExpectedCount=0` 作为默认策略，因为 `FAngelscriptTest::HasMetExpectedErrors` 里 `0` 具有特殊语义：需要至少匹配一次，但不要求精确次数。对明确只打一条的 fragment 优先使用 `1`。
- [ ] **P2.1** 📦 Git 提交：`[AngelscriptTest/Syntax] Refactor: add expected error aware negative compile helper`

- [ ] **P2.2** 增加局部 helper 以降低 call site 噪声
  - 可在 `SyntaxTestHelpers` 内新增 `ExpectErrorLogs(FAutomationTestBase&, TConstArrayView<const TCHAR*>)` 或 `RegisterExpectedCompileErrors(...)`。
  - 该 helper 只做 Automation expected-error 登记，不读取 diagnostics，不改变编译结果判断。
  - 若 `TConstArrayView<const TCHAR*>` 与 UE 版本/API 可用性不确定，可使用 `std::initializer_list<const TCHAR*>` 或简单重载，避免为了语法漂亮引入兼容风险。
- [ ] **P2.2** 📦 Git 提交：`[AngelscriptTest/Syntax] Refactor: centralize expected compile error registration`

### Phase 3：逐个修复 4 个负向测试

- [ ] **P3.1** 修复 `Class_Negative`
  - 在 `ClassN_BadParent` 前登记 `Class AClassBadParentActor has an unknown super type ANonExistentActor.`
  - 在 `ClassN_SelfInherit` 前登记 `Class ASelfActor has an unknown super type ASelfActor.`
  - 保留现有 `AssertFailsToCompile` 编译失败断言，不把测试改成只匹配日志。
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register class negative expected errors`

- [ ] **P3.2** 修复 `Struct_Negative`
  - 在 `StructN_Inherit` 前登记 `Error parsing script struct FChild. Structs may not inherit from anything.`
  - 其他负向 case 只有在最小复现中确认存在未预期 `Error` 日志时才登记，避免过宽。
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register struct negative expected errors`

- [ ] **P3.3** 修复 `UFunction.Specifiers_Negative`
  - 为 `UFuncSN_Invalid` 登记 `Unknown function specifier InvalidSpecifier on method AUFuncInvalidActor::Foo.`
  - 为 `UFuncSN_NumberSpec` 登记 `Unknown function specifier 999 on method AUFuncNumSpecActor::Foo.`
  - 为 `UFuncSN_EmptyComma` 登记 `Unknown function specifier None on method AUFuncEmptyCommaActor::Foo.`
  - 如果后续复现显示 `UFuncSN_PureNonConst` 或其他 case 也泄漏 `Error`，单独补精确片段，不用 `Unknown function specifier` 一把梭。
- [ ] **P3.3** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register UFunction negative expected errors`

- [ ] **P3.4** 修复 `UProperty.Specifiers_Negative`
  - 为 `UPropSN_Invalid` 登记 `Unknown property specifier InvalidSpecifier on property AUPropInvalidActor::X.`
  - 为 `UPropSN_ConflictRepNotRep` 登记 `The NotReplicated specifier is only allowed structs.`
  - 为 `UPropSN_EmptyComma` 登记 `Unknown property specifier None on property AUPropEmptyCommaActor::X.`
  - 为 `UPropSN_RepUsingNoFunc` 登记 `No function specified for ReplicatedUsing on property AUPropRepNoFuncActor::X.`
  - 为 `UPropSN_NumberSpec` 登记 `Unknown property specifier 123 on property AUPropNumSpecActor::X.`
- [ ] **P3.4** 📦 Git 提交：`[AngelscriptTest/Syntax] Fix: register UProperty negative expected errors`

### Phase 4：验证与文档收口

- [ ] **P4.1** 运行 4 个具体失败用例
  - 命令示例：
    ```powershell
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
      -TestPrefix "Angelscript.TestModule.Syntax.TypeDeclaration.FAngelscriptSyntaxTypeDeclarationTest.Class_Negative" `
      -Label syntax-negative-class-fixed -TimeoutMs 600000
    ```
  - 4 个用例目标：全部 `Passed=1, Failed=0`。
- [ ] **P4.1** 📦 Git 提交（如验证记录需要落文档）：`[Docs/Plans] Docs: record fixed syntax negative focused runs`

- [ ] **P4.2** 运行 Syntax 前缀回归
  - 命令：
    ```powershell
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
      -TestPrefix "Angelscript.TestModule.Syntax" -Label syntax-negative-regression -TimeoutMs 600000
    ```
  - 目标：Syntax 前缀无失败；若出现其他负向测试 error log 泄漏，按本计划的精确登记方式补齐。
- [ ] **P4.2** 📦 Git 提交（如需）：`[AngelscriptTest/Syntax] Test: stabilize syntax negative regression`

- [ ] **P4.3** 运行全量 `Angelscript` 回归并更新 live failure 记录
  - 命令：
    ```powershell
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
      -TestPrefix "Angelscript" -Label full-angelscript-after-syntax-negative-fix -TimeoutMs 3600000
    ```
  - 目标：7 个失败中的 Syntax 4 个消失；剩余失败应只剩本计划范围外的 `BindConfig`、`Widget`、`Aura` 等项。
  - 若 `TechnicalDebtInventory.md` 或其他 live failure 文档记录了本轮 4 个失败，执行完成后同步更新。
- [ ] **P4.3** 📦 Git 提交：`[Docs/Test] Docs: update live failure inventory after syntax negative fix`

---

## 备选方案

### 方案 A：只在 call site 手写 `AddExpectedErrorPlain`

每个会打预期 `Error` 的 `AssertFailsToCompile` 调用前手写：

```cpp
TestRunner->AddExpectedErrorPlain(
	TEXT("Unknown function specifier InvalidSpecifier on method AUFuncInvalidActor::Foo."),
	EAutomationExpectedErrorFlags::Contains,
	1);
```

优点：

- 改动最小，完全沿用 Preprocessor 测试现有模式。
- 不触碰 helper API，风险低。

缺点：

- 负向 syntax 测试会出现较多重复样板。
- 未来新增同类负向测试仍容易忘记登记 expected-error。

### 方案 B：在 runtime 增加“收集 diagnostics 但不打 UE_LOG”的 scoped flag

在 `FAngelscriptEngine` 增加类似 `bSuppressCompileDiagnosticLogs` 的标志，让 `ScriptCompileError(...)` 继续写 `Diagnostics`，但在测试 helper 设置该 flag 时跳过 `UE_LOG`。

优点：

- 从根上让 `bSuppressCompileErrorLogs=true` 覆盖 preprocessor 与 compile 两个阶段。
- call site 不需要知道哪些错误会打日志。

缺点：

- 会改 runtime core 行为面，即使只在测试使用，也需要更谨慎验证。
- 容易和 `bIgnoreCompileErrorDiagnostics` 语义混淆；后者会影响 diagnostics 收集，不适合直接复用。

当前建议：**先执行测试侧 expected-error 登记方案**。如果后续发现同类泄漏大面积存在，再单独开 Plan 评估 runtime scoped flag。

---

## 验收标准

1. 4 个 Syntax 负向测试单独运行全部通过。
2. `Angelscript.TestModule.Syntax` 前缀回归通过。
3. 全量 `Angelscript` 回归中不再出现以下 4 个 Syntax negative 失败：
   - `Class_Negative`
   - `Struct_Negative`
   - `UFunction.Specifiers_Negative`
   - `UProperty.Specifiers_Negative`
4. 负向测试仍然保留“编译必须失败”的断言，不把测试降级成只吞日志。
5. 不新增 runtime 生产行为变化，除非执行时明确切换到备选方案 B 并补充对应验证。

---

## 风险与注意事项

### 风险

1. **expected-error 片段过宽导致误吞真实回归**
   - 缓解：优先登记完整、稳定的错误句子；仅在同一测试内重复次数不确定时使用更短片段。

2. **预期次数不准确导致测试仍失败**
   - 缓解：对明确一条日志的 case 使用 `ExpectedCount=1`；对同一 fragment 可能打多次的 case，先通过最小复现确认实际次数，再决定是否用 `0`。

3. **helper API 变更影响大量 syntax 测试**
   - 缓解：新增重载，不改变现有调用签名；只迁移本计划列出的 call site。

### 已知行为变化

1. **Automation 结果变化**
   - 修复后，预期中的 `LogAngelscript Error` 会被 Automation expected-error 机制消费，不再使测试失败。

2. **诊断输出仍保留**
   - `ReportCompileDiagnostics(...)` 仍会通过 `AddInfo` 输出源码和 diagnostics，失败排查能力不应降低。

---

## 执行记录

待执行时补充：

| 日期 | 操作 | Run 目录 | 结果 |
|---|---|---|---|
| 待补 | Baseline focused runs | 待补 | 待补 |
| 待补 | Syntax regression | 待补 | 待补 |
| 待补 | Full `Angelscript` regression | 待补 | 待补 |

## Context

`Plugins/Angelscript/Source/AngelscriptTest/Shared/` 当前有 47 个文件、9 个职责簇混在一起。其中 `AngelscriptTestUtilities.h` 是 1093 行的「上帝头」，把 7 段不同职责（引擎获取/Cleanup/内存探针/共享重置/模块编译/AS 执行/夹具）全部 inline 在同一文件内；同时把 `BlueprintActionDatabase.h`、`K2Node_GetSubsystem.h`、AS SDK 三件套通过 umbrella 传染给 400+ 测试 TU。

另一方面，"调用 AS 函数"这件事在 `Shared/AngelscriptBindingsAssertions.h`（378 行，9 个 `Expect*`）+ `Shared/AngelscriptGlobalFunctionInvoker.h`（408 行，`FASGlobalFunctionInvoker` fluent 类）+ `AngelscriptTestUtilities.h` 873-1015 段（`ExecuteIntFunction*` / `ExecuteInt64Function`）+ 各 Bindings/*.cpp 内 4-5 份文件私有 helper（Math / Orientation / Curve / WorldFunc 等的 `ExecuteValueFunction` / `ExecuteIntFunctionWithAddressArg` / `ExecuteFunctionExpectingException`）之间有 **≥7 个并行入口**。命名族（`Expect*` / `Execute*Function*` / `.Call()` / `.CallAndReturn`）互不对齐，与 UE 风格 / AS 底层 `asIScriptContext::Execute()` 也不一致。

本 change 是原 `refactor-as-test-utilities-header-split` 的扩展产物（已重命名）。原 proposal 承诺「公共符号名 0 改名」，但同时改名 + 拆头 + 命名规范化 + 散落 helper 收编一次性做完会导致 71 个 Bindings/*.cpp 内 ~200+ callsite 同步改名、风险过大；并且 AS namespace 改写无法兼容、AS 不允许同名函数同时存在于 namespace 内外。本次做了核心翻转：**最大化 C++ 可 alias 的兼容、推迟所有无法 alias 的破坏性步骤到 follow-up change**。

## Goals / Non-Goals

**Goals:**

1. 把 `AngelscriptTestUtilities.h` 1093 行拆成 6 个主题头 + 1 个 .cpp，umbrella 缩为 ~40 行纯 include。
2. 把"AS 函数执行"的所有入口收口到 `Shared/AngelscriptTestExecute.h` 单文件：包含底层 `FAngelscriptTestExecutor` 类 + `Execute*` 自由函数族 + `Compile*` 独立族 + 全部旧符号 inline alias / 旧头 forward。
3. 建立以 `Execute` 为根动词、词位 `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect|(空)][Near|AtLeast|(空)][<Type>|<T>]` 的命名族契约（spec 强制）。
4. 删除 `FBindingsCoverageProfile` 及其 `AngelscriptBindingsCoverage.h` 头，避免 Bindings Coverage 的命名上下文污染通用 `Execute*` API；`Execute*` 仅接收普通 case label，module scope 仅接收显式 module name。
5. 编辑器头依赖（`BlueprintActionDatabase` / `K2Node_*`）收敛到 `AngelscriptTestEngineCleanup.h` 一个文件。
6. 退役 4 个纯转发别名（`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`）+ 同步替换 ~46 callsite。
7. **任何旧 callsite（含外部插件 `AngelscriptGAS` 等）在本 change 落地后继续编译通过，零修改**。

**Non-Goals:**

- 不进行 Bindings/*.cpp 71 文件、~200+ callsite 的批量改名（只更新示例 `AngelscriptBindingsExampleSection.h` 作为新命名官方示范，作为唯一 callsite 改名位置）。
- 不删除任何旧符号 / 旧头 / inline alias / forward 头（删除推迟到 follow-up）。
- 不引入任何新的 Profile / NamingContext 抽象替代 `FBindingsCoverageProfile`；CQTest 的 Automation path + `TEST_METHOD` 名已经提供测试身份。
- 不进行 AS 脚本字符串字面量 namespace 改写（`SetIter_SumElements` → `SetIter::SumElements`，1500+ 处）—— AS 不允许同名函数在 namespace 内外并存，无兼容期。
- 不收编各 Bindings/*.cpp 内文件私有 `Execute*Function*` helper —— 只加 `// TODO` 标记，由 follow-up 逐个迁入。
- 不改动 `MockDebugServer` / `TestEnginePool` / `Debugger*` 套件 / `TestEngineHelper` / `TestLegacyHelpers.h` / `TestMacros.h` / `TestEngine.h/.cpp` / `ReflectiveAccess.h` —— 与本目标无关。
- 不同步 `Documents/Guides/TestConventions.md` 与 `.agents/skills/_angelscript-test-guide/SKILL.md` —— 另开 follow-up。
- 不修改已有 `angelscript-test-helper-api` capability 的外部消费契约。

## Decisions

### D1: 合并 header 拆分 + 命名规范化为单 change，撤销「0 改名」承诺改为「永久 alias 兼容」

原 proposal 严守「公共符号名 0 改名」是为了让 400+ 测试 TU 零修改。但同时摆在面前的是 71 个 Bindings/*.cpp 里 ≥7 个并行入口的命名乱象。两件事拆开做意味着：第一次 change 完成后，再花一个独立 change 把刚拆好的 6 个头之一（`AngelscriptTestExecution.h`）改名为 `AngelscriptTestExecute.h` 并合并散落入口 —— 显然是浪费 round-trip。

本次合并做并采用**最大化兼容**策略：

- 第 6 个主题头**直接命名为 `AngelscriptTestExecute.h`**（与新命名族收口名对齐，省一次改名 round-trip）。
- **新增** `Execute*` 主命名族作为新代码强制入口（spec 内禁止新代码使用旧名）。
- **保留** 所有旧符号 / 旧头作为 inline alias / forward 头（永久兼容直到 follow-up 清理）。

替代方案：

- 严守 0 改名 + 不引入新命名族：浪费现有 `FASGlobalFunctionInvoker` 命名机会，命名乱象长期延续。已否决。
- 全量改名 + 同步替换 71 个 Bindings/*.cpp 内 ~200+ callsite：风险过大，违反 OpenSpec "incremental change" 原则。已否决。
- 仅做 header 拆分（不引入命名族）：错过把第 6 个主题头一次性以最终名落地的机会，未来需要二次拆分。已否决。

### D2: 命名族根动词 = `Execute`

候选根动词：`Execute` / `Invoke` / `Run` / `Call`。选 `Execute` 的理由：

1. AS 底层 API 就叫 `asIScriptContext::Execute()`，命名族与机制对齐。
2. 仓库内 `Execute*Function*` 一族已是事实约定（`Utilities.h` 873-1015 段 + Bindings/*.cpp 内 4-5 份散落 helper），本次是把它升级成标准。
3. `Invoke` / `Call` 与"函数调用"过于通用，缺乏与 AS 执行的语义绑定。
4. `Run` 暗示长生命周期（如 `RunSession`），不适合一次 fn 调用。

替代方案：

- `Invoke` 作为根动词：用户最初倾向，后改回 `Execute`（理由：与底层 API 对齐 + 仓库现状）。已否决。
- 不收口为单一根动词，保留 `Expect*` + `Execute*` 双族：命名乱象延续。已否决。

### D3: 词位 `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect][Near|AtLeast][<Type>]`

词位语义严格区分：

- `Execute`（不带后缀）：仅执行不取返回。
- `AndGet`：取返回不断言。
- `AndExpect`：取返回并断言相等。
- `AndValidate`：取返回并自定义校验。
- `BatchAndExpect`：批量执行同一 fn N 次。

修饰词位置：

- `Near` / `AtLeast` 紧贴 `Expect`（修饰断言语义） — `ExecuteAndExpectNearFloat` / `ExecuteAndExpectIntAtLeast`。
- `Batch` 紧贴 `Execute`（修饰执行行为）— `ExecuteBatchAndExpectInt`。

类型后缀在最末：`Int` / `Bool` / `Float` / `Double` / `<T>`，无歧义时省略（成员 `ExecuteAndGet<T>`）。

替代方案：

- `AndGet` vs `AndExtract` / `AndAssert` vs `AndExpect` / `Near` vs `Approx` / `Batch` vs `Many` / `AtLeast` vs `GreaterOrEqual`：选短词 + UE 语境通用词。已采纳 `AndGet` / `AndExpect` / `Near` / `Batch` / `AtLeast`。
- 复数后缀 `ExpectInts`（批量）→ 改为前置修饰 `ExecuteBatchAndExpectInt`：复数后缀难扫，且与单数版命名一致性差。已否决。
- `ExecuteAndExpect<T>` 重载支持 validator lambda：lambda 重载分辨率歧义大，IDE 提示混乱。已分名为 `ExecuteAndValidate<T>`。

### D4: executor 类名 = `FAngelscriptTestExecutor`

三选一：

- `FAngelscriptExecutor`：最短，与 `FAngelscriptEngine` 自然成对，但缺 "Test" 限定。
- **`FAngelscriptTestExecutor`**：明确 Test 属性（采纳）。
- `FAngelscriptGlobalFunctionExecutor`：保留原 `FASGlobalFunctionInvoker` 的 "GlobalFunction" 语义，但过长。

采纳 `FAngelscriptTestExecutor` 的理由：

1. 与头文件名 `AngelscriptTestExecute.h` 自然成对。
2. 明确 "Test" 限定，避免与未来可能的运行时 `FAngelscriptExecutor` 撞名。
3. 长度可接受（同 `FAngelscriptTestEngine`）。

### D5: compile-side 独立成 `Compile*` 族

`ExpectBindingCompileFailure` 在 AS 编译阶段就报错，**根本没到 Execute 步骤**，强行叫 `ExecuteAndExpectCompileFailure` 名实不副。独立成 `Compile*` 族（仅 `CompileAndExpectFailure` 一员），保持语义清晰。

替代方案：

- 收编到 `Execute*` 族：名实不副。已否决。
- 用 `Validate*` / `Verify*` 族：与 `Execute*` / `Compile*` 主线无关，无价值。已否决。

### D6: 兼容范围只覆盖 C++ 可 alias 的维度，其余推迟到 follow-up

C++ 可 alias 的维度：

| 维度 | 兼容机制 | 本 change 实施 |
|------|---------|----------------|
| `ExpectGlobalInt` 等自由函数 | `inline` 转发函数 | ✓ |
| `FASGlobalFunctionInvoker` 类名 | `using FASGlobalFunctionInvoker = FAngelscriptTestExecutor;` | ✓ |
| `.Call` / `.CallAndReturn<T>` / `.ReadReturnStruct<T>` 成员方法 | inline 转发方法 | ✓ |
| `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` 旧头 | 改为 forward `#include` | ✓ |

C++ 无法 alias / AS 不支持兼容的维度（推迟到 follow-up change）：

| 维度 | 为什么不能 alias | 推迟去向 |
|------|------------------|----------|
| AS 脚本 namespace 改写 | AS 不允许同名函数在 namespace 内外并存 | `followups.md` |
| 71 个 Bindings/*.cpp 内 ~200+ callsite 改名 | 仅风险隔离考虑 | `followups.md` |
| 各 Bindings/*.cpp 内私有 `Execute*Function*` helper 收编 | 文件私有，可逐个独立处理 | `followups.md`（本 change 仅加 `// TODO` 标记） |

### D7: 删除 `FBindingsCoverageProfile`，不再把 Bindings 命名上下文传入通用执行层

实地审查发现原 Phase 5 方案的前提不成立：`FBindingsCoverageProfile` 中并不存在 `BodyInst` / `MsgDlg` / `MathOrient` 等业务缩写字段。该类型实际只有 5 个抽象槽位：

```cpp
struct FBindingsCoverageProfile
{
    const TCHAR* Theme;
    const TCHAR* Variant;
    const TCHAR* ModulePrefix;
    const TCHAR* CasePrefix;
    const TCHAR* LogCategory;
};
```

这些槽位是 Bindings Coverage Section 模式为了拼模块名和日志标签引入的命名上下文，不是执行 AS 函数所需的通用信息。把它传进 `AngelscriptTest::ExecuteAndExpectInt` 等函数，会让通用执行层依赖 Bindings 专用概念，边界不清。

Phase 5 采用删除方案：

- `AngelscriptTest::Execute*` / `Compile*` 只接收普通 `CaseLabel`，不再接收 `FBindingsCoverageProfile`，也不调用 `FormatCaseLabel(Profile, ...)`。
- `FCoverageModuleScope` 不再接收 Profile，而是接收显式 `ModuleName` + `Source`，只承担 AS module 生命周期 RAII。
- 删除 `AngelscriptBindingsCoverage.h` 和 `FBindingsCoverageProfile`。Bindings 测试若需要 module name，直接写全词 module name（如 `ASBodyInstance_Latent`）或使用文件私有全词 helper，不再共享一个不通用的 Profile 抽象。
- CQTest 已经通过 `TEST_CLASS_WITH_FLAGS(..., "Angelscript.TestModule.Bindings.BodyInstance", ...)` 与 `TEST_METHOD(...)` 提供测试身份；不再用 Profile 重复表达。

替代方案：

- 保留 Profile 并改为 `ForSubject()` 工厂：比原方案更内聚，但仍会让测试作者学习一个 Bindings 特有上下文；用户明确认为该抽象不通用。已否决。
- 做全模块 `FAngelscriptTestNamingContext`：容易把 CQTest 已有身份、module lifecycle、assertion label 三件事重新耦合成新大上下文。已否决。
- 每个测试文件继续手写 5 字段 Profile：重复、易缩写、易不同步。已否决。

### D8: 散落 helper 保持原状 + 加 `// TODO` 标记

各 Bindings/*.cpp 内文件私有 `ExecuteValueFunction` / `ExecuteIntFunctionWithAddressArg` 等是 `static` / 匿名命名空间内的 helper，**外部不依赖**。本 change 不去收编：

- 收编进 `Execute.h` 会产生大量同名冲突（每个文件的 `ExecuteValueFunction<T>` 模板特化 / 默认实参 / Profile 引用都不一样）。
- 收编后还要在原 cpp 里删除并立即修复因签名变化产生的少量 callsite —— 违反「不动 callsite」的兼容承诺。
- 留 `// TODO(refactor-as-test-shared-layout-and-naming): migrate <helper-list> to Shared/AngelscriptTestExecute.h` 标记给 follow-up，作为渐进迁移的清单。

### D9: 不在本 change 内做 callsite 批量替换 + 删兼容层

callsite 替换（71 个 Bindings/*.cpp、~200+ 处）+ 删别名 + 删 forward 头是高频低风险但量大的工作，由用户驱动渐进替换更合理：

- 用户可以一次只重命名一个文件（Math / Orientation / Iterator / ...），每次验证 build + test。
- 仓库在本 change 完成后处于「新旧并存、稳定可用」的中间态，所有旧 callsite 编译通过，新代码必须用 `Execute*`。
- follow-up change 完成所有 callsite 迁移后，最后一次提交统一删除兼容层。

### D10: 不在本 change 内做 AS 脚本 namespace 改写

AS 不允许同名函数同时存在于 namespace 内外，无兼容期可走。改写 1500+ 字符串字面量本身风险也大（拼写错误难发现，编译期无法捕获 AS 字符串）。整个 Phase 推迟到独立 follow-up change，单独走风险评估和试点节奏。

## Risks / Trade-offs

- **[`FAngelscriptTestExecutor` 与旧 `FASGlobalFunctionInvoker` 的同名成员歧义]** → Mitigation：所有旧成员方法以 inline 转发实现，禁止重载新成员；新成员名与旧成员名不冲突（`Execute` ≠ `Call`、`ExecuteAndGet` ≠ `CallAndReturn`、`ExecuteAndExtractStruct` ≠ `ReadReturnStruct`）。
- **[forward 头被新代码错误依赖]** → Mitigation：spec 内 Scenario 禁止新代码 include 旧 forward 头；`Shared/README.md` 内显式标注两个 forward 头为 legacy；follow-up change 内执行删除时间表。
- **[散落 helper 与 `Execute*` 主族命名相似导致读者混淆]** → Mitigation：(a) 散落 helper 全部 `static` 限定作用域，IDE 跳转明确指向本地；(b) 文件顶 `// TODO` 标记提示 reader 走 `Execute.h` 主族；(c) 新代码不允许新增散落 helper（spec 内禁止 `Expect*` / `Invoke*` / `Call*` 等新并行词族）。
- **[删除 Profile 后 module name 重复字符串增多]** → Mitigation：只保留必要的 module name 字符串，全部使用全词；多 section 文件可用文件私有 `Make<Subject>ModuleName(SectionName)` helper，但该 helper 不进入通用 Shared API。
- **[`ResetSharedCloneEngine` / `AcquireCleanSharedCloneEngine` / `GetOrCreateSharedCloneEngine` 替换 4 个别名时被外部插件（如 GAS）依赖]** → Mitigation：原 proposal 已 audit 这 4 个别名仅在 `AngelscriptTest` 模块内部被调用，不影响外部插件；本 change 沿用该 audit 结论；Phase 1 末做一次 `rg` cross-check 确认无外部依赖。

## Migration Plan

按 5 Phase 顺序锁定（不并行）：

1. **Phase 1**：拆 6 个主题头（含直接以 `AngelscriptTestExecute.h` 命名的第 6 头，仅含 Utilities.h 873-1015 段）+ 退役 4 别名 + Cleanup 收敛 + `Shared/README.md` + 散落 helper TODO 标记。
2. **Phase 2**：把 `AngelscriptGlobalFunctionInvoker.h` + `AngelscriptBindingsAssertions.h` 合并进 `AngelscriptTestExecute.h`；旧两头改成 forward；callsite 不动。
3. **Phase 3**：在 `AngelscriptTestExecute.h` 内增加 `Execute*` 新命名族 + 旧符号 inline alias；executor 类改名为 `FAngelscriptTestExecutor`。
4. **Phase 4**：更新 `AngelscriptBindingsExampleSection.h` 内示例到新命名（唯一改 callsite 位置）；新建 `followups.md` 登记待清理清单。
5. **Phase 5**：删除 `FBindingsCoverageProfile`，通用 `Execute*` API 与 Bindings module naming 解耦。

每 Phase 末 verification：

- `Tools\RunBuild.ps1` 全量编译过。
- `Tools\RunTestSuite.ps1` 全量自动化套件不退化（`275/275` C++ + `301/301` ASSDK + 现有 Bindings 套件）。
- Phase 2 / 3 完成后 `rg` 旧头是否被非 forward 用法依赖。

### Rollback

每 Phase 独立可回滚（git 单 commit 还原）。本 change 整体在 follow-up 介入前都是新旧并存稳定态。

## Open Questions

- **OQ1**：`FCoverageModuleScope` Section 字符串与 `TEST_METHOD` 名是否对齐 / 是否引入宏 `ASTEST_BINDINGS_SECTION(Profile, Source)` 自动拼接？  
  与命名族无强耦合，可独立讨论。倾向：保留现状，不引入宏（避免增加学习成本）；如未来 Section 字符串与 method 名不一致导致定位困难，再开 follow-up 引入宏方案。

## Shared/ 目录三态对比

### A. 现状（本 change 启动前，47 个文件）

| 簇 | 关键文件 | 行数 | 本 change 是否动 |
|----|---------|------|------------------|
| 上帝头 | `AngelscriptTestUtilities.h` | 1093 | **拆** |
| Bindings 工具 | `AngelscriptBindingsAssertions.h` / `BindingsCoverage.h` / `BindingsModuleBuilder.h` / `BindingsExampleSection.h` / `GlobalFunctionInvoker.h` | 1058 | **部分合并** |
| 反射访问 | `AngelscriptReflectiveAccess.h` | 979 | 不动 |
| Debugger 套件 | 10 个 `Debugger*` / `MockDebugServer*` | ~3088 | 不动 |
| 测试引擎核心 | `TestEngine.{h,cpp}` / `TestEngineHelper.{h,cpp}` / `TestEnginePool.h` | 1208 | 不动 |
| 宏/夹具/世界 | `TestMacros.h` / `TestWorld.h` / `FunctionalTestUtils.h` / `TestLegacyHelpers.h` | 380 | 不动 |
| Native 接口 | 5 个 `Native*` | 477 | 不动 |
| 学习/探针/碰撞/性能 | `LearningTrace.*` / `ConstructionContextProbe.*` / `CollisionTestHelpers.h` / `PerformanceTestUtils.h` | ~655 | 不动 |
| infra 自测 | 7 个 `*Tests.cpp` | ~1683 | 跟随重命名 |

各 Bindings/*.cpp 内还散落 4-5 份私有 `Execute*Function*` helper（Math / Orientation / Curve / WorldFunc）。

### B. `AngelscriptTestUtilities.h` 内部切线（1093 行实地行号）

| 段 | 行段 | 主要符号 | Phase 1 去向 |
|----|------|---------|--------------|
| 1 | 32-247 | `CreateBareScriptEngine` / `CreateIsolated*` / `GetOrCreateSharedCloneEngine` | `AngelscriptTestEngineAcquisition.h/.cpp` |
| 2 | 250-407 | `CleanupDetachedASTypesForGarbageCollection` + `WITH_EDITOR` 区块 | `AngelscriptTestEngineCleanup.h` |
| 3 | 409-466 | `SampleBindFreeMem` / `AcquireTransientFullTestEngineWithProbe` | `AngelscriptTestMemoryProbe.h` |
| 4 | 468-689 | `ResetSharedCloneEngine` / `LogSharedEngineDebugState` | 归并到 Acquisition（与共享引擎语义同源）|
| 5 | 693-870 | `BuildModule` / `GetFunctionByDecl` / `FScopedAutomaticImportsOverride` | `AngelscriptTestModuleBuilder.h` |
| 6 | 873-1015 | `ExecuteIntFunction` / `ExecuteIntFunctionExpectingScriptException` / `ExecuteInt64Function` | **直接进 `AngelscriptTestExecute.h`** |
| 7 | 1016+ | `FAngelscriptTestFixture` | `AngelscriptTestFixture.h` |

### C. Phase 1 完成时

```
Shared/
  AngelscriptTestUtilities.h                   ~40   (umbrella)
  AngelscriptTestEngineAcquisition.h/.cpp     ~430   NEW (含原 Utilities.h 1+4 段)
  AngelscriptTestEngineCleanup.h              ~170   NEW (BP DB 依赖在此收敛)
  AngelscriptTestMemoryProbe.h                 ~60   NEW
  AngelscriptTestModuleBuilder.h              ~180   NEW
  AngelscriptTestFixture.h                     ~90   NEW
  AngelscriptTestExecute.h                    ~150   NEW (仅 873-1015 段)
  README.md                                          NEW
  (Bindings 簇维持原状, 其它 8 个簇全部不动)
```

`AngelscriptTestExecute.h` 此时**只含从 Utilities.h 873-1015 段搬来的内容**，符号名暂保持原状。

### D. 最终态（本 change 完成，新旧并存稳定态）

```
Shared/
  AngelscriptTestUtilities.h                   ~40   umbrella
  AngelscriptTestEngineAcquisition.h/.cpp     ~430
  AngelscriptTestEngineCleanup.h              ~170
  AngelscriptTestMemoryProbe.h                 ~60
  AngelscriptTestModuleBuilder.h              ~180
  AngelscriptTestFixture.h                     ~90
  AngelscriptTestExecute.h                   ~1100   <- AS 函数执行新入口（含永久兼容层）
        新 API（主要, 强制走这套）:
        - FAngelscriptTestExecutor 类
        - ResolveFunctionByDecl / ResolveFunctionByName
        - .Execute() / .ExecuteAndGet<T>() / .ExecuteAndExtractStruct<T>()
        - ExecuteAndExpectInt / Bool / Double
        - ExecuteAndExpectNearFloat / NearDouble
        - ExecuteAndExpectIntAtLeast
        - ExecuteBatchAndExpectInt
        - ExecuteAndValidate<T>
        - ExecuteAndExpectException
        - CompileAndExpectFailure (Compile* 独立族)
        兼容 alias（永久保留, 禁止新代码使用）:
        - using FASGlobalFunctionInvoker = FAngelscriptTestExecutor
        - .Call → .Execute / .CallAndReturn<T> → .ExecuteAndGet<T> / .ReadReturnStruct<T> → .ExecuteAndExtractStruct<T>
        - inline ExpectGlobalInt/Bool/Double/IntAtLeast/Ints/ReturnBool/ReturnFloat/ReturnCustom<T>
        - inline ExpectBindingCompileFailure
        - inline ExecuteIntFunction / ExecuteIntFunctionExpectingScriptException / ExecuteInt64Function

  AngelscriptGlobalFunctionInvoker.h           ~3    <- 永久 forward: #include "AngelscriptTestExecute.h"
  AngelscriptBindingsAssertions.h              ~3    <- 永久 forward: #include "AngelscriptTestExecute.h"
  AngelscriptBindingsCoverage.h                      <- 删除（Profile 抽象不再保留）
  AngelscriptBindingsModuleBuilder.h           88    (ModuleScope, 不动)
  AngelscriptBindingsExampleSection.h          80    (Phase 4 贴新命名, 作为新命名官方示范)
  (其它 8 个簇全部维持原状)

Bindings/*.cpp (71 files, 全部不动):
  - 旧 callsite (ExpectGlobalInt / FASGlobalFunctionInvoker / 旧 Execute*Function*) 继续编译通过
  - 私有 helper (Math/Orientation 等 4-5 份 ExecuteValueFunction 类) 保持原状
  - 文件头加 // TODO(refactor-as-test-shared-layout-and-naming) 标记, 指向 followups.md
```

**Phase 5 删除了 `AngelscriptBindingsCoverage.h`**（`FBindingsCoverageProfile` 及其 helper）。其余旧符号 / 旧 forward 头 / 散落 helper 一律保留，由 follow-up change 渐进清理。

## Implementation Record (Phases 1–5, completed May 2026)

| Phase | Submodule commit (Angelscript) | Parent gitlink | Verification |
|-------|-------------------------------|----------------|--------------|
| 1 | `621cb1b` split + `06702b1` alias retirement | `055e5fd`, `c91d516` | Fast suite 1834/1834 |
| 2 | `4f88c8d` merge Invoker + Assertions into Execute.h | `e1f6e8b` | Fast suite 1834/1834 |
| 3 | `2b0f7ee` `FAngelscriptTestExecutor` + `Execute*` family | `a32b229` | Fast suite 1834/1834 |
| 4 | `2357a29` example section migration | `da6d137` | Fast suite 1834/1834; SharedExample PASS |
| 5 | `8ca8191` delete Profile; 125 files migrated | *(parent commit)* | Build OK; Bindings 260/260; Fast suite 1834/1834 (manual shard agg.) |

**Phase 5 migration notes:**

- ~117 Bindings/Syntax/Compiler/Functional/Interface test files: removed `FBindingsCoverageProfile` parameter from `ExpectGlobal*` / `Execute*` callsites; `FCoverageModuleScope` now takes explicit full-word `ModuleName`.
- `AngelscriptGAS` test module (3 files): same Profile removal pattern.
- Post-migration fixes: `AddExpectedError` strings must match `FCoverageModuleScope` module names — corrected `ASAssetReg_` → `ASAssetRegistry_` (AssetRegistry) and `ASTemplateCQ_` → `ASTemplate_` (Template CQTest `NegativePath`).
- `TESTING_GUIDE.md` / `TESTING_GUIDE_ZH.md`: updated `FCoverageModuleScope` examples.
- Known infra: `RunTestSuiteFast.ps1` aggregator may throw `ConvertTo-AngelscriptWorkerPlanJson` after all shards pass; manual `[done]` line aggregation remains authoritative.

### E. 文件数账本（最终态）

| | 现状 | 最终 | Δ |
|--|------|------|---|
| `Shared/` 文件总数 | 47 | 54 | **+7** |
| "AS 函数执行"主要入口 | ≥7 | 1（含 6 个 inline 兼容 alias） | **-6** |
| 编译期 callsite 报错数 | 0 | **0**（兼容层托底） | 0 |

本 change 的真正价值密度：**Execute.h 成为新代码强制入口**，旧入口降级为兼容 alias，等待 follow-up change 收尾。

## 为什么放弃 AS namespace 改写

AS 语法允许 namespace（如 `namespace SetIter { void SumElements() {} }`），与全局函数 `void SetIter_SumElements() {}` **不允许并存**：

- 若同时声明，AS 编译器会报名字冲突（namespace 限定符不参与 mangle）。
- 若只保留 namespace 版，所有 callsite（包括 C++ 测试里的字符串字面量 `"SetIter_SumElements"`）必须同步改成 `"SetIter::SumElements"`。
- 字符串字面量改名错误无法被编译期捕获，需要 100% 运行测试才能发现。

因此 AS namespace 改写**没有 C++ 那样的 inline alias 兼容机制**。1500+ 字符串字面量分布在：

- 71 个 Bindings/*.cpp 内的 `FunctionDecl` 字符串
- 各文件内的 AS source 字面量（`R"AS(...)AS"` 多行字符串内的函数定义 + 调用）
- `AddExpectedError` 内的报错信息字符串

如果在本 change 内做，意味着：

- ≥4500 处字符串字面量替换（每处 namespace 切换涉及定义 + 调用 + 错误信息）。
- 失败一处即测试退化，难以定位。
- 必须强制全量 test suite 验证，无法 incremental ship。

推迟到独立 follow-up change 的好处：

- 单独走风险评估和试点节奏（先 1-2 个文件做实验，确认运行模式）。
- 与本 change 的 C++ 层重命名工作解耦，互不影响。
- 若实施过程中发现 AS 语法支持的边界问题（如 namespace 嵌套、转发声明），可独立调整方案。

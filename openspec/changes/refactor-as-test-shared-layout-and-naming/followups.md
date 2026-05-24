# Follow-up 清理清单

本 change（`refactor-as-test-shared-layout-and-naming`）只完成「Header 拆分 + 新命名族落地 + C++ 可 alias 的兼容层 + 散落 helper TODO 标记」，仓库进入「新旧并存、稳定可用」的中间态。

以下 8 项是本 change **故意推迟**的渐进清理工作，由用户驱动以后续独立 follow-up change 处理。每项都含触发条件、影响面、推荐节奏与最终目标。

## 1. Bindings/*.cpp callsite 渐进迁移

**触发条件**：本 change 已落地，仓库内 `Execute*` 主命名族 + `FAngelscriptTestExecutor` 已可用，旧 `ExpectGlobal*` / `FASGlobalFunctionInvoker` / 旧 `Execute*Function*` 通过 inline alias 永久兼容。

**待清理**：71 个 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/*.cpp` 文件、~200+ 处 callsite。

**推荐节奏**：每次 follow-up change 处理 1-3 个文件（按 theme 聚合，如先 Math 系、再 Iterator 系），每次 commit 末跑一次 `RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.<Theme>." `。

**最终目标**：所有 callsite 走新名；与 #6（删除兼容层）联动 — 必须**所有**callsite 迁移完毕才能进 #6。

## 2. Bindings/*.cpp 内文件私有 `Execute*Function*` helper 收编

**触发条件**：本 change Phase 1.9 已给每个含私有 helper 的文件加 `// TODO(refactor-as-test-shared-layout-and-naming)` 标记。

**待清理**：

- `AngelscriptMathBindingsTests.cpp` / `AngelscriptMathFunctionLibraryTests.cpp` / `AngelscriptMathOrientationFunctionLibraryTests.cpp`：私有 `ExecuteValueFunction<T>`（每文件一份，签名相似但 Profile 引用不同）。
- `AngelscriptCurveFloatBindingsTests.cpp`（或类似文件）：私有 `ExecuteIntFunctionWithAddressArg`。
- `AngelscriptWorldFunctionBindingsTests.cpp`（或类似文件）：私有 `ExecuteIntFunction` / `ExecuteFunctionExpectingException`。
- 其它通过 `rg "static (bool|template) .*Execute\w+Function" Plugins\Angelscript\Source\AngelscriptTest\Bindings` 发现的散落 helper。

**推荐节奏**：与 #1 callsite 迁移合并处理 — 一次 follow-up 处理一个文件的同时把该文件的私有 helper 迁入 `AngelscriptTestExecute.h`（或确认主族已覆盖该签名后直接删除私有 helper）。

**最终目标**：所有 `Bindings/*.cpp` 内不再出现 `static` / 匿名命名空间内的 `Execute*Function*` helper；所有 helper 已收编到 `AngelscriptTestExecute.h` 主族（或以新 `Execute*` 名替代）。

## 3. Profile 实例变量名重命名

**触发条件**：本 change Phase 5 已完成 `FBindingsCoverageProfile` 字段双字段并存，但 Profile 实例变量名（如全局 `GBodyInstProfile`）保持原样 — C++ 没有变量名 alias 机制。

**待清理**：

- `GBodyInstProfile` → `GBodyInstanceProfile`
- `GMsgDlgProfile` → `GMessageDialogProfile`
- `GMathOrientProfile` → `GMathOrientationProfile`
- `GCollisionValProfile` → `GCollisionValidationProfile`
- `GMathPlatProfile` → `GMathPlatformProfile`
- `GJsonConvProfile` → `GJsonConversionProfile`
- 其它通过 `rg "G\w+Profile" Plugins\Angelscript\Source\AngelscriptTest\Bindings` 发现的实例。

**推荐节奏**：每次 follow-up 处理一个 Profile（连同其在所有 cpp 中的 ~10-20 个引用），单 commit 验证 build + 该 theme 的 tests。

**最终目标**：所有 Profile 实例变量名全词化。

## 4. Profile 字段去重（删除旧缩写字段）

**触发条件**：#3 完成（所有 Profile 实例变量名已全词化），且全模块 `rg -n "BodyInst\b|MsgDlg\b|MathOrient\b|CollisionVal\b|MathPlat\b|JsonConv\b" Plugins\Angelscript\Source\AngelscriptTest` 仅命中 `FBindingsCoverageProfile` 内部声明，无外部读取。

**待清理**：删除 `FBindingsCoverageProfile` 内 `BodyInst` / `MsgDlg` / `MathOrient` / `CollisionVal` / `MathPlat` / `JsonConv` 等旧缩写字段及其构造时同步赋值代码。

**推荐节奏**：单 follow-up 一次性处理（小范围）。

**最终目标**：`FBindingsCoverageProfile` 内只剩全词字段。

## 5. AS 脚本 namespace 改写（`SetIter_SumElements` → `SetIter::SumElements`）

**触发条件**：本 change 已落地，C++ 侧命名族已稳定。

**风险**：AS 不允许同名函数同时存在于 namespace 内外，**没有兼容期可走**；1500+ 字符串字面量改写错误无法被 C++ 编译期捕获，必须 100% 运行测试才能发现。

**待清理**：

- 71 个 Bindings/*.cpp 内的 `FunctionDecl` 字符串字面量。
- 各文件内 AS source 多行字符串（`R"AS(...)AS"`）内的函数定义 + 调用。
- `AddExpectedError` 内含 AS 模块名 / 函数名的报错信息字符串。

**推荐节奏**：

1. 第 1 个 follow-up：在 1-2 个简单文件（如 Iterator）上做完整试点；记录失败模式（拼写错误、namespace 嵌套限制、转发声明问题等）；产出"AS namespace 改写 SOP"。
2. 第 2 个 follow-up 起：按 theme 一次处理 1 个 theme（约 3-5 个文件），每次 commit 末必须跑该 theme 的全部 tests。
3. 最后一次 follow-up：全模块 `rg -n "[A-Z]\w+_\w+\(" Plugins\Angelscript\Source\AngelscriptTest\Bindings` 确认无下划线分组的 AS 函数残留。

**最终目标**：所有 AS 脚本函数采用 namespace 分组，下划线分组完全消失。

## 6. 删除兼容层（旧符号 inline alias / forward 头）

**触发条件**：#1 / #2 / #3 / #4 / #5 全部完成；全模块 `rg -n "ExpectGlobal|FASGlobalFunctionInvoker|ExecuteIntFunction|\.Call\(\)|\.CallAndReturn|\.ReadReturnStruct" Plugins\Angelscript\Source\AngelscriptTest` 仅命中 `Shared/AngelscriptTestExecute.h` 内的 inline alias 实现，无外部依赖。

**待清理**：

- `Shared/AngelscriptTestExecute.h` 内 `using FASGlobalFunctionInvoker = ...` 别名段。
- `Shared/AngelscriptTestExecute.h` 内 inline `ExpectGlobal*` / `ExecuteIntFunction*` / `ExpectBindingCompileFailure` 兼容包装段。
- `Shared/AngelscriptTestExecute.h` 内 `.Call` / `.CallAndReturn<T>` / `.ReadReturnStruct<T>` inline 转发成员。
- `Shared/AngelscriptGlobalFunctionInvoker.h` 文件（删除）。
- `Shared/AngelscriptBindingsAssertions.h` 文件（删除）。
- 同时检查 `refactor-angelscript-test-helper-api` capability 内引用旧头路径的 Scenario：如果该 capability 的 spec 还提到 `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` 作为公共 helper 入口，**必须先开一个 modified-capability change** 把推荐入口改为 `AngelscriptTestExecute.h`，再做本步删除。

**推荐节奏**：单 follow-up 一次性处理（小范围）；commit 前后均需运行 `RunBuild.ps1` + 全套 `RunTestSuite.ps1`。

**最终目标**：仓库内只剩 `AngelscriptTestExecute.h` 一个执行入口，无任何 alias / forward 头。

## 7. 文档同步

**触发条件**：本 change 落地后随时可做（与 #1-#6 不强依赖）。

**待清理**：

- `.agents/skills/_angelscript-test-guide/SKILL.md`：更新「测试 helper 推荐表」，把 `FASGlobalFunctionInvoker` / `ExpectGlobal*` 推荐替换为 `FAngelscriptTestExecutor` / `ExecuteAndExpect*`；增加 `Execute*` / `Compile*` 命名族说明。
- `Documents/Guides/TestConventions.md`：同步推荐入口；明确"新代码必须用 `Execute*` 主族，旧名仅作 inline alias 兼容"；指向 `Shared/README.md` 与本 change `followups.md` 作为渐进清理路径。
- `Documents/Guides/TestCatalog.md`：检查 baseline 编号是否需调整（应不需要 — 不新增 / 移除任何 test case）。

**推荐节奏**：单 follow-up 一次性处理。

## 8. umbrella header 进一步瘦身（评估）

**触发条件**：本 change 落地后随时可做（独立评估）。

**评估点**：

- 现 umbrella `AngelscriptTestUtilities.h` 缩为 ~40 行 `#include` 聚合后，仍透传 `Shared/AngelscriptTestEngineCleanup.h`（含 `WITH_EDITOR` 区块），意味着任何 `#include "Shared/AngelscriptTestUtilities.h"` 的 TU 仍间接拉编辑器头依赖。
- 评估是否值得把 umbrella 进一步细化（如 `AngelscriptTestUtilities.h` 不含 Cleanup，新增 `AngelscriptTestUtilitiesFull.h` 含 Cleanup），让多数测试 TU 不再透传编辑器头。

**待清理（如评估通过）**：

- 拆分 umbrella 为 light / full 两层。
- 全模块审查每个测试 TU 是否真的需要 Cleanup 头；不需要的切到 light umbrella。

**推荐节奏**：单独 OpenSpec change 评估收益（编译时间收益是否值得拆分 umbrella）。

**最终目标**：测试 TU 透传的编辑器头依赖最小化。

---

## 推荐 follow-up 切片顺序

```
follow-up A: #7 文档同步 (轻量, 立即可做)
follow-up B: #1 + #2 (callsite 迁移 + 散落 helper 收编, 按 theme 切片, 多次 follow-up)
follow-up C: #3 Profile 实例变量名重命名 (按 Profile 切片)
follow-up D: #4 Profile 字段去重 (单次)
follow-up E: #5 AS namespace 改写 (先试点, 再 theme 切片, 多次 follow-up)
follow-up F: #6 删除兼容层 (单次, 强依赖 A-E 完成)
follow-up G: #8 umbrella 瘦身评估 (独立 change, 与其它无依赖)
```

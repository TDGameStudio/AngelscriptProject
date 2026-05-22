## Context

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` 目前 4 个针对 native 编译器核心的"白盒"测试文件总计 17 个 `TEST_METHOD`(详见 `proposal.md`)。每层都已建立访问内部状态的最小基础设施(`FTokenizerAccessor : asCTokenizer` 暴露 `GetToken`;`FParserAccessor : asCParser` 暴露 `Reset` / `ParseExpression` / `ParseStatement`;`asCByteCode` 通过 `asCBuilder` 直接构造),但每个文件只覆盖 3-5 个最具代表性的场景,大量分支(全 token 类型、operator 矩阵、AST 节点形状、opcode 桶、跳转解析、错误恢复)未被锁定。

项目处于 maturity stage,核心运行时 / 编辑器 / 测试基础设施稳定;AS fork 基线为 2.33 + 选择性 2.38 回拉(`Documents/Guides/AngelscriptForkStrategy.md`),持续从上游手术式吸收改进。这种 fork 策略对 native 编译器核心的"行为锁定测试"需求高于一般项目 — 没有覆盖的分支在每次回拉时都成为潜在回归源。

参考素材:`Reference/angelscript-v2.38.0/sdk/tests/test_feature/source/test_compiler.cpp`(6286 行)、`test_parser.cpp`、`testlongtoken.cpp` 已存在但未被项目测试运行器接入,可作为场景启发源(不直接 port,改写为 CQTest)。

约束:

- 必须遵循 `Documents/Guides/TestConventions.md` 第 1 节(测试层级矩阵)— Native Core 层固定落 `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`,前缀 `Angelscript.TestModule.AngelScriptSDK.*`,helper 用 `AngelscriptNativeTestSupport.h` / `AngelscriptTestAdapter.h`,不引入 `FAngelscriptEngine`。
- 必须遵循 `Documents/Rules/ASInlineFormattingRule.md`(列 0 起、Tab、Allman、`R"(...)"` 或 `R"AS(...)AS"`);ASSDK 层禁止 `\n` 字符串拼接。
- 必须使用 `Tools/RunTests.ps1` / `Tools/RunTestSuite.ps1` 作为标准入口,所有命令显式带 timeout(`Documents/Guides/Test.md` 强制约束)。

## Goals / Non-Goals

**Goals:**

- 在不改 product 代码的前提下,把 native SDK 4 层覆盖从采样级提升到系统化(17 → ~132 `TEST_METHOD`)。
- 每层独立可合并 PR,每 PR 完成标准是子前缀 `RunTests.ps1` 全绿 + `Angelscript.TestModule.AngelScriptSDK` 总组无回归。
- 共享 helper 全部 inline header-only,落在 `AngelscriptNativeTestSupport.h` 现有命名空间内,不新建 `*Helpers.h` 文件。
- 不动现有 4 个核心文件(`AngelscriptTokenizerTests.cpp`、`AngelscriptParserTests.cpp`、`AngelscriptScriptNodeTests.cpp`、`AngelscriptBytecodeTests.cpp`)的类名 / Automation 前缀,避免 discovery 回归。
- 文件按主题拆分,每文件 ~10 个 `TEST_METHOD` / 150-300 LOC,易 review、不增加单文件增量编译时间。

**Non-Goals:**

- 不修改 product 代码(产品行为零变化)。
- 不接入 / port `Reference/angelscript-v2.38.0/sdk/tests/` 原生测试套件作为独立运行入口。
- 不增加 / 修改 Reference SDK 自身代码。
- 不解 `TechnicalDebtInventory.md` 已列 debt 项。
- 不引入新的 Automation group 或 `DefaultEngine.ini` 条目(现有 `AngelscriptNative` group 已 glob `Angelscript.TestModule.AngelScriptSDK.*`)。
- 不要求百分百枚举式覆盖(例如全 ~200 个 opcode);本轮目标是按"代表性 + 高价值边界"补全。
- 不引入 lambda / 八进制 / 嵌套块注释等不确定支持特性的"必须支持"断言;采用"行为锁定"模式,命名以 `_OrDocumentReject` / `_DocumentBehavior` 标记。

## Decisions

### D1. 走 OpenSpec 流程

**选择**:走完整 OpenSpec change 生命周期(propose → apply → archive),change-id `test-as-native-sdk-coverage`,无 SPEC delta 以外的 product 代码变化。

**为什么**:虽然本次零产品代码改动属 AGENTS.md 允许"低风险跳过 OpenSpec"类目,但工作量(12 文件 / ~3000-5000 LOC / 4 phase)和跨期落地特征足够一份 propose-tracked plan 受益。`tasks.md` 作为唯一实施计划,Phase 勾选作为进度信号。

**替代方案**:跳过 OpenSpec,直接 PR — 拒绝;失去归档与多人协作可见性。

### D2. 文件按主题拆分(每层 3 个新文件)

**选择**:每层新增 3 个 `AngelscriptNative<Layer><Topic>Tests.cpp`,既不动现有 4 个文件,也不把所有新增 case 塞进同一文件。

**为什么**:现有文件保持"smoke / sanity 入口"语义,新文件按子主题组织(如 Tokenizer 拆 Literals / Operators / Whitespace),review 视角清晰,单文件 ≤ 300 LOC,增量编译影响小。`Documents/Guides/TestConventions.md` §2 ASSDK / Native 规则要求 `AngelscriptNative*Tests.cpp` 命名。

**替代方案**:全部追加到现有 4 文件 — 拒绝;每文件会膨胀到 1500+ LOC,违反 §2 文件命名规则的"主题清晰"意图,review 困难。

**替代方案**:每层只 1 个 mega 文件 — 拒绝;同上,失去主题维度。

### D3. Automation 前缀按层 + 主题

**选择**:每个新 `TEST_CLASS_WITH_FLAGS` 用 `Angelscript.TestModule.AngelScriptSDK.<Layer>.<Topic>` 路径(如 `…AngelScriptSDK.Tokenizer.Literals`),自动通过现有 `AngelscriptNative` group 的 `Contains="Angelscript.TestModule.AngelScriptSDK.,MatchFromStart=true"` glob 归集。

**为什么**:符合 `TestConventions.md` §4 "层级优先"前缀策略;不需要新增 `DefaultEngine.ini` group;每个子前缀都可单独跑 `RunTests.ps1 -TestPrefix "…AngelScriptSDK.Tokenizer"`。

**替代方案**:用扁平 `…AngelScriptSDK.<Topic>` 不带 Layer — 拒绝;丢失层归属,Tokenizer 与 Bytecode 同级混排。

### D4. Helper 全部 inline 进 `AngelscriptNativeTestSupport.h`

**选择**:7 个新 helper(`CreateBareSdkEngine`、`TokenizeAll`、`CountNodesOfType`、`NodeTypeHistogram`、`MaxNodeDepth`、`DumpBytecodeOpcodes`、`EmitToBuffer`)全部 inline,加在该文件已有 `AngelscriptNativeTestSupport` namespace。

**为什么**:已有 helper(`FNativeMessageCollector`、`CreateNativeEngine`、`CompileNativeModule`、`PrepareAndExecute`)就是 inline header-only 模式,保持一致;header-only 避免新增编译单元;每个新文件 `#include "AngelscriptNativeTestSupport.h"` 立即可用。

**替代方案**:新建 `AngelscriptNativeSdkInternalTestSupport.h` 区分 "公共 API helper" 与 "internal accessor helper" — 拒绝;两者数量都不大(7 vs 6),拆分增加 cognitive overhead 而非降低。

### D5. Accessor 模式沿用现有

**选择**:Tokenizer 用 `struct FTokenizerAccessor : asCTokenizer { using asCTokenizer::GetToken; };`(已在 `AngelscriptTokenizerTests.cpp` 中);Parser 用 `struct FParserAccessor : asCParser`(已在 `AngelscriptParserTests.cpp` 中,提供 `Reset` / `ParseExpressionSnippet` / `ParseStatementSnippet`)。新文件直接复制粘贴这两个 accessor 进各自的 anonymous / private namespace。

**为什么**:已是项目既定模式,不引入新机制;每文件独立 anonymous namespace 隔离。

**替代方案**:把 accessor 提到共享头(`AngelscriptNativeTestSupport.h`)— 拒绝;`asCTokenizer` 和 `asCParser` 是 fork-internal 头(`source/as_tokenizer.h`、`source/as_parser.h`),需要 `StartAngelscriptHeaders.h` / `EndAngelscriptHeaders.h` 隔离;放到共享头会污染所有 includer,每文件自己声明更干净。

### D6. 不确定特性用 "行为锁定" 命名

**选择**:对于 lambda、八进制字面量、嵌套块注释等不确定 fork 是否支持的特性,测试方法名以 `_OrDocumentReject` / `_DocumentBehavior` / `_IfSupported` 后缀,断言"当前实际行为"而非"必须支持"。

**为什么**:fork 当前能力是 2.33 + 选择性 2.38,某些 2.38 特性可能未回拉,预先研究每特性的存在状态成本高;"行为锁定"模式让测试既不假设支持也不假设不支持,只锁定"目前的实际响应",未来回拉时若行为改变测试会显著失败,届时再决定如何更新。

**替代方案**:回拉前先研究每特性的 fork 支持状态 — 拒绝;成本远高于本身的 case 编写;且很多 token / parser 边界根本无法事前查文档确认。

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| 破坏现有 17 个测试的 discovery | 不动现有 4 个文件的类名 / 前缀;每 phase 提交前必跑 `Angelscript.TestModule.AngelScriptSDK` 全前缀验证现有 case 仍 100% 通过 |
| AS internal API 漂移(`asCByteCode`、`asCScriptNode` 字段在选择性 2.38 回拉时变形) | 测试只使用 fork 当前 `2.33 + 选择性 2.38` 已暴露字段;`InstrSizeMatchesInfoTable` 等 case 用 `asBCInfo[op].type` → `asBCTypeSize[]` 间接验证而非硬编码 size |
| 测试运行时间膨胀 | 全部 ~115 case 为内存级(无 module `Build()`),~ms 级,预估总增加 < 10s,远低于 600000ms 默认 budget |
| 跨 phase 类名冲突 | 类名前缀统一 `F<File>` 形式(如 `FAngelscriptNativeTokenizerLiteralsTests`);每文件独立 `namespace ..._Private`,避免 helper 名冲突 |
| 不确定支持的特性导致 false positive | 用 `_OrDocumentReject` 命名 + 行为锁定断言(见 D6) |
| Reference SDK 启发不足或场景偏老 | Phase 0 完成后,phase 入口前先快速扫一遍 `test_feature/source/{test_compiler,test_parser,testlongtoken}.cpp` 提取本层适用场景;不直接 port,改写为 CQTest 风格 |
| `ASInlineFormattingRule.md` 误用导致 review 反复 | 每文件首个 raw string 由 review template 检查(列 0、Tab、Allman),Phase 0 helpers 完成后写一个 lint helper(可选)或在 PR 描述里固定 self-checklist |

## Migration Plan

不涉及运行时迁移(纯测试新增,零产品行为变化)。

落地按 phase 推进,每 phase 一个 PR:

1. **Phase 0 — Helpers**:`AngelscriptNativeTestSupport.h` 追加 7 个 inline helper;现有 17 个测试仍 100% 通过。
2. **Phase 1 — Tokenizer**:3 个新文件,~30 case;`…AngelScriptSDK.Tokenizer.*` 全绿。
3. **Phase 2 — Parser**:3 个新文件,~35 case;`…AngelScriptSDK.Parser.*` 全绿。
4. **Phase 3 — ScriptNode**:3 个新文件,~25 case;`…AngelScriptSDK.ScriptNode.*` 全绿。
5. **Phase 4 — Bytecode**:3 个新文件,~25 case;`…AngelScriptSDK.Bytecode.*` 全绿;同步 `TestCatalog.md` / `Test.md` / `Plugins/Angelscript/AGENTS.md` 文档;调用 `openspec-archive-change` 归档。

每 phase 完成后:
- 跑该层子前缀 + 全 `Angelscript.TestModule.AngelScriptSDK` 前缀回归(命令见 `tasks.md`)。
- 在 `tasks.md` 勾选对应 checkbox。
- 提交 PR,等 review / merge,再进入下一 phase。

回滚策略:每 phase 是独立 PR,任意 phase 出现非测试问题(如 fork 内部 API 已变),revert 该 PR 即可,不影响已 merge 的前序 phase。

## Open Questions

- Q1:fork 当前对 lambda 表达式 / 八进制字面量 / 嵌套块注释 / heredoc 字符串(`asEP_ALLOW_MULTILINE_STRINGS`)的支持状态是 reject 还是 accept?**解决路径**:不在 propose 阶段答;在 apply 阶段第一次写到对应 case 时实测 + 注释固化(见 D6 行为锁定模式)。
- Q2:`asCByteCode::Optimize()` 在 fork 中是否暴露足够稳定的接口供测试直接调用?**解决路径**:Phase 4 起步时,先在 `AngelscriptBytecodeTests.cpp` 现有 4 case 中确认 `asCByteCode` 当前可访问的公共方法 surface,再决定 `OptimizeReducesOrPreservesSize` 等 case 是否需要 accessor friend。
- Q3:`Reference/angelscript-v2.38.0/sdk/tests/` 中的 `testlongtoken.cpp` 是否值得 port 为独立文件?**解决路径**:Phase 1 内单一 case `LongIdentifierBoundary` 即可覆盖核心场景;不为它单独建文件。

# 本仓库 OpenSpec 附件习惯（对照现有 change）

`openspec-work` 只写了一句：change 目录是 free-form，`tasks.md` 保持干净 checklist，笔记/日志/数据另存。真正怎么拆文件，是已完成和进行中的 change 练出来的。下面按仓库里已经在用的形状归纳，作为本 change 后续改 skill 时要收进去的附件合同。

## 主制品 vs 附件

| 位置 | 职责 | 不该放 |
|---|---|---|
| `proposal.md` / `design.md` / `specs/` / `tasks.md` | 合同：为什么、怎么做、行为、勾选步骤 | 调查日志、失败命令、benchmark 表 |
| change 根上的 `issues.md`、`background.md`、`findings.md`、`verification.md`、`implementation-progress.md` | 执行中渐进记录 | 新的实现步骤（步骤仍进 `tasks.md`） |
| `attachments/` | 专题研究、方案对比、文件地图、例子 | 覆盖 design/spec 的第二份规范 |
| `research/`、`audits/`、`benchmarks/`、`verification/` | 更大的专题堆 | 把 checkbox 写成小说 |

`refactor-as-primary-engine-typed-ast-generate/attachments/README.md` 写得很清楚：附件解释主制品为什么这么写，**不能覆盖** design / specs / tasks。方向变了先改主制品，附件里标 superseded，不要删文件。

## 仓库里反复出现的附件类型

| 类型 | 出现在 | 记什么 |
|---|---|---|
| `attachments/README.md` 或本 change 的 `INDEX.md` | `feature-as-multithreaded-type-registration`、`refactor-as-subsystem-typeinfo-bind-cache`、`refactor-as-primary-engine-typed-ast-generate` | 索引 + **不能丢掉的结论** |
| `background.md` | `fix-as-double-int64-bytecode-execution`、`feature-unreal-angelscript-product-version`、`refactor-as-native-sdk-regression-suite` | 缺陷/意图、证据路径、被否决的 owner |
| `issues.md` | `improve-as-bind-reviewability-and-tests`、`test-as-native-sdk-comprehensive-coverage`、多数 `fix-as-*` | 带 ID 的问题账本，状态会变 |
| `findings.md` | `docs-plugin-architecture-debt-audit`、部分 archive | 核查表：证据、裁决、覆盖情况 |
| `verification.md` | 多数 `fix-*` / 部分 `feature-*` | 命令、`Saved/Tests` 或 `Saved/Build` 报告、pass/fail |
| `implementation-progress.md` | `feature-as-typed-semantic-aot` | 按日期的检查点：意外行为、根因、验证 |
| `attachments/implementation-plan.md` | `feature-as-multithreaded-type-registration` | writing-plans 级文件地图、接口草图、验证命令；勾选仍在 `tasks.md` |
| `attachments/test-plan.md` | `feature-as-usingleton-keyword` | 测什么、哪一层、哪个文件 |
| `attachments/*-and-recommendation.md` | multithreaded、typed-ast | 方案对比和推荐 |
| `attachments/*-follow-on.md` | subsystem-typeinfo-bind-cache | 明确不做、另开 change |
| 专题拆文件 | usingleton 的 syntax/registry/reload；subsystem 的 class-map/storage | 一块决策一份，design 只链过去 |
| `research/` | `docs-as-test-direction-map`、`feature-as-typed-semantic-aot` | 大调研，和 checkbox 分开 |

薄的 chore 可以没有这些。`feature` / `fix` / `refactor` / `improve` / `test` 一旦开始 apply，至少要能往 `issues.md` 或 `implementation-progress.md` 追加。

## 和本 change 的对应

讨论/对照类已经在 `attachments/`（见 `INDEX.md`）。执行账本放在 change 根：`issues.md`、`implementation-progress.md`，跟已完成的 `fix-*` / `improve-as-bind-reviewability-and-tests` / `feature-as-typed-semantic-aot` 一样。

# 执行中渐进记问题（已完成 change 里怎么做的）

用户要求：OpenSpec **执行过程中**碰到的相关问题，也要能渐进记下来。这不是新发明，本仓库已经完成的 change 里就是这么干的。

## 原则（从现有文件抽出）

1. **`tasks.md` 只勾完成。** 不要把失败日志、wrapper 超时、oracle 修偏写进 checkbox。`openspec-work` 和 `improve-as-bind-reviewability-and-tests/issues.md` 都这么说。
2. **发现问题就追加，不要等收工再回忆。** `test-as-native-sdk-comprehensive-coverage/issues.md`：新发现既要改总表状态，也要加一条带复现/分类/动作/最终证据的编年记录。
3. **状态会变，ID 不改。** bind-reviewability 的模型：`Observed → Confirmed → Designing → Implementing → Verified`，外加 `Deferred`（必须写原因和何时再开）。double-int64 用 `Closed` + Required closure。
4. **不要用放宽测试来藏问题。** native-sdk comprehensive：ledger 里的条目不是 waived failure。typed-semantic-aot 的 progress：测试绿是因为测试自己 `ApplyToEngineConfig`，官方 Generate 路径其实没开 collect-binds——记下来，再补 task。
5. **工具问题和工作区问题也记。** product-version 的 `TOOL-001`、native-sdk 的 `TOOL-022`/`TOOL-035`：RunBuild wrapper 5 秒返回 124、子进程其实还在跑；脚本参数名写错。这些不是产品 bug，但下一轮会再踩。
6. **证据写路径，不写“过了”。** `Saved/Build/...`、`Saved/Tests/.../Report/index.json`、pass 数、exit code。
7. **附件不覆盖主制品。** 实现推翻了 design，先改 design/specs/tasks，再在 progress/issues 里写偏差。typed-ast attachments README：标 superseded，不删历史。
8. **范围外就另开 change 或 Deferred。** bind-reviewability 的 Scope Routing：公共行为合同 / 架构另开 OpenSpec；本账本只留当前 change 能收的。

## 往哪写

| 碰到什么 | 写到哪 | 样板 |
|---|---|---|
| 实现/测试/工具上的一个可跟踪问题 | 根目录 `issues.md` | bind-reviewability 的 ID 块；或 double-int64 的表 |
| 某次 apply 的检查点、意外行为、根因 | 根目录 `implementation-progress.md` | typed-semantic-aot：日期 + task 号 + 证据 |
| 某次验证的命令和报告 | 根目录 `verification.md` | 多数 `fix-as-*` |
| 审计/债务对照 | `findings.md` | docs-plugin-architecture-debt-audit |
| 专题研究、方案、文件地图 | `attachments/` | 见 `repo-attachment-conventions.md` |

一次会话可以只追加一段，不必重写整份 ledger。

## `issues.md` 建议字段（收自 bind-reviewability + native-sdk）

```markdown
## <ID>: <结果导向的标题>

- Status: Observed | Confirmed | Designing | Implementing | Verified | Deferred
- Scope: <路径或主题>
- Evidence: <源码/测试/运行/对话观察>
- Decision: <已定方向或明确未决>
- Implementation: <已改路径或 not started>
- Verification: <命令/报告，或 not run>
- Next: <下一轮能接着做的一件事>
```

ID 前缀按本 change 主题，不要和别的 change 撞。本 change 用 `OSPEC-TASK-*`、`TOOL-*`。

## 本 change 分桶

- 规划问题 / 规划进度：`../planning/issues.md`、`../planning/progress.md`（实现默认不读）
- 实施问题 / 实施进度：`issues.md`、`progress.md`
- OpenSpec 自身中途重构：`openspec-refactors.md`

# TOptional Advance 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional/Advance`
- 约定: 上级 `../Organization.md`

组合正例：多步 / 往返 / 生命周期。文件头 `@Harness Advance`，`@Kind Observe` 或 `RoundTrip`。**单 API 的 Observe 归 `../Function/`**，不要搬进来；Throw 归 `../Exception/`；CompileReject 归 `../Reject/` 与 `../Negative/`。

---

## 1. 清单

| 文件 | 组合题材 |
|---|---|
| `TOptionalRoundTrip.as` | 跨 UFUNCTION 边界的往返：值进/值出、unset 安全进、产出「maybe result」并消费两个分支、set-in / unset-out |
| `TOptionalSequence.as` | 多步生命周期：重复 set/reset 周期、跨步骤携带、latest-wins 槽位、由被调方代为 set |

## 2. 为什么这些是组合而不是 Function

单个 `Set` / `Reset` / `Get` 的语义在 `../Function/` 已经钉死。这里的入口之所以进 Advance，是因为它们**跨越多次调用或多个 API 的编排**：

- `ProduceOptional` / `ConsumeProducedOptionalBothBranches`：函数返回 optional，调用方对 present / absent 两个分支分别取值。这是 optional 最真实的用法（「可能没有结果」），单 API 文件表达不了。
- `RepeatedSetResetCyclesKeepStateCorrect`：多次 set/reset 后状态仍然正确，验证的是销毁/重建路径的可重复性。
- `OptionalCarriedAcrossSteps`：一个 optional 在多个步骤间被连续改写，每步都用 `Get` 安全读。

## 3. 不收

- 需要 `SpawnActor` 的活引用：TOptional 无 WorldStory 题材，`NewObject` 已够，留在 `../UClass/`
- UPROPERTY 承载：`../UClass/TOptionalProperty`
- unset 读 Throw：`../Exception/TOptionalGetValueUnset`

# 杂项系统覆盖矩阵（CVar / AnimInstance）

> 域：控制台变量、动画实例。单独成域以便后续各自扩展。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| CVar | AngelscriptCoverageCVarTests.cpp | 11 | ✅ | 控制台变量声明/读写/回调 |
| AnimInstance | AngelscriptCoverageAnimInstanceTests.cpp | 2 | 🟡 | 仅"可编译"查询，缺运行期行为断言 |

**小计**：2 文件 / 13 方法

## 待增强（详见 `../coverage-gaps.md §1`）

- G1 `AngelscriptCoverageAnimInstanceTests.cpp`：把"可编译"查询升级为运行期行为断言（状态机/变量驱动/通知）。

# USTRUCT 覆盖矩阵

> 域：USTRUCT 声明、成员、默认值、运算符、容器与委托中的使用。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| UStruct | AngelscriptCoverageUStructTests.cpp | 43 | ✅ | USTRUCT 全面覆盖（仓内最大测试文件，16k+ 行） |
| UStructMember | AngelscriptCoverageUStructMemberTests.cpp | 4 | ✅ | USTRUCT 成员访问/默认值 |

**小计**：2 文件 / 47 方法

> 说明：`AngelscriptCoverageUStructTests.cpp` 体量极大，建议后续若继续扩展可按"声明/成员/运算符/序列化/容器交互"拆分子文件，并在本矩阵补行。

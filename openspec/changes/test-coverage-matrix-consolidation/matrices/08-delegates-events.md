# 委托与事件覆盖矩阵

> 域：单播/多播/动态委托与事件系统的声明、绑定、广播、句柄、BlueprintAssignable。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| Delegate | AngelscriptCoverageDelegateTests.cpp | 13 | ✅ | 单播声明/绑定/执行/ExecuteIfBound/签名矩阵/脚本结构参数 |
| MulticastDelegate | AngelscriptCoverageMulticastDelegateTests.cpp | 11 | ✅ | 多播 Add/Remove/Broadcast/句柄 |
| DynamicDelegate | AngelscriptCoverageDynamicDelegateTests.cpp | 12 | ✅ | 动态委托 Bind/Add/序列化往返/BlueprintAssignable·Callable |
| Event | AngelscriptCoverageEventTests.cpp | 16 | ✅ | 事件绑定/触发/生命周期/碰撞/Widget/RepNotify/内建实例 |

**小计**：4 文件 / 52 方法

## 已知边界

- AS Lambda 语法绑定委托/事件不支持（`DelegateLambdaSyntaxIsUnsupported` / `EventLambdaSyntaxIsUnsupported`）；`BindStatic` 不适用（无静态函数概念）。详见 `../coverage-gaps.md §2.4`。

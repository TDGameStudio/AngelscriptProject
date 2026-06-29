# 组件覆盖矩阵

> 域：UActorComponent 及派生（Scene / Primitive / 特化组件）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| Component | AngelscriptCoverageComponentTests.cpp | 25 | ✅ | UActorComponent 基础/注册/生命周期 |
| SceneComponent | AngelscriptCoverageSceneComponentTests.cpp | 8 | ✅ | 世界/相对变换/附加/socket/层级/标签 |
| PrimitiveComponent | AngelscriptCoveragePrimitiveComponentTests.cpp | 11 | ✅ | 渲染/碰撞配置/物理/Hit·Overlap 事件/隐藏 |
| SpecialComponent | AngelscriptCoverageSpecialComponentTests.cpp | 11 | ✅ | 特化组件（含 EnhancedInput 关联） |

**小计**：4 文件 / 55 方法

> 说明：物理/碰撞的系统级测试见 `13-physics-collision.md`；本矩阵聚焦组件 API 表面。

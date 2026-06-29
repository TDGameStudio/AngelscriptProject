# UCLASS 与类系统覆盖矩阵

> 域：UCLASS 宏、类系统、CDO/default、生命周期、类特性、默认子对象组件、UObject 属性引用语义。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| UClass | AngelscriptCoverageUClassTests.cpp | 35 | ✅ | UCLASS 宏/类系统/CDO/default |
| UClass.Property | AngelscriptCoverageUClassPropertyTests.cpp | 18 | ✅ | UObject 属性引用语义 |
| UClass.DefaultComponent | AngelscriptCoverageUClassDefaultComponentTests.cpp | 4 | ✅ | DefaultComponent 根/附加/socket/继承/无效说明符边界 |
| ClassLifecycle | AngelscriptCoverageClassLifecycleTests.cpp | 8 | ✅ | Actor/Pawn/Component/Widget/多级继承生命周期 |
| ClassFeatures | AngelscriptCoverageClassFeaturesTests.cpp | 14 | ✅ | 继承/access/方法重写等类特性 |

**小计**：5 文件 / 79 方法

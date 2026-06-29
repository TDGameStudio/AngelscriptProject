# 资源加载 / 材质 / 存档 覆盖矩阵

> 域：软引用资源加载、字面量资源、动态材质参数、SaveGame 序列化。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| AssetLoading | AngelscriptCoverageAssetLoadingTests.cpp | 6 | ✅ | 同步软对象/软类加载、全局 LoadObject、软引用路径/异步边界 |
| LiteralAsset | AngelscriptCoverageLiteralAssetTests.cpp | 7 | ✅ | 字面量资源引用 |
| Material | AngelscriptCoverageMaterialTests.cpp | 3 | ✅ | 动态材质参数（标量/向量/纹理）读写 |
| SaveGame | AngelscriptCoverageSaveGameTests.cpp | 3 | 🟡 | SaveGame 基础往返；嵌套 struct/数组字段往返待补 |

**小计**：4 文件 / 19 方法

## 待增强（详见 `../coverage-gaps.md §1`）

- G2 `AngelscriptCoverageSaveGameTests.cpp`：补嵌套 struct / 数组字段的 save→load 往返断言。

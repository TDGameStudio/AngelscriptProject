# 对象引用与 GC 覆盖矩阵

> 域：UObject handle、弱/软引用、TSubclassOf、垃圾回收。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| Handle | AngelscriptCoverageHandleTests.cpp | 14 | ✅ | handle 声明/比较/Cast/GetClass/GetName 等操作 |
| Handles | AngelscriptCoverageHandlesTests.cpp | 10 | 🟡 | handle 作属性/参数/容器元素；TObjectPtr 显式属性往返待审计 |
| WeakReference | AngelscriptCoverageWeakReferenceTests.cpp | 10 | 🟡 | TWeakObjectPtr 基础/失效/反向引用断环 + TSubclassOf 全套；弱引用数组待补 |
| SoftReference | AngelscriptCoverageSoftReferenceTests.cpp | 11 | ✅ | TSoftObjectPtr / TSoftClassPtr 同步加载/路径/属性/容器 |
| GC | AngelscriptCoverageGCTests.cpp | 12 | ✅ | 回收/UPROPERTY 保护/跨帧/NewObject/可达性链/强循环引用回收 |

**小计**：5 文件 / 57 方法

## 待增强（详见 `../coverage-gaps.md §1`）

- G3 `TArray<TWeakObjectPtr<T>>` 元素往返（`WeakObjectPtrArrayContainer` 已起步，可加深）。
- G4 `TObjectPtr<T>` 作显式 UPROPERTY 的声明/读写专项断言（需审计是否已隐含覆盖）。

## 已知边界

- 脚本级 `TScriptInterface<I>` 引用：fork 不支持（见 `../coverage-gaps.md §2.3`）。

# UE 宏 / UENUM / UFUNCTION / UINTERFACE / 元说明符 覆盖矩阵

> 域：USTRUCT 以外的 UE 反射宏与说明符（UEnum / UFunction / UInterface / 综合宏 / meta）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| UEnum | AngelscriptCoverageUEnumTests.cpp | 13 | ✅ | UENUM/枚举值/位标志 |
| UFunction | AngelscriptCoverageUFunctionTests.cpp | 27 | ✅ | UFUNCTION 说明符/调用路径（8k+ 行） |
| UInterface | AngelscriptCoverageUInterfaceTests.cpp | 12 | 🟡 | C++ UINTERFACE 实现路径；脚本级 interface 受 fork 限制 |
| Macros | AngelscriptCoverageMacrosTests.cpp | 19 | ✅ | 综合宏/UDelegate/元数据/编辑器条件/被拒绝边界 |
| MetaSpecifier | AngelscriptCoverageMetaSpecifierTests.cpp | 13 | ✅ | meta=() 说明符 |

**小计**：5 文件 / 84 方法

## 已知边界

- 脚本级 `interface` 声明、`UINTERFACE` 宏在脚本中声明、`TScriptInterface<I>` 均被拒绝（`Macros.cpp` 中以 `*Rejected` 边界测试记录）。详见 `../coverage-gaps.md §2.3`。

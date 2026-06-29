# 控制流与语言特性覆盖矩阵

> 域：控制流、命名空间、注释、预处理、类型转换、mixin、const、运算符重载等语言层特性。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| Conditional | AngelscriptCoverageConditionalTests.cpp | 10 | ✅ | if/else/switch/三元 |
| Loop | AngelscriptCoverageLoopTests.cpp | 8 | ✅ | for/while/do-while/for-each |
| Jump | AngelscriptCoverageJumpTests.cpp | 6 | ✅ | break/continue/return |
| SpecialControlFlow | AngelscriptCoverageSpecialControlFlowTests.cpp | 3 | ✅ | 特殊控制流边界 |
| Namespace | AngelscriptCoverageNamespaceTests.cpp | 8 | ✅ | namespace 声明/访问 |
| Comment | AngelscriptCoverageCommentTests.cpp | 1 | ✅ | 注释解析 |
| Preprocessor | AngelscriptCoveragePreprocessorTests.cpp | 7 | ✅ | #include/#if/#elif/#else/编辑器配置分支/诊断 |
| TypeConversion | AngelscriptCoverageTypeConversionTests.cpp | 6 | ✅ | 隐式/显式类型转换 |
| Mixin | AngelscriptCoverageMixinTests.cpp | 7 | ✅ | mixin 函数库 |
| Const | AngelscriptCoverageConstTests.cpp | 3 | ✅ | const 限定/常量表达式 |
| OperatorOverload | AngelscriptCoverageOperatorOverloadTests.cpp | 3 | ✅ | 运算符重载 |

**小计**：11 文件 / 62 方法

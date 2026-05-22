## Why

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` 目前只对 AS native 编译器核心 4 层(词法 / 语法 / AST / 字节码)提供 17 个 `TEST_METHOD`(`AngelscriptTokenizerTests.cpp` 5、`AngelscriptParserTests.cpp` 5、`AngelscriptScriptNodeTests.cpp` 3、`AngelscriptBytecodeTests.cpp` 4),属于"采样级"白盒覆盖。每层都搭好了访问基础设施(`FTokenizerAccessor`、`FParserAccessor`、`asCByteCode` 直接构造),但 token 类型、operator 矩阵、AST 节点形状、opcode 桶、跳转解析、错误恢复等大量分支未被锁定。对一个已进入 maturity 阶段、持续从上游 AS 2.38 选择性回拉的 fork(参 `Documents/Guides/AngelscriptForkStrategy.md`),这种采样覆盖不足以在选择性回拉时及早发现行为漂移。本次系统化补全 4 层的"白盒"覆盖,在不改 product 代码的前提下把 native 单元测试规模从 17 提升到 ~132。

## What Changes

- 新增 12 个 native 单元测试文件,跨 4 个层(每层 3 个主题文件)
  - Tokenizer: `AngelscriptNativeTokenizer{Literals,Operators,Whitespace}Tests.cpp`
  - Parser: `AngelscriptNativeParser{Declarations,Expressions,Errors}Tests.cpp`
  - ScriptNode: `AngelscriptNativeScriptNode{Shape,SourceRange,Copy}Tests.cpp`
  - Bytecode: `AngelscriptNativeBytecode{Opcodes,Jumps,Optimize}Tests.cpp`
- 在 `AngelscriptNativeTestSupport.h` 中追加 7 个 inline header-only 帮助函数(`CreateBareSdkEngine`、`TokenizeAll`、`CountNodesOfType`、`NodeTypeHistogram`、`MaxNodeDepth`、`DumpBytecodeOpcodes`、`EmitToBuffer`),不影响现有 helper
- 新增 ~115 个 `TEST_METHOD`(Tokenizer ~30、Parser ~35、ScriptNode ~25、Bytecode ~25),全部通过现有 `AngelscriptNative` group 自动归集
- 同步更新 `Documents/Guides/TestCatalog.md` 计数(17 → ~132)、`Documents/Guides/Test.md` SDK 子前缀样例命令、`Plugins/Angelscript/AGENTS.md` native 测试规模数字
- **不修改** 现有 4 个核心测试文件的类名 / Automation 前缀(避免 discovery 回归)
- **不修改** 任何产品代码、`Build.cs`、引擎配置 `.ini`
- **不引入** Reference SDK 原生 `test_compiler.cpp`(6286 行)直接 port,只把它作为场景启发

## Capabilities

### New Capabilities

- `as-native-sdk-test-coverage`: AS native 编译器核心 4 层(词法、语法、AST、字节码)的系统化白盒单元测试覆盖契约。规定测试文件落点、Automation 前缀分层、accessor 模式复用、helper 共享位置、子前缀回归命令。

### Modified Capabilities

(无 — 本次不修改任何现有 spec 的需求行为。)

## Impact

- **代码路径**:`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` 新增 12 文件;`AngelscriptNativeTestSupport.h` 追加 inline helper
- **APIs**:零公共 API 变化(测试通过 fork 内已暴露的 `asCTokenizer::GetToken` protected 提升、`asCParser::ParseScript/ParseExpression/ParseStatement`、`asCByteCode` 公共构造访问)
- **依赖**:仅依赖 fork 当前 `2.33 + 选择性 2.38`(`Documents/Guides/AngelscriptForkStrategy.md`)既有字段
- **构建**:`AngelscriptTest.Build.cs` 已用目录递归扫描,新增 `.cpp` 自动纳入,无需修改
- **运行时预算**:~115 case 全为内存级(无 module `Build()` 路径),预估累加 < 10s,远低于 600000ms 默认 budget(`Documents/Guides/Test.md` 强制约束)
- **现有测试 discovery**:每 phase 提交前必须跑 `Angelscript.TestModule.AngelScriptSDK` 全前缀,确认现有 17 case 仍 100% 通过
- **文档**:`TestCatalog.md`、`Test.md`、`Plugins/Angelscript/AGENTS.md` 同步;`TechnicalDebtInventory.md` 不需更新(本次不解 debt 列表项)

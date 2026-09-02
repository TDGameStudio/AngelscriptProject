# AS_Compiler — asCCompiler 编译流程

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: 编译管理器 (asCBuilder) 的多阶段构建流程、代码生成器 (asCCompiler) 的表达式编译模型、重载决议策略
> **关键源码**:
> `ThirdParty/angelscript/source/as_compiler.h` (25 KB, 501 行) / `.cpp` (604 KB, 18945 行 — 最大文件)
> · `ThirdParty/angelscript/source/as_builder.h` (17 KB, 332 行) / `.cpp` (203 KB, 7007 行)
> **关联文档**:
> `AS_Parser.md` — AST 输入
> · `AS_ByteCode.md` — 字节码输出
> · `AS_TypeRegistration.md` — 类型信息来源
> · `AS_VirtualMachine.md` — 执行产出的字节码

---

## 概览

当前生产默认是 **LEGACY 流水线**。新引擎默认 `asCOMPILER_PIPELINE_LEGACY`。`asCOMPILER_PIPELINE_CANONICAL` 是可选的捕获/旁路挂接，直到 `asCModule::Build()` 从 `asCBytecodeCodeGen::Generate()` 发布字节码；`IsCanonicalBytecodeCodeGenReady()` 当前为 false。生产字节码仍由 `asCCompiler` 发出。`asCBytecodeCodeGen` 是隔离的只读后端，覆盖已实现的语言子集，不是公开 dual 选择。HIR oracle 仍在，默认不捕获。LLVM 不是目标。公开契约见 `Documents/Guides/AngelscriptCanonicalAST.md`。

AngelScript 的编译分为两个层次：**asCBuilder** 负责多阶段构建编排（解析 → 类型注册 → 布局 → 编译），**asCCompiler** 负责单个函数的语法树 → 字节码代码生成。`as_compiler.cpp` 以 604 KB / 18945 行成为整个引擎中最大的文件，其复杂性主要来自表达式编译、隐式转换和重载决议。

---

## asCBuilder — 多阶段构建编排

`asCBuilder` 将模块编译拆分为 5 个有序阶段：

```text
asCModule::Build()
  └→ asCBuilder 阶段流水线
     ├── BuildParallelParseScripts()  // 阶段 0: 并行解析所有 .as 脚本
     ├── BuildGenerateTypes()         // 阶段 1: 提取类型声明
     │     └→ RegisterTypesFromScript()
     ├── BuildGenerateFunctions()     // 阶段 2: 注册函数/方法签名
     │     ├→ ParseScripts()           // 注册非类型声明
     │     ├→ CompileInterfaces()      // 编译接口
     │     ├→ CompileClasses()         // ★ 编译类（属性+方法签名）
     │     └→ RegisterGlobalVariables()
     ├── BuildLayoutClasses()         // 阶段 3: 布局类内存
     │     ├→ LayoutClass() for each class
     │     └→ CreateDefaultDestructors()
     ├── BuildLayoutFunctions()       // 阶段 3b: 布局函数参数
     │     ├→ LayoutFunction() for each func
     │     └→ CompileGlobalVariables()  // 全局变量初始化
     └── BuildCompileCode()           // 阶段 4: ★ 编译所有函数体
           ├→ CompileFactory() for each factory
           ├→ CompileFunctions()       // 遍历所有函数描述
           └→ Clean up parsers & class declarations
```

### CompileClasses (行 3259-3266)

```cpp
void asCBuilder::CompileClasses(asUINT numTempl)
{
    for (n = 0; n < classDeclarations.GetLength(); n++)
        CompileClass(classDeclarations[n]);  // ★ 支持按需编译
}
```

`CompileClass` 支持**按需编译**——当编译 A 类时发现依赖 B 类，会通过 `EnsureClassCompiled()` 触发 B 类的编译，避免声明顺序依赖。

### CompileFunctions (行 959-1000)

```cpp
void asCBuilder::CompileFunctions()
{
    for( n = 0; n < functions.GetLength(); n++ )
    {
        asCCompiler compiler(this);
        compiler.CompileFunction(this, script, paramNames, node, func, classDecl);
    }
}
```

每个函数创建独立的 `asCCompiler` 实例，保证编译状态隔离。

---

## asCCompiler — 单函数代码生成

### CompileFunction 主流程 (行 993-1250)

```text
CompileFunction(builder, script, paramNames, funcNode, outFunc, classDecl)
==========================================================================
Step 1: Reset() — 重置编译器状态
Step 2: SetupParametersAndReturnVariable() — 分配参数和返回值变量
Step 3: 解析函数体（按需 ParseStatementBlock）
Step 4: CompileStatementBlock(block, ..., &bc) — ★ 编译语句块
Step 5: 拼接字节码:
  - JitEntry 指令
  - 构造函数: 基类构造调用 + 成员初始化
  - 主体字节码
  - 变量析构 + Label(0) 返回标签
  - 参数析构
Step 6: FinalizeFunction() — 字节码后处理
  - byteCode.Finalize()      // PostProcess+Optimize+ResolveJump+ExtractLine
  - ExtractTryCatchInfo()
  - ExtractObjectVariableInfo()
  - 输出到 outFunc->scriptData->byteCode
```

### 语句编译 (行 1695-1760)

```cpp
void CompileStatementBlock(block, ownVariableScope, stopCondition, bc)
{
    for each child node:
      if (snDeclaration) → CompileDeclaration(node, &statement)
      else               → CompileStatement(node, stopCondition, &statement)
      // 不可达代码检测 + 警告
}
```

`CompileStatement` 按节点类型分发：

| 节点类型 | 编译方法 |
|---------|---------|
| `snIf` | `CompileIfStatement` |
| `snFor` | `CompileForStatement` |
| `snForEach` | `CompileForeachStatement` |
| `snWhile` | `CompileWhileStatement` |
| `snDoWhile` | `CompileDoWhileStatement` |
| `snSwitch` | `CompileSwitchStatement` |
| `snReturn` | `CompileReturnStatement` |
| `snBreak` | `CompileBreakStatement` |
| `snContinue` | `CompileContinueStatement` |
| 其他 | `CompileExpressionStatement` |

### 表达式编译模型

表达式编译采用**中缀 → 后缀 → 栈式求值**三步法：

```text
CompileExpression(expr, ctx)
============================
1. ConvertToPostFix(expr, postfix)     // ★ Shunting Yard 算法
2. CompilePostFixExpression(postfix, ctx)
   for each node in postfix:
     if operand → CompileExpressionTerm(node, v)
       → CompileExprPreOp()
       → CompileExpressionValue()   // 常量/变量/函数调用/Cast
       → CompileExprPostOp()        // 成员访问/索引/调用
     if operator → CompileOperator(node, l, r, out)
       → CompileOperatorOnHandles()
       → CompileMathOperator()
       → CompileBitwiseOperator()
       → CompileComparisonOperator()
       → CompileBooleanOperator()
       → CompileOverloadedDualOperator()
```

### asCExprContext — 表达式上下文

编译期每个表达式的求值状态通过 `asCExprContext` 传递：

```cpp
struct asCExprContext {
    asCByteCode bc;            // 当前表达式的字节码
    asCExprValue type;         // 表达式的值类型（含常量值、栈偏移）
    int property_get/set;      // 属性访问器 funcId
    asCArray<asSDeferredParam> deferredParams;  // 延迟清理的参数
    asCString methodName;      // 未决方法名（重载解析前）
    // ...
};
```

---

## 重载决议 — MatchFunctions (行 2597-2855)

这是编译器中最复杂的算法之一：

```text
MatchFunctions(funcs, args, node, name, namedArgs, ...)
========================================================
Step 1: 按参数数量过滤（考虑默认参数）
Step 2: 对每个候选函数，逐参数调用 MatchArgument():
  - ImplicitConversion(临时上下文, 参数类型, ..., false)
  - 返回转换代价（EConvCost 枚举值之和）
  - 代价 -1 = 不匹配
Step 3: 取交集——只保留所有参数都匹配的候选
Step 4: 匹配命名参数（namedArgs）
Step 5: 选择总代价最低的候选
  - 相同代价 → 保留多个（后续报歧义错误）
Step 6: FilterConst() — 非 const 调用优先选非 const 重载
```

### 隐式转换代价 (EConvCost)

| 代价 | 枚举值 | 含义 |
|------|--------|------|
| 0 | `asCC_NO_CONV` | 完全匹配 |
| 1 | `asCC_CONST_CONV` | const 添加 |
| 2-3 | `asCC_FLOAT_*_CONV` | 浮点宽窄转换 |
| 4-5 | `asCC_INT_TO_FLOAT/DOUBLE` | 整数→浮点 |
| 6 | `asCC_PRIMITIVE_SIZE_CONV` | 原始类型大小转换 |
| 7 | `asCC_SIGNED_CONV` | 有符号/无符号 |
| 8 | `asCC_SHADOW_CONV` | UE shadow 类型转换 |
| 9-12 | `asCC_*_TO_*_CONV` | 各种对象/原始类型转换 |

---

## 变量管理

编译器内部维护多个数组跟踪变量分配：

```text
variableAllocations[]    // 每个变量的类型
variableIsTemporary[]    // 是否临时变量
variableIsOnHeap[]       // 是否堆分配
tempVariableOffsets[]    // 所有临时变量偏移
freeVariables[]          // 当前空闲变量槽
tempVariables[]          // 当前活跃临时变量
reservedVariables[]      // 保留不可用的变量
```

`AllocateVariable()` 首先尝试复用 `freeVariables` 中的空闲槽，找不到才分配新槽。`DeallocateVariable()` 将槽归还 `freeVariables`。

---

## UE Fork 扩展

| 位置 | 修改 | 动机 |
|------|------|------|
| L1001-1010 | `allowEditPropertyAccess` 判断 | `__InitDefaults` / `ConstructionScript` 等函数允许写 editable 属性 |
| L5611 | `CompileForeachStatement` | 将 `foreach` 降级为 `opForBegin`/`opForNext`/`opForValue` 调用 |
| L236 | `ANGELSCRIPTRUNTIME_API` 导出宏 | 匹配 UE Runtime 模块 |
| L1042-1052 | 比较运算符参数类型不匹配警告 | `opEquals`/`opCmp` 参数应与容器类型匹配 |

---

## 小结

- 编译分两层：`asCBuilder`（5 阶段构建编排）+ `asCCompiler`（单函数代码生成）
- 构建阶段：解析 → 类型注册 → 函数签名 → 内存布局 → 字节码编译
- 表达式编译使用 Shunting Yard 算法转后缀，再栈式求值生成字节码
- 重载决议通过 `MatchFunctions` + `ImplicitConversion` 代价计算选择最佳匹配
- 变量管理通过多数组跟踪分配/释放/临时状态，支持槽复用
- `as_compiler.cpp` 是 604 KB 的巨型文件，反映了表达式编译和类型转换的固有复杂性

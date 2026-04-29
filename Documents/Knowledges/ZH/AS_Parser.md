# AS_Parser — asCParser 递归下降解析器

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: 词法分析 → 语法分析 → AST 构建的前端流水线实现原理
> **关键源码**:
> `ThirdParty/angelscript/source/as_parser.h` (7 KB) / `.cpp` (114 KB, 5147 行)
> · `ThirdParty/angelscript/source/as_tokenizer.h` / `.cpp` (2.5 KB / 12 KB)
> · `ThirdParty/angelscript/source/as_scriptnode.h` / `.cpp` (3 KB / 3.4 KB)
> **关联文档**:
> `AS_LanguageSyntax.md` — 完整 Token/AST/BNF 速查表
> · `AS_Compiler.md` — 编译器如何消费 AST
> · `AS_ScriptEngine.md` — 引擎通过 `asCBuilder` 调用解析器

---

## 概览

`asCParser` 是 AngelScript 的手写**递归下降解析器**，负责将 Token 流转换为 `asCScriptNode` AST 树。它的核心难点在于**声明 vs 函数歧义的消解**——通过 `IsVarDecl()` / `IsFuncDecl()` / `IsVirtualPropertyDecl()` 三个前瞻函数实现无回溯的 LL(k) 解析。源码中内嵌了 51 条 BNF 规则注释，构成了完整的语言形式文法。

---

## 架构总览

```text
源码 (asCScriptCode)
  │
  ▼
asCTokenizer          // 词法分析：256 桶跳转表 + 贪心匹配
  │ GetToken()
  ▼
asCParser             // 语法分析：递归下降 + 前瞻消歧
  │ Parse*()
  ▼
asCScriptNode tree    // AST：侵入式双向链表树
  │
  ▼
asCBuilder / asCCompiler  // 下游消费者
```

---

## 解析器核心机制

### 顶层入口 `ParseScript()` (行 2419-2517)

这是脚本文件的主入口，实现了**无限循环 + 错误恢复**模式：

```text
ParseScript(bool inBlock)
==============================
for(;;) {
  while(!isSyntaxError) {
    GetToken(&t)
    switch(t.type):
      ttImport     → ParseImport()
      ttEnum       → ParseEnumeration()
      ttTypedef    → ParseTypedef()
      ttClass/Struct → ParseClass()
      ttInterface  → ParseInterface()
      ttMixin      → ParseMixin()
      ttFuncDef    → ParseFuncDef()
      ttLocal      → ParseLocal()
      ttConst/Scope/Auto/IsDataType →    // ★ 关键歧义点
        IsVirtualPropertyDecl()? → ParseVirtualPropertyDecl()
        IsVarDecl()?             → ParseDeclaration()
        else                     → ParseFunction()  // 默认假设是函数
      ttNamespace  → ParseNamespace()
      ttEnd        → return    // EOF
  }
  // ★ 错误恢复：跳到 ';' 或 '{'，跟踪嵌套 {} 
  isSyntaxError = false;  // 重置，继续解析后续内容
}
```

**关键设计**：错误恢复确保一个语法错误不会阻止整个文件的解析。

### 前瞻消歧函数

当遇到可能是类型开头的 Token（`const`、`::`、`auto`、已知数据类型）时，解析器无法仅凭当前 Token 判断是变量声明、虚拟属性还是函数。三个前瞻函数按优先级依次尝试：

#### `IsVarDecl()` (行 2966-3066)

```text
IsVarDecl()
===========
1. 跳过 access/private/protected 修饰符
2. IsType(t1)? → 必须以有效类型开头，否则 false
3. 下一个是 ttIdentifier? → 必须有标识符名，否则 false
4. 检查标识符后面的 token:
   ';' | '=' | ','  → return true（明确是变量）
   '('  →  ★ 歧义点：
     找到匹配的 ')'
     ')' 后面是 '{' 或 identifier? → return false（是函数）
     其他  → return true（带括号初始化的变量，如 int x(5)）
```

#### `IsFuncDecl()` (行 3111-3250)

```text
IsFuncDecl(bool isMethod)
=========================
if isMethod:
  构造函数模式: identifier + '(' → return true
  析构函数模式: '~' → return true

IsType(t1)? → 必须以返回类型开头
'&' → return true（引用返回，一定是函数）
identifier → 检查后面是否有 '('
  找到匹配的 ')'
  if isMethod: 跳过 const + UE 扩展修饰符
  ★ 后面是 '{' → return true（有函数体 = 一定是函数）
```

**UE Fork 扩展**：`IsFuncDecl` 中扩展了大量方法修饰符识别：`final`、`override`、`property`、`mixin`、`accept_temporary_this`、`no_discard`、`deprecated` 等 12+ 个。

### 类解析 `ParseClass()` (行 3705-3829)

```text
ParseClass()
=============
1. 接受 'class' 或 'struct' 关键字
   isStruct = (t.type == ttStruct)   // struct 禁止 default 语句
2. 解析类名 → ParseIdentifier()
3. 可选继承列表 ':' Identifier {',' Identifier}
4. 类体 '{' ... '}' 内逐项分发：
   ttFuncDef          → ParseFuncDef()
   IsFuncDecl(true)   → ParseFunction(true)
   IsVirtualPropertyDecl() → ParseVirtualPropertyDecl()
   IsVarDecl()        → ParseDeclaration(true)
   IsAccessDecl()     → ParseAccessDecl()
   !isStruct && IsClassDefaultStatement() → ParseClassDefaultStatement()
```

### 表达式解析

表达式采用经典的**中缀 → 后缀 → 编译**三步法：

```text
ParseExpression()        // BNF:9: EXPR ::= EXPRTERM {EXPROP EXPRTERM}
  └→ ParseExprTerm()     // 前缀运算 + 值 + 后缀运算
      ├→ ParseExprPreOp()   // '-' | '+' | '!' | '++' | '--' | '~' | '@'
      ├→ ParseExprValue()   // 常量 | 函数调用 | 变量 | Cast | Lambda
      └→ ParseExprPostOp()  // '.' | '[' | ARGLIST | '++' | '--'

ParseAssignment()        // ASSIGN ::= CONDITION [ASSIGNOP ASSIGN]  (右结合)
  └→ ParseCondition()    // CONDITION ::= EXPR ['?' ASSIGN ':' ASSIGN]
```

### 函数体的延迟解析

一个重要的性能优化：`ParseFunction()` 中函数体只做**浅层解析**（`SuperficiallyParseStatementBlock()`），仅匹配 `{}` 平衡，不解析内部语句。真正的深度解析在编译器需要时按需触发：

```cpp
// as_parser.cpp:3424
node->AddChildLast(SuperficiallyParseStatementBlock());  // ★ 只匹配括号
```

---

## AST 节点内存管理

```cpp
asCScriptNode *asCParser::CreateNode(eScriptNode type)
{
    auto* ptr = MemStack.Alloc(sizeof(asCScriptNode), alignof(asCScriptNode));
    return new(ptr) asCScriptNode(type);  // ★ 栈分配器，零碎片
}
```

- 使用 `FMemStackBase` 线性栈分配器，避免频繁 `new`/`delete`
- AST 节点在解析器析构时随栈分配器一起批量释放
- 节点通过 `AddChildLast()` 组装，使用侵入式双向链表

---

## UE Fork 修改

| 位置 | 修改 | 动机 |
|------|------|------|
| 头文件 L50 | `ANGELSCRIPTRUNTIME_API` 导出宏 | 匹配 UE Runtime 模块 |
| L4740-4859 | `ParseForeach()` / `ParseForeachVariable()` | 新增 `foreach(var : container)` 语法 |
| L3217-3230 | `IsFuncDecl` 扩展修饰符列表 | 支持 12+ 个 UE 特有方法修饰符 |
| L3800 | `!isStruct && IsClassDefaultStatement()` | struct 不允许 default 语句 |

---

## 小结

- `asCParser` 是 5147 行的手写递归下降解析器，内嵌 51 条 BNF 规则
- 声明/函数歧义通过 `IsVarDecl()` / `IsFuncDecl()` 前瞻消解
- 函数体延迟解析（`SuperficiallyParseStatementBlock`）降低首次解析成本
- 错误恢复通过跳到 `;`/`{` 并重置 `isSyntaxError` 实现
- AST 节点使用线性栈分配器（`FMemStackBase`），批量释放

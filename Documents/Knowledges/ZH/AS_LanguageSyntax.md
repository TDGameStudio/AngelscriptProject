# AS_LanguageSyntax — 语言语法速查

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: Token 定义、词法分析、AST 节点类型、语法规则骨架
> **关键源码**:
> `ThirdParty/angelscript/source/as_tokendef.h` (12 KB, 351 行) — Token 类型定义与关键字表
> · `ThirdParty/angelscript/source/as_tokenizer.h` / `.cpp` (2.5 KB / 12 KB) — 词法分析器
> · `ThirdParty/angelscript/source/as_scriptnode.h` / `.cpp` (3 KB / 3.4 KB) — AST 节点
> · `ThirdParty/angelscript/source/as_parser.h` / `.cpp` (7 KB / 114 KB) — 递归下降解析器
> · `Core/angelscript.h` (73 KB) — asETokenClass 枚举
> **关联文档**:
> `AS_Parser.md` — 解析器实现深入分析
> · `AS_Compiler.md` — 编译器如何消费 AST
> · `AS_ScriptEngine.md` — 引擎属性对语法的影响

---

## 概览

AngelScript 的语法前端由三层组成：**Tokenizer**（词法分析）→ **Parser**（递归下降语法分析）→ **AST**（抽象语法树）。本文作为速查手册，汇总了完整的 Token 类型表、关键字列表、AST 节点类型枚举、以及从源码中提取的 EBNF 语法规则骨架。

---

## Token 分类系统

`asETokenClass` 定义于 `angelscript.h` 第 326-334 行，将所有 Token 分为 6 类：

| 分类 | 枚举值 | 值 | 说明 |
|------|--------|------|------|
| 未知 | `asTC_UNKNOWN` | 0 | 无法识别的字符 |
| 关键字 | `asTC_KEYWORD` | 1 | 关键字与运算符 |
| 值 | `asTC_VALUE` | 2 | 数字/字符串/位常量 |
| 标识符 | `asTC_IDENTIFIER` | 3 | 用户标识符 |
| 注释 | `asTC_COMMENT` | 4 | 单行/多行注释 |
| 空白 | `asTC_WHITESPACE` | 5 | 空格/换行/UTF8-BOM |

Tokenizer 的 `ParseToken()` 按固定优先级判定：空白 → 注释 → 常量 → 标识符 → 关键字 → 未知。

---

## 完整 Token 类型 (eTokenType)

定义于 `as_tokendef.h` 第 46-187 行，共 ~90 个枚举值。

### 特殊 Token

| 枚举 | 含义 |
|------|------|
| `ttUnrecognizedToken` | 无法识别 |
| `ttEnd` | 文件结尾 EOF |

### 空白与注释

| 枚举 | 匹配内容 |
|------|----------|
| `ttWhiteSpace` | `' '`, `'\t'`, `'\r'`, `'\n'`, UTF8-BOM |
| `ttOnelineComment` | `// ... \n` |
| `ttMultilineComment` | `/* ... */` |

### 字面量

| 枚举 | 示例 | 说明 |
|------|------|------|
| `ttIdentifier` | `myVar` | 标识符 |
| `ttIntConstant` | `1234` | 整数 |
| `ttFloat32Constant` | `12.34f` | 32 位浮点（带 `f` 后缀） |
| `ttFloat64Constant` | `12.34` | 64 位浮点（无后缀） |
| `ttStringConstant` | `"abc"` | 单行字符串 |
| `ttMultilineStringConstant` | 含 `\n` 的字符串 | 多行字符串 |
| `ttHeredocStringConstant` | `"""text"""` | Heredoc 字符串 |
| `ttNonTerminatedStringConstant` | `"abc` | 未终结字符串（错误） |
| `ttBitsConstant` | `0xFF`, `0b1010`, `0o77` | 进制常量 |

### 运算符

**算术运算符**:

| 枚举 | 符号 | 枚举 | 符号 |
|------|------|------|------|
| `ttPlus` | `+` | `ttAddAssign` | `+=` |
| `ttMinus` | `-` | `ttSubAssign` | `-=` |
| `ttStar` | `*` | `ttMulAssign` | `*=` |
| `ttSlash` | `/` | `ttDivAssign` | `/=` |
| `ttPercent` | `%` | `ttModAssign` | `%=` |
| `ttStarStar` | `**` | `ttPowAssign` | `**=` |
| `ttInc` | `++` | `ttDec` | `--` |

**位运算符**:

| 枚举 | 符号 | 枚举 | 符号 |
|------|------|------|------|
| `ttBitOr` | `\|` | `ttOrAssign` | `\|=` |
| `ttAmp` | `&` | `ttAndAssign` | `&=` |
| `ttBitXor` | `^` | `ttXorAssign` | `^=` |
| `ttBitNot` | `~` | | |
| `ttBitShiftLeft` | `<<` | `ttShiftLeftAssign` | `<<=` |
| `ttBitShiftRight` | `>>` | `ttShiftRightLAssign` | `>>=` |
| `ttBitShiftRightArith` | `>>>` | `ttShiftRightAAssign` | `>>>=` |

**比较运算符**:

| 枚举 | 符号 |
|------|------|
| `ttEqual` / `ttNotEqual` | `==` / `!=` |
| `ttLessThan` / `ttGreaterThan` | `<` / `>` |
| `ttLessThanOrEqual` / `ttGreaterThanOrEqual` | `<=` / `>=` |

**逻辑运算符**:

| 枚举 | 符号 |
|------|------|
| `ttAnd` | `and` / `&&` |
| `ttOr` | `or` / `\|\|` |
| `ttXor` | `xor` / `^^` |
| `ttNot` | `not` / `!` |

**其他符号**:

| 枚举 | 符号 | 枚举 | 符号 |
|------|------|------|------|
| `ttAssignment` | `=` | `ttEndStatement` | `;` |
| `ttListSeparator` | `,` | `ttDot` | `.` |
| `ttScope` | `::` | `ttHandle` | `@` |
| `ttQuestion` | `?` | `ttColon` | `:` |
| `ttOpenParanthesis` | `(` | `ttCloseParanthesis` | `)` |
| `ttOpenBracket` | `[` | `ttCloseBracket` | `]` |
| `ttStartStatementBlock` | `{` | `ttEndStatementBlock` | `}` |

### 保留关键字

| 枚举 | 关键字 | 枚举 | 关键字 |
|------|--------|------|--------|
| `ttIf` | `if` | `ttElse` | `else` |
| `ttFor` | `for` | `ttForeach` | `foreach` |
| `ttWhile` | `while` | `ttDo` | `do` |
| `ttSwitch` | `switch` | `ttCase` | `case` |
| `ttDefault` | `default` | `ttBreak` | `break` |
| `ttContinue` | `continue` | `ttReturn` | `return` |
| `ttFallthrough` | `fallthrough` | | |
| `ttBool` | `bool` | `ttVoid` | `void` |
| `ttInt` | `int` / `int32` | `ttInt8` | `int8` |
| `ttInt16` | `int16` | `ttInt64` | `int64` |
| `ttUInt` | `uint` / `uint32` | `ttUInt8` | `uint8` |
| `ttUInt16` | `uint16` | `ttUInt64` | `uint64` |
| `ttFloat` | `float` | `ttFloat32` | `float32` |
| `ttFloat64` | `float64` | `ttDouble` | `double` |
| `ttTrue` | `true` | `ttFalse` | `false` |
| `ttNull` | `nullptr` | `ttConst` | `const` |
| `ttClass` | `class` | `ttStruct` | `struct` |
| `ttEnum` | `enum` | `ttInterface` | `interface` |
| `ttNamespace` | `namespace` | `ttMixin` | `mixin` |
| `ttLocal` | `local` | `ttAuto` | `auto` |
| `ttCast` | `Cast` | `ttImport` | `import` |
| `ttFuncDef` | `funcdef` | `ttTypedef` | `typedef` |
| `ttPrivate` | `private` | `ttProtected` | `protected` |
| `ttIn` | `in` | `ttOut` | `out` |
| `ttInOut` | `inout` | `ttIs` | `is` |
| `ttNotIs` | `!is` | `ttAccess` | `access` |

### 上下文关键字（非 Token）

以下标识符在特定语法上下文中有特殊含义，但 Tokenizer 不识别为关键字（`as_tokendef.h` 第 318-346 行）：

```text
this        super       from        shared      final
override    abstract    function    property    mixin
get         set         external    readonly    inherited
editdefaults            accept_temporary_this
external_implicit_this  no_discard  allow_discard
deprecated              unsafe_during_construction
defaults                __generated
if_handle_then_const    handle_only
__auto_constref_type    __any_implicit_integer
```

---

## Tokenizer 工作原理

### 关键字跳转表

```cpp
// as_tokenizer.cpp:50-88
asCTokenizer::asCTokenizer()
{
    memset(keywordTable, 0, sizeof(keywordTable));
    for( n = 0; n < numTokenWords; n++ )
    {
        unsigned char start = tokenWords[n].word[0];
        // ★ 按首字符分桶，桶内按长度从长到短排序（贪心匹配）
        keywordTable[start][insert] = &tokenWords[n];
    }
}
```

- 使用 256 个桶的跳转表（按首字符 ASCII 索引）
- 每个桶内按 token 长度**从长到短**排序，确保贪心匹配（如 `>>=` 优先于 `>>`）

### 标识符 vs 关键字区分

```cpp
// as_tokenizer.cpp:387-423
bool asCTokenizer::IsIdentifier(...)
{
    if( 字母/下划线/Unicode 开头 )
    {
        tokenType = ttIdentifier;
        // 继续扫描直到非标识符字符
        if( IsKeyWord(source, tokenLength, ...) )
            return false;  // ★ 如果匹配了关键字，就不是标识符
        return true;
    }
}
```

### 数字常量识别

支持 4 种进制前缀：

| 前缀 | 进制 | 示例 |
|------|------|------|
| `0b` / `0B` | 二进制 | `0b1010` |
| `0o` / `0O` | 八进制 | `0o77` |
| `0d` / `0D` | 十进制 | `0d99` |
| `0x` / `0X` | 十六进制 | `0xFF` |

浮点数以 `f`/`F` 后缀区分 float32 和 float64。

---

## AST 节点类型 (eScriptNode)

定义于 `as_scriptnode.h` 第 47-98 行，共 ~50 个节点类型：

### 顶层声明

| 节点 | 含义 |
|------|------|
| `snScript` | 脚本根节点 |
| `snFunction` | 函数声明（含 lambda） |
| `snClass` | class 声明 |
| `snInterface` | interface 声明 |
| `snEnum` | enum 声明 |
| `snTypedef` | typedef 声明 |
| `snFuncDef` | funcdef 声明 |
| `snNamespace` | namespace 声明 |
| `snMixin` | mixin 声明 |
| `snImport` | import 声明 |
| `snVirtualProperty` | 虚拟属性（get/set） |
| `snAccessDeclaration` | access 声明 |
| `snClassDefaultStatement` | class default 语句 |

### 类型与参数

| 节点 | 含义 |
|------|------|
| `snDataType` | 数据类型节点 |
| `snIdentifier` | 标识符节点 |
| `snParameterList` | 参数列表 |
| `snScope` | 作用域限定 `::` |

### 语句

| 节点 | 含义 |
|------|------|
| `snStatementBlock` | `{ ... }` 语句块 |
| `snDeclaration` | 变量声明 |
| `snExpressionStatement` | 表达式语句 |
| `snIf` | if 语句 |
| `snFor` | for 语句 |
| `snForEach` | foreach 语句 |
| `snWhile` | while 语句 |
| `snDoWhile` | do-while 语句 |
| `snSwitch` | switch 语句 |
| `snCase` | case 分支 |
| `snReturn` | return 语句 |
| `snBreak` | break |
| `snContinue` | continue |
| `snFallthrough` | fallthrough |

### 表达式

| 节点 | 含义 |
|------|------|
| `snExpression` | 表达式 |
| `snExprTerm` | 表达式项 |
| `snExprValue` | 表达式值 |
| `snExprPreOp` | 前缀运算 |
| `snExprPostOp` | 后缀运算 |
| `snExprOperator` | 二元运算符 |
| `snAssignment` | 赋值表达式 |
| `snCondition` | 条件表达式 `?:` |
| `snFunctionCall` | 函数调用 |
| `snConstructCall` | 构造调用 |
| `snArgList` | 参数列表 |
| `snCast` | 类型转换 |
| `snVariableAccess` | 变量访问 |
| `snConstant` | 常量字面量 |
| `snInitList` | 初始化列表 `{ }` |
| `snListPattern` | 列表模式 |
| `snNamedArgument` | 命名参数 |

### 节点结构

```cpp
class asCScriptNode
{
    eScriptNode nodeType;    // 节点类型
    eTokenType  tokenType;   // 关联的 token 类型
    size_t      tokenPos;    // 源码位置
    size_t      tokenLength; // 源码长度

    asCScriptNode *parent;   // 父节点
    asCScriptNode *next;     // 同级后继
    asCScriptNode *prev;     // 同级前驱
    asCScriptNode *firstChild; // 第一个子节点
    asCScriptNode *lastChild;  // 最后一个子节点
};
```

AST 使用**侵入式双向链表**（非数组）连接兄弟节点，子节点通过 `firstChild`/`lastChild` 头尾指针快速追加。

---

## 语法规则骨架 (EBNF)

以下是从 `as_parser.cpp` 源码中提取的完整 BNF 规则（按层级编号排序）：

### 顶层 (Level 0-1)

```ebnf
SCRIPT    ::= {IMPORT | ENUM | TYPEDEF | CLASS | MIXIN | LOCAL
              | INTERFACE | FUNCDEF | VIRTPROP | VAR | FUNC
              | NAMESPACE | ';'}

NAMESPACE ::= 'namespace' IDENTIFIER '{' SCRIPT '}'
IMPORT    ::= 'import' TYPE ['&'] IDENTIFIER PARAMLIST 'from' STRING ';'
ENUM      ::= {'shared'|'external'} 'enum' IDENTIFIER
              (';' | ('{' IDENTIFIER ['=' EXPR] {',' IDENTIFIER ['=' EXPR]} '}'))
TYPEDEF   ::= 'typedef' PRIMTYPE IDENTIFIER ';'
FUNCDEF   ::= {'external'|'shared'} 'funcdef' TYPE ['&'] IDENTIFIER PARAMLIST ';'
CLASS     ::= {'shared'|'abstract'|'final'|'external'} 'class' IDENTIFIER
              (';' | ([':' IDENTIFIER {',' IDENTIFIER}] '{' {VIRTPROP|FUNC|VAR|FUNCDEF} '}'))
INTERFACE ::= {'external'|'shared'} 'interface' IDENTIFIER
              (';' | ([':' IDENTIFIER {',' IDENTIFIER}] '{' {VIRTPROP|INTFMTHD} '}'))
MIXIN     ::= 'mixin' FUNCTION
LOCAL     ::= 'local' FUNCTION
```

### 函数与属性 (Level 1-2)

```ebnf
FUNC      ::= {'shared'|'external'} ['private'|'protected']
              [((TYPE ['&']) | '~')] IDENTIFIER PARAMLIST ['const']
              {'override'|'final'} (';' | STATBLOCK)
INTFMTHD  ::= TYPE ['&'] IDENTIFIER PARAMLIST ['const'] ';'
VIRTPROP  ::= ['private'|'protected'] TYPE ['&'] IDENTIFIER '{'
              {('get'|'set') ['const'] [('override'|'final')] (STATBLOCK|';')} '}'
VAR       ::= ['private'|'protected'] TYPE IDENTIFIER
              [('=' (INITLIST|EXPR)) | ARGLIST]
              {',' IDENTIFIER [('=' (INITLIST|EXPR)) | ARGLIST]} ';'
PARAMLIST ::= '(' ['void' | (TYPE TYPEMOD [IDENTIFIER] ['=' EXPR]
              {',' TYPE TYPEMOD [IDENTIFIER] ['=' EXPR]})] ')'
```

### 类型 (Level 3-6)

```ebnf
TYPE      ::= ['const'] SCOPE DATATYPE ['<' TYPE {',' TYPE} '>'] {('[' ']') | '@'}
TYPEMOD   ::= ['&' ['in' | 'out' | 'inout']]
DATATYPE  ::= (IDENTIFIER | PRIMTYPE | '?' | 'auto')
PRIMTYPE  ::= 'void'|'int'|'int8'|'int16'|'int32'|'int64'
             |'uint'|'uint8'|'uint16'|'uint32'|'uint64'
             |'float'|'float32'|'float64'|'double'|'bool'
SCOPE     ::= ['::'] {IDENTIFIER '::'} [IDENTIFIER ['<' TYPE {',' TYPE} '>'] '::']
```

### 语句 (Level 7-8)

```ebnf
STATBLOCK ::= '{' {VAR | STATEMENT} '}'
STATEMENT ::= IF | FOR | FOREACH | WHILE | RETURN | STATBLOCK
             | BREAK | CONTINUE | DOWHILE | SWITCH | EXPRSTAT
EXPRSTAT  ::= [ASSIGN] ';'

IF        ::= 'if' '(' ASSIGN ')' STATEMENT ['else' STATEMENT]
FOR       ::= 'for' '(' (VAR|EXPRSTAT) EXPRSTAT [ASSIGN {',' ASSIGN}] ')' STATEMENT
WHILE     ::= 'while' '(' ASSIGN ')' STATEMENT
DOWHILE   ::= 'do' STATEMENT 'while' '(' ASSIGN ')' ';'
SWITCH    ::= 'switch' '(' ASSIGN ')' '{' {CASE} '}'
CASE      ::= (('case' EXPR) | 'default') ':' {STATEMENT}
RETURN    ::= 'return' [ASSIGN] ';'
BREAK     ::= 'break' ';'
CONTINUE  ::= 'continue' ';'
INITLIST  ::= '{' [ASSIGN | INITLIST] {',' [ASSIGN | INITLIST]} '}'
```

### 表达式 (Level 9-17)

```ebnf
EXPR       ::= EXPRTERM {EXPROP EXPRTERM}
EXPRTERM   ::= ([TYPE '='] INITLIST) | ({EXPRPREOP} EXPRVALUE {EXPRPOSTOP})
EXPRPREOP  ::= '-' | '+' | '!' | '++' | '--' | '~' | '@'
EXPRPOSTOP ::= ('.' (FUNCCALL|IDENTIFIER))
              | ('[' [IDENTIFIER ':'] ASSIGN {',' [IDENTIFIER ':' ASSIGN} ']')
              | ARGLIST | '++' | '--'
EXPRVALUE  ::= 'void' | CONSTRUCTCALL | FUNCCALL | VARACCESS
              | CAST | LITERAL | '(' ASSIGN ')' | LAMBDA
CONSTRUCTCALL ::= TYPE ARGLIST
FUNCCALL   ::= SCOPE IDENTIFIER ARGLIST
VARACCESS  ::= SCOPE IDENTIFIER
CAST       ::= 'cast' '<' TYPE '>' '(' ASSIGN ')'
LAMBDA     ::= 'function' '(' [[TYPE TYPEMOD] IDENTIFIER
              {',' [TYPE TYPEMOD] IDENTIFIER}] ')' STATBLOCK
LITERAL    ::= NUMBER | STRING | BITS | 'true' | 'false' | 'null'
ARGLIST    ::= '(' [IDENTIFIER ':'] ASSIGN {',' [IDENTIFIER ':'] ASSIGN} ')'
ASSIGN     ::= CONDITION [ASSIGNOP ASSIGN]
CONDITION  ::= EXPR ['?' ASSIGN ':' ASSIGN]

EXPROP     ::= MATHOP | COMPOP | LOGICOP | BITOP
MATHOP     ::= '+' | '-' | '*' | '/' | '%' | '**'
COMPOP     ::= '==' | '!=' | '<' | '<=' | '>' | '>=' | 'is' | '!is'
LOGICOP    ::= '&&' | '||' | '^^' | 'and' | 'or' | 'xor'
BITOP      ::= '&' | '|' | '^' | '<<' | '>>' | '>>>'
ASSIGNOP   ::= '=' | '+=' | '-=' | '*=' | '/=' | '|=' | '&=' | '^='
              | '%=' | '**=' | '<<=' | '>>=' | '>>>='
```

---

## UE Fork 语法扩展

### 新增关键字

| 关键字 | Token | 来源 |
|--------|-------|------|
| `foreach` | `ttForeach` | UE 扩展，支持 `foreach(var : container)` |
| `fallthrough` | `ttFallthrough` | switch case 穿透标记 |
| `struct` | `ttStruct` | 与 `class` 同义但禁止 `default` 语句 |
| `local` | `ttLocal` | 模块级 local 函数 |
| `access` | `ttAccess` | 自定义访问修饰符 |
| `unresolved_object` | `ttUnresolvedObject` | 未解析对象标记 |

### 新增上下文关键字

`readonly`, `editdefaults`, `inherited`, `accept_temporary_this`, `external_implicit_this`, `no_discard`, `allow_discard`, `deprecated`, `unsafe_during_construction`, `defaults`, `__generated` — 均为 UE Fork 添加的上下文关键字。

### foreach 语法 (UE 扩展)

```ebnf
FOREACH   ::= 'foreach' '(' FOREACHVAR [',' FOREACHVAR] ':' CONDITION ')' STATEMENT
FOREACHVAR ::= TYPE ['&'] [IDENTIFIER] IDENTIFIER
```

解析在 `asCParser::ParseForeach()` / `ParseForeachVariable()` 中实现，编译在 `asCCompiler::CompileForeachStatement()` 中降级为 `opForBegin` / `opForNext` / `opForValue` 方法调用。

---

## 小结

- AngelScript 使用 ~90 个 Token 类型，通过 256 桶跳转表实现 O(1) 首字符定位 + 贪心匹配
- AST 有 ~50 种节点类型，使用侵入式双向链表结构
- 语法规则完整记录在 `as_parser.cpp` 的 BNF 注释中，共 51 条产生式
- 解析器是手写的递归下降解析器，每个 BNF 规则对应一个 `Parse*()` 方法
- UE Fork 扩展了 `foreach`、`fallthrough`、`struct`、`local`、`access` 等关键字和大量上下文关键字
